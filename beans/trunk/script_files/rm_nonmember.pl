#!/usr/bin/perl 

# Created: 05/28/2017 02:56:13 PM
# Last Edit: 2018 Oct 07, 02:56:02 PM
# $Id$

=head1 NAME

rm_nonmember.pl - remove separate group members that moodle includes in gradebook export

=cut

use strict;
use warnings;

=head1 SYNOPSIS

rm_nonmember.pl -f homework/1.yaml -l GL00036 | sponge homework/1.yaml

=cut

use Cwd;
use File::Basename;
use YAML qw/LoadFile DumpFile Dump Bless/;
use Grades;
use List::Util qw/sum/;

my $script = Grades::Script->new_with_options;
my $id = $script->league || basename( getcwd );
my $file = $script->file;

my $all_grade = LoadFile $file;
my $league = League->new( id => $id );
my $member = $league->members;
my @good_id;
foreach my $member (@$member) {
    my $id = $member->{id};
    push @good_id, $id if $league->is_member($id);
}
my %good_grade;
@good_grade{ @good_id } = @$all_grade{ @good_id };

=head1 DESCRIPTION

The moodle gradebook doesn't appear to support separate groups or visible groups. Though the quiz and assignment modules do. 

So all the groups in a course are exported from the gradebook together.

This script removes records of ids not in the present league.

=cut

print Dump \%good_grade;

=head1 AUTHOR

Dr Bean C<< <drbean at cpan, then a dot, (.), and org> >>

=head1 COPYRIGHT & LICENSE

Copyright 2018 Dr Bean, all rights reserved.

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.

=cut

# End of rm_nonmember.pl

# vim: set ts=8 sts=4 sw=4 noet:


