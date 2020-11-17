package Moodle::Command::section_populate;

use lib "lib";

# use Moodle -command;
use YAML4Moodle::Command::description;
use YAML4Moodle::Command::xml;
use YAML4Moodle::Command::gift;
use strict;
use warnings;
use YAML qw/Dump LoadFile DumpFile/;
# use IO::All;
use Scalar::Util qw/looks_like_number/;
use List::MoreUtils qw/all/;

sub abstract { "moopl section_populate -q question_category -s course_section -r random_question_number -g grade_category -c course" }
sub description { "Run moosh section_populate for list of quiz questions in section/9/question.yaml" }

sub usage_desc { "moopl section_populate -q question_category -s course_section -r random_question_number -g grade_category -c course"}

sub opt_spec  {
        return (
		["q=s", "question_category"]
		, ["s=s", "course_section"]
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

	my @types = qw/quiz studentquiz assign url page forum/;
	my %module = ( jigsaw => 'quiz'
		, drag => 'quiz'
		, match => 'quiz'
		, scramble => 'quiz'
		, description => 'quiz'
		, essay => 'quiz'
		, studentquiz => 'studentquiz'
		, assign => 'assign'
		, url => 'url'
		, page => 'page'
		, forum => 'forum'
	);
	my $section_n = { general => 0
		, read => 1
		, pic => 2
		, question => 3
		, information => 4
		, solution => 5
		, opinion => 6
		, test0 => 7
		, test1 => 8
		}->{$section};
	my $curriculum_default = LoadFile "/home/$ENV{USER}/curriculum/online/default.yaml";
	my $course_default = LoadFile "/home/$ENV{USER}/curriculum/$course_name/online/default.yaml";
	my $default_option;
	$default_option->{$_} = $curriculum_default->{$_} for keys %$curriculum_default;
	my ($section_default, $section_naming, $activity_list) = LoadFile "/home/$ENV{USER}/curriculum/$course_name/online/$section.yaml";
	for my $type ( @types ) {
		$default_option->{$type}->{$_} = $course_default->{$type}->{$_}
			for keys %{$course_default->{$type}};
		$default_option->{$type}->{$_} = $section_default->{$type}->{$_}
			for keys %{$section_default->{$type}};
	}
	die "list of activities: $activity_list?\n" unless ref( $activity_list) eq "ARRAY" and $activity_list;
	die "default options $default_option not a HASH\n" unless ref $default_option eq 'HASH';
	# die "Not all activity options in $options a HASH\n" unless all { ref $options->{$_} eq 'HASH' } keys %$options;
	# die "Not all activity options in $options option strings\n" unless all { ref $_ eq '' } ( values %{ $options->{$_} } for keys %options );
	my $section_name = $section_naming->{section}->{name} or die "no '$section' section name\n";
	my $section_summary = $section_naming->{section}->{summary} or die "no '$section' section summary\n";
	my @section_set = ("name \"$section_name\"", "summaryformat 4", "summary \"$section_summary\"");
	for my $setting ( @section_set ) {
		my $section_set_line = "/home/$ENV{USER}/moosh/moosh.php -n section-config-set -s $section_n course $course $setting";
		warn "\nsection-set-line='$section_set_line'\n";
		system( $section_set_line ) == 0 or die "'$section_set_line' failed";
	}
	my $n = 0;
	for my $activity ( @$activity_list ) {
		my $content_list = delete $activity->{content};
		#die "No activity $n with $content_list contents?\n" unless
		#	defined $content_list and ref($content_list) eq 'ARRAY';
		my $first_one = $content_list->[0];
		my ( $topic, $story, $type, $form ) = 
			map { $first_one->{$_} } qw/topic story type form/;
		my $cards = "/home/$ENV{USER}/curriculum/$course_name/$topic/cards.yaml";
		my $yaml = LoadFile $cards;
		die "No '$type' activity for '$topic' topic, '$story' story, '$form' form?\n" unless
			$topic and  $story and  $type and  defined $form;
		my $default_options = $default_option->{ $module{$type} };
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
		$name = "\"$name\"";
		my $activity_add_line;
		if ( $type eq 'forum' ) {
			$option_hash{intro} = $yaml->{$story}->{$type}->{$form}->{rubric};
			$activity_add_line = "/home/$ENV{USER}/moosh/moosh.php -n activity-add -n $name -s $section_n -o \"--timeopen=1 --intro=\"$(IFS= cat /home/$ENV{USER}/curriculum/$course_name/$story/intro.md) --introformat=4 --type=eachuser  --grade=3 --gradecat=$gradecat --decimalpoints=0\" forum $course";
		}
		elsif ( $type eq 'studentquiz' ) {
			$option_hash{intro} = $yaml->{$story}->{$type}->{$form}->{rubric};
		}
		elsif ( $type eq 'url' ) {
			$option_hash{externalurl} = $yaml->{$story}->{$type}->{$form}->{externalurl};
			$option_hash{intro} = $intro;
		}
		elsif ( $type eq 'page' ) {
			$option_hash{content} = $yaml->{$story}->{$type}->{$form}->{rubric};
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
		$activity_add_line = "/home/$ENV{USER}/moosh/moosh.php -n activity-add --name=$name -s $section_n --options=\"$option_string\" $module{$type} $course";
		warn "\n$module{$type}-add-line='$activity_add_line'\n";
		my $activity_id = qx( $activity_add_line );
		warn "$module{$type}_id=$activity_id";
		chomp $activity_id;
		die "Failed to add '$name' activity to '$section' section with activity-add! activity_id=$activity_id\n" unless looks_like_number( $activity_id );
		if ( $module{$type} eq 'forum' ) {
			my $activity_set_line =  "/home/$ENV{USER}/moosh/moosh.php -n activity-config-set activity $activity_id forum intro \"$option_hash{intro}\"";
			warn "\n$module{$type}-set-line='$activity_set_line'";
			system( $activity_set_line ) == 0 or die "'$activity_set_line' failed";
		}
		if ( $module{$type} eq 'quiz' ) {
			for my $question ( @$content_list ) {
				my ( $topic, $story, $type, $form, $intro ) = 
				map { $question->{$_} } qw/topic story type form intro/;
				die "No '$name' '$type' quiz for '$topic' topic, '$story' story, '$form' form?\n" unless
					$topic and  $story and  $type and  defined $form;
				die "No '$option_hash{parentcategory}' parent category, '$option_hash{categorycontext}' context for '$option_hash{questioncategory}' question category\n"
					unless $option_hash{parentcategory} and $option_hash{categorycontext} and $option_hash{questioncategory};
				my $category_create_line = "/home/$ENV{USER}/moosh/moosh.php -n questioncategory-create --reuse -p $option_hash{parentcategory} -c $option_hash{categorycontext} $option_hash{questioncategory}";
				warn "\ncategory-create-line='$category_create_line'\n";
				my $category_id = qx( $category_create_line );
				warn "category_id=$category_id\n";
				die "category_id?\n" unless $category_id;
				chomp $category_id;
my $handle   = undef;
my $encoding = ":encoding(UTF-8)";
				if ( $intro ) {
					my $description = YAML4Moodle::Command::description::execute('', { d=>$intro, i=>$name, t=>$topic, s=>$story, f=>$form});
					my $file = "/var/lib/moodle/repository/$topic/quiz_${story}_description_${form}.xml";

open($handle, "> $encoding", $file)
    || die "$0: can't open $file in write-open mode: $!";
print $handle $description;
close $handle or die "$0: can't close $file";
die "No $story description $form form file in repository/$topic?" unless
	-s $file;
					# $description > io( $file );
					system( "/home/$ENV{USER}/moosh/moosh.php -n question-import $file $activity_id $category_id") == 0 or die 
					"question import of '$story' '$form' form '$intro' description intro in '$category' category into '$activity_id' quiz, from '$file' file failed. ";
				}
				my $file;
				for my $format ( qw(xml) ) {
					my $question = YAML4Moodle::Command::xml::execute('', { c=>$course_name, t=>$topic, s=>$story, q=>$type, f=>$form });
					die "YAML4Moodle build of '$topic' '$type' quiz for, '$story' story, '$form' failed\n"
						unless $question;
					$file = "/var/lib/moodle/repository/$topic/quiz_${story}_${type}_$form.$format";
					open($handle, "> $encoding", $file)
						|| die "$0: can't open $file in write-open mode: $!";
					print $handle $question;
					close $handle or die "$0: can't close $file";
					die "No $story ($type) $form form file in repository/$topic?" unless
						-s $file;
				}
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
					system( "/home/$ENV{USER}/moosh/moosh.php -n question-import $file $activity_id $category_id") == 0 or die 
					"question import of all '$story' '$type' activity: '$form' form questions in '$category' category into '$activity_id' quiz, from '$file' file failed. ";
				}
				elsif ( looks_like_number( $random ) ) {
					my $tag = "${topic}_${story}_${type}_$form";
					# my $import_random_line = "/home/$ENV{USER}/moosh/moosh.php -n -v question-importrandom -r $random -t '$tag' -m $tagcomponent -l $tagcollid $file $activity_id $category_id";
					my $import_random_line = "/home/$ENV{USER}/moosh/moosh.php -n question-importrandom $file $activity_id $category_id $random $tag $tagcollid $tagcomponent";
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
