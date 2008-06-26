#!/usr/bin/perl

use strict;
use warnings;

use YAML qw/ LoadFile DumpFile /;
use IO::All;

die "scores.yaml scoresheet already exists: $!\n" if -e 'scores.yaml';

my @yaml = glob "*.yaml";
# die if $#yaml;

# my $examfile = "$yaml[0]";
my $examfile = "./round.yaml";
my $exam = LoadFile( $examfile );
my $league = LoadFile( "../league.yaml" );
my @members = @{$league->{member}};
my %ids = map { $_->{name} => $_->{id} } @members;
my %names = map { $_->{id} => $_->{name} } @members;

my $sched;
my $groups = $exam->{group};

# my @number = qw/First Second Third Fourth Fifth Sixth/;
my @number = qw/1 2 3 4 5 6 7 8 9/;

GROUP: foreach my $groupNumber ( keys %$groups )
{
	my $group = $groups->{$groupNumber};
	if ($groupNumber eq 'absent') {
		$sched->{Absent} = $group;
		next;
	}
	local $YAML::SortKeys = 0;
	my @roles =  sort keys %$group; 
	if ( grep { $_ eq "Bye" } keys %$group)
	{
		for my $byer ( values %$group )
		{
			$sched->{$groupNumber}->{Bye}->{$byer} = "Bye";
		}
		next GROUP;
	}
	my %rolequestions = ( $roles[0] => [ 4..7,8, ], $roles[1] => [ 0..3,8 ] );
	map
	{
		my $name = $group->{$_};
		$sched->{$groupNumber}->{$_}->{$name} = 0;
		for my $question ( @{$rolequestions{$_}} )
		{
			# $sched->{$groupNumber}->{$_}->{"question$number[$question]"} = 0;
			$sched->{$groupNumber}->{$_}->{correct} = 0;
		}
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
