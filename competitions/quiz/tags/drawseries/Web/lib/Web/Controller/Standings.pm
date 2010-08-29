package Web::Controller::Standings;

use strict;
use warnings;
use parent 'Catalyst::Controller';

use List::Util qw/sum/;

=head1 NAME

Web::Controller::Standings - Catalyst Controller

=head1 DESCRIPTION

Catalyst Controller to show results of a number of rounds. This could be a Swiss controller, but Swiss is just about pairing, rather than the CompComps themselves.

=head1 METHODS

=cut


=head2 index

http://server.school.edu/comp/standings

Display results up to the present round.

=cut

sub index : Local {
	my ($self, $c) = @_;
	my $tourid = $c->session->{league};
	my $tournament = $c->model('SwissDB::Tournaments')->find(
		{ id => $tourid });
	my $round = $tournament->round->value;
	my $members = $tournament->members;
	my @columns = Swiss::Schema::Result::Players->columns;
	my (%playerlist, @absentees);
	while ( my $member = $members->next ) {
		my $player = { map { $_ => $member->profile->$_ } @columns };
		$player->{firstround} = $member->firstround;
		my $rating = $member->profile->rating->find({
				tournament => $tourid, round => $round-1 });
		$player->{rating} = $rating->value;
		$playerlist{ $player->{id} } = $player;
		push @absentees, $player if $member->absent eq 'True';
	}
	my @Roles = qw/White Black/;
	my @roles = map { lcfirst $_ } @Roles;
	my $matches = $tournament->matches;
	my $games;
	for my $round ( 1 .. $round ) {
		my @games;
		my $matches = $matches->search({ round => $round });
		while ( my $match = $matches->next ) {
			my %contestants = map { ucfirst($_) =>
				$playerlist{ $match->$_ } } @roles;
			push @games, {contestants => \%contestants,
					win => $match->win,
					forfeit => $match->forfeit };
		}
		$games->{$round} = \@games;
	}
	$c->stash->{tournament} = $tourid;
	$c->stash->{roles} = \@Roles;
	$c->stash->{games} = $games;
	$c->stash->{template} = "standings.tt2";
}


=head1 AUTHOR

Dr Bean,,,

=head1 LICENSE

This library is free software, you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;
