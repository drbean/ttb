package Tennis::Controller::Tournament;
use Moose;
use namespace::autoclean;

BEGIN {extends 'Catalyst::Controller'; }

use DateTime;

=head1 NAME

CompComp::Controller::Tournament - Catalyst Controller

=head1 DESCRIPTION

Catalyst Controller.

=head1 METHODS

=cut


=head2 form_create

Display form to collect information for quiz to create

=cut

sub form_create : Local {
	my ($self, $c) = @_;
	$c->stash->{template} = 'quiz/form_create.tt2';
}


=head2 list

Fetch all Round objects in the tournament and pass to quiz/list.tt2 in stash to be displayed

=cut
 
sub list : Local {
    my ($self, $c) = @_;
    my $leagueId = $c->session->{league};
    my $league = $c->model('dicDB::League')->find({id=>$leagueId});
    my $field = $league->field;
    $c->stash->{round} = [$c->model('DB::Rounds')->search({
	    league => $leagueId })];
    my $player = $c->session->{player_id};
    $c->stash->{league} = { name => $league->name, id => $leagueId,
	    description => $field };
    $c->stash->{template} = 'tournament/rounds.tt2';
}


=head2 create

http://server.school.edu/tennis/create/exerciseId/roundId

Create next tennis tournament round using swiss roundId pairing and exerciseId Bett based content.

=cut

sub create :Global :Args(2)  {
	my ($self, $c, $storyId, $round) = @_;
	my $league = $c->session->{league};
	my @swiss = $c->model("SwissDB::Matches")->search({
		tournament => $league, round => $round });
	die "No pairings in round $round in $league tournament" unless
		@swiss;
	my @draw = ( [ qw/tournament round player pair role opponent/ ] );
	my @matches = ( [ qw/league round pair winner forfeit/ ] );
	my @games = ( [qw/league round pair id serverpoints receiverpoints winner/] );
	my @points = ( [qw/league round pair game id winner/] );
	for my $match ( @swiss ) {
		my $table = $match->pair;
		my $w = $match->white;
		my $b = $match->black;
		push @draw,	[ $league, $round, $w, $table, 'White', $b ],
				[ $league, $round, $b, $table, 'Black', $w ];
		push @matches,
			[ $league, $round, $table, 'Unknown', 'Unknown'];
		push @games, [ $league, $round, $table, 1, 0, 0, 'Unknown' ];
		push @points, [ $league, $round, $table, 1, 1, 'Unknown' ];
	}
	$c->model('DB::Point')->populate(\@points);
	$c->model('DB::Game')->populate(\@games);
	$c->model('DB::Match')->populate(\@matches);
	$c->model("DB::Draw")->populate(\@draw);
	my $now = DateTime->now( time_zone => 'local' );
	$c->model('DB::Rounds')->update_or_create({
			league => $league,
			story => $storyId,
			id => $round,
			swissround => $round,
			start => $now,
			stop => $now->clone->add( days => 5),
			# stop => time+3600*24*7,
			});
	$c->stash( {status_msg =>
		"Round $round in the $league league added.\n"});
	$c->detach('list');
}

=head2 go

http://server.school.edu/tennis/go/roundId

Allow play action to take/show questions.

=cut

sub go : Global :Args(1) {
	my ($self, $c, $roundId) = @_;
	my $leagueId = $c->session->{league};
	my $round = $c->model('DB::Rounds')->find({
		league => $leagueId, id => $roundId });
	$c->stash->{error_msg} =
		"No Round $roundId yet created." unless $round;
	if ( $round ) {
		$c->model("DB::Round")->update_or_create({
		tournament => $leagueId, value => $roundId }) ;
		$c->stash( {status_msg =>
			"Round $roundId in the $leagueId league has started.\n"});
	}
	$c->detach('list');
}


=head2 stop

http://server.school.edu/tennis/stop/roundId

Deny play action to take/show questions.

=cut

sub stop : Global :Args(1) {
	my ($self, $c, $roundId) = @_;
	my $leagueId = $c->session->{league};
	my $round = $c->model('DB::Round')->find({ tournament => $leagueId});
	$c->stash->{error_msg} =
		"No Round $roundId yet created, or already 0."
			unless $round and $round->value;
	if ( $round ) {
		$c->model("DB::Round")->update_or_create({
		tournament => $leagueId, value => 0 }) ;
		$c->stash( {status_msg =>
			"Round $roundId in the $leagueId league now stopped.\n"});
	}
	$c->detach('list');
}


use orz;

=head2 record

Record answers, show a page as record. Fail if quiz has been deleted.

=cut
 
sub record :Global :Args(2)  {
	my ($self, $c, $topic, $story) = @_;
	my $player = $c->session->{player_id};
	my $leagueId = $c->session->{league};
    my $league = $c->model('DB::Leagues')->find({ id => $leagueId });
	my $genre = $league->genre->data;
	my $quiz = $genre->quiz->find({ topic => $topic, story => $story });
	my $questions = $quiz->questions;
	my ($record, @popquestions);
	while ( my $question = $questions->next ) {
		my $qid = $question->id;
		my $response = $c->request->params->{$qid};
		if ( my $played = $question->played->find({ player => $player,
				league => $leagueId }) ) {
			$record->{$qid} = { id => $question->id,
				content => $question->content,
				response => $played->response,
				newresponse => $response
			};
			$c->stash->{error_msg} =
		"You already submitted your answers. They cannot be changed.";
		}
		elsif ( $quiz->action eq 'False' ) {
			$record->{$qid} = { id => $question->id,
				content => $question->content,
				response => '',
			};
			$c->stash->{error_msg} =
"Too late. The $topic$story quiz has closed. You cannot submit answers.";
		}
		else {
			my $correct = $response eq $question->answer? 1: 0;
			$record->{$qid} = { id => $qid,
				content => $question->content,
				response => $response, };
			push @popquestions, { league => $leagueId,
				player => $player, topic => $topic,
				story => $story, question => $qid,
				response => $response };
		}
	}
	$c->model('DB::Play')->populate( \@popquestions ) if @popquestions;
	$c->stash->{questions} = $record;
	$c->stash->{genre} = $genre->name;
	$c->stash->{template} = "record.tt2";
}


=head2 tally

Tally correct answers, show a results page

=cut
 
sub tally :Global :Args(2)  {
	my ($self, $c, $topic, $story) = @_;
	my $leagueId = $c->session->{league};
    my $league = $c->model('DB::Leagues')->find({ id => $leagueId });
	my $genre = $league->genre->data;
	my $quiz = $genre->quiz->find({ topic => $topic, story => $story });
	my $questions = $quiz->questions;
	my @quiz;
	while ( my $q = $questions->next ) {
		push @quiz, { content => $q->content, id => $q->id, };
	}
	my @quizids = map { $_->{id} } @quiz;
	my ($tallies, %totals, @playerids);
	my $players = $league->members;
	while ( my $player = $players->next ) {
		my $pid = $player->profile->id;
		push @playerids, $pid;
		my $played = $player->play->search({
				topic => $topic, story => $story });
		while (my $question = $played->next ) {
			my $profile = $question->profile;
			my $qid = $profile->id;
			my $correct = $profile->answer eq $question->response?
					1: 0;
			$tallies->{$pid}->{$qid} = $correct;
		}
		$tallies->{$pid}->{total} = sum map { $tallies->{$pid}->{$_} }
					keys %{ $tallies->{$pid} };
	}
	my %questiontotals;
	for my $qid ( @quizids ) {
		for my $pid ( @playerids ) {
			next unless defined $tallies->{$pid}->{$qid};
			$questiontotals{$qid} += $tallies->{$pid}->{$qid};
		}
	}
	my $round = $c->model('SwissDB::Round')->find({ tournament => $leagueId
			})->round;
	$c->stash->{league} = $leagueId;
	$c->stash->{topic} = $topic;
	$c->stash->{story} = $story;
	$c->stash->{quiz} = \@quiz;
	$c->stash->{tallies} = $tallies;
	$c->stash->{totals} = \%questiontotals;
	$c->stash->{genre} = $genre->name;
	$c->stash->{template} = "tallies.tt2";
}


=head2 score

Compare number of correct answers of pairs, choose winners/losers, show a results page

=cut
 
sub score :Global :Args(2)  {
	my ($self, $c, $topic, $story) = @_;
	my $leagueId = $c->session->{league};
	$c->stash->{league} = $leagueId;
    my $league = $c->model('DB::Leagues')->find({ id => $leagueId });
	my ($tallies, %totals, @playerids);
	my $players = $league->members;
	while ( my $player = $players->next ) {
		my $pid = $player->profile->id;
		push @playerids, $pid;
		my $played = $player->play->search({
				topic => $topic, story => $story });
		while (my $question = $played->next ) {
			my $profile = $question->profile;
			my $qid = $profile->id;
			my $correct = $profile->answer eq $question->response?
					1: 0;
			$tallies->{$pid}->{$qid} = $correct;
		}
		$tallies->{$pid}->{total} = sum map { $tallies->{$pid}->{$_} }
					keys %{ $tallies->{$pid} };
	}
	my $draw = $c->model( 'Drawlist', { league => $leagueId } );
	$c->stash->{round} = $draw->[0];
	my $games = $draw->[1];
	$c->stash->{unpaired} = $draw->[2];
	my $roles = [ qw/White Black/ ];
	my @games;
	for my $game ( @$games ) {
		my $players = $game->contestants;
		my $role = exists $players->{$roles->[0]}? $roles->[0]: "Bye";
		my $us = $players->{$role};
		my $ourid = $us->id;
		die "No $ourid player quiz tally?" unless exists $tallies->{$ourid};
		my $ourcorrect = $tallies->{$ourid}->{total};
		my $otherrole = $roles->[1];
		my $them = $players->{$otherrole};
		my $theirid; $theirid = $them->id if defined $them;
		die "No $them tally against $us?" unless defined $theirid and exists
						$tallies->{$theirid} or $role eq 'Bye';
		my $theircorrect; $theircorrect = $tallies->{$theirid}->{total}
			if defined $theirid;
		my ( $ourpoints, $theirpoints, $result );
		if ( $role eq 'Bye' ) {
			$ourpoints = 5;
			$result = 'Bye'
		}
		elsif ( not defined $ourcorrect ) {
			$ourpoints = 0;
			$theirpoints = defined $theircorrect? 5: 0;
			$result = defined $theircorrect? 'Forfeit:Win': 'Forfeit:Forfeit';
		}
		elsif ( not defined $theircorrect ) {
			$ourpoints = 5;
			$theirpoints = 0;
			$result = "Win:Forfeit";
		}
		else {
			$ourpoints = $ourcorrect > $theircorrect? 5:
					$ourcorrect < $theircorrect? 3: 4;
			$theirpoints = $ourcorrect > $theircorrect? 3:
					$ourcorrect < $theircorrect? 5: 4;
			$result = $ourcorrect > $theircorrect? "Win:Loss":
					$ourcorrect < $theircorrect? "Loss:Win": "Draw:Draw";
		}
		my $game = { contestants => $game->contestants, result => $result,
					scores => { $role => $ourpoints, } };
		$game->{scores}->{$otherrole} = $theirpoints if $otherrole;
		push @games, $game;
	}
	$c->stash->{topic} = $topic;
	$c->stash->{story} = $story;
	$c->stash->{game} = \@games;
	$c->stash->{roles} = $roles;
	$c->stash->{template} = "scores.tt2";
}


=head2 crosstable

Compare number of correct answers of pairs, choose winners/losers, show a results page

=cut
 
sub crosstable :Path('/cross') :Args(1)  {
	my ( $self, $c, $leagueId ) = @_;
    my $league = $c->model('DB::Leagues')->find({ id => $leagueId });
	my $crosstable = $c->model( 'Crosstable', { league => $league } );
}


=head2 delete

Delete a quiz. Delete of Questions done here too.

=cut

sub delete :Global :Args(2)  {
	my ($self, $c, $topic, $story) = @_;
	my $quiz = $c->model('DB::Game')->find({
			topic => $topic, story => $story });
	$quiz->delete;
	$c->response->redirect($c->uri_for('list',
		   {status_msg => "Game deleted."}));
}


=head2 index 

=cut

sub index : Private {
    my ( $self, $c ) = @_;

    $c->response->body('Matched CompComp::Controller::Players in Players.');
}

no orz;

=head1 AUTHOR

Dr Bean

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

__PACKAGE__->meta->make_immutable;

1;
