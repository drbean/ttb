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
                , ["c=i", "course id on moodle"]
	);
}


sub execute {
	my ($self, $opt, $args) = @_;

	my ($league) = @$opt{qw/l/};
	my $course_id;
	($course_id) = @$opt{qw/c/};
	my $semester="$ENV{SEMESTER}";

	chdir "/var/www/cgi-bin/moodle";

	unless ( $course_id ) {
		$course_id = qx/Moosh -n course-list -i "shortname='$league'"/;
		chomp $course_id;
	}

	use Grades;
	my $l = League->new( leagues => "/home/drbean/$semester", id => $league );
	my $g = Grades->new({ league => $l });
	my $cl = $g->classwork;
	my $lastsession = $cl->lastsession;
	my $beancans = $cl->beancan_names($lastsession);
	my @groups = sort keys %$beancans;
	print "league: $league\n";
	$" = " ";
	print "beancans: @groups\n";
	print "Session: $session, Week: $lastweek\n";
	my $grouping_string = qx/Moosh -n grouping-create -d "session $session" $session $course_id/;
	print $grouping_string;
	chomp $grouping_string;
	(my $grouping_id = $grouping_string) =~ s/^.*\((.*)\).*$/$1/;
	# my $grouping_id = "126";
	for my $group ( @groups ) {
		my $group_string = qx/Moosh -n group-create "$session-$group" $course_id/;
		chomp $group_string;
		(my $group_id = $group_string) =~ s/^.*\((.*)\).*$/$1/;
		my $members = $beancans->{$group};
		my @members = map { '"' . $_ . '"' } @$members;
		system("Moosh -n group-assigngrouping -G $grouping_id $group_id");
		system("Moosh -n group-memberadd -c $course_id -g $group_id @$members");
	}
	system("Moosh -n course-config-set course $course_id defaultgroupingid $grouping_id")

}

1;
