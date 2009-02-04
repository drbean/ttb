#!/usr/bin/perl

use strict;
use warnings;
use Text::Template;
use IO::All;
use YAML qw/LoadFile/;
use List::MoreUtils qw/zip/;

my $t = Text::Template->new(TYPE=>'FILE', SOURCE=>'./t/703/seats.tmpl', DELIMITERS => ['[*', '*]']);
my $chart;
#for my $k (0..7) {
#	for my $j (0..6) {
#		$seats->{'s'.$j.$k} = { id => $j.$k, name => $j.$k, team => $j.$k};
#	}
#}
my $league = LoadFile './t/703/league.yaml';
my $member = $league->{member};
my %names = map { $_->{name} => $_ } @$member;
my $arrangement = $league->{seats};
my $groups = LoadFile './t/703/groups.yaml';
for my $team ( keys %$arrangement ) {
	my $seats = $arrangement->{$team};
	my @seats = map { "s$_" } @$seats;
	my $member = $groups->{$team};
	for my $number ( 0 .. $#seats ) {
		my $name = $member->[$number];
		my $id = $names{$name}->{id};
		$chart->{$seats[$number]} = { id => $id,
					name => $name,
					team => $team };
		}
	}
my $text = $t->fill_in( HASH => $chart );
io('./t/703/groupseat.tex')->print($text);
