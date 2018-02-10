#!/usr/bin/perl 

# Created: 05/28/2017 02:56:13 PM
# Last Edit: 2017 Dec 17, 05:58:31 PM
# $Id$

=head1 NAME

peer_eval.pl - compare peer evaluation with teacher's and score evaluator on closeness of fit

=cut

our $VERSION = '0.01';

use strict;
use warnings;

=head1 SYNOPSIS

peer_eval.pl -l GL00036 -r 3 -x house,fishing -s 100 -o 70 -t 30 > 3/g3.yaml

=cut

use Cwd;
use File::Basename;
use YAML qw/LoadFile DumpFile Dump Bless/;
use Grades;
use List::Util qw/sum/;

my $script = Grades::Script->new_with_options;
my $id = $script->league || basename( getcwd );
my $exam = $script->round;
my $exercise = $script->exercise;
my $same = $script->session;
my $one = $script->one;
my $two = $script->two;

my $league = League->new( id => $id );
my %members = map { $_->{id} => $_ } @{ $league->members };
my $examMax = $league->yaml->{examMax};

=head1 DESCRIPTION

Compare peer evaluations in $round/g$n.yaml of form, 

fishing:
    evaluations_by_of:
	N03200006:
	    N03200034: 2
	N03200011:
	    N03200027: 3

(N03200006 evaluated N03200034's fishing work and gave it a grade of 2)

Or, 

fishing:
    evaluations_of_by
	N03200034:
	    N03200006: 2
	N03200027:
	    N03200011: 3

with teacher's in $round/g$m.yaml of form

grade:
    N03200027: 3
    N03200034: 4

and award 100% of allocated points for equality of evaluations, 70% for differences of 1 and 30% for differences of 2.

In the example, N03200006 gets 30% and N03200011 gets 100%.

Append to $round/g$n.yaml

evaluators:
  N03200006:
    fishing:
	N03200034:
	    peer: 2
	    drbean: 4
    house:
	N03200034:
	    peer: 3
	    drbean: 5

evaluees:
  N03200034:
    fishing:
      N03200006: 2
      N03200036: 4
      drbean: 4
    house:
      N03200006: 3
      drbean: 5
 

=cut

my ( @exercises, $n, @g, $report );
if ( $exercise ) {
    @exercises = split /,/, $exercise;
    $n = $#exercises;
    $g[$_] = LoadFile "$exam/g" . ($_+1) . ".yaml" for (0 ..$n+1 );
}
else {
    my @files = glob "$exam/g*.yaml";
    push @g, LoadFile $_ for @files;
    push @exercises, $g[$_]->{exercise} for (0 .. $#g-1);
    $n = $#exercises;
}

my ( $evaluators, $evaluees, $fitness );

for my $m ( 0 .. $n ) {
    my $teacher_evaluation = $g[$m]->{grade};
    my $exercise = $exercises[$m];
    $report->{$exercise} = $g[$n+1]->{$exercise};
    my $peers;
    if ( exists $g[$n+1]->{$exercise}->{evaluations_by_of} ){
	$peers = $g[$n+1]->{$exercise}->{evaluations_by_of} }
    elsif ( exists $g[$n+1]->{$exercise}->{evaluations_of_by} ) {
	my $evaluations_of_by = $g[$n+1]->{$exercise}->{evaluations_of_by};
	for my $evaluee (keys %$evaluations_of_by) {
	    my $evaluations = $evaluations_of_by->{$evaluee};
	    for my $evaluator ( keys %$evaluations ) {
	    $peers->{$evaluator}->{$evaluee} = $evaluations->{$evaluator};
	    }
	}
	DumpFile "peers.$exercise.yaml", $peers;
    }
    else { die "no evaluations in g$n+1.yaml $exercise\n" }

    my $allocatedMax = $examMax / ( $n+1 );
    for my $evaluator ( keys %members ) {
	if ( exists $peers->{$evaluator} ) {
	    my $peer_evaluation = $peers->{$evaluator};
	    my $total_fitness = $fitness->{$evaluator};
	    my ( $evaluator_fit );
	    for my $evaluee ( keys %$peer_evaluation ) {
		my $evaluation_difference =  abs ( $teacher_evaluation->{$evaluee} - $peer_evaluation->{$evaluee} );
		if ( $evaluation_difference == 0 ) {
		    $evaluator_fit = $same * $examMax / 100;
		}
		elsif ( $evaluation_difference == 1 ) {
		    $evaluator_fit = $one * $examMax / 100;
		}
		elsif ( $evaluation_difference == 2 ) {
		    $evaluator_fit = $two * $examMax / 100;
		}
		else {
		    warn "evaluation difference = $evaluation_difference\n";
		    $evaluator_fit = 10 * $examMax / 100;
		}
		push @$total_fitness, $evaluator_fit;
		$evaluators->{$evaluator}->{$evaluee}->{$exercise}->{drbean} = $teacher_evaluation->{$evaluee};
		$evaluators->{$evaluator}->{$evaluee}->{$exercise}->{peer} = $peer_evaluation->{$evaluee};
		$evaluators->{$evaluator}->{$evaluee}->{$exercise}->{fit} = $evaluator_fit;
		Bless($evaluators->{$evaluator}->{$evaluee}->{$exercise})->keys(['drbean', 'peer', 'fit']);
		$evaluees->{$evaluee}->{$exercise}->{drbean} = $teacher_evaluation->{$evaluee};
		$evaluees->{$evaluee}->{$exercise}->{$evaluator} = $peer_evaluation->{$evaluee};
		$fitness->{$evaluator} = $total_fitness;
	    }
	}
    }
}

$report->{evaluators} = $evaluators;
$report->{evaluees} = $evaluees;

for my $evaluator ( keys %members ) {
    my $final_fitness = $fitness->{$evaluator};
    my $fitness;
    if ( $final_fitness and @$final_fitness ) {
     $fitness = (sum @$final_fitness) / @$final_fitness;
    }
    else { $fitness = 0 }
    $report->{fitness}->{$evaluator} = $fitness;
}

print Dump $report, $report->{fitness};

=head1 AUTHOR

Dr Bean C<< <drbean at cpan, then a dot, (.), and org> >>

=head1 COPYRIGHT & LICENSE

Copyright 2017 Dr Bean, all rights reserved.

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.

=cut

# End of peer_eval.pl

# vim: set ts=8 sts=4 sw=4 noet:


