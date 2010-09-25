package Web::Controller::Play;

use strict;
use warnings;
use parent 'Catalyst::Controller';

=head1 NAME

Web::Controller::Play - Catalyst Controller

=head1 DESCRIPTION

Catalyst Controller.

=head1 METHODS

=cut


=head2 play

Show a created quiz from the database.

=cut
 
sub play : Global {
	my ($self, $c, $topic, $story) = @_;
	my $quiz = $c->model('DB::Quiz')->find({
		topic => $topic, story => $story });
	$c->stash->{topic} = $topic;
	$c->stash->{story} = $story;
	$c->stash->{template} = 'play.tt2';
	my $stateofplay = $quiz->action;
	if ( $stateofplay eq 'False' ) {
		$c->stash->{status_msg} =
"The $topic$story quiz has either finished, or not yet started. See Dr Bean.\n";
		return;
	}
	my $questions = $c->model('DB::Questions')->search({
		topic => $topic, story => $story });
	my @questions;
	while ( my $q = $questions->next ) {
		push @questions, { content => $q->content, id => $q->id, };
	}
	$c->stash->{questions} = \@questions;
}


=head2 go

Allow play action to show questions.

=cut

sub go : Global {
	my ($self, $c, $topic, $story) = @_;
	my $quiz = $c->model('DB::Quiz')->find({
		topic => $topic, story => $story });
	$quiz->update({ action => 'True' });
	$c->stash->{topic} = $topic;
	$c->stash->{story} = $story;
	$c->stash->{status_msg} = "The $topic$story quiz has started.\n";
	$c->stash->{template} = 'play.tt2';
}


=head2 stop

Prevent play action from showing questions.

=cut

sub stop : Global {
	my ($self, $c, $topic, $story) = @_;
	my $quiz = $c->model('DB::Quiz')->find({
		topic => $topic, story => $story });
	$quiz->update({ action => 'False' });
	$c->stash->{topic} = $topic;
	$c->stash->{story} = $story;
	$c->stash->{status_msg} = "The $topic$story quiz has ended.\n";
	$c->stash->{template} = 'play.tt2';
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
