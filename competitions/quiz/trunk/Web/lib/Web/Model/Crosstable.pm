package Web::Model::Crosstable;

# Last Edit: 2010  2月 15, 22時15分50秒
# $Id$

use strict;
use warnings;

=head1 NAME

Web::Model::Crosstable - With controller context

=head1 DESCRIPTION

Moose role Catalyst::Component::InstancePerContext allows passing of Catalyst controller context.

=cut

use Moose;
with 'Catalyst::Component::InstancePerContext';

=head2 crosstable

Create crosstable from SwissDB data. Method used by cross(table) action.

=cut
 
sub crosstable {
	my ($self, $c, $args) = @_;
	my $league = $c->model('SwissDB::Tournaments')->find({ id =>
		$args->{league} });
	my $round = $league->round->round;
	my $opponents = $league->opponents->search({ round => $round });
	my $roles = $league->roles->search({ round => $round });
	my $scores = $league->scores;
	my $ratings = $league->ratings->search({ round => $round -1 });
	my ( @games, @lineup, @unpaired, %seen );
	while ( my $pair = $opponents->next ) {
		my $player = $pair->ego;
		my $id = $player->id;
		my $rating = $ratings->find({ player => $id })->value;
		my $score = $scores->find({ player => $id })->score;
		my $swissplayer = Games::Tournament::Contestant::Swiss->new( id => $id,
			name => $player->name, rating => $rating, score => $score );
		if ( $pair->opponent !~ m/unpaired|bye/i ) {
			my $opponent = $pair->other;
			my $oppid = $opponent->id;
			if ( $seen{ $id } ) {
				die "${id}'s opponent is $oppid, but is ${oppid}'s opponent $id?
					" unless $seen{$oppid} == 1 and $seen{$id} == 1;
				next;
			}
			my $swissopponent = Games::Tournament::Contestant::Swiss->new(
				id => $oppid, name => $opponent->name,
					rating => $ratings->find({ player => $oppid })->value,
					score => $scores->find({ player => $oppid })->score );
			push @lineup, $swissplayer, $swissopponent;
			$seen{$id}++;
			$seen{$oppid}++;
			my $roleplayer = $roles->find({ player => $id })->role;
			my $roleopponent = $roles->find({ player => $oppid })->role;
			push @games, { contestants => { $roleplayer => $swissplayer,
					$roleopponent => $swissopponent } };
		}
		elsif ( $pair->opponent =~ m/bye/i ) {
			push @lineup, $swissplayer;
			push @games, { contestants => {Bye => $swissplayer} };
		}
		elsif ( $pair->opponent =~ m/unpaired/i ) {
			push @unpaired, $pair->player;
		}
		else {
			die "$id has no opponent, but no bye and not unpaired.";
		}
	}
	@games = map { Games::Tournament::Card->new( %$_ ) } @games;
	my $tourney = Games::Tournament::Swiss->new( entrants => \@lineup );
	@games = $tourney->orderPairings( @games );
	return [ $round, \@games, \@unpaired ];
}

=head2 build_per_context_instance

The method that $c->component( 'Crosstable', $args ) will call.

=cut
 
sub build_per_context_instance {
	my ($self, $c, $args) = @_;
	return $self->crosstable( $c, $args );
}


# vim: set ts=8 sts=4 sw=4 noet:

=head1 AUTHOR

A clever guy

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;
