package Tennis::Controller::Score;
use Moose;
use namespace::autoclean;

BEGIN {extends 'Catalyst::Controller'; }

=head1 NAME

Tennis::Controller::Score - Catalyst Controller

=head1 DESCRIPTION

Catalyst Controller.

=head1 METHODS

=cut

=head2 setup

=cut

sub setup :Chained('/') :PathPart('score') :CaptureArgs(0) {
	my ( $self, $c ) = @_;
	my $leagueId = $c->session->{league};
	my $playerId = $c->session->{player_id};
	my $roundId = $c->session->{round};
	my $tournament = $c->model('DB::Tournament')->find({id => $leagueId});
	my $league = $c->model('dicDB::League')->find({id => $leagueId});
	my $player = $tournament->members->find($leagueId, $playerId);
	my $table = $player->draws->find($leagueId, $roundId, $playerId)->pair;
	my $round = $tournament->rounds->find({id => $roundId});
	my $exercise = $round->story;
	die unless $player;
	$c->stash( league => $league );
	$c->stash( tournament => $tournament );
	$c->stash( playerId => $playerId );
	$c->stash( player => $player );
	$c->stash( roundId => $roundId );
	$c->stash( round => $round );
	$c->stash( exercise => $exercise );
	$c->stash( table => $table );
}

=head2 match

Find match.

=cut

sub match :Chained('setup') :PathPart('') :CaptureArgs(0) {
	my ($self, $c) = @_;
	my $player = $c->stash->{player};
	my $playerId = $player->profile->id;
	my $league = $c->stash->{league};
	my $round = $c->stash->{round};
	my $roundId = $c->stash->{roundId};
	my $table = $c->stash->{table};
	my $match = $round->matches->find({pair => $table});
	# my $opponent = $player->draws->find({round => $roundId})->opponent;
	$c->stash( match => $match );
	$c->stash( role => $player->draws->find({round => $roundId})->role );
	# $c->stash( opponent => $opponent );
}

=head2 game

Find game.

=cut

sub game :Chained('match') :PathPart('') :CaptureArgs(0) {
	my ($self, $c) = @_;
	my $match = $c->stash->{match};
	my $table = $c->stash->{table};
	my $games = $match->games->search({ pair => $table });
	$c->stash( games => $games );
}

=head2 point

Find point.

=cut

sub point :Chained('game') :PathPart('') :Args(0) {
	my ($self, $c) = @_;
	my $games = $c->stash->{games};
	my $table = $c->stash->{table};
	my $game = $games->search({pair => $table}, { order_by => {
		-desc => 'id'}, rows => 1 })->first;
	my $points = $game->points;
	$c->stash( points => $points );
	$c->stash(template => 'scoreboard.tt2');
}

#=head2 play
#
#Rally, Let, or Fault?
#
#=cut
#
#sub play :Chained('point') :PathPart('') :Args(0) {
#	my ($self, $c) = @_;
#	my $league = $c->stash->{league};
#	my $exercise = $c->stash->{round}->story;
#	$c->stash->{template => 'play/scoreboard.tt2'};
#}



#=head2 index
#
#=cut
#
#sub index :Path :Args(0) {
#    my ( $self, $c ) = @_;
#    $c->response->body('Matched Tennis::Controller::Play in Play.');
#}


=head1 AUTHOR

Dr Bean

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

__PACKAGE__->meta->make_immutable;

1;
