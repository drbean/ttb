package Moodle::Command::group_build;

use lib "lib";

use Moodle -command;
use strict;
use warnings;
use YAML qw/Dump LoadFile DumpFile/;
use IO::All;

sub abstract { "Leverage Moosh's php scripts to do higher-level moodle work in perl" }
sub description { "Leverage Moosh's php scripts to do higher-level moodle work in perl" }

sub usage_desc { "moodle group_build -l BMA0031 -c 23" }

sub opt_spec  {
        return (
                ["l=s", "league"]
	);
}


sub execute {
	my ($self, $opt, $args) = @_;

	my ($league) = @$opt{qw/l/};
	my $semester="$ENV{SEMESTER}";

	chdir "/var/www/cgi-bin/moodle";

	my @course_info = qx/Moosh course-list -n "shortname='$league'"/;
	my $course_id_line = chomp $course_info[1];
	(my $course_id = $course_id_line) =~ tr/"//;

	use Grades;
	my $l = League->new( leagues => "/home/drbean/$semester", id => $league );
	my $g = Grades->new({ league => $l });
	my $cl = $g->classwork;
	my $lastweek = $cl->lastweek + 1;
	my $session = $cl->week2session($lastweek);
	my $beancans = $cl->beancan_names($session);
	my @groups = keys %$beancans;
	print "league: $league\n";
	$" = " ";
	print "beancans: ", @groups, "\n";
	print "Session: $session, Week: $lastweek\n";
	my $grouping_id = qx/Moosh grouping-create -d \"session $session\" $session $course_id/;
	chomp $grouping_id;
	for my $group ( @groups ) {
		my $group_id = qx/Moosh group-create \"$session-$group\" $course_id/;
		chomp $group_id;
		my $members = $beancans->{$group};
		system("Moosh group-assigngrouping -G $grouping_id $group_id");
		system("Moosh group-memberadd -c $course_id -g $group_id @$members");
	}

}

1;
