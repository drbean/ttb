#!/usr/bin/perl 

# Created: 西元2010年10月31日 19時06分22秒
# Last Edit: 2010 11月 24, 20時54分25秒
# $Id$

=head1 NAME

score_comp.pl - Question/answer self-evaluations tallies at each table

=head1 VERSION

Version 0.01

=cut

our $VERSION = '0.01';

use strict;
use warnings;
use IO::All;
use YAML qw/LoadFile Dump/;
use List::Util qw/sum/;
use Cwd; use File::Basename;
use Grades;


=head1 SYNOPSIS

score_comp.pl -l . -r 10 > comp/10/scores.yaml

=cut


my $leagues = "/home/drbean/class";

my $script = Grades::Script->new_with_options;
my $id = $script->league || basename( getcwd );
my $round = $script->round;

my $league = League->new( leagues => $leagues, id => $id );
my $g = Compcomp->new( league => $league );

my $dir = $g->compcompdirs;
my $responses = LoadFile "$dir/$round/response.yaml";

my $scores;
for my $table ( keys %$responses ) {
    my %tally;
    my $topics = $responses->{$table};
    for my $topic ( keys %$topics ) {
	my $forms = $topics->{$topic};
	for my $form ( keys %$forms ) {
	    my $pair = $forms->{$form};
	    for my $player ( keys %$pair ) {
		my $play = $pair->{$player};
$DB::single=1 unless ref( $play ) eq 'HASH';
$DB::single=1 unless ref( $play->{q} ) eq 'HASH' and ref( $play->{a} ) eq 'HASH';
		$tally{$player} += sum ( values( %{ $play->{q} } ),
				values( %{ $play->{a} } ) );
	    }
	}
    }
    @{$scores->{$table}}{keys %tally} = @tally{keys %tally};
}

print Dump $scores;

=head1 DESCRIPTION

Contestants at each table rate their questions and answers. comptron.pl produces a score card, response.yaml. score_comp.pl tallies the points contestants have given themselves at each of the tables in the round.

=cut

=head1 AUTHOR

Dr Bean C<< <drbean at cpan, then a dot, (.), and org> >>

=head1 COPYRIGHT & LICENSE

Copyright 2010 Dr Bean, all rights reserved.

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.

=cut

# End of score_comp.pl

# vim: set ts=8 sts=4 sw=4 noet:


