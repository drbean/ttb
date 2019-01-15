package Moodle::Command::question_import;

use lib "lib";

use Moodle -command;
use strict;
use warnings;
use YAML qw/Dump LoadFile DumpFile/;
use IO::All;
use Scalar::Util qw/looks_like_number/;

sub abstract { "moopl question_import -e midterm" }
sub description { "Run moosh question_import for list of quiz questions in exam/question.yamlk" }

sub usage_desc { "moopl question_import -e midterm" }

sub opt_spec  {
        return (
                ["e=s", "exam"]
	);
}


sub execute {

	my ($self, $opt, $args) = @_;

	my $exam = $opt->{qw/e/};
	my $semester="$ENV{SEMESTER}";

	chdir "/var/www/cgi-bin/moodle";
	## Save questions in ${exam}_exam_$semester category for quiz
	#my $category = qx|~/dot/postgres/db/script/db moodle -p 5433 -d mood071 -u postgres  -t question_categories -a select -k name  -v final_exam_071 -s id|;
	#my @category = split /\n/, $category;
	#die "${exam}_exam_$semester category id is which @category category?\n"
	#	unless @category == 1;
	#my $id = shift @category;
	#chomp $id;
	my $category = 4755;
	die "${exam}_exam_$semester category id is $category?\n"
		unless looks_like_number($category);

	## Get exam quiz activity id
	#my $quiz = qx/Moosh -n sql-run "SELECT id FROM {quiz} WHERE name =  \'${exam}_exam_$semester\'"/;
	#chomp $quiz;
	my $quiz= 2281;
	die "${exam}_exam_$semester quiz id is $quiz?\n"
		unless looks_like_number($quiz);

	my $yaml = LoadFile "/home/drbean/curriculum/correspondence/exam/question.yaml";
	my $question_list = $yaml->{$semester}->{$exam};
	die "list of questions: $question_list\n" unless ref( $question_list) eq "ARRAY" and $question_list;
	for my $question ( @$question_list ) {
		my ( $topic, $story, $type, $form ) = 
			map { $question->{$_} } qw/topic story type form/;
		my $file = "/var/lib/moodle/repository/$topic/quiz_${story}_${type}_$form.xml";
		die "No $story ($type) $form form file in repository/$topic?" unless
			-e $file;
		qx/Moosh -n question-import $file $quiz $category/;
	}
}

1;
