#!/usr/bin/perl

# Last Edit: 2010  2月 27, 13時52分06秒
# $Id$

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
has 'latex' => (traits => ['Getopt'], is => 'ro', isa => 'Bool',
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
	my $leagues = "/home/drbean/class";
	my $leagueId = $script->league;
	my $league = LoadFile "$leagueId/league.yaml";
	my $session = $script->session;
	my $latex = $script->latex;
	my $filetype = $latex? "tex": "html";
	my $fileprefix = $latex? "latex": "html";
	my $room = $league->{room};
	my $rooms = "$leagues/rooms";
	my $roomconfig = LoadFile "$rooms/$room/config.yaml";
	my $groupworkdirs = $league->{groupwork};
	my $sessionpath = "$leagueId/$groupworkdirs";
	my @subdirs = grep { -d } glob "$sessionpath/*";
	my @series = sort { $a <=> $b } map m/^$sessionpath\/(\d+)$/, @subdirs;
	die "No $session session\n" unless any { $_ eq $session } @series;
	my $member = $league->{member};
	die "Not all members have names in $league->{id} league"
		unless all { $_->{name} } @$member;
	my %names = map { $_->{name} => $_ } @$member;
	my $arrangement = $roomconfig->{fours};
	my $groups = LoadFile "$sessionpath/$session/groups.yaml";
	my $chart = { league => $league->{id}, session => $session };
	for my $team ( keys %$arrangement ) {
		my $seats = $arrangement->{$team};
		my @seats = map { "s$_" } @$seats;
		my $member = $groups->{$team};
		unless ( $member ) {
			warn "No $team team in $leagueId league\n";
			next;
		}
		for my $number ( 0 .. $#seats ) {
			my $name = $member->[$number];
			my $id; $id = $names{$name}->{id} if $name;
			warn "$team team member " . ($number+1) .
					" in $seats[$number]?" unless $id;
			$chart->{$seats[$number]} = { id => $id,
						name => $name,
						team => $team };
		}
	}
	my $t = Text::Template->new(TYPE=>'FILE',
		SOURCE=>"$rooms/$room/${fileprefix}seats.tmpl",
						DELIMITERS => ['[*', '*]']);
	my $text = $t->fill_in( HASH => $chart );
	io("$sessionpath/$session/teamseat.$filetype")->print($text);
}
