package Web::Model::Drawlist;

# Last Edit: 2010  2月 13, 14時14分22秒
# $Id$

use strict;
use warnings;

=head1 NAME

Web::Model::Drawlist - With controller context

=head1 DESCRIPTION

Moose role Catalyst::Component::InstancePerContext allows passing of Catalyst controller context.

=cut

use Moose;
with 'Catalyst::Component::InstancePerContext';

require Games::Tournament::Swiss;
require Games::Tournament::Contestant::Swiss;


=head2 drawlist

Get draw table from SwissDB. Method used by login and score actions.

=cut
 
sub drawlist {
	my ($self, $c, $args) = @_;
	my $league = $c->model('SwissDB::Tournaments')->find({ id =>
		$args->{league} });
	my $round = $league->round->round;
	my $opponents = $league->opponents->search({ round => $round });
	my $roles = $league->roles->search({ round => $round });
	my ( @games, @unpaired, %seen );
	while ( my $pair = $opponents->next ) {
		if ( $pair->opponent =~ m/bye/i ) {
			$c->stash->{byegame} = { contestants => {Bye => $pair->ego->name} };
		}
		elsif ( $pair->opponent =~ m/unpaired/i ) {
			push @unpaired, $pair->player;
		}
		else {
			my $player = $pair->ego;
			my $opponent = $pair->other;
			if ( $seen{ $player->id } ) {
				die $player->id . "'s opponent is " . $opponent->id .
				 ", but is " . $opponent->id . "'s opponent " . $player->id .
				 "?" unless $seen{$opponent->id} == 1 and
							 $seen{$player->id} == 1;
				next;
			}
			$seen{$player->id}++;
			$seen{$opponent->id}++;
			my $roleplayer = $roles->find({ player => $player->id })->role;
			my $roleopponent = $roles->find({ player => $opponent->id })->role;
			push @games, { contestants => { $roleplayer => $player,
					$roleopponent => $opponent } };
		}
	}
	return [ $round, \@games, \@unpaired ];
}

=head2 build_per_context_instance

The method that $c->component( 'Drawlist', $args ) will call.

=cut
 
sub build_per_context_instance {
	my ($self, $c, $args) = @_;
	return $self->drawlist( $c, $args );
}


# vim: set ts=8 sts=4 sw=4 noet:

=head1 AUTHOR

A clever guy

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;
