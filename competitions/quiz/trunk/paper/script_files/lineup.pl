#!/usr/bin/perl 

# Created: 西元2010年11月01日 09時25分27秒
# Last Edit: 2011  1月 16, 11時23分07秒
# $Id$

=head1 NAME

lineup.pl - Generate a list of players in a round from the tables

=head1 VERSION

Version 0.01

=cut

our $VERSION = '0.01';

use strict;
use warnings;
use IO::All;
use YAML qw/LoadFile Dump DumpFile/;
use Cwd; use File::Basename;
use List::MoreUtils qw/any/;
use Grades;

=head1 SYNOPSIS

lineup.pl -l . -r 7 > comp/7/members.yaml

=cut

my $leagues = "/home/drbean/class";

my $script = Grades::Script->new_with_options;
my $id = $script->league || basename( getcwd );
my $round = $script->round;

my $league = League->new( leagues => $leagues, id => $id );
my $g = Compcomp->new( league => $league );
my $members = $league->members;
my %members = map { $_->{id} => $_ } @$members;

my $config = $g->config($round);
my @roles = qw/White Black/;

my $tables = $g->tables($round);
my @ids;
my $n = 0;
for my $n ( keys %$tables ) {
    my $table = $tables->{$n};
    my @players = map { $table->{$_} } @roles;
    for my $player ( @players ) {
	die "$player at table $n is not a player, " unless 
	    any { $player eq $_ } keys %members;
	push @ids, $player;
    }
    $n++;
}
if ( $config->{bye} ) {
	push @ids, $config->{bye};
}
if ( $config->{late} ) {
	my $tardies = $config->{late};
	for my $tardy ( @$tardies ) {
	    push @ids, @$tardy unless any { $tardy eq $_ } @ids;
	}
}
my @sorted = sort @ids;
my @members = map { $members{$_} } @sorted;

print Dump \@members;

=head1 DESCRIPTION

The players in league.yaml or in the swiss database are not the same as the players who appeared that day and played. Get a list of players who played, for amendment of league.yaml, for amendment of the swiss database.

=cut


# DumpFile "comp/$round/members.yaml", \@members;


=head1 AUTHOR

Dr Bean C<< <drbean at cpan, then a dot, (.), and org> >>

=head1 COPYRIGHT & LICENSE

Copyright 2010 Dr Bean, all rights reserved.

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.

=cut

# End of lineup.pl

# vim: set ts=8 sts=4 sw=4 noet:


