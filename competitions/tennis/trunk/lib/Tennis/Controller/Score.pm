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

sub setup :Chained('/') :PathPart('score') :CaptureArgs(1) {
	my ( $self, $c, $roundId ) = @_;
	my $leagueId = $c->session->{league};
	my $playerId = $c->session->{player_id};
	$roundId ||= $c->session->{round};
	my $tournament = $c->model('DB::Tournament')->find({id => $leagueId});
	my $league = $c->model('dicDB::League')->find({id => $leagueId});
	my $player = $tournament->members->find($leagueId, $playerId);
	my $table = $player->draws->find($leagueId, $roundId, $playerId)->pair;
	my $round = $tournament->rounds->find({id => $roundId});
	my $exercise = $round->story;
	die unless $player;
	my $profile = $player->profile;
	my $playerName = $profile->name;
	$c->stash( league => $league );
	$c->stash( tournament => $tournament );
	$c->stash( playerId => $playerId );
	$c->stash( playerName => $playerName );
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
	my $league = $c->stash->{league};
	my $round = $c->stash->{round};
	my $roundId = $c->stash->{roundId};
	my $table = $c->stash->{table};
	my $match = $round->matches->find({pair => $table});
	my $draw = $player->draws->find({round => $roundId});
	$c->stash( match => $match );
	$c->stash( role => $draw->role );
}

=head2 game

Find game.

=cut

sub game :Chained('match') :PathPart('') :CaptureArgs(0) {
	my ($self, $c) = @_;
	my $match = $c->stash->{match};
	my $table = $c->stash->{table};
	my $started = $match->games->get_column('id')->max;
	my $games = $match->games->search( undef, {order_by =>
		{ -asc => 'id'}});
	$c->stash( games => $games );
	$c->stash( started => $started );
}

=head2 point

Find point.

=cut

sub point :Chained('game') :PathPart('') :CaptureArgs(0) {
	my ($self, $c) = @_;
	my $games = $c->stash->{games};
	my $gamepoints;
	while (my $game = $games->next ) {
		my $gameid = $game->id;	
		$gamepoints->[$gameid] = $game->points->search(undef, {
			order_by => { -asc => 'id' }});
	}
	$c->stash( points => $gamepoints );
	$games->reset;
	$c->stash( games => $games );
}

=head2 play

Rally, Let, or Fault?

=cut

sub play :Chained('point') :PathPart('') :Args(0) {
	my ($self, $c) = @_;
	my $points = $c->stash->{points};
	my ($faults, $lets, $rally);
	for my $game ( 1 .. $#$points ) {
		my @pointIds = $points->[$game]->get_column('id')->all;
		for my $point ( @pointIds ) {
			$faults->{$game}->{$point} = $points->[$game]->find({
				id => $point})->faults->search(undef, {
				order_by => { -asc => 'id' }});
			$lets->{$game}->{$point} = $points->[$game]->find({
				id => $point})->lets->search(undef, {
				order_by => { -asc => 'id' }});
			$rally->{$game}->{$point} = $points->[$game]->find({
				id => $point})->rally;
		}
	}
	$c->stash( faults => $faults );
	$c->stash( lets => $lets );
	$c->stash( rally => $rally );
	$c->stash(template => 'scoreboard.tt2');
}



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
