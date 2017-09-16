#!/usr/bin/perl

use strict;
use warnings;
use IO::All;
use YAML::XS qw/LoadFile DumpFile Dump/;
use Cwd;

$_REPL->load_plugin('DumpHistory');

my $semester=$ENV{SEMESTER};
# my $semester='061';
my $school='must';
my $league='251';
my $course_id = 18;

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
