#!/usr/bin/perl

package Script;
use strict;
use warnings;
use Moose;
with 'MooseX::Getopt';

has 'man' => (is => 'ro', isa => 'Bool');
has 'help' => (is => 'ro', isa => 'Bool');
has 'league' => (traits => ['Getopt'], is => 'ro', isa => 'Str',
		cmd_aliases => 'l',);
has 'session' => (traits => ['Getopt'], is => 'ro', isa => 'Str',
		cmd_aliases => 's',);
has 'html' => (traits => ['Getopt'], is => 'ro', isa => 'Bool',
		cmd_aliases => 'h',);


package main;

use strict;
use warnings;
use Pod::Usage;
use Text::Template;
use IO::All;
use YAML qw/LoadFile/;
use List::MoreUtils qw/any/;
use Cwd;

run() unless caller();


sub run {
	my $script = Script->new_with_options( league => getcwd );
	pod2usage(1) if $script->help;
	pod2usage(-exitstatus => 0, -verbose => 2) if $script->man;
	my $leagueId = $script->league;
	my $league = LoadFile "$leagueId/league.yaml";
	my $session = $script->session;
	my $filetype = $script->html? "html": "tex";
	my $series = $league->{series};
	die "No $session session\n" unless any { $_ eq $session } @$series;
	my $member = $league->{member};
	my %names = map { $_->{name} => $_ } @$member;
	my $arrangement = $league->{seats};
	my $groups = LoadFile "$leagueId/$session/groups.yaml";
	my $chart = { league => $league->{id}, session => $session };
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
	my $t = Text::Template->new(TYPE=>'FILE',
		SOURCE=>"$leagueId/seats.tmpl", DELIMITERS => ['[*', '*]']);
	my $text = $t->fill_in( HASH => $chart );
	io("$leagueId/$session/teamseat.$filetype")->print($text);
}
