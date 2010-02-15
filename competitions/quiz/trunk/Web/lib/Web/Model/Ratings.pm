package Web::Model::Ratings;

# Last Edit: 2010  2月 13, 16時58分32秒
# $Id$

use strict;
use warnings;

=head1 NAME

Web::Model::Ratings - With controller context

=head1 DESCRIPTION

Moose role Catalyst::Component::InstancePerContext allows passing of Catalyst controller context.

=cut

use Moose;
with 'Catalyst::Component::InstancePerContext';

require Games::Tournament::Swiss;
require Games::Tournament::Contestant::Swiss;


=head2 ratings

Get ratings from SwissDB. Do things with them. Put new ones back.

=cut

sub ratings {
	my ($self, $c, $args) = @_;
	my $leagueId = $args->{league};
	my $league = $c->model('SwissDB::Tournaments')->find({ id => $leagueId });
	my $round = $league->round->round - 1;
	my %ratings;
	my $ratings = $league->ratings->search({ round => $round });
	while ( my $rating = $ratings->next ) {
		my $id = $rating->player;
		$ratings{$id} = $rating->value;
	}
	return \%ratings;
}

=head2 build_per_context_instance

The method that $c->component( 'Ratings', $args ) will call.

=cut
 
sub build_per_context_instance {
	my ($self, $c, $args) = @_;
	return $self->ratings( $c, $args );
}


# vim: set ts=8 sts=4 sw=4 noet:

=head1 AUTHOR

A clever guy

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;
