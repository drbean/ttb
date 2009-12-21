package Web::Controller::Quiz;

use strict;
use warnings;
use parent 'Catalyst::Controller';

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
    my $genre = $league->genre->genre->name;
    # Retrieve all of the text records as text model objects and store in
    # stash where they can be accessed by the TT template
    $c->stash->{quiz} = [$c->model('DB::Quiz')->search(
	    { genre => $genre })];
    # Set the TT template to use.  You will almost always want to do this
    # in your action methods (actions methods respond to user input in
    # your controllers).
    my $player = $c->session->{player_id};
    my @play = $c->model('DB::Play')->search(
	    { league => $leagueid, player => $player },
		{ select => [ 'topic', 'story', { sum => 'correct' } ],
		'group_by' => [qw/topic story/],
		as => [ qw/topic story questions/ ],
		});
    my %questionscores = map { $_->quiz => $_->get_column('questions') } @play;
    $c->stash->{questions} = \%questionscores;
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
	$c->stash->{quiz_id} = $quizId;
	$c->stash->{template} = 'quiz/list.tt2';
}
			
=head2 delete

Delete a quiz. Delete of Questions done here too.

=cut

sub delete : Local {
	my ($self, $c, $id) = @_;
	my $quiz = $c->model('DB::Quiz');
	my $words = $quiz->find({id => $id})->words;
	my %entries;
	while (my $word = $words->next)
	{
		my $token = $word->published;
		my $entry = $word->dictionary;
		if ( $entry )
		{
			my $count = $entry->count;
			$entry->update( {count => --$count} );
		}
	}
	$quiz->search({id => $id})->delete_all;
	$c->stash->{status_msg} = "Quiz deleted.";
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
