#!/usr/bin/perl 

# Created: 西元2010年02月23日 22時33分13秒
# Last Edit: 2011  6月 03, 16時04分07秒
# $Id$

=head1 NAME

comptron.pl - Scantron form for CompComp responses

=head1 VERSION

Version 0.02

=cut

our $VERSION = '0.02';

=head1 SYNOPSIS 

comptron.pl -l BMA0077 -r 1 -x 3 > BMA0077/classwork/1/response.yaml

 Options:
   -x --exercise      number of questions from exam
   -r --round         the round
   -o --one	      the old round (overall round) in the whole league season
   -l --league        league's id
 

=cut

=head1 DESCRIPTION

This script generates a YAML file which allows easy transcription from a paper record sheet by 2 competitors of their separate White and Black responses to CompComp quiz questions in order, so you can keep all the data that originally existed on the record sheet. This data can be returned later in a finer-grained grading report than would be possible only inputting the number correct.

=cut

use 5.010;
use strict;
use warnings;
use FindBin qw/$Bin/;
use lib "$Bin/../../web/lib";
use Config::General;

use YAML qw/Dump Bless/;
use Grades;

use Games::Tournament::Contestant::Swiss;
use Games::Tournament::Swiss;

use CompComp;

my $connect_info = CompComp::Model::SwissDB->config->{connect_info};
my $schema = CompComp::SwissSchema->connect( @$connect_info );

my $leagues = CompComp->config->{leagues};

my $scantron = Grades::Script->new_with_options;
my $id = $scantron->league;
my $round = $scantron->round;
my $overallround = $scantron->one || $round;
my $qn = $scantron->exercise;

( my $leagueid = $id ) =~ s/^([[:alpha:]]+[[:digit:]]+).*$/$1/;
my $league = League->new( leagues => $leagues, id => $leagueid );
my $comp = Compcomp->new( league => $league );

my $members = $league->members;

my %members = map { $_->{name} => $_ } @$members;
my @dbmembers = $schema->resultset('Members')->search({ tournament => $id }); 
my $lineup = map { Games::Tournament::Contestant::Swiss->new(
	id => $_->player, name => $_->profile->name, score => $_->score,
	rating => $_->rating->find({ round => $round }) ) } @dbmembers;

my @pairs = $schema->resultset('Matches')->search({
	tournament => $id, round => $round });

die "No pairing in round $round in $id tournament," unless @pairs;

my $roundconfig = $comp->config( $overallround );
# my $tables = $comp->pairs( $round );
# @pairs = sort { $a->ego->score <=> $b->ego->score } @pairs;

my ($n, $response, %seen, %formorder);

for my $pair ( @pairs ) {
    my $white = $pair->white;
    my $black = $pair->black;
    my $table = $pair->pair;
    next if $black eq 'Bye';
    my $topic = $comp->compTopic( $overallround, $table );
    my $form = $comp->compForm( $overallround, $table );
    $qn ||= $comp->compqn( $overallround, $table );
    my %questions; @questions{1..$qn } = ( undef ) x $qn;
    my $selection = $comp->activities( $overallround );
    my $free = {
	    $white => { q => { 1 => undef} , a => { 1 => undef} },
	    $black => { q => { 1 => undef} , a => { 1 => undef} }
	     };
    Bless( $free->{$white} )->keys( [ 'q', 'a'] );
    Bless( $free->{$black} )->keys( [ 'q', 'a'] );
    Bless( $free )->keys( [ $white, $black ] );
    my $set = { $white => \%questions,
		$black => \%questions };
    Bless( $set->{$white} )->keys([ 1 .. $qn ]);
    Bless( $set->{$black} )->keys([ 1 .. $qn ]);
    Bless( $set )->keys( [ $white, $black ] );
    $response->{ $table }->{$topic}->{$form}->{ free } = $free;
    $response->{ $table }->{$topic}->{$form}->{ set } = $set;
    # Bless($response->{$table})->keys([qw/undertaker oakland spirits wardead/ ]);
}

my @formorders = values %formorder;
# Bless( $response )->keys([ map { sort { $a <=> $b } @$_ } @formorders ]);
$YAML::UseAliases = 0;

my @tables = sort {$a <=> $b} keys %$response;
Bless( $response )->keys([ @tables ]);

print Dump $response;

=head1 AUTHOR

Dr Bean C<< <drbean at cpan, then a dot, (.), and org> >>

=head1 COPYRIGHT & LICENSE

Copyright 2010 Dr Bean, all rights reserved.

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.

=cut

# End of comptron.pl

# vim: set ts=8 sts=4 sw=4 noet:


