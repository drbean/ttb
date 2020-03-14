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
		["q=i", "question_category"]
		, ["s=i", "course_section"]
		, ["r=i", "random_question_number"]
		, ["g=i", "grade_category"]
		, ["t=i", "tag_collection_id"]
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
	my ( $options, $activity_list ) = LoadFile "/home/drbean/curriculum/$course_name/spring/$section.yaml";
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
		my $module_options = $options->{ $module{$type} };
		my (%option_hash, $option_string);
		$option_hash{gradecat} = $gradecat;
		$option_hash{$_} = "$module_options->{$_}" for keys %$module_options;
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
		my @option_list; push @option_list, "--$_=$option_hash{$_}" for keys %option_hash;
		$option_string = join ' ', "@option_list";
		if ( $type eq 'forum' ) {
			my $name = $intro;
			my $forum_id = qx(/home/drbean/moodle/moosh/moosh.php -n activity-add -n '$name' -s $section -o "--timeopen=1 --intro=$(IFS= cat /home/drbean/curriculum/$course_name/$story/intro.md) --introformat=4 --type=eachuser  --grade=3 --gradecat=$gradecat --decimalpoints=0" forum $course);
			warn "forum_id=$forum_id";
		}
		elsif ( $type eq 'studentquiz' ) {
			my $name = $intro;
			my $studentquiz_id = qx(/home/drbean/moodle/moosh/moosh.php -n activity-add -n '$name' -s $section -o "--timeopen=1 --intro=$(IFS= cat /home/drbean/curriculum/$course_name/$story/intro.md) --introformat=4 --grade=3 --gradecat=$gradecat --decimalpoints=0" studentquiz $course);
			warn "studentquiz_id=$studentquiz_id";
		}
		elsif ( $type eq 'url' ) {
			my $name = $yaml->{$story}->{$type}->{$form}->{identifier};
			$option_hash{externalurl} = $yaml->{$story}->{$type}->{$form}->{externalurl};
		my @option_list; push @option_list, "--$_=$option_hash{$_}" for keys %option_hash;
		$option_string = join ' ', "@option_list";
			# my $url_id = qx(/home/drbean/moodle/moosh/moosh.php -n activity-add -n '$name' -s $section -o "--timeopen=1 --intro=$intro --introformat=4 --externalurl=$option_hash{url}" url $course);
			my $activity_add_line = "/home/drbean/moodle/moosh/moosh.php -n activity-add -n '$name' -s $section -o=\"$option_string\" $type $course";
			warn "\nactivity-add-line='$activity_add_line'\n";
			my $activity_id = qx( $activity_add_line );
			warn "$module{$type}_id=$activity_id";
		}
		elsif ( $type eq 'assign' ) {
			my $name = $yaml->{$story}->{$type}->{$form}->{identifier};
			# $option_string .= "--intro=$yaml->{$story}->{$type}->{$form}->{rubric}";
			# my $assign_id = qx(/home/drbean/moodle/moosh/moosh.php -n activity-add -n '$name' -s $section -o "--timeopen=1 --intro=$intro --introformat=4 --externalassign=$option_hash{assign}" assign $course);
			my $activity_add_line = "/home/drbean/moodle/moosh/moosh.php -n activity-add -n '$name' -s $section -o=\"$option_string\" $type $course";
			warn "\nactivity-add-line='$activity_add_line'\n";
			my $assign_id = qx( $activity_add_line );
			warn "assign_id=$assign_id";
		}
		elsif ( $module{$type} eq 'quiz' ) {
			my $name = $yaml->{$story}->{$type}->{$form}->{identifier};
			die "No '$name' identifier in the topic '$topic' '$type' quiz about the '$story' story, '$form' form\n" unless $name;
			my $activity_add_line = "/home/drbean/moodle/moosh/moosh.php -n activity-add -n '$name' -s $section -o=\"$option_string\" quiz $course";
			warn "\nactivity-add-line='$activity_add_line'\n";
			my $quiz_id = qx( $activity_add_line );
			warn "quiz_id=$quiz_id";
			chomp $quiz_id;
			die "Failed to add '$name' activity to section $section with activity-add! activity_id=$quiz_id\n" unless looks_like_number( $quiz_id );
			for my $question ( @$content_list ) {
				my ( $topic, $story, $type, $form, $intro ) = 
					map { $question->{$_} } qw/topic story type form intro/;
				die "No '$name' '$type' quiz for '$topic' topic, '$story' story, '$form' form?\n" unless
					$topic and  $story and  $type and  defined $form;
				if ( $intro ) {
					my $description = qx"yaml4moodle description -d '$intro' -i $name -t $topic -s $story -f $form";
					my $file = "/var/lib/moodle/repository/$topic/quiz_${story}_description_${form}.xml";
					$description > io( $file );
					system( "Moosh -n question-import $file $quiz_id $category") == 0 or die 
					"question import of '$story' '$form' form '$intro' description intro in '$category' category into '$quiz_id' quiz, from '$file' file failed. ";
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
					system( "Moosh -n question-import $file $quiz_id $category") == 0 or die 
					"question import of all '$story' '$type' activity: '$form' form questions in '$category' category into '$quiz_id' quiz, from '$file' file failed. ";
				}
				elsif ( looks_like_number( $random ) ) {
					my $tag = "${topic}_${story}_${type}_$form";
					system( "Moosh -n question-import -r $random --tag='$tag' --component=$tagcomponent --collection=$tagcollid $file $quiz_id $category") == 0 or die 
					"question import of '$story' '$type' activity: '$form' form with '$random' random questions with '$name' tag in the '$tagcollid' collection for the '$tagcomponent' component in '$category' category failed";

				}
				else { die "'$random' questions in '$story' '$type' activity: '$form' form?" }
			}
		}
		else {die "'$module{$type}' activity type for '$type' exercise?\n"}
		$n++;
	}
}

1;
