#!/usr/bin/perl 

# Created: 西元2010年02月23日 22時33分13秒
# Last Edit: 2017 Apr 05, 11:02:59 AM
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
# use lib "/var/www/cgi-bin/comp/lib";
use lib "/home/drbean/comp/web/lib";
use Config::General;
use Cwd; use File::Basename;

use YAML qw/Dump Bless/;
use Grades;

use Games::Tournament::Contestant::Swiss;
# use Games::Tournament::Swiss;

use CompComp::Model::SwissDB;
use CompComp::SwissSchema;

my $connect_info = CompComp::Model::SwissDB->config->{connect_info};
my $schema = CompComp::SwissSchema->connect( $connect_info );

my $season = $ENV{SEMESTER};
my $leagues = "/home/drbean/$season";

my $scantron = Grades::Script->new_with_options;
my $id = $scantron->league || basename( getcwd );
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

die "No pairing in round $round in $id tournament in $season season," unless @pairs;

my $roundconfig = $comp->config( $overallround );
# my $tables = $comp->pairs( $round );
# @pairs = sort { $a->ego->score <=> $b->ego->score } @pairs;

my ($n, $response, %seen, %formorder);

for my $pair ( @pairs ) {
    my $white = $pair->white;
    my $black = $pair->black;
    my $table = $pair->pair;
    next if $black eq 'Bye';
    my %questions; @questions{1..$qn } = ( undef ) x $qn;
    my $free = {
	    $white => { point => { 1 => undef} },
	    $black => { point => { 1 => undef} }
	     };
    Bless( $free )->keys( [ $white, $black ] );
    #my $set = { $white => \%questions,
    #    	$black => \%questions };
    #Bless( $set->{$white} )->keys([ 1 .. $qn ]);
    #Bless( $set->{$black} )->keys([ 1 .. $qn ]);
    #Bless( $set )->keys( [ $white, $black ] );
    my $topics = $comp->compTopics( $overallround, $table );
    for my $topic ( @$topics ) {
	my $forms = $comp->compForms( $overallround, $table, $topic );
	for my $form ( @$forms ) {
	    $response->{ free }->{ $table }->{$topic}->{$form} = $free;
	    # $response->{ set }->{ $table }->{$topic}->{$form} = $set;
	}
	# Bless($response->{ free}->{ $table }->{$topic})->keys([qw/1 2 3 4 5 6 7 8 9 10/ ]);
	# Bless($response->{ set}->{ $table }->{$topic})->keys([qw/influences coventgreen/ ]);
	# Bless($response->{ free}->{ $table })->keys([qw/fast-track tips/ ]);
	# Bless($response->{ free}->{ $table })->keys([qw/dickson abreu smallwood jackson/ ]);
	# Bless($response->{ free}->{ $table })->keys([qw/biomom biodad emersonj/ ]);
	# Bless($response->{ free}->{ $table })->keys([qw/goetz allen ward clay/ ]);
	# Bless($response->{ free}->{ $table })->keys([qw/aliens space_travel naive_alien_questions/ ]);
	# Bless($response->{ free}->{ $table })->keys([qw/mercer tipton raveling jones jackson smith/ ]);
	# Bless($response->{ free}->{ $table })->keys([qw/experience website seller/ ]);
	# Bless($response->{ free}->{ $table })->keys([qw/million minutes life/ ]);
	# Bless($response->{ free}->{ $table })->keys([qw/treatment chores expectations/ ]);
	# Bless($response->{ free}->{ $table })->keys([qw/native aid violence/ ]);
	# Bless($response->{ free}->{ $table })->keys([qw/blackh abath carlos-rocha/ ]);
	# Bless($response->{ free}->{ $table })->keys([qw/economics publishing/ ]);
	# Bless($response->{ free}->{ $table })->keys([qw/interracial self/ ]);
	# Bless($response->{ free}->{ $table })->keys([qw/partner society/ ]);
	# Bless($response->{ free}->{ $table })->keys([qw/lerman seixas spano diaz/ ]);
	#Bless($response->{ free}->{ $table })->keys([qw/bezos sivers novogratz/ ]);
	# Bless($response->{ free}->{ $table })->keys([qw/tal perma/ ]);
	# Bless($response->{ free}->{ $table })->keys([qw/theory-x_y me_mypartner drbean/ ]);
	# Bless($response->{ free}->{ $table })->keys([qw/students-teachers women-men experience/ ]);
	# Bless($response->{ free}->{ $table })->keys([qw/trinka bruno kroenke/ ]);
	# Bless($response->{ free}->{ $table })->keys([qw/franklin fernandez nguyen/ ]);
	# Bless($response->{ free}->{ $table })->keys([qw/education school English/ ]);
	# Bless($response->{ free}->{ $table })->keys([qw/kerpen neal collins wang/ ]);
	# Bless($response->{ free}->{ $table })->keys([qw/personal_health health_systems/ ]);
	# Bless($response->{ free}->{ $table })->keys([qw/cars citrus internet/ ]);
	# Bless($response->{ free}->{ $table })->keys([qw/1st_impressions traffic language marriage/ ]);
	# Bless($response->{ set}->{ $table })->keys([qw/old connell warm/ ]);
    }
    # Bless($response->{$table})->keys([qw/rueda salazar vanbeke/ ]);
}

my @formorders = values %formorder;
# Bless( $response )->keys([ map { sort { $a <=> $b } @$_ } @formorders ]);
$YAML::UseAliases = 0;

my @tables = sort {$a <=> $b} keys %{$response->{free}};
Bless( $response->{ free } )->keys([ @tables ]);
# Bless( $response->{ set } )->keys([ @tables ]);

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


