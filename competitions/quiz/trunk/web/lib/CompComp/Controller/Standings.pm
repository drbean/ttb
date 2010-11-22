package CompComp::Controller::Standings;

use strict;
use warnings;
use parent 'Catalyst::Controller';

use List::Util qw/sum first/;

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
	my $tourid = $c->session->{league};
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
}


=head1 AUTHOR

Dr Bean,,,

=head1 LICENSE

This library is free software, you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;
