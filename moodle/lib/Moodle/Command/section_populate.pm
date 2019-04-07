package Moodle::Command::section_populate;

use lib "lib";

use Moodle -command;
use strict;
use warnings;
use YAML qw/Dump LoadFile DumpFile/;
use IO::All;
use Scalar::Util qw/looks_like_number/;

sub abstract { "moopl section_populate -c question_category -s course_section -r random_question_number -g grade_category" }
sub description { "Run moosh section_populate for list of quiz questions in section/9/question.yaml" }

sub usage_desc { "moopl section_populate -c question_category -s course_section -r random_question_number -g grade_category"}

sub opt_spec  {
        return (
		["c=i", "question_category"]
		, ["s=i", "course_section"]
		, ["r=i", "random_question_number"]
		, ["g=i", "grade_category"]
	);
}

sub execute {

	my ($self, $opt, $args) = @_;

	my ($category, $section, $random_option, $gradecat) = @$opt{qw/c s r g/};
	my $semester="$ENV{SEMESTER}";

	chdir "/var/www/cgi-bin/moodle";

	my $activity_list = LoadFile "/home/drbean/curriculum/correspondence/section/$section/activity.yaml";
	die "list of activities: $activity_list\n" unless ref( $activity_list) eq "ARRAY" and $activity_list;
	my $n = 0;
	for my $question_list ( @$activity_list ) {
		die "No activity $n with $question_list questions?\n" unless
			defined $question_list and ref($question_list) eq 'ARRAY';
		my $first_one = $question_list->[0];
		my ( $topic, $story, $type, $form ) = 
			map { $first_one->{$_} } qw/topic story type form/;
		die "No '$type' quiz for '$topic' topic, '$story' story, '$form' form?\n" unless
			$topic and  $story and  $type and  defined $form;
		my $cards = "/home/drbean/curriculum/correspondence/$topic/cards.yaml";
		my $yaml = LoadFile $cards;
		my $name = $yaml->{$story}->{$type}->{$form}->{identifier};
		die "No '$name' identifier in '$topic' '$type' quiz for '$story' '$form' form\n" unless $name;
		my $quiz_id = qx(/home/drbean/moodle/moosh/moosh.php -n activity-add -n '$name' -s $section -o="--timeopen=1 --intro=$topic: $story $form --grade=3 --gradecat=$gradecat --groupmode=1 --groupingid=127 --attempts=4 --decimalpoints=0 --overduehandling=0 --shuffleanswers=1 --subnet=210.60.168.212 --browsersecurity=safebrowser --safeexambrowser_allowedkeys=fa490bbb44096e7be888c2c0f164b9c01478691b9ce05c101761d2c885e0b6e5" quiz 36);
		chomp $quiz_id;
		die "Failed to add '$name' activity to section $section with activity-add! activity_id=$quiz_id\n" unless looks_like_number( $quiz_id );
		for my $question ( @$question_list ) {
			my ( $topic, $story, $type, $form ) = 
				map { $question->{$_} } qw/topic story type form/;
			die "No '$name' '$type' quiz for '$topic' topic, '$story' story, '$form' form?\n" unless
				$topic and  $story and  $type and  defined $form;
			system( "FORM=$form; STORY=$story; QUIZ=$type; TOPIC=$topic; for format in gift xml ; do yaml4moodle \$format -c correspondence -t \$TOPIC -s \$STORY -q \$QUIZ -f \$FORM > /var/lib/moodle/repository/\${TOPIC}/quiz_\${STORY}_\${QUIZ}_\${FORM}.\$format ; done" )
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
				system( "Moosh -n question-import -r $random -t '$name' $file $quiz_id $category") == 0 or die 
				"question import of '$story' '$type' activity: '$form' form with '$random' random questions in '$category' category failed";

			}
			else { die "'$random' questions in '$story' '$type' activity: '$form' form?" }
		}
		$n++;
	}
}

1;
