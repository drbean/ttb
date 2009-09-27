package Web::Controller::Login;

use strict;
use warnings;
use parent 'Catalyst::Controller';

=head1 NAME

Web::Controller::Login - Login Controller for Web

=head1 DESCRIPTION

[enter your description here]

=head1 METHODS

=cut

=head2 login

=cut

sub login :Path :Args(0)  {
    my ( $self, $c ) = @_;
    my $id       = $c->request->params->{id}       || "";
    my $name     = $c->request->params->{name}     || "";
    my $password = lc $c->request->params->{password} || "";
    if ( $id && $name && $password ) {
        my $username = $id;
        if ( $c->authenticate( { id => $username, password => $password } ) ) {
            $c->session->{player_id} = $id;
            $c->session->{question} = undef;
            my @memberships =
              $c->model("DB::Members")->search( { player => $id } );
            my @leagues;
            for my $membership (@memberships) {
                push @leagues, $membership->league;
            }
            unless ( @leagues == 1 ) {
                $c->stash->{id}         = $id;
                $c->stash->{name}       = $name;
                $c->stash->{leagues}   = \@leagues;
                $c->stash->{template}   = 'membership.tt2';
                return;
            }
            else {
                $c->session->{league}   = $leagues[0]->id;
		if ( defined $c->session->{exercise}) {
		    my $exercise = $c->session->{exercise};
		    $c->response->redirect(
			$c->uri_for( "/play/update/$exercise" ) );
		}
		else {
			$c->response->redirect( $c->uri_for("/exercises/list") );
		}
		return;
	    }
        }
        else {
            $c->stash->{error_msg} = "Bad username or password.";
        }
    }
    else {
        $c->stash->{error_msg} = "You need id, name and password.";
    }
    $c->stash->{template} = 'login.tt2';
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
