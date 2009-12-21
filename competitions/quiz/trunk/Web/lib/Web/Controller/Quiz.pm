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
	my $opponents = $c->model('SwissDB::Opponents')->search({
			round => 1, tournament => $leagueId });
	my $roles = $c->model('SwissDB::Roles')->search({
			round => 1, tournament => $leagueId });
	my ($points, %opponents, %roles, %parity,
		$byegame, $lategames, $unpairedgames);
	while ( my $pair = $opponents->next ) {
		if ( $pair->opponent =~ m/bye/i ) {
			my $player = $pair->player;
			$points->{$player} = 5;
			$byegame = { contestants => {Bye => $player },
				results => { 'Bye' => $points->{$player} } };
		}
		elsif ( $pair->opponent =~ m/late/i ) {
			my $unpaired = $pair->opponent;
			for my $unpaired ( @$unpaired ) {
				$points->{$unpaired} = 1;
			}
		}
		elsif ( $pair->opponent =~ m/unpaired/i ) {
			my $unpaired = $pair->opponent;
			for my $unpaired ( @$unpaired ) {
				$points->{$unpaired} = 0;
			}
		}
		else {

			my $player = $pair->player;
			my $opponent = $pair->opponent;
			$opponents{$player} = $opponent;
			$opponents{$opponent} = $player;
			$parity{$player}++;
			$parity{$opponent}++;
			$roles{$player} = $roles->find({
					player => $player })->role;
			$roles{$opponent} = $roles->find({
					player => $opponent })->role;
		}
	}
	my ($game, %seen);
	for my $player ( keys %opponents ) {
		next if $seen{$player};
		my $opponent = $opponents{$player};
		die
"${player}'s opponent is $opponent, but is ${opponent}'s opponent $player?"
			unless $parity{$opponent} == 2 and
				$parity{$player} == 2;
		die "No $player quiz tally?" unless exists $tallies->{$player};
		my $ourcorrect = $tallies->{$player}->{total};
		die "No $opponent card against $player?" unless exists
						$tallies->{$opponent};
		my $theircorrect = $tallies->{$opponent}->{total};
$DB::single=1;
		if ( not defined $ourcorrect ) {
			$points->{$player} = 0;
			$points->{$opponent} = defined $theircorrect? 5: 0;
		}
		elsif ( not defined $theircorrect ) {
			$points->{$player} = 5;
			$points->{$opponent} = 0;
		}
		else {
			$points->{$player} = $ourcorrect > $theircorrect? 5:
					$ourcorrect < $theircorrect? 3: 4;
			$points->{$opponent} = $ourcorrect > $theircorrect? 3:
					$ourcorrect < $theircorrect? 5: 4;
		}
		my %rolepair = ( $player => $roles{$player},
				$opponent => $roles{$opponent});
		my %role2player = reverse %rolepair;
		push @$game, { contestants => { White => $role2player{White},
						Black => $role2player{Black} },
			results => { White => $points->{$role2player{White}}, 
				 Black => $points->{$role2player{Black}} } };
		$seen{$opponent} = 1;
	}
	push @$game, $byegame if defined $byegame;
	$c->stash->{game} = $game;
	$c->stash->{roles} = [ qw/White Black/ ];
	$c->stash->{points} = $points;
	$c->stash->{genre} = $genre->name;
	$c->stash->{target} = $targetId;
	$c->stash->{template} = "scores.tt2";
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
