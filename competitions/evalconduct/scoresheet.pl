#!/usr/bin/perl

use strict;
use warnings;

use Games::Tournament::RoundRobin;
use Games::League::Member;

use YAML qw/ LoadFile DumpFile /;
use IO::All;

die "scores.yaml scoresheet already exists: $!\n" if -e 'scores.yaml';

my @yaml = glob "*.yaml";
my @roundfile = grep m/^.\d+.yaml$/, @yaml;
die "too many roundfile" if $#roundfile;
my $roundfile = $roundfile[0];
my $round = LoadFile( $roundfile );
my $league = LoadFile( "../class.yaml" );
my @members = @{$league->{member}};
my %ids = map { $_->{name} => $_->{id} } @members;
my %names = map { $_->{id} => $_->{name} } @members;


my $sched;
my $groups = $round->{group};
my $byes = $groups->{Bye};

foreach my $group ( keys %$groups )
{
	next if $group eq 'Bye';
	my @group =  @{$round->{group}->{$group}}; 
	my @lineup;
	my $k;
	foreach my $player ( @group )
	{
		my $playerId = $ids{$player};
		my $member = Games::League::Member->new( 
			index => $k++, name => $player, id => $playerId);
		push @lineup, $member;
	}
	my $roundrobin =
	Games::Tournament::RoundRobin->new(v => 3, league => \@lineup);
	my $participants = $roundrobin->partners(3);
	foreach my $member ( @$participants )
	{
		my $partners = $roundrobin->partners( $member);
		my @keys = map {
			my $partner = $_;
			my $index = $partner->index;
			my $meeting = $roundrobin->meeting($member, $partner);
			if ($index == 3)
			{"$meeting. As Tester" }
			else { "$meeting. With $_" }
		} @$partners;
		$sched->{$group}->{$member->name . ' ' . $member->{id}}->{$_} =
								0 foreach @keys;
	}
}

foreach my $byer ( @$byes ) 
{
	$sched->{Bye}->{$byer . ' ' . $ids{$byer}} = 3;
}

DumpFile( 'scores.yaml', $sched );

my $scoresheet = io qq/scores.yaml/;
my @lines = $scoresheet->getlines;
'' > $scoresheet;
foreach my $line ( @lines )
{
	if ( $line =~ m/^ *\d\./ )
	{	my $length = length $line;
		my $filler = 13 - $length;
		substr($line, -2)  = ' ' x (24-$length) . "\n";
	}
	$line >> $scoresheet;
}
