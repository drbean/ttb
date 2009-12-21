package Web::Controller::Exercises;

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

Display form to collect information for exercise to create

=cut

sub form_create : Local {
	my ($self, $c) = @_;
	$c->stash->{template} = 'exercises/form_create.tt2';
}


=head2 list

Fetch all Exercise objects and pass to exercises/list.tt2 in stash to be displayed

=cut
 
sub list : Local {
    # Retrieve the usual perl OO '$self' for this object. $c is the Catalyst
    # 'Context' that's used to 'glue together' the various components
    # that make up the application
    my ($self, $c) = @_;
    my $leagueid = $c->session->{league};
    my $league = $c->model('DB::League')->find({id=>$leagueid});
    my $genre = $c->model('DB::Leaguegenre')->next({league=>$leagueid})->genre;
    # my $genre = $league->genre->genre;
    # Retrieve all of the text records as text model objects and store in
    # stash where they can be accessed by the TT template
    $c->stash->{exercises} = [$c->model('DB::Exercise')->search(
	    { genre => $genre })];
    # Set the TT template to use.  You will almost always want to do this
    # in your action methods (actions methods respond to user input in
    # your controllers).
    my $player = $c->session->{player_id};
    my @play = $c->model('DB::Play')->search(
	    { league => $leagueid, player => $player },
		{ select => [ 'exercise', { sum => 'correct' } ],
		'group_by' => [qw/exercise/],
		as => [ qw/exercise letters/ ],
		});
    my %letterscores = map { $_->exercise => $_->get_column('letters') } @play;
    $c->stash->{letters} = \%letterscores;
    my @quiz = $c->model('DB::Quiz')->search(
	    { league => $league, player => $player },
		{ select => [ 'exercise', { sum => 'correct' } ],
		'group_by' => [qw/exercise/],
		as => [ qw/exercise questions/ ],
		});
    my %quizscores = map { $_->exercise => $_->get_column('questions') } @quiz;
    $c->stash->{questions} = \%quizscores;
    $c->stash->{league} = $league->name;
    $c->stash->{template} = 'exercises/list.tt2';
}


=head2 create

http://server.school.edu/dic/exercises/create/topicId/storyId

Create comprehension questions.

=cut

sub create : Local {
	my ($self, $c, $topic, $story) = @_;
	my $questions = $c->model('DB::Questions')->search( {
			topic => $topic, story => $story } );
	my $genre = $questions->next->genre;
	my $exerciseId = "$topic$story";
	my $exercise = $c->model('DB::Exercise')->update_or_create({
			id => $topic,
			genre => $genre });
	$c->stash->{exercise_id} = $exerciseId;
	$c->stash->{template} = 'exercises/list.tt2';
}
			
=head2 delete

Delete an exercise. Delete of Questions and Questionwords done here too. TODO But delete of Questionwords not appearing to be done!

=cut

sub delete : Local {
	my ($self, $c, $id) = @_;
	my $exercise = $c->model('DB::Exercise');
	my $words = $exercise->find({id => $id})->words;
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
	$exercise->search({id => $id})->delete_all;
	$c->stash->{status_msg} = "Exercise deleted.";
       $c->response->redirect($c->uri_for('list',
                   {status_msg => "Exercise deleted."}));
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
