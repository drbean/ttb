#!/usr/bin/perl

use strict;
use warnings;

use YAML qw/ LoadFile DumpFile /;
use IO::All;

die "scores.yaml scoresheet already exists: $!\n" if -e 'scores.yaml';

my $round = LoadFile( 'round.yaml' );
my $league = LoadFile( "../league.yaml" );
my @members = @{$league->{member}};
my %ids = map { $_->{name} => $_->{id} } @members;
my %names = map { $_->{id} => $_->{name} } @members;

my $sched;
my $groups = $round->{group};

my @number = qw/First Second Third Fourth Fifth Sixth/;

foreach my $group ( keys %$groups )
{
	local $YAML::SortKeys = 0;
	if ($group eq 'absent') {
		$sched->{Absent} = $groups->{$group};
		next;
	}
	$sched->{Chinese}->{$group} = 0;
	$sched->{letters}->{$group}->{story} = 0;
	my @roles =  sort keys %{$groups->{$group}}; 
	foreach my $role ( @roles )
	{
		my $name = $groups->{$group}->{$role};
		$sched->{letters}->{$group}->{$role} = 0;
		#foreach (0..0)
		#{
		#	$sched->{letters}->{$group}->{$role}
		#		->{"Conversation$number[$_]"} = 0;
		#}
	}
}

DumpFile( 'scores.yaml', $sched );

my $scoresheet = io qq/scores.yaml/;
my @lines = $scoresheet->getlines;
'' > $scoresheet;
LINE: foreach my $line ( @lines )
{
	unless ( $line =~ m/0$/ )
	{
		$line >> $scoresheet;
		next LINE;
	}
	else
	{	my $length = length $line;
		my $filler = 13 - $length;
		substr($line, -2)  = ' ' x (28-$length) . "\n";
		$line >> $scoresheet;
	}
}
