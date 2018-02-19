#!/usr/bin/perl 

# Created: 02/10/2018 01:56:05 PM
# Last Edit: 2018 Feb 10, 03:10:56 PM
# $Id$

=head1 NAME

merge_email.pl - munge league.yaml with email addresses from ~/admin/SEMESTER/SCHOOL/LEAGUE_email.yaml

=cut

use strict;
use warnings;
use YAML qw/LoadFile Dump/;
use Cwd; use File::Basename;
use Grades;

=head1 SYNOPSIS

merge_email.pl -l FLA0011 | sponge league.yaml

=cut

my $script = Grades::Script->new_with_options( league => basename(getcwd) );
pod2usage(1) if $script->help;
pod2usage(-exitstatus => 0, -verbose => 2) if $script->man;

my $leagueId = $script->league;
my $semester = $ENV{SEMESTER};
my $leagues = "/home/drbean/$semester";
$leagueId = basename( getcwd ) if $leagueId eq '.';

=head1 DESCRIPTION

Email addresses in ~/admin/SEMESTER/SCHOOL/LEAGUE_email.yaml, which has to be created by hand, are added to the Chinese, id, name, password and rating values of the corresponding member, keyed on their school id.

=cut

my $l = League->new( leagues => "/home/drbean/$semester", id => $leagueId );
my $c = $l->yaml;
my $school = $c->{school};
my %m = map { $_->{id} => $_ } @{ $l->members };

my $email_file = "$ENV{HOME}/admin/$semester/$school/${leagueId}_email.yaml";
my $e = LoadFile $email_file;
for my $member ( keys %m ) {
    die "$member not in $email_file\n" if not exists $e->{$member};
}
$m{$_}->{email} = $e->{$_} for (keys %m) ;
my @m;
push @m, $m{$_} for sort keys %m;
$c->{member} = \@m;
print Dump $c;

=head1 AUTHOR

Dr Bean C<< <drbean at cpan, then a dot, (.), and org> >>

=head1 COPYRIGHT & LICENSE

Copyright 2018 Dr Bean, all rights reserved.

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.

=cut

# End of merge_email.pl

# vim: set ts=8 sts=4 sw=4 noet:
