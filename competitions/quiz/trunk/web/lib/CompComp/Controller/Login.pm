package CompComp::Controller::Login;

# Last Edit: 2015 Nov 08, 14:37:21
# $Id$

use strict;
use warnings;
use parent 'Catalyst::Controller';

=head1 NAME

CompComp::Controller::Login - Catalyst Controller

=head1 DESCRIPTION

Catalyst Controller.

=head1 METHODS

=cut


=head2 index

Login logic. We redirect to the quiz, if it appears as the one argument. 'name' is reserved in the stash for the application name. Use 'playername'.

=cut

sub index :Path :Args(0)  {
    my ( $self, $c ) = @_;
    my $id       = $c->request->params->{id}       || "";
    my $name     = $c->request->params->{name}     || "";
    my $password = lc $c->request->params->{password} || "";
    if ( $id && $name && $password ) {
        my $username = $id;
        if ( $c->authenticate( { id => $username, password => $password } ) ) {
            $c->session->{player_id} = $id;
            $c->session->{question} = undef;
            my $officialrole = 1;
            if ( $c->check_user_roles($officialrole) ) {
                $c->stash->{id}   = $id;
                $c->stash->{officialname} = $name;
                $c->stash->{tournaments} =
                  [ $c->model('SwissDB::Tournaments')->search( {} ) ];
                $c->stash->{template} = 'official.tt2';
                return;
            }
            my @memberships =
              $c->model("SwissDB::Members")->search( { player => $id } );
            my @tournaments;
            for my $membership (@memberships) {
                push @tournaments, $membership->tournament;
            }
            unless ( @tournaments == 1 ) {
                $c->stash->{id}         = $id;
                $c->stash->{playername}       = $name;
                $c->stash->{tournaments}   = \@tournaments;
                $c->stash->{template}   = 'membership.tt2';
                return;
            }
            else {
                my $tournamentId   = $tournaments[0]->id;
                $c->session->{tournament}   = $tournamentId;
				if ( defined $c->session->{quiz}) {
					my $quiz = $c->session->{quiz};
					$c->response->redirect(
						$c->uri_for( "/play/update/$quiz" ) );
				}
				else {
					my $draw = $c->model( 'Drawlist', { tournament => $tournamentId } );
					$c->stash->{round} = $draw->[0];
					$c->stash->{game} = $draw->[1];
					$c->stash->{unpaired} = $draw->[2];
					$c->stash->{tournament} = $tournamentId;
					$c->stash->{roles} = [ qw/White Black/ ];
					$c->stash->{template} = 'draw.tt2';
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

=head2 official

Set tournament official is organizing. Use session player_id to authenticate the participant.

=cut

sub official : Local {
	my ($self, $c) = @_;
	my $tournament = $c->request->params->{tournament} || "";
	my $password = lc $c->request->params->{password} || "";
        my $username = $c->session->{player_id};
        if ( $c->authenticate( {id =>$username, password=>$password} ) ) {
		# my $officialrole = "official";
		my $officialrole = 1;
		if ( $c->check_user_roles($officialrole) ) {
			$c->session->{tournament} = $tournament;
			$c->response->redirect($c->uri_for("/standings/index"));
			return;
		}
		else {
		# Set an error message
		$c->stash->{error_msg} = "Bad username or password?";
		$c->stash->{template} = 'login.tt2';
		}
	}
	$c->stash->{template} = 'login.tt2';
}


=head2 membership

Set tournament multi-membership player is participating in.

=cut

sub membership : Local {
	my ($self, $c) = @_;
	my $tournament = $c->request->params->{tournament} || "";
	my $password = $c->request->params->{password} || "";
	$c->session->{tournament} = $tournament;
	$c->session->{quiz} = undef;
	$c->response->redirect( $c->uri_for("/standings/index") );
	return;
}


=head1 AUTHOR

Dr Bean,,,

=head1 LICENSE

This library is free software, you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;
