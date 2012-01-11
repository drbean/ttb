package CompComp::Controller::Game;

use strict;
use warnings;
use parent 'Catalyst::Controller';

use List::Util qw/sum/;

=head1 NAME

CompComp::Controller::Exercises - Catalyst Controller

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

Fetch all Game objects in the league's genre and pass to quiz/list.tt2 in stash to be displayed

=cut
 
sub list : Local {
    # Retrieve the usual perl OO '$self' for this object. $c is the Catalyst
    # 'Context' that's used to 'glue together' the various components
    # that make up the application
    my ($self, $c) = @_;
    my $leagueid = $c->session->{league};
    my $league = $c->model('DB::Leagues')->find({id=>$leagueid});
    my $genre = $league->genre->data->id;
    $c->stash->{quiz} = [$c->model('DB::Game')->search( { genre => $genre })];
    # Retrieve all of the text records as text model objects and store in
    # stash where they can be accessed by the TT template
    # Set the TT template to use.  You will almost always want to do this
    # in your action methods (actions methods respond to user input in
    # your controllers).
    my $player = $c->session->{player_id};
    #my @play = $c->model('DB::Play')->search(
    #        { league => $leagueid, player => $player },
    #    	{ select => [ 'topic', 'story', { sum => 'correct' } ],
    #    	'group_by' => [qw/topic story/],
    #    	as => [ qw/topic story questions/ ],
    #    	});
    #my %questionscores = map { $_->quiz => $_->get_column('questions') } @play;
    #$c->stash->{questions} = \%questionscores;
    $c->stash->{league} = $league->name;
    $c->stash->{template} = 'quiz/list.tt2';
}


=head2 create

http://server.school.edu/dic/quiz/create/topicId/storyId

Create comprehension questions. The quizId is not the Game result source's primary key. It is not even in there.

=cut

sub create :Global :Args(2)  {
	my ($self, $c, $topic, $story) = @_;
	my $question1 = $c->model('DB::Questions')->search( {
			topic => $topic, story => $story } )->next;
	my $genre = $question1->genre;
	my $description = $question1->description;
	my $quizId = "$topic$story";
	my $quiz = $c->model('DB::Game')->update_or_create({
			genre => $genre,
			topic => $topic,
			story => $story,
			description => $description,
			action => 'False',
			});
	$c->response->redirect($c->uri_for('list',
		   {status_msg => "Game added"}));
}


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


=head1 AUTHOR

Dr Bean,,,

=head1 LICENSE

This library is free software, you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;
