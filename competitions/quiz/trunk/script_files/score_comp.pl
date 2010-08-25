#!/usr/bin/perl

# Created: 西元2010年04月04日 19時52分56秒
# Last Edit: 2010 Aug 25, 01:42:19 PM
# $Id$

use strict;
use warnings;
use 5.10.0;

use YAML qw/Bless Dump/;
use Grades;
use Cwd; use File::Basename;

my $answers = Grades::Script->new_with_options;
my $id = $answers->league || basename( getcwd );
my $round = $answers->round;

my $league = League->new( id => $id );
my $comp = CompComp->new( league => $league );

my $config = $comp->config( $round );
my $pairs = $config->{pair};

my $response;
for my $pair ( keys %$pairs ) {
	next if $pair eq 'Bye';
	# $response->{Chinese}->{$pair} = 0;
	my $quiz = $comp->compQuiz( $round, $pair );
	my $topic = $comp->compTopic($round, $pair);
	my $form = $comp->compForm($round, $pair);
	my ($codedvalue, $n);
	for my $item ( @$quiz ) {
		if ( $item->{option} ) {
			my $option = $item->{option};
			$codedvalue->[$n++] = { map {
				$option->[$_] => $_ } 0..$#$option };
		}
		else { $codedvalue->[$n++] = { True => 'T', False => 'F' }; }
	}
	my $idsbyRole = $comp->idsbyCompRole( $round, $pair );
	my $responses = $comp->compResponses( $round, $pair );
	die "Table ${pair}'s responses to $topic quiz, form $form,"
				unless defined $responses;
	for my $id ( @$idsbyRole ) {
		my $score = 0;
		for my $n ( 0 .. $#$quiz ) {
			my $myanswer = $responses->{$id}->{$n+1} // '??';
			my $theanswer = $codedvalue->[$n]->{
				$quiz->[$n]->{answer} };
			unless ( $myanswer eq 'T' or $myanswer eq 'F' ) {
				warn "${id}'s answer, $myanswer, to question " . ($n+1) .
					" in " . $topic . $form . " quiz,";
				next;
			}
			unless ( $theanswer eq 'T' or $theanswer eq 'F' ) {
				die "Right answer is $theanswer, on question " . ($n+1) .
					" in " . $topic . $form . " quiz?";
			}
			$score++ if $myanswer eq $theanswer;
		}
		$response->{letters}->{$pair}->{$id} = $score;
		$response->{letters}->{$pair}->{story} =
				$comp->compTopic( $round, $pair ) .
				$comp->compForm( $round, $pair );
	}
	Bless( $response->{letters}->{$pair} )->keys([ @$idsbyRole, 'story' ]);
}

print Dump $response;
