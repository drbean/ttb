package Web::Controller::Play;

use strict;
use warnings;
use parent 'Catalyst::Controller';

use List::Util qw/sum/;

=head1 NAME

Web::Controller::Play - Catalyst Controller

=head1 DESCRIPTION

Catalyst Controller.

=head1 METHODS

=cut


=head2 start

Show a created quiz from the database.

=cut
 
sub start : Local {
	my ($self, $c, $topic, $story) = @_;
	my $questions = $c->model('DB::Questions')->search({
		topic => $topic, story => $story });
	my @questions;
	while ( my $q = $questions->next ) {
		push @questions, { content => $q->content, id => $q->id, };
	}
	$c->stash->{topic} = $topic;
	$c->stash->{story} = $story;
	$c->stash->{questions} = \@questions;
    $c->stash->{template} = 'play.tt2';
}


=head2 check

Check answers, show a page as record.

=cut
 
sub check : Local {
	my ($self, $c, $topic, $story) = @_;
	my $player = $c->session->{player_id};
	my $target = $c->model('DB::Jigsawroles')->find({ player => $player });
	my $targetId = $target? $target->role: 'all';
	my $leagueId = $c->session->{league};
	my $genre = $c->model("DB::Leaguegenre")->find(
			{ league => $leagueId } )->genre;
	my $questions = $genre->questions->search(
		{ topic => $topic, story => $story } );
	my (@record, @popquestions);
	while ( my $question = $questions->next ) {
		my $qid = $question->id;
		my $response = $c->request->params->{$qid};
		if ( my $played = $question->played->find({ player => $player,
				league => $leagueId }) ) {
			push @record, { question => $question->id,
				content => $question->content,
				response => $played->response,
				newresponse => $response
			};
			$c->stash->{error_msg} =
		"You already submitted your answers. They cannot be changed.";
		}
		else {
			my $correct = $response eq $question->answer? 1: 0;
			push @record, { question => $qid,
				content => $question->content,
				response => $response, };
			push @popquestions, { league => $leagueId,
				player => $player, topic => $topic,
				story => $story, question => $qid,
				response => $response };
		}
	}
	$c->model('DB::Play')->populate( \@popquestions ) if @popquestions;
	$c->stash->{questions} = \@record;
	$c->stash->{genre} = $genre->name;
	$c->stash->{target} = $targetId;
	$c->stash->{template} = "record.tt2";
	}


=head2 score

Score answers, show a results page

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
	my ($scores, %totals, @playerids);
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
			$scores->{$pid}->{$qid} = $correct;
		}
		$scores->{$pid}->{total} = sum map { $scores->{$pid}->{$_} }
					keys %{ $scores->{$pid} };
	}
	my %questiontotals;
	for my $qid ( @quizids ) {
		for my $pid ( @playerids ) {
			next unless defined $scores->{$pid}->{$qid};
			$questiontotals{$qid} += $scores->{$pid}->{$qid};
		}
	}
	$c->stash->{quiz} = \@quiz;
	$c->stash->{scores} = $scores;
	$c->stash->{totals} = \%questiontotals;
	$c->stash->{genre} = $genre->name;
	$c->stash->{target} = $targetId;
	$c->stash->{template} = "scores.tt2";
	}


=head2 list

Fetch all Play objects and pass to play/list.tt2 in stash to be displayed

=cut
 
sub list : Local {
    # Retrieve the usual perl OO '$self' for this object. $c is the Catalyst
    # 'Context' that's used to 'glue together' the various components
    # that make up the application
    my ($self, $c) = @_;
    # Retrieve all of the text records as text model objects and store in
    # stash where they can be accessed by the TT template
    $c->stash->{exercises} = [$c->model('DB::Exercise')->all];
    # Set the TT template to use.  You will almost always want to do this
    # in your action methods (actions methods respond to user input in
    # your controllers).
    $c->stash->{template} = 'exercises/list.tt2';
}


=head2 index 

=cut

sub index : Private {
    my ( $self, $c ) = @_;
    $c->response->body('Matched dic::Controller::Play in Play.');
}


=head1 AUTHOR

Dr Bean,,,

=head1 LICENSE

This library is free software, you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;
