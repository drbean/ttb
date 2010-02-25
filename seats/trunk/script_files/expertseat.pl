#!/usr/bin/perl

# Last Edit: 2010  2月 25, 09時33分32秒
# $Id: /mi/ttb/seats/trunk/script_files/teamseat.pl 4344 2010-02-20T12:46:04.449172Z drbean  $

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
use List::MoreUtils qw/any all/;
use Cwd;

run() unless caller();

sub run {
	my $script = Script->new_with_options( league => getcwd );
	pod2usage(1) if $script->help;
	pod2usage(-exitstatus => 0, -verbose => 2) if $script->man;
	my $leagueId = $script->league;
	my $league = LoadFile "$leagueId/league.yaml";
	my $session = $script->session;
	my $html = $script->html;
	my $filetype = $html? "html": "tex";
	my $fileprefix = $html? "html": "";
	my $groupworkdirs = $league->{groupwork};
	my $sessionpath = "$leagueId/$groupworkdirs";
	my @subdirs = grep { -d } glob "$sessionpath/*";
	my @series = sort { $a <=> $b } map m/^$sessionpath\/(\d+)$/, @subdirs;
	die "No $session session\n" unless any { $_ eq $session } @series;
	my $member = $league->{member};
	my %names = map { $_->{name} => $_ } @$member;
	my $regions = $league->{regions};
	my $expertseats = $league->{expertseats};
	my $groups = LoadFile "$sessionpath/$session/groups.yaml";
	my $chart;
	for my $region ( keys %$regions ) {
		my $regionalgroups = $regions->{$region};
		my $arrangement = $expertseats->{$region};
		my $order = 0;
		for my $expertgroup ( sort keys %$arrangement ) {
			my $seats = $arrangement->{$expertgroup};
			my @members;
			for my $group ( @$regionalgroups ) {
				my $name = $groups->{$group}->[$order];
				push @members, {
					name => $name,
					id => $names{$name}->{id},
					team => $group } if $name;
			}
			my @seats = map { "s$_" } @$seats;
			for my $number ( 0 .. $#seats ) {
				$chart->{$seats[$number]} = $members[$number];
			}
			$order++;
		}
	}
	my $t = Text::Template->new(TYPE=>'FILE',
		SOURCE=>"$leagueId/${fileprefix}seats.tmpl",
						DELIMITERS => ['[*', '*]']);
	my $text = $t->fill_in( HASH => $chart );
	io("$sessionpath/$session/expertseat.html")->print($text);
	io("$sessionpath/$session/expertseat.$filetype")->print($text);
}
