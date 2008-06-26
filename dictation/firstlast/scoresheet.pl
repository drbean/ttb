#!/usr/bin/perl

use strict;
use warnings;

use Games::Tournament::RoundRobin;
use Games::League::Member;

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
my $byes = $groups->{Bye};

foreach my $group ( keys %$groups )
{
	my @group =  @{$groups->{$group}} if $groups->{$group};
	my @lineup;
	my $k;
	if ($group eq 'Bye' ) {
		next unless $byes;
		foreach my $byer ( @$byes ) 
		{
			$sched->{Bye}->{$byer . ' ' . $ids{$byer}} = 3;
		}
	}
	else
	{
		foreach my $member ( @group ) 
		{
			my @keys = map { 'Conversation' . $_ } 1..@{$round->{texts}};
			$sched->{$group}->{$member .' '.
					$ids{$member}}->{Signatures} = 0;
			$sched->{$group}->{$member .' '.
					$ids{$member}}->{$_} = 0 foreach @keys;
		}
	}
}


DumpFile( 'scores.yaml', $sched );

my $scoresheet = io qq/scores.yaml/;
my @lines = $scoresheet->getlines;
'' > $scoresheet;
foreach my $line ( @lines )
{
	if ( $line =~ m/^ *(Conversation\d|Signatures): 0$/ )
	{	my $length = length $line;
		my $filler = 13 - $length;
		substr($line, -2)  = ' ' x (24-$length) . "\n";
	}
	$line >> $scoresheet;
}
