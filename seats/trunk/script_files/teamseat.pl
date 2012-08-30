#!/usr/bin/perl

# Last Edit: 2012 Aug 30, 11:00:39 AM
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
has 'beancan' => (traits => ['Getopt'], is => 'ro', isa => 'Int',
		cmd_aliases => 'n',);

package main;

use strict;
use warnings;
use Pod::Usage;
use Text::Template;
use IO::All;
use YAML qw/LoadFile/;
use List::Util qw/max/;
use List::MoreUtils qw/any all/;
use Cwd; use File::Basename;
use Net::FTP;
use Grades;
use Encode;

run() unless caller();

sub run {
	my $script = Script->new_with_options( league => basename(getcwd) );
	pod2usage(1) if $script->help;
	pod2usage(-exitstatus => 0, -verbose => 2) if $script->man;
	my $leagues = "/home/drbean/011";
	my $leagueId = $script->league;
	$leagueId = basename( getcwd ) if $leagueId eq '.';
	my $leagueO = League->new( id => $leagueId );
	# my $grades = Grades->new({ league => $leagueO })->grades;
	my $leaguedirs = $leagueO->leagues; 
	my $leaguePath = $leaguedirs . '/'. $leagueId;
	my $league = LoadFile "$leaguePath/league.yaml";
	my $session = $script->session;
	my $latex = $script->latex;
	my $filetype = $latex? "tex": "html";
	my $fileprefix = $latex? "latex": "html";
	my $room = $league->{room};
	my $rooms = "$leagues/rooms";
	my $roomconfig = LoadFile "$rooms/$room/config.yaml";
	my $groupworkdirs = $league->{groupwork};
	my $sessionpath = "$leaguePath/$groupworkdirs";
	my @subdirs = grep { -d } glob "$sessionpath/*";
	my @series = sort { $a <=> $b } map m/^$sessionpath\/(\d+)$/, @subdirs;
	die "No $session session\n" unless any { $_ eq $session } @series;
	my $groups = LoadFile "$sessionpath/$session/groups.yaml";
	my $n = $script->beancan || max map { 
				$#{$groups->{$_}} + 1 } keys %$groups;
	my $member = $league->{member};
	die "Not all members have names in $league->{id} league"
		unless all { $_->{name} } @$member;
	my %names = map { $_->{name} => $_ } @$member;
	my $beancansize = { 3=>'threes', 4=>'fours' }; 
	my $arrangement = $roomconfig->{ $beancansize->{$n} };
	my $colors = $roomconfig->{colors};
	my $regions = $roomconfig->{regions};
	my $expertseats = $roomconfig->{ $beancansize->{$n} . 'experts'};
	my $teamchart = { league => $league->{id}, session => $session };
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
			#my $rating; $rating = $grades->{$id} ||
			#	$names{$name}->{rating} if $name;
			warn "$team team member " . ($number+1) .
					" in $seats[$number]?" unless $id;
			$teamchart->{$seats[$number]} = { id => $id,
						name => $name,
						# rating => $rating,
						color => $colors->{$team} || $team,
						team => $team };
		}
	}
	my $expertchart;
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
				$expertchart->{$seats[$number]} = $members[$number];
			}
			$order++;
		}
	}
	my $web = Net::FTP->new( 'web.nuu.edu.tw' ) or warn "web.nuu?"; 
	$web->login("greg", "") or warn "login: greg?"; 
	$web->cwd( 'public_html' ) or die "No cwd to public_html,"; 
	my $t = Text::Template->new(TYPE=>'FILE',
		SOURCE=>"$rooms/$room/${fileprefix}seats.tmpl",
						DELIMITERS => ['[*', '*]']);
	my $teamtext = $t->fill_in( HASH => $teamchart );

	io("$sessionpath/$session/teamseat.$filetype")->print( encode('UTF-8', $teamtext) );
	$web->put( "$sessionpath/$session/teamseat.$filetype", "${leagueId}f.html" )
			or die "put teamseat.html?" if $filetype eq "html"; 
	my $experttext = encode(
		'UTF-8', $t->fill_in( HASH => $expertchart ) );
	io("$sessionpath/$session/expertseat.$filetype")->print($experttext);
	$web->put( "$sessionpath/$session/expertseat.$filetype",
			"${leagueId}fex.html" ) or die "put expertseat.html?" if $filetype eq "html"; 

}
