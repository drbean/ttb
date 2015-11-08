package CompComp::Controller::Standings;

use strict;
use warnings;
use parent 'Catalyst::Controller';

use List::Util qw/sum first/;
use IO::All;
use Net::FTP;

=head1 NAME

CompComp::Controller::Standings - Catalyst Controller

=head1 DESCRIPTION

Catalyst Controller to show results of a number of rounds. This could be a Swiss controller, but Swiss is just about pairing, rather than the CompComps themselves.

=head1 METHODS

=cut


=head2 index

http://server.school.edu/comp/standings

Display results up to the present round. TODO Tardy, forfeit points not being shown.

=cut

sub index : Local {
	my ($self, $c) = @_;
	my $tourid = $c->session->{tournament};
	my $tournament = $c->model('SwissDB::Tournaments')->find(
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
	$c->stash->{tournament} = $tourid;
	$c->stash->{roles} = \@Roles;
	$c->stash->{play} = $play;
	$c->stash->{players} = \@players;
	$c->stash->{rounds} = $rounds;
	$c->stash->{template} = "standings.tt2";
	$c->detach('ftp');
}

=head2 ftp

	$self->forward('ftp')

Private method used by standing, history actions to put standings on http://web.nuu.edu.tw/~greg/$tourid/standing.html

=cut

sub ftp : Private {
	my ($self, $c, $round) = @_;
	my $ftp = Net::FTP->new('web.nuu.edu.tw');
	$ftp->login('greg', '6y6t6y6t');
	$ftp->binary;
	my $config = $c->config;
	my $leaguedirs = $config->{leagues};
	my %leaguesByGenre;
	my @genres = qw/conversation business speaking friends customs media multimedia college literature intercultural/;
	$leaguesByGenre{$_} = $config->{ $_ } for @genres;
	my %leaguegenre = map { my $genre = $_ ;  my $leagues = $leaguesByGenre{$genre};
						map { $_ => $genre } @$leagues } @genres;
	my $tourid = $c->stash->{tournament};
	my $genre = $leaguegenre{$tourid};
	$ftp->cwd("/public_html/$tourid/");
	my $standingfile = "$leaguedirs/$tourid/comp/standing.html";
	io($standingfile)->print
		( $c->view('TT')->render($c, 'standings.tt2') );
	$ftp->put($standingfile, "standing.html");
	$c->response->redirect
		("http://web.nuu.edu.tw/~greg/$tourid/standing.html");
}

=head2 history

	http://sac.nuu.edu.tw/comp/standing/17

Need to be able to go back and look at standings without writing database or doing another pairing. Adds 'win', 'forfeit' info unless 'Unknown'.

=cut

sub history : Local {
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


=head1 AUTHOR

Dr Bean,,,

=head1 LICENSE

This library is free software, you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;
