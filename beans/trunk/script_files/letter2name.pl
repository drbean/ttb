#!/usr/bin/perl 

# Created: 西元2014年06月09日 13時37分26秒
# Last Edit: 2016 Sep 10, 07:47:31 PM
# $Id$

=head1 NAME

letter2name.pl - Name of player from letter in group in session

=cut

our $VERSION = '0.01';

use strict;
use warnings;

=head1 SYNOPSIS

letter2name.pl -l GL00019 -s 3 -g Red -l B

=cut

use Cwd; use File::Basename;
use Getopt::Long;
use YAML qw/LoadFile/;

=head1 DESCRIPTION

Returns name of player (without \n) from letter designation

=cut

my $leagues = "/home/drbean/$ENV{SEMESTER}";
my ($session, $group, $letter, $help, $man);
my $league => basename(getcwd);
GetOptions ("league=s" => \$league,
            "session=s"   => \$session,
            "group=s"   => \$group,
            "letter=s"   => \$letter,
            "man"   => \$man,
            "help"  => \$help)
    or die("Error in command line arguments\n");

pod2usage(1) if $help;
pod2usage(-exitstatus => 0, -verbose => 2) if $man;

my $letter2order = { A => 0, B => 1, C => 2 };

my $file = LoadFile "$leagues/$league/session/$session/groups.yaml";
my $can = $file->{$group};
my $size = scalar @$can;
my $order = $letter2order->{$letter} % $size;

my $name = $file->{$group}->[$order];

print $name;

=head1 AUTHOR

Dr Bean C<< <drbean at cpan, then a dot, (.), and org> >>

=head1 COPYRIGHT & LICENSE

Copyright 2014 Dr Bean, all rights reserved.

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.

=cut

# End of letter2name.pl

# vim: set ts=8 sts=4 sw=4 noet:


