#!/usr/bin/perl 

# Created: Thu 26 Dec 2019 12:36:07 PM CST
# Last Edit: 2019 Dec 26, 04:12:51 PM
# $Id$

=head1 NAME

collate_gradebook.pl - classwork.yaml scores to moodle-friendly csv

=cut

our $VERSION = '0.01';

use strict;
use warnings;
use Pod::Usage;

=head1 SYNOPSIS

collate_gradebook.pl -l BMA0034 -w 3 -t internetPerson > 3.csv

=cut

use IO::All;
use YAML qw/Dump LoadFile DumpFile/;
use Cwd; use File::Basename;
use Grades;

my $script = Grades::Script->new_with_options( league => basename(getcwd) );
pod2usage(1) if $script->help;
pod2usage(-exitstatus => 0, -verbose => 2) if $script->man;

my $leagueId = $script->league;
my $lastweek = $script->weights;
my $topic = $script->two;
my $semester = $ENV{SEMESTER};
my $leagues = "/home/drbean/$semester";
$leagueId = basename( getcwd ) if not defined $leagueId;
$lastweek = $ENV{LASTWEEK} if not defined $lastweek;
$topic = $ENV{TOPIC} if not defined $topic;

=head1 DESCRIPTION

Converts beancan-sorted name-keyed $lastweek.yaml scores into id-keyed $lastweek.csv scores

=cut

my $l = League->new( leagues => "/home/drbean/$semester", id => $leagueId );
my $g = Grades->new({ league => $l });
my $c = $l->yaml;
my $m = $l->members;
my %m = map { $_->{name} => $_  } @$m;

my $y = LoadFile "classwork/$lastweek.yaml";
my %scores;
@scores{ keys %$_  } = values %$_ for values %$y;
my %grade;
$grade{$m{$_}->{id} } = $scores{$_} for keys %scores;

my $io = io "-";
$io->print( '"ID number","Quiz: ' . $topic . '"' . "\n"  );
$io->append( "$_,$grade{$_}\n" ) for sort keys %grade;
$io->autoflush;

=head1 AUTHOR

Dr Bean C<< <drbean at cpan, then a dot, (.), and org> >>

=head1 COPYRIGHT & LICENSE

Copyright 2019 Dr Bean, all rights reserved.

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.

=cut

# End of collate_gradebook.pl

# vim: set ts=8 sts=4 sw=4 noet:my $y = LoadFile 'classwork/3.yaml';
# my %scores;
# @scores{ keys %$_ } = values %$_ for values %$y;
# my %grade;
# $grade{$m{$_}->{id} } = $scores{$_} for keys %scores;
#
# my $io = io 'classwork/14.csv';
# $io->print( '"ID number","Quiz: transaction"' . "\n" );
# $io->append( "$_,$grade{$_}\n") for keys %grade;
# $io->autoflush;
# ~}"
