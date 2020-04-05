package Moodle::Command::section_populate;

use lib "lib";

use Moodle -command;
use strict;
use warnings;
use YAML qw/Dump LoadFile DumpFile/;
use IO::All;
use Scalar::Util qw/looks_like_number/;
use List::MoreUtils qw/all/;

sub abstract { "moopl section_populate -q question_category -s course_section -r random_question_number -g grade_category -c course" }
sub description { "Run moosh section_populate for list of quiz questions in section/9/question.yaml" }

sub usage_desc { "moopl section_populate -q question_category -s course_section -r random_question_number -g grade_category -c course"}

sub opt_spec  {
        return (
		["q=s", "question_category"]
		, ["s=i", "course_section"]
		, ["r=i", "random_question_number"]
		, ["g=i", "grade_category"]
		, ["l=i", "tag_collection_id"]
		, ["m=s", "tag_component_name"]
		, ["c=i", "course"]
		, ["n=s", "course_name"]
	);
}

sub execute {

	my ($self, $opt, $args) = @_;

	my ($category, $section, $random_option, $tagcollid, $tagcomponent, $gradecat, $course, $course_name) = @$opt{qw/q s r l m g c n/};
	my $semester="$ENV{SEMESTER}";
	# my $course_name = "$ENV{COURSE_NAME[$course]}"

	chdir "/var/www/cgi-bin/moodle";

	my %module = ( jigsaw => 'quiz'
		, drag => 'quiz'
		, match => 'quiz'
		, scramble => 'quiz'
		, description => 'quiz'
		, essay => 'quiz'
		, studentquiz => 'studentquiz'
		, assign => 'assign'
		, url => 'url'
		, forum => 'forum'
	);
	my $options = LoadFile "/home/drbean/curriculum/$course_name/spring/default.yaml";
	my $activity_list = LoadFile "/home/drbean/curriculum/$course_name/spring/$section.yaml";
	die "list of activities: $activity_list\n" unless ref( $activity_list) eq "ARRAY" and $activity_list;
	die "options $options not a HASH\n" unless ref $options eq 'HASH';
	# die "Not all activity options in $options a HASH\n" unless all { ref $options->{$_} eq 'HASH' } keys %$options;
	# die "Not all activity options in $options option strings\n" unless all { ref $_ eq '' } ( values %{ $options->{$_} } for keys %options );
	my $n = 0;
	for my $activity ( @$activity_list ) {
		my $content_list = delete $activity->{content};
		#die "No activity $n with $content_list contents?\n" unless
		#	defined $content_list and ref($content_list) eq 'ARRAY';
		my $first_one = $content_list->[0];
		my ( $topic, $story, $type, $form ) = 
			map { $first_one->{$_} } qw/topic story type form/;
		my $cards = "/home/drbean/curriculum/$course_name/$topic/cards.yaml";
		my $yaml = LoadFile $cards;
		die "No '$type' activity for '$topic' topic, '$story' story, '$form' form?\n" unless
			$topic and  $story and  $type and  defined $form;
		my $default_options = $options->{ $module{$type} };
		my %option_hash;
		$option_hash{gradecat} = $gradecat;
		$option_hash{$_} = "$default_options->{$_}" for keys %$default_options;
		my $more_opts;
		if ( keys %$activity ) {
			my $more_opts = $activity;
			die "more_opts '$more_opts' not a HASH\n" unless ref $more_opts eq 'HASH';
			die "more_opts '$more_opts' not a HASH of option strings\n" unless
				all { ref $_ eq '' } values %$more_opts;
			$option_hash{$_} = "$more_opts->{$_}" for keys %$more_opts;
		}
		my $intro = delete $first_one->{intro};
		$intro = "$topic: $story $form" unless $intro;
		$option_hash{intro} = "\\\"$intro\\\"";
		my $name = $yaml->{$story}->{$type}->{$form}->{identifier};
		die "No '$name' identifier in the topic '$topic' '$type' activity about the '$story' story, '$form' form\n" unless $name;
		my $activity_add_line;
		if ( $type eq 'forum' ) {
			$option_hash{intro} = $yaml->{$story}->{$type}->{$form}->{rubric};
			$activity_add_line = "/home/drbean/moodle/moosh/moosh.php -n activity-add -n '$name' -s $section -o \"--timeopen=1 --intro=\"$(IFS= cat /home/drbean/curriculum/$course_name/$story/intro.md) --introformat=4 --type=eachuser  --grade=3 --gradecat=$gradecat --decimalpoints=0\" forum $course";
		}
		elsif ( $type eq 'studentquiz' ) {
			$option_hash{intro} = $yaml->{$story}->{$type}->{$form}->{rubric};
		}
		elsif ( $type eq 'url' ) {
			$option_hash{externalurl} = $yaml->{$story}->{$type}->{$form}->{externalurl};
			$option_hash{intro} = $intro;
		}
		elsif ( $type eq 'assign' ) {
			$option_hash{intro} = $yaml->{$story}->{$type}->{$form}->{rubric};
		}
		elsif ( $module{$type} eq 'quiz' ) {
			$option_hash{intro} = $intro;
			$option_hash{questioncategory} = $category if $category;
		}
		else {die "'$module{$type}' activity type for '$type' exercise?\n"}
		my @option_list; push @option_list, "--$_=$option_hash{$_}" for sort keys %option_hash;
		my $option_string = join ' ', @option_list;
		$activity_add_line = "/home/drbean/moodle/moosh/moosh.php -n activity-add --name='$name' -s $section --options=\"$option_string\" $module{$type} $course";
		warn "\n$module{$type}-add-line='$activity_add_line'\n";
		my $activity_id = qx( $activity_add_line );
		warn "$module{$type}_id=$activity_id";
		chomp $activity_id;
		die "Failed to add '$name' activity to section $section with activity-add! activity_id=$activity_id\n" unless looks_like_number( $activity_id );
		if ( $module{$type} eq 'quiz' ) {
			for my $question ( @$content_list ) {
				my ( $topic, $story, $type, $form, $intro ) = 
				map { $question->{$_} } qw/topic story type form intro/;
				die "No '$name' '$type' quiz for '$topic' topic, '$story' story, '$form' form?\n" unless
					$topic and  $story and  $type and  defined $form;
				die "No '$option_hash{parentcategory}' parent category, '$option_hash{categorycontext}' context for '$option_hash{questioncategory}' question category\n"
					unless $option_hash{parentcategory} and $option_hash{categorycontext} and $option_hash{questioncategory};
				my $category_create_line = "/home/drbean/moodle/moosh/moosh.php -n questioncategory-create --reuse -p $option_hash{parentcategory} -c $option_hash{categorycontext} $option_hash{questioncategory}";
				warn "\ncategory-create-line='$category_create_line'\n";
				my $category_id = qx( $category_create_line );
				warn "category_id=$category_id\n";
				die "category_id?\n" unless $category_id;
				chomp $category_id;
				if ( $intro ) {
					my $description = qx"yaml4moodle description -d '$intro' -i $name -t $topic -s $story -f $form";
					my $file = "/var/lib/moodle/repository/$topic/quiz_${story}_description_${form}.xml";
					$description > io( $file );
					system( "/home/drbean/moodle/moosh/moosh.php -n question-import $file $activity_id $category_id") == 0 or die 
					"question import of '$story' '$form' form '$intro' description intro in '$category' category into '$activity_id' quiz, from '$file' file failed. ";
				}
				system( "FORM=$form; STORY=$story; QUIZ=$type; TOPIC=$topic; for format in gift xml ; do yaml4moodle \$format -c $course_name -t \$TOPIC -s \$STORY -q \$QUIZ -f \$FORM > /var/lib/moodle/repository/\${TOPIC}/quiz_\${STORY}_\${QUIZ}_\${FORM}.\$format ; done" )
				== 0 or die "YAML4Moodle build of '$topic' '$type' quiz for, '$story' story, '$form' failed\n";
				my $file = "/var/lib/moodle/repository/$topic/quiz_${story}_${type}_$form.xml";
				die "No $story ($type) $form form file in repository/$topic?" unless
				-e $file;
				my $random = 0;
				if ( $type eq 'jigsaw' or $type eq 'drag' ) {
					my $random_question = $question->{random};
					if ( $random_question and looks_like_number($random_question) ) {
						$random = $random_question;
					}
					elsif ( $random_option ) {
						$random = $random_option;
					}
				}
				if ( $random == 0 ) {
					system( "/home/drbean/moodle/moosh/moosh.php -n question-import $file $activity_id $category_id") == 0 or die 
					"question import of all '$story' '$type' activity: '$form' form questions in '$category' category into '$activity_id' quiz, from '$file' file failed. ";
				}
				elsif ( looks_like_number( $random ) ) {
					my $tag = "${topic}_${story}_${type}_$form";
					# my $import_random_line = "/home/drbean/moodle/moosh/moosh.php -n -v question-importrandom -r $random -t '$tag' -m $tagcomponent -l $tagcollid $file $activity_id $category_id";
					my $import_random_line = "/home/drbean/moodle/moosh/moosh.php -n question-importrandom $file $activity_id $category_id $random $tag $tagcollid $tagcomponent";
					warn "\nimportrandom-line='$import_random_line'\n";
					system( $import_random_line ) == 0 or die 
					"question import of '$story' '$type' activity: '$form' form with '$random' random questions with '$tag' tag in the '$tagcollid' collection for the '$tagcomponent' component in '$category_id' category failed";

				}
				else { die "'$random' questions in '$story' '$type' activity: '$form' form?" }
			}
		}
		$n++;
	}
}

1;
