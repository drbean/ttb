package Moodle::Command::question_import;

use lib "lib";

use Moodle -command;
use strict;
use warnings;
use YAML qw/Dump LoadFile DumpFile/;
use IO::All;
use Scalar::Util qw/looks_like_number/;

sub abstract { "moopl question_import -e midterm -c question_category -s course_section" }
sub description { "Run moosh question_import for list of quiz questions in section/9/question.yaml" }

sub usage_desc { "moopl question_import -e exercise -c question_category -s course_section" }

sub opt_spec  {
        return (
                ["e=s", "exercise"]
		, ["c=s", "question_category"]
		, ["s=s", "course_section"]
	);
}


sub execute {

	my ($self, $opt, $args) = @_;

	my ($exercise, $category, $section) = $opt->{qw/e c s/};
	my $semester="$ENV{SEMESTER}";

	chdir "/var/www/cgi-bin/moodle";
	# Save questions in ${exam}_exam_$semester category for quiz
	unless ( looks_like_number( $category ) ) {
		my $candidates = qx{~/dot/postgres/db/script/db moodle -p 5433 -d mood072 -u drbean -t question_categories -a select -k name  -v $category -s id};
		@category = split /\n/, $candidates;
		die "${exam}_exam_$semester category id is which @category category?\n"
		unless @category == 1;
		$category = shift @category;
		chomp $category;
	}
	# my $category = 4755;
	die "${exam}_exam_$semester category id is $category?\n"
		unless looks_like_number($category);

	# Get exam quiz activity id
	my $quiz = qx{~/dot/postgres/db/script/db moodle -p 5433 -d mood071 -u drbean -t quiz -a select -k name  -v test_of_question-import -s id};
	chomp $quiz;
	# my $quiz= 2281;
	die "${exam}_exam_$semester quiz id is $quiz?\n"
		unless looks_like_number($quiz);

	my $yaml = LoadFile "/home/drbean/curriculum/correspondence/section/$section/question.yaml";
	my $question_list = $yaml->{$exercise};
	die "list of questions: $question_list\n" unless ref( $question_list) eq "ARRAY" and $question_list;
	for my $question ( @$question_list ) {
		my ( $topic, $story, $type, $form ) = 
			map { $question->{$_} } qw/topic story type form/;
		my $file = "/var/lib/moodle/repository/$topic/quiz_${story}_${type}_$form.xml";
		die "No $story ($type) $form form file in repository/$topic?" unless
			-e $file;
		system( "Moosh -n question-import $file $quiz $category") == 0 or die 
			"question import of $story: $form in $category category failed";
	}
}

1;
