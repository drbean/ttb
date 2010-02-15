package Web::Controller::Quiz;

use strict;
use warnings;
use parent 'Catalyst::Controller';

use List::Util qw/sum/;

=head1 NAME

dic::Controller::Exercises - Catalyst Controller

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

Fetch all Quiz objects in the league's genre and pass to quiz/list.tt2 in stash to be displayed

=cut
 
sub list : Local {
    # Retrieve the usual perl OO '$self' for this object. $c is the Catalyst
    # 'Context' that's used to 'glue together' the various components
    # that make up the application
    my ($self, $c) = @_;
    my $leagueid = $c->session->{league};
    my $league = $c->model('DB::Leagues')->find({id=>$leagueid});
    my $genre = $league->genre->genre->id;
    $c->stash->{quiz} = [$c->model('DB::Quiz')->search( { genre => $genre })];
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

Create comprehension questions. The quizId is not the Quiz result source's primary key. It is not even in there.

=cut

sub create : Local {
	my ($self, $c, $topic, $story) = @_;
	my $question1 = $c->model('DB::Questions')->search( {
			topic => $topic, story => $story } )->next;
	my $genre = $question1->genre;
	my $description = $question1->description;
	my $quizId = "$topic$story";
	my $quiz = $c->model('DB::Quiz')->update_or_create({
			genre => $genre,
			topic => $topic,
			story => $story,
			description => $description,
			action => 'False',
			});
	$c->response->redirect($c->uri_for('list',
		   {status_msg => "Quiz added"}));
}


=head2 record

Record answers, show a page as record. Fail if quiz has been deleted.

=cut
 
sub record : Local {
	my ($self, $c, $topic, $story) = @_;
	my $player = $c->session->{player_id};
	my $target = $c->model('DB::Jigsawroles')->find({ player => $player });
	my $targetId = $target? $target->role: 'all';
	my $leagueId = $c->session->{league};
	my $genre = $c->model("DB::Leaguegenre")->find(
			{ league => $leagueId } )->genre;
	my $quiz = $genre->quiz->find({ topic => $topic, story => $story});
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
	$c->stash->{target} = $targetId;
	$c->stash->{template} = "record.tt2";
}


=head2 tally

Tally correct answers, show a results page

=cut
 
sub tally : Local {
	my ($self, $c, $topic, $story) = @_;
	my $player = $c->session->{player_id};
	my $target = $c->model('DB::Jigsawroles')->find({ player => $player });
	my $targetId = $target? $target->role: 'all';
	my $leagueId = $c->session->{league};
	my $genre = $c->model("DB::Leaguegenre")->find(
			{ league => $leagueId } )->genre;
	my $questions = $genre->questions->search(
		{ topic => $topic, story => $story } );
	my @quiz;
	while ( my $q = $questions->next ) {
		push @quiz, { content => $q->content, id => $q->id, };
	}
	my @quizids = map { $_->{id} } @quiz;
	my ($tallies, %totals, @playerids);
	my $league = $c->model('DB::Leagues')->find({ id => $leagueId });
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
	$c->stash->{round} = $round;
	$c->stash->{quiz} = \@quiz;
	$c->stash->{tallies} = $tallies;
	$c->stash->{totals} = \%questiontotals;
	$c->stash->{genre} = $genre->name;
	$c->stash->{target} = $targetId;
	$c->stash->{template} = "tallies.tt2";
}


=head2 score

Compare number of correct answers of pairs, choose winners/losers, show a results page

=cut
 
sub score : Local {
	my ($self, $c, $topic, $story) = @_;
	my $player = $c->session->{player_id};
	my $target = $c->model('DB::Jigsawroles')->find({ player => $player });
	my $targetId = $target? $target->role: 'all';
	my $leagueId = $c->session->{league};
	$c->stash->{league} = $leagueId;
	my $genre = $c->model("DB::Leaguegenre")->find(
			{ league => $leagueId } )->genre;
	my $questions = $genre->questions->search(
		{ topic => $topic, story => $story } );
	my @quiz;
	while ( my $q = $questions->next ) {
		push @quiz, { content => $q->content, id => $q->id, };
	}
	my @quizids = map { $_->{id} } @quiz;
	my ($tallies, %totals, @playerids);
	my $league = $c->model('DB::Leagues')->find({ id => $leagueId });
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
	$c->forward( 'drawlist' );
	my $games = $c->stash->{game};
	my @games;
	for my $game ( @$games ) {
		my $players = $game->{contestants};
		my ( $role, $us ) = each %$players;
		die "No $player quiz tally?" unless exists $tallies->{$player};
		my ( $otherrole, $them ) = each %$players;
		my $ourcorrect = $tallies->{$us}->{total};
		die "No $them card against $us?" unless exists
						$tallies->{$them};
		my $theircorrect = $tallies->{$them}->{total};
		my ( $ourpoints, $theirpoints );
		if ( not defined $ourcorrect ) {
			$ourpoints = 0;
			$theirpoints = defined $theircorrect? 5: 0;
		}
		elsif ( not defined $theircorrect ) {
			$ourpoints = 5;
			$theirpoints = 0;
		}
		else {
			$ourpoints = $ourcorrect > $theircorrect? 5:
					$ourcorrect < $theircorrect? 3: 4;
			$theirpoints = $ourcorrect > $theircorrect? 3:
					$ourcorrect < $theircorrect? 5: 4;
		}
		push @games, { contestants => { $role => $us, $otherrole => $them },
					results => { $role => $ourpoints, 
				 $otherrole => $theirpoints } };
	}
	my $byegame = $c->stash->{byegame};
	push @games, $byegame if defined $byegame;
	$c->stash->{topic} = $topic;
	$c->stash->{story} = $story;
	$c->stash->{game} = \@games;
	$c->stash->{roles} = [ qw/White Black/ ];
	$c->stash->{genre} = $genre->name;
	$c->stash->{target} = $targetId;
	$c->stash->{template} = "scores.tt2";
}


=head2 drawlist

Get draw table from SwissDB. Method used by login and score actions.

=cut
 
sub drawlist : Private {
	my ($self, $c) = @_;
	my $league = $c->model('SwissDB::Tournaments')->find({ id =>
		$c->stash->{league} });
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
	$c->stash->{unpaired} = \@unpaired;
	$c->stash->{round} = $round;
	$c->stash->{game} = \@games;
}


=head2 ratings

Get ratings from SwissDB. Do things with them. Put new ones back.

=cut

sub ratings : Local {
	my ($self, $c) = @_;
	my $league = $c->model('SwissDB::Tournaments')->find({ id =>
		$c->stash->{league} });
	my $round = $league->round->round - 1;
	my %ratings;
	my $ratings = $league->ratings->search({ tournament => $c->stash->{league},
			round => $round });
	while ( my $rating = $ratings->next ) {
		my $id = $rating->player;
		$ratings{$id} = $rating->value;
	}
	$c->stash->{rating} = \%ratings;
}


=head2 delete

Delete a quiz. Delete of Questions done here too.

=cut

sub delete : Local {
	my ($self, $c, $topic, $story) = @_;
	my $quiz = $c->model('DB::Quiz')->find({
			topic => $topic, story => $story });
	$quiz->delete;
	$c->response->redirect($c->uri_for('list',
		   {status_msg => "Quiz deleted."}));
}


=head2 index 

=cut

sub index : Private {
    my ( $self, $c ) = @_;

    $c->response->body('Matched dic::Controller::Players in Players.');
}


=head1 AUTHOR

Dr Bean,,,

=head1 LICENSE

This library is free software, you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;
