package Web::Controller::Root;

use strict;
use warnings;
use parent 'Catalyst::Controller';

#
# Sets the actions in this controller to be registered with no prefix
# so they function identically to actions created in MyApp.pm
#
__PACKAGE__->config->{namespace} = '';

=head1 NAME

Web::Controller::Root - Root Controller for Web

=head1 DESCRIPTION

[enter your description here]

=head1 METHODS

=cut

=head2 index

=cut

sub index :Path :Args(0) {
    my ( $self, $c ) = @_;

    # Hello World
    $c->response->body( $c->welcome_message );
}

sub default :Path {
    my ( $self, $c ) = @_;
    $c->response->body( 'Page not found' );
    $c->response->status(404);
}

sub auto : Private {
	my ($self, $c) = @_;
	my $quiz = $c->request->query_params->{quiz};
	$c->session->{quiz} = $quiz if $quiz;
	if ($c->controller eq $c->controller('Login')) {
	   return 1;
	}
	if (!$c->user_exists) {
	   $c->log->debug('***Root::auto User not found, forwarding to /login');
	   $c->response->redirect($c->uri_for('/login'));
	   return 0;
       }
       return 1;
}

=head2 end

Attempt to render a view, if needed.

=cut

sub end : ActionClass('RenderView') {}

=head1 AUTHOR

Dr Bean

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;
# vim: set ts=8 sts=4 sw=4 noet:
