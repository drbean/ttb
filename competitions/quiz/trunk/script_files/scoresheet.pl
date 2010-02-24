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
my $byes = $round->{byes};

# my @number = qw/First Second Third Fourth Fifth Sixth/;
my @number = qw/1 2 3 4 5 6 7 8/;

GROUP: foreach my $group ( keys %$groups )
{
	my @group =  values %{$groups->{$group}} if $groups->{$group};
	my @lineup;
	my $k;
	if ($group eq 'Bye' ) {
		next unless $byes;
		foreach my $byer ( @$byes ) 
		{
			$sched->{$group}->{Bye}->{$byer} = "Bye";
		}
		next GROUP;
	}
	else
	{
		foreach my $member ( @group )
		{
			$sched->{$group}->{$member} = 0;
		}
	}
}

DumpFile( 'scores.yaml', $sched );

my $scoresheet = io qq/scores.yaml/;
my @lines = $scoresheet->getlines;
'' > $scoresheet;
LINE: foreach my $line ( @lines )
{
	if ( $line =~ m/.*: 0$/ )
	{	my $length = length $line;
		my $filler = 13 - $length;
		substr($line, -2)  = ' ' x (28-$length) . "\n";
	}
	$line >> $scoresheet;
}
