#!/usr/bin/perl 

# Created: 10/29/2017 02:02:50 PM
# Last Edit: 2017 Oct 29, 03:35:51 PM
# $Id$

=head1 NAME

standing.pl - show results of a number of compcomp rounds.

=head1 VERSION

Version 0.01

=cut

our $VERSION = '0.01';

use strict;
use warnings;

=head1 SYNOPSIS

standing.pl -l 2L1a

=cut

use List::Util qw/sum first/;
use IO::All;
use YAML qw/LoadFile/;
use Net::FTP;

use Grades;

=head1 DESCRIPTION

Show standings in a CompComp competition. Display results up to the present round. TODO Tardy, forfeit points not being shown.

This could be a Swiss script, but Swiss is just about pairing, rather than the CompComps themselves.

=cut

my $script = Grades::Script->new_with_options;
my $tourid = $script->league or die "League id?";
my $config = LoadFile "/var/www/cgi-bin/comp/compcomp.yaml";
my $name = $config->{name};
require FindBin;
# FindBin->again;
unshift @INC, "$FindBin::Bin/../lib";
use lib "/home/drbean/swiss/web/lib";
require $name . ".pm";
my $model = "${name}::Schema";
my $modelfile = "$name/Model/DB.pm";
my $modelmodule = "${name}::Model::DB";
my $connect_info = $modelmodule->config->{connect_info};
my $d = $model->connect( @$connect_info );
my $tournament = $d->model('SwissDB::Tournaments')->find(
	{ id => $tourid });
my $rounds = $tournament->round->value;
my $members = $tournament->members;
my @columns = Swiss::Schema::Result::Players->columns;
my (%playerlist, @absentees);
while ( my $member = $members->next ) {
	my $player = { map { $_ => $member->profile->$_ } @columns };
	$player->{firstround} = $member->firstround;
	$player->{score} = $member->score->value if $member->score ;
	my $rating = $member->profile->rating->find({
			tournament => $tourid, round => $rounds-1 });
	$player->{rating} = $rating->value if $rating;
	$playerlist{ $player->{id} } = $player;
	push @absentees, $player if $member->absent eq 'True';
}
my @players = sort { $b->{score} <=> $a->{score} } values %playerlist;
my %position;
@position{ map { $_->{id} } @players } = ( 1 .. @players );
my @Roles = qw/White Black/;
my @roles = map { lcfirst $_ } @Roles;
my $matches = $tournament->matches;
my $play;
for my $round ( 1 .. $rounds ) {
	my @games;
	my @matches = $matches->search({ round => $round })->all;
	for my $match ( @matches ) {
		my %contestant = map { ucfirst($_) =>
						$match->$_ } @roles;
		my %opponent; @opponent{ 'White', 'Black' } =
			@contestant{ 'Black', 'White' };
		if ( $contestant{Black} eq 'Bye' ) {
			$play->{$round}->{ $contestant{White} }
				->{opponent} = 'Bye';
			$play->{$round}->{ $contestant{White} }->{role}
				= 'Bye';
			$play->{$round}->{ $contestant{White} }->{point}
				= 'Bye';
			next;
		}
		my $forfeit = $match->forfeit;
		unless ( $forfeit eq 'None' or $forfeit eq 'Unknown' ) {
			my @forfeiters = $forfeit eq 'Both'? @Roles:
				( $forfeit );
			for ( @forfeiters ) {
				$play->{$round}->{ $contestant{$_} }
					->{opponent} = $position{$opponent{$_}};
				$play->{$round}->{ $contestant{$_} }
					->{role} = $_;
				$play->{$round}->{ $contestant{$_} }
					->{point} = 'Forfeit';
			}
		}
		my $tardy = $match->tardy;
		unless ( $tardy eq 'None' or $tardy eq 'Unknown' ) {
			my @tardies = $tardy eq 'Both'? @Roles:
				( $tardy );
			for ( @tardies ) {
				$play->{$round}->{ $contestant{$_} }
					->{opponent} = $position{$opponent{$_}};
				$play->{$round}->{ $contestant{$_} }
					->{role} = $_;
				$play->{$round}->{ $contestant{$_} }
					->{point} = 'Tardy';
			}
		}
		my $win = $match->win;
		unless ( $win eq 'None' or $win eq 'Unknown' ) {
			my %points = $win eq 'White'?
				( White => 'Win', Black => 'Loss' ):
				$win eq 'Black'?
				( White => 'Loss', Black => 'Win' ):
				$win eq 'Both'?
				( White => 'Draw', Black => 'Draw' ):
				( White => '??', Black => '??' );
			for ( @Roles ) {
				$play->{$round}->{ $contestant{$_} }
				->{opponent} = $position{$opponent{$_}};
			$play->{$round}->{ $contestant{$_} }
				->{role} = $_;
			$play->{$round}->{ $contestant{$_} }
				->{point} = $points{$_};
			}
		}
	}
}

my $stash;
$stash->{tournament} = $tourid;
$stash->{roles} = \@Roles;
$stash->{play} = $play;
$stash->{players} = \@players;
$stash->{rounds} = $rounds;
$stash->{template} = "standings.tt2";

my @genres = qw/conversation business speaking friends customs media multimedia college literature intercultural/;
my %leaguesByGenre;
$leaguesByGenre{$_} = $config->{ $_ } for @genres;
my %leaguegenre = map { my $genre = $_ ;  my $leagues = $leaguesByGenre{$genre};
					map { $_ => $genre } @$leagues } @genres;
my $genre = $leaguegenre{$tourid};

my $leaguedirs = $config->{leagues};
my $standingfile = "$leaguedirs/$tourid/comp/standing.html";
io($standingfile)->print( Template->new({})->process("standings.tt2", $stash ));
ftp( $standingfile );

=head2 ftp


Private method used by standing, history actions to put standings on http://web.nuu.edu.tw/~greg/$tourid/standing.html

=cut

sub ftp {
	my ($standingfile) = @_;
	my $ftp = Net::FTP->new('web.nuu.edu.tw');
	$ftp->login('greg', '');
	$ftp->binary;
	$ftp->cwd("/public_html/$tourid/");
	$ftp->put($standingfile);
}

=head2 history

	http://sac.nuu.edu.tw/comp/standing/17

Need to be able to go back and look at standings without writing database or doing another pairing. Adds 'win', 'forfeit' info unless 'Unknown'.

=cut

sub history {
	my ($self, $c, $round) = @_;
	my $tourid = $c->session->{tournament};
	$round ||= $c->model('DB::Round')->find( { tournament => $tourid } )
			->value;
	my $tournament = $c->model('DB::Tournaments')->find(
		{ id => $tourid });
	my $members = $tournament->members;
	my @columns = Swiss::Schema::Result::Players->columns;
	my (%playerlist, @absentees);
	while ( my $member = $members->next ) {
		my $player = { map { $_ => $member->profile->$_ } @columns };
		$player->{firstround} = $member->firstround;
		my $rating = $member->profile->rating->find({
				tournament => $tourid, round => $round-1 });
		my $value;
		try { $value = $rating->value; }
			catch { warn "No rating for $player->{id}: $_"; };
		$player->{rating} = $value || 0;
		my $score;
		try { $score = $member->score->value; }
			catch { warn "No score for $player->{id}: $_"; };
		$player->{score} = $score || 0;
		$playerlist{ $player->{id} } = $player;
		push @absentees, $player if $member->absent eq 'True';
	}
	my $Roles = $c->model('GTS')->roles;
	my @roles = map { lcfirst $_ } @$Roles;
	my $matches = $tournament->matches->search({ round => $round });
	my %games;
	while ( my $match = $matches->next ) {
		my %contestants;
		if ( $match->black eq 'Bye' ) {
			my $byer = $match->white;
			$contestants{Bye} = $playerlist{ $byer };
		}
		else {
			%contestants = map { ucfirst($_) =>
				$playerlist{ $match->$_ } } @roles;
		}
		my $table = $match->pair;
		$games{$table} = {contestants => \%contestants,
				win => $match->win,
				forfeit => $match->forfeit };
	}
	my @games = map $games{$_}, sort {$a<=>$b} keys %games;
	$c->stash->{tournament} = $tourid;
	$c->stash->{round} = $round;
	$c->stash->{roles} = $Roles;
	$c->stash->{games} = \@games;
	$c->stash->{template} = "standings.tt2";
	$c->detach('ftp');
}


1;

=head1 AUTHOR

Dr Bean C<< <drbean at cpan, then a dot, (.), and org> >>

=head1 COPYRIGHT & LICENSE

Copyright 2017 Dr Bean, all rights reserved.

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.

=cut

# End of standing.pl

# vim: set ts=8 sts=4 sw=4 noet:


