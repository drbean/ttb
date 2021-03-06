#!/usr/bin/perl 

# Created: 西元2010年02月23日 22時33分13秒
# Last Edit: 2010  4月 11, 11時54分56秒
# $Id$

=head1 NAME

comptron.pl - Scantron form for CompComp responses

=head1 VERSION

Version 0.02

=cut

our $VERSION = '0.02';

=head1 SYNOPSIS 

comptron.pl -l BMA0077 -r 1 > BMA0077/classwork/1/response.yaml

=cut

=head1 DESCRIPTION

This script generates a YAML file which allows easy transcription from a paper record sheet by 2 competitors of their separate White and Black responses to CompComp quiz questions in order, so you can keep all the data that originally existed on the record sheet. This data can be returned later in a finer-grained grading report than would be possible only inputting the number correct.

=cut

use strict;
use warnings;
use FindBin qw/$Bin/;
use lib "$Bin/../../Web/lib";
use Config::General;

use YAML qw/Dump Bless/;
use Grades;

use Games::Tournament::Contestant::Swiss;
use Games::Tournament::Swiss;

BEGIN {
    my @MyAppConf = glob( "$Bin/../../Web/*.conf" );
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

my $league = League->new( leagues => $::leagues, id => $id );
my $grades = Grades->new( league => $league );

my $members = $league->members;

my %members = map { $_->{name} => $_ } @$members;
my @dbmembers = $schema->resultset('Members')->search({ tournament => $id }); 
my $lineup = map { Games::Tournament::Contestant::Swiss->new(
	id => $_->player, name => $_->profile->name, score => $_->score,
	rating => $_->rating->find({ round => $round }) ) } @dbmembers;

my @pairs = $schema->resultset('Opponents')->search({
	tournament => $id, round => $round });

die "No pairing in round $round in $id tournament," unless @pairs;

my $roundconfig = $grades->config( 'CompComp', $round );
# my $tables = $grades->pairs( $round );
@pairs = sort { $a->ego->score <=> $b->ego->score } @pairs;

my ($n, $response, %seen);

for my $pair ( @pairs ) {
    my $player = $pair->player;
    my $opponent = $pair->opponent;
    next if $seen{ $player };
    next if $opponent eq 'Unpaired' or $opponent eq 'Bye';
    $seen{$player}++;
    $seen{$opponent}++;
    my $playerrole = $pair->ego->role->find({
            tournament => $id, round => $round });
    my ( $first, $second ) = ( $playerrole and $playerrole->role eq 'White' )?
	( $player, $opponent ): ( $opponent, $player );
    my $qn = $grades->compqn( $round, $first);
    my %questions; @questions{1..$qn } = ( undef ) x $qn;
    $response->{$first} = { $player => \%questions, $opponent => \%questions };
    Bless( $response->{ $first }->{$first} )->keys( [ 1 .. $qn ] );
    Bless( $response->{ $first }->{$second} )->keys( [ 1 .. $qn ] );
    Bless( $response->{ $first } )->keys( [ $first, $second ] );
}


# Bless( $response )->keys([ 1 .. $n ]);
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


