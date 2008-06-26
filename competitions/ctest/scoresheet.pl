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
	my @roles =  sort keys %{$groups->{$group}}; 
	map
	{
		my $name = $groups->{$group}->{$_};
		$sched->{Chinese}->{$group} = 0;
		map
		{
			$sched->{letters}->{$group}->{$name}
				->{"Conversation$number[$_]"} = 0;
		} 0..0
	} @roles;
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
