#!/usr/bin/perl 

# Created: 西元2010年02月23日 22時33分13秒
# Last Edit: 2010  3月 24, 21時14分14秒
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

This script generates a YAML file which allows easy transcription from a paper record sheet by 2 competitors of their separate responses to CompComp quiz questions, so you can keep all the data that originally existed on the record sheet. This data can be returned later in a finer-grained grading report than would be possible only inputting the number correct.

=cut

use strict;
use warnings;
use FindBin qw/$Bin/;
use lib "$Bin/../lib";
use Config::General;

use YAML qw/Dump/;
use Grades;

BEGIN {
    my @MyAppConf = glob( "$Bin/../*.conf" );
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

my $pairs = $schema->resultset('Opponents')->search({
	tournament => $id, round => $round });

my ($n, $response, %seen);
my $qn = 3;

while ( my $pair = $pairs->next ) {
    my $player = $pair->player;
    my $opponent = $pair->opponent;
    my %questions; @questions{1..$qn } = ( undef ) x $qn;
    next if $seen{ $player };
    next if $opponent eq 'Unpaired' or $opponent eq 'Bye';
    $response->{++$n} = { $player => \%questions, $opponent => \%questions };
    $seen{$player}++;
    $seen{$opponent}++;
}

$YAML::UseAliases = 0;
print Dump \@response;

=head1 AUTHOR

Dr Bean C<< <drbean at cpan, then a dot, (.), and org> >>

=head1 COPYRIGHT & LICENSE

Copyright 2010 Dr Bean, all rights reserved.

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.

=cut

# End of comptron.pl

# vim: set ts=8 sts=4 sw=4 noet:


