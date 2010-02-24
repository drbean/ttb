#!/usr/bin/perl 

# Created: 西元2010年02月23日 22時33分13秒
# Last Edit: 2010  2月 24, 10時12分49秒
# $Id$

=head1 NAME

comptron.pl - Scantron form for CompComp responses

=head1 VERSION

Version 0.01

=cut

our $VERSION = '0.01';

use strict;
use warnings;
use FindBin qw/$Bin/;
use lib "$Bin/../lib";

use YAML qw/LoadFile DumpFile/;
use Grades;

my $scantron = Grades::Script->new_with_options;
my $id = $scantron->league;
my $exam = $scantron->exam;

my $league = League->new( id => $id );
my $grades = Grades->new( league => $league );

my $members = $league->members;

my %members = map { $_->{name} => $_ } @$members;
my $compschema = 
my $pairs = $grades->jigsawGroups( $exam );

=head1 DESCRIPTION

This script allows easy transcription from a record sheet by 2 competitors of their separate responses to CompComp quiz questions, thus keeping all the data that originally existed on the record sheet. This data can be returned later in a fine-grained grading report.

=cut

run unless caller;

sub run {

my ($n, @r, %seen);

my $o = LoadFile 'comp/1/opponent.yaml';
for ( keys %$o ) { $n++; push @r, { $n++ => { $_ => {1 => 1, 2 => 1, 3 => 1}, $o->{$_} => {1 => 1, 2 => 1, 3 => 1} } } unless $seen{ $o->{$_} }; $seen{$_}++; $seen{$o->{$_}}++; } ;
@r;
$_REPL->load_plugin('DumpHistory');

DumpFile 'comp/1/response.yaml', \@r;

}

=head1 AUTHOR

Dr Bean C<< <drbean at cpan, then a dot, (.), and org> >>

=head1 COPYRIGHT & LICENSE

Copyright 2010 Dr Bean, all rights reserved.

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.

=cut

# End of comptron.pl

# vim: set ts=8 sts=4 sw=4 noet:


