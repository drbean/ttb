#!/usr/bin/perl 

# Created: 西元2010年02月23日 22時33分13秒
# Last Edit: 2010  9月 25, 11時15分43秒
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

BEGIN {
    my @MyAppConf = glob( "$Bin/../../web/*.conf" );
    die "Which of @MyAppConf is the configuration file?"
                unless @MyAppConf == 1;
    %::config = Config::General->new($MyAppConf[0])->getall;
    $::name = $::config{name};
    $::leagues = $::config{leagues};
    require "$::name.pm"; $::name->import;
    # require "$::name/SwissSchema.pm"; $::name->import;
}

no strict qw/subs refs/;
my $connect_info = "${::name}::Model::SwissDB"->config->{connect_info};
# my $connect_info = [ 'dbi:SQLite:db/demo','','' ];
my $schema = "${::name}::SwissSchema"->connect( @$connect_info );
use strict;


my $scantron = Grades::Script->new_with_options;
my $id = $scantron->league;
my $round = $scantron->round;
my $qn = $scantron->exercise;

my $league = League->new( leagues => $::leagues, id => $id );
my $comp = CompComp->new( league => $league );

my $members = $league->members;

my %members = map { $_->{name} => $_ } @$members;
my @dbmembers = $schema->resultset('Members')->search({ tournament => $id }); 
my $lineup = map { Games::Tournament::Contestant::Swiss->new(
	id => $_->player, name => $_->profile->name, score => $_->score,
	rating => $_->rating->find({ round => $round }) ) } @dbmembers;

my @pairs = $schema->resultset('Matches')->search({
	tournament => $id, round => $round });

die "No pairing in round $round in $id tournament," unless @pairs;

my $roundconfig = $comp->config( $round );
# my $tables = $comp->pairs( $round );
# @pairs = sort { $a->ego->score <=> $b->ego->score } @pairs;

my ($n, $response, %seen, %formorder);

for my $pair ( @pairs ) {
    my $white = $pair->white;
    my $black = $pair->black;
    my $table = $pair->pair;
    next if $black eq 'Bye';
    my $form = $comp->compTopic( $round, $table ) .
		    $comp->compForm( $round, $table );
    push @{ $formorder{$form} }, $table;
    $qn ||= $comp->compqn( $round, $table );
    my %questions; @questions{1..$qn } = ( undef ) x $qn;
    $response->{$table} = { $white => \%questions, $black => \%questions };
    Bless( $response->{ $table }->{$white} )->keys( [ 1 .. $qn ] );
    Bless( $response->{ $table }->{$black} )->keys( [ 1 .. $qn ] );
    Bless( $response->{ $table } )->keys( [ $white, $black ] );
}

my @formorders = values %formorder;
Bless( $response )->keys([ map { sort @$_ } @formorders ]);
$YAML::UseAliases = 0;
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


