#!/usr/bin/perl 

# Created: Sat 28 Dec 2019 12:38:13 PM CST
# Last Edit: 2019 Dec 28, 09:23:17 PM
# $Id$

=head1 NAME

zero_classwork.pl - hand-filled-in classwork.yaml

=cut

our $VERSION = '0.02';

use strict;
use warnings;
use Pod::Usage;

=head1 SYNOPSIS

zero_classwork.pl -l FLA0019 -r 3 > classwork/3.yaml

=cut

use IO::All;
use YAML qw/Dump LoadFile DumpFile Bless/;
use Cwd; use File::Basename;
use Grades;

my $script = Grades::Script->new_with_options( league => basename(getcwd) );
pod2usage(1) if $script->help;
pod2usage(-exitstatus => 0, -verbose => 2) if $script->man;

my $leagueId = $script->league;
my $lastweek = $script->round;
my $semester = $ENV{SEMESTER};
my $leagues = "/home/drbean/$semester";
$leagueId = basename( getcwd ) if not defined $leagueId;
$lastweek = $ENV{LASTWEEK} if not defined $lastweek;

=head1 DESCRIPTION

Make easy to generate beancan-sorted name-keyed $lastweek.yamlzero classwork when have to fill in by hand

=cut

use Grades;
my $l = League->new( leagues => "/home/drbean/$semester", id => $leagueId );
my $g = Grades->new({ league => $l });
my $cl = $g->classwork;
my $m = $l->members;
my %m = map { $_->{name} => $_  } @$m;

my $grades;
my $beancans = $cl->beancan_names(2);
for my $beancan (keys %$beancans) {
	my $players = $beancans->{$beancan};
	my %zeros;
	@zeros{@$players} = (0) x @$players;
	$grades->{$beancan} = \%zeros;
	Bless($grades->{$beancan})->keys($players);
}

print Dump $grades;

=head1 AUTHOR

Dr Bean C<< <drbean at cpan, then a dot, (.), and org> >>

=head1 COPYRIGHT & LICENSE

Copyright 2019 Dr Bean, all rights reserved.

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.

=cut

# End of zero_classwork.pl

# vim: set ts=8 sts=4 sw=4 noet:
