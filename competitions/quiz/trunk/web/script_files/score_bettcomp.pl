#!/usr/bin/perl 

# Created: 西元2010年10月31日 19時06分22秒
# Last Edit: 2012 Mar 25, 05:50:06 PM
# $Id$

=head1 NAME

score_bettcomp.pl - Question/answer bett competition tallies at each table

=head1 VERSION

Version 0.01

=cut

our $VERSION = '0.01';

use strict;
use warnings;
use FindBin qw/$Bin/;
use lib "$Bin/../lib";
use lib "$Bin/../../../bett/lib";
use YAML qw/LoadFile Dump Bless/;
use List::Util qw/sum/;
use Scalar::Util qw/looks_like_number/;
use Cwd; use File::Basename;
use Grades;


=head1 SYNOPSIS

score_bettcomp.pl -l . -r 10 > comp/10/scores.yaml

=cut

use Games::Tournament::Contestant::Swiss;
use Games::Tournament::Swiss;

use CompComp;
use Bett;

my $connect_info = CompComp::Model::SwissDB->config->{connect_info};
my $schema = CompComp::SwissSchema->connect( @$connect_info );
my $bett_connect_info = Bett::Model::DB->config->{connect_info};
my $bett_schema = Bett::Schema->connect( $bett_connect_info );

my $leagues = "/home/drbean/002";

my $script = Grades::Script->new_with_options;
my $id = $script->league || basename( getcwd );
my $round = $script->round;

( my $leagueid = $id ) =~ s/^([[:alpha:]]+[[:digit:]]+).*$/$1/;
my $league = League->new( leagues => $leagues, id => $leagueid );
my $g = Compcomp->new( league => $league );

my $dir = $g->compcompdirs;
my $config = Bett->config;

my $members = $league->members;
my %members = map { $_->{name} => $_ } @$members;
my @dbmembers = $schema->resultset('Members')->search({ tournament => $id }); 
my $lineup = map { Games::Tournament::Contestant::Swiss->new(
	id => $_->player, name => $_->profile->name, score => $_->score,
	rating => $_->rating->find({ round => $round }) ) } @dbmembers;
my @pairs = $schema->resultset('Matches')->search({
	tournament => $id, round => $round });
die "No pairing in round $round in $id tournament," unless @pairs;
my $tablen = scalar @pairs;

my @courses = qw/S Yn Wh/;
my $exercises = $g->topicNames( $round );
my $questions;
for my $ex (@$exercises) {
    for my $course (@courses) {
	$questions->{$ex}->{$course} = $bett_schema->resultset($course)->search({
		league => $leagueid, exercise => $ex });
    }
}

my $scores;
for my $table ( @pairs ) {
    my %tally;
    my $pair = $table->pair;
    my $white = $table->white;
    my $black = $table->black;
    my %opponent; @opponent{$white, $black} = ($black, $white);
    for my $exercise ( @$exercises ) {
	for my $type ( @courses ) {
	    my $course = $questions->{$exercise}->{$type};
	    for my $player ( $white, $black ) {
		my $play = $course->find({ player => $player });
		my ($grammatical, $ungrammatical, $answer) = (0) x 3;
		if ( $play ) {
		    $grammatical = $play->score
			+ $config->{uc $type}->{chances}->{answer}
			- $play->answerchance;
		    $ungrammatical = $config->{uc $type}->{chances}->{question}
			- $play->questionchance;
		    $answer = $play->score;
		}
		$tally{$player} += 2 * $grammatical;
		$tally{ $opponent{ $player } } += $ungrammatical + $answer;
	    }
	}
    }
    @{$scores->{$pair}}{keys %tally} = @tally{keys %tally};
}

Bless( $scores )->keys([ 0 .. $tablen-1 ]);

print Dump $scores;

=head1 DESCRIPTION

First, White at each table enters the question in http://school.edu/bett/login?name=X&id=U9938007&password=53kr34 and Black enters the answer. If White's question is not grammatical, Black gets one point. If White's question *is* grammatical, White gets 2 points, and if Black's answer is correct, Black gets one point. 

Then it is Black's turn to enter a question, and White's turn to answer. If each player asks 1-3 questions, 1 and 3 (or 2) points, if 4-6, 2 and 4 (or 3) points, and if 7+ questions, 3 and 5 (or 4) points to their grade.

This incorporates functionality from comptron.pl and score_comp.pl.

=cut

=head1 AUTHOR

Dr Bean C<< <drbean at cpan, then a dot, (.), and org> >>

=head1 COPYRIGHT & LICENSE

Copyright 2012 Dr Bean, all rights reserved.

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.

=cut

# End of score_comp.pl

# vim: set ts=8 sts=4 sw=4 noet:


