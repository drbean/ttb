package Moodle::Command::jigsaw_deploy;

use lib "lib";

use Moodle -command;
use strict;
use warnings;
use YAML qw/Dump LoadFile DumpFile/;
use IO::All;

sub abstract { "moopl jigsaw_deploy -l 2L1b -c conversation -t story -s gold -f 0,1,2 -x 5 -g 45" }
sub description { "Build gold jigsaw for course, session 5, grouping id 45" }

sub usage_desc { "moodle jigsaw_deploy -l BMA0031 -c 23" }

sub opt_spec  {
        return (
                ["l=s", "league"]
				, ["c=s", "course"]
				, ["t=s", "topic"]
				, ["s=s", "story"]
				, ["f=s", "form"]
				, ["g=s", "grouping"]
				, ["w=s", "section"]
				, ["q=s", "question category"]
	);
}


sub execute {
	my ($self, $opt, $args) = @_;

	my ($league, $course, $topic, $story, $form, $grouping, $section, $question1_cat) = @$opt{qw/l c t s f g w q/};
	my $semester="$ENV{SEMESTER}";

	chdir "/var/www/cgi-bin/moodle";

	my $course_id = qx/Moosh -n course-list -i "shortname='$league'"/;
	chomp $course_id;
	my $expert_groups = qx/Moosh -n group-list -G $grouping $course_id/;
	my @expert_groups = split /\n/, $expert_groups;

	use Grades;
	my $l = League->new( leagues => "/home/drbean/$semester", id => $league );
	my $yaml = LoadFile "/home/drbean/curriculum/$course/$topic/cards.yaml";
	my @form = split /,/, $form;
	my $n=0;
	for my $form ( @form ) {
		my $cards = $yaml->{$story}->{jigsaw}->{$form};
		my @roles = qw/A B/;
		my %role_cards;
		@role_cards{@roles}= @$cards{@roles};
		$role_cards{$_} .= "\n" for @roles;
		my $quiz_cards = $cards->{quiz};

		print "cards: $story, $form\n";
		for my $group ( @expert_groups ) {
			next unless $group =~ m/\bgroup\b/;
			my $group_id_re = qr/\d+/;
			my $group_name_re = qr/\d-\d/;
			( my $id = $group ) =~ s/^[\D]*($group_id_re).*$/$1/;
			( my $group_form = $group ) =~ s/^[\D]*$group_id_re\s"$section-($group_name_re).*$/$1/;
			next unless $form eq $group_form;
			( my $role = $group ) =~ s/^.*"$group_id_re-$group_name_re-([AB]).*$/$1/;
			my $json = qq/{"op":"&","c":[{"type":"group","id":$id}],"showc":[false]}/;
			system("Moosh -n -v activity-add -n \"$story $form $role\" -s $section -o \"--content='$role_cards{$role}'\" page $course_id");
		}
		my $quiz_id = qx/Moosh -n activity-add -n \"$story $form quiz\" -s $section -o '--availabilityconditionsjson={"op":"&","c":[{"op":"|","c":[{"type":"completion","cm":2951,"e":1},{"type":"completion","cm":2950,"e":1}]}],"showc":[false]}' quiz $course_id/;
		chomp $quiz_id;
		my $quiz_content = qx/yaml4moodle xml -c $course -t $topic -s $story -f $form/;
		my $xml = io "/var/lib/moodle/repository/$topic/quiz_${story}_jigsaw_$form.xml";
		io($xml)->print($quiz_content);
		my $question_category_id = $question1_cat + ++$n;
		system("Moosh -n question-import $xml $quiz_id $question_category_id");
	}

	# system("moopl group_build -l $league");

}

1;
