package Moodle::Command::jigsaw_deploy;

use lib "lib";

use Moodle -command;
use strict;
use warnings;
use YAML qw/Dump LoadFile DumpFile/;
use IO::All;

sub abstract { "moopl jigsaw_deploy -l 2L1b -c conversation -t story -s gold -f 0 -x 5 -g 45" }
sub description { "Build jigsaw for course, session 5, grouping id 45" }

sub usage_desc { "moodle jigsaw_deploy -l BMA0031 -c 23" }

sub opt_spec  {
        return (
                ["l=s", "league"]
				, ["c=s", "course"]
				, ["t=s", "topic"]
				, ["s=s", "story"]
				, ["f=s", "form"]
				, ["g=s", "grouping"]
				, ["x=s", "section"]
	);
}


sub execute {
	my ($self, $opt, $args) = @_;

	my ($league, $course, $topic, $story, $form, $grouping, $section) = @$opt{qw/l c t s f g x/};
	my $semester="$ENV{SEMESTER}";

	chdir "/var/www/cgi-bin/moodle";

	my $course_id = qx/Moosh -n course-list -i "shortname='correspondence_062'"/;
	chomp $course_id;
	my $expert_groups = qx/Moosh -n group-list -G $grouping $course_id/;
	my @expert_groups = split /\n/, $expert_groups;

	use Grades;
	my $l = League->new( leagues => "/home/drbean/$semester", id => $league );
	my $yaml = LoadFile "/home/drbean/curriculum/$course/$topic/cards.yaml";
	my $cards = $yaml->{$story}->{drag}->{$form};
	my @roles = qw/A B C/;
	my %role_cards;
	@role_cards{@roles}= @$cards{@roles};
	my $quiz_cards = $cards->{quiz};

	print "cards: $story, $form\n";
	for my $group ( @expert_groups ) {
		next unless $group =~ m/\bgroup\b/;
		( my $id = $group ) =~ s/^[\D]*(\d+).*$/$1/;
		( my $role = $group ) =~ s/^.*"\d+-([ABC]).*$/$1/;
		my $json = q/{\"op\":\"&\",\"c\":[{\"type\":\"group\",\"id\":/ . $id . q/}],\"showc\":[false]}/;
		system("Moosh -n activity-add -n $story$form -c \"$role_cards{$role}\" -s $section -a \"$json\" page $course_id");
	}
	my $quiz_id = qx/Moosh -n activity-add -n \"$story$form quiz\" -s $section quiz $course_id/;
	print $quiz_id . "\n";
	my $quiz_content = qx/yaml4moodle xml -c $course -t $topic -s $story -f $form/;
	my $xml = io "/var/lib/moodle/repository/$topic/quiz_${story}_jigsaw_$form.xml";
	io($xml)->print($quiz_content);
	system("Moosh -n question-import /var/lib/moodle/repository/$topic/quiz_${story}_jigsaw_$form.xml $quiz_id");

	# system("moopl group_build -l $league");

}

1;
