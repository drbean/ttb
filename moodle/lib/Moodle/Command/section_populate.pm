package Moodle::Command::section_populate;

use lib "lib";

use Moodle -command;
use strict;
use warnings;
use YAML qw/Dump LoadFile DumpFile/;
use IO::All;
use Scalar::Util qw/looks_like_number/;

sub abstract { "moopl section_populate -c question_category -s course_section -r random_question_number" }
sub description { "Run moosh section_populate for list of quiz questions in section/9/question.yaml" }

sub usage_desc { "moopl section_populate -c question_category -s course_section - random_question_number" }

sub opt_spec  {
        return (
		["c=s", "question_category"]
		, ["s=s", "course_section"]
		, ["r=s", "random_question_number"]
	);
}

sub execute {

	my ($self, $opt, $args) = @_;

	my ($category, $section, $random) = @$opt{qw/c s r/};
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
		die "name='$name'?" unless $name;
		my $quiz_id = qx(/home/drbean/moodle/moosh/moosh.php -n activity-add -n '$name' -s $section -o="--timeopen=1 --intro=goodwill --grade=3 --gradecat=475 --groupmode=1 --groupingid=127 --attempts=4 --decimalpoints=0 --overduehandling=0 --shuffleanswers=1" quiz 36);
		chomp $quiz_id;
		die "Failed to add '$name' activity to section $section with activity-add! activity_id=$quiz_id\n" unless looks_like_number( $quiz_id );
		for my $question ( @$question_list ) {
			my ( $topic, $story, $type, $form ) = 
				map { $question->{$_} } qw/topic story type form/;
			die "No '$name' '$type' quiz for '$topic' topic, '$story' story, '$form' form?\n" unless
				$topic and  $story and  $type and  defined $form;
			my $file = "/var/lib/moodle/repository/$topic/quiz_${story}_${type}_$form.xml";
			die "No $story ($type) $form form file in repository/$topic?" unless
				-e $file;
			system( "Moosh -n question-import -r $random -t '$name' $file $quiz_id $category") == 0 or die 
				"question import of '$story': '$form' with '$random' random questions in '$category' category failed";
		}
		$n++;
	}
}

1;
