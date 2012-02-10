package Tennis::Controller::Login;
use Moose;
use namespace::autoclean;

BEGIN {extends 'Catalyst::Controller'; }

=head1 NAME

Tennis::Controller::Login - Catalyst Controller

=head1 DESCRIPTION

Catalyst Controller.

=head1 METHODS

=cut


=head2 index

=cut

sub index :Path :Args(0) {
	my ( $self, $c ) = @_;
	my $name = $c->request->params->{name};
	my $id = $c->request->params->{id};
	my $password = $c->request->params->{password};
	my $exercise = $c->request->params->{exercise};
	if ($id && $password) {
		if ($c->authenticate({ id => $id,
				  password => $password  } )) {
			$c->session->{player_id} = $id;
			my $officialrole = 1;
			if ( $c->check_user_roles($officialrole) ) {
				$c->stash->{id}   = $id;
				$c->stash->{name} = $name;
				$c->stash->{leagues} =
				  [ $c->model('dicDB::League')->search( {} ) ];
				$c->stash->{template} = 'official.tt2';
				return;
			}
			my @memberships = $c->model("dicDB::Member")->search
				({player => $id});
			my @leagues;
			push @leagues, $_->league for @memberships;
			if ( @leagues != 1 ) {
				$c->stash->{id} = $id;
				$c->stash->{username} = $name;
				$c->stash->{leagues} = \@leagues;
				$c->stash->{template} = 'membership.tt2';
				return;
			}
			else {
				my $league = $leagues[0]->id;
				$c->session->{league} = $league;
				my $round = $c->model("DB::Round")->find({
					tournament => $league})->value;
				$c->session->{round} = $round if defined $round;
				$c->response->redirect($c->uri_for( "/play"));
			}
		} else {
			$c->stash(error_msg =>
				"Bad id or password.");
		}
	} else {
		$c->stash(error_msg =>
			"Empty id or password.")
		unless ($c->user_exists);
	}
	$c->stash(template => 'login.tt2');
}


=head2 official

Set league official is organizing. Use session player_id to authenticate the participant.

=cut

sub official : Local {
	my ($self, $c) = @_;
	my $league = $c->request->params->{league} || "";
	my $jigsawrole = $c->request->params->{jigsawrole} || "";
	my $password = lc $c->request->params->{password} || "";
	my $round = $c->request->params->{round};
	my $username = $c->session->{player_id};
	if ( $c->authenticate( {id =>$username, password=>$password} ) ) {
		# my $officialrole = "official";
		my $officialrole = 1;
		if ( $c->check_user_roles($officialrole) ) {
			$c->session->{league} = $league;
			my $round = $c->model("DB::Round")->search({
				tournament => $league})->value;
			$c->session->{round} = $round if defined $round;
			$c->response->redirect($c->uri_for("/tournament/list"), 303);
			return;
		}
		else {
		# Set an error message
		$c->stash->{error_msg} = "Bad username or password?";
		$c->stash(round => $round);
		$c->stash->{template} = 'login.tt2';
		}
	}
	$c->response->header( 'Cache-Control' => 'no-cache' );
	$c->stash->{template} = 'login.tt2';
}


=head2 membership

Set league multi-membership player is participating in.

=cut

sub membership :Local {
	my ($self, $c) = @_;
	my $league = $c->request->params->{league} || '';
	my $password = $c->request->params->{password} || '';
	my $exercise = $c->request->params->{exercise};
	if ( $league ) {
		$c->session->{league} = $league;
		$c->response->redirect(
			$c->uri_for( "/game" ));
	}
	else {
		$c->stash->{template} = 'login.tt2';
		return;
	}
}


=head1 AUTHOR

Dr Bean

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

__PACKAGE__->meta->make_immutable;

1;
