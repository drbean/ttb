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
my $regions = $league->{regions};
my $expertseats = $league->{expertseats};
my $groups = LoadFile './t/703/groups.yaml';
for my $region ( keys %$regions ) {
	my $regionalgroups = $regions->{$region};
	my $arrangement = $expertseats->{$region};
	my $order = 0;
	for my $expertgroup ( sort keys %$arrangement ) {
		my $seats = $arrangement->{$expertgroup};
		my @members = map { my $name = $groups->{$_}->[$order]; {
			name => $name,
			id => $names{$name}->{id},
			team => $_ }			} @$regionalgroups;
		my @seats = map { "s$_" } @$seats;
		for my $number ( 0 .. $#seats ) {
			$chart->{$seats[$number]} = $members[$number];
		}
		$order++;
	}
}
my $text = $t->fill_in( HASH => $chart );
io('./t/703/expertseat.tex')->print($text);
