#!/usr/bin/perl 

# Created: 西元2010年10月31日 19時06分22秒
# Last Edit: 2014 Oct 27, 11:46:42 AM
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
use YAML qw/LoadFile Dump Bless/;
use List::Util qw/sum first/;
use Scalar::Util qw/looks_like_number/;
use Cwd; use File::Basename;
use Grades;


=head1 SYNOPSIS

score_comp.pl -l . -r 10 > comp/10/scores.yaml

=cut


my $leagues = "/home/drbean/031";

my $script = Grades::Script->new_with_options;
my $id = $script->league || basename( getcwd );
my $round = $script->round;

my $league = League->new( leagues => $leagues, id => $id );
my $g = Compcomp->new( league => $league );

my $dir = $g->compcompdirs;
my $config = LoadFile "$dir/$round/round.yaml";
my $responses = LoadFile "$dir/$round/response.yaml";
my $groups = $config->{group};
my @tables = sort {$a <=> $b} keys % { $responses->{ free } };

my $scores;
my $divisions = $config->{divisions};
$divisions = [qw/free set/] unless $divisions;
for my $division ( @$divisions ) {
    if ( $division eq 'free' ) {
	for my $table ( @tables ) {
	    my %tally;
	    my $group = $groups->{$table};
	    my ($white, $black) = ( $group->{White}, $group->{Black} );
	    my %opponent; @opponent{$white, $black} = ($black, $white);
	    my $topics = $responses->{ $division }->{$table};
	    for my $topic ( keys %$topics ) {
		my $forms = $topics->{$topic};
		for my $form ( keys %$forms ) {
		    my $pairwork = $forms->{$form};
		    my @players = keys %$pairwork;
		    for my $player ( @players ) {
			my $score = 0;
			my $play = $pairwork->{$player};
			if ( first { $_ eq 'point' } keys %$play ) {
			    my $points = $play->{point};
			    for my $n ( keys %$points ) {
				my $point = $points->{$n};
				unless ( $point ) {
				warn
				    "Table $table, $topic $form FREE quiz, $player, qn $n: ,";
				next;
				}
				if ( $point and $point =~ m/Fault/ ) {
				    $tally{$player} += 0;
				    $tally{$opponent{$player}}++;
				}
				elsif ( $point and $point =~ m/Unreturned/ ) {
				    $tally{$player} += 1;
				}
				elsif ( $point and $point =~ m/Returned/ ) {
				    $tally{$player} += 0;
				    $tally{$opponent{$player}}++;
				}
				elsif ( $point and $point =~ m/Old/ ) {
				    $tally{$player} += 0;
				}
				elsif ( $point and $point =~ m/Nil/ ) {
				    $tally{$player} += 0;
				}
				else {
				    warn
					"Table $table, $topic $form FREE quiz, $player, qn $n: $point,";
				}
			    }
			}
			else {
			    my ( $qs, $as ) = @$play{qw/q a/};
			    for my $rs ( $qs, $as ) {
				for my $r ( keys %$rs ) {
				    my $point = $rs->{$r};
				    unless ( looks_like_number $point ) {
					$point = '';
					warn
		"Table $table FREE quiz, $player, qn $r: $point,";
					next;
				    }
				    $score += $point;
				}
			    }
			}
			$tally{$player} += $score;
		    }
		    @{$scores->{$table}}{keys %tally} = @tally{keys %tally};
		}
	    }
	}
    }
    elsif ( $division eq 'set' ) {
	my $cardfile = $config->{text};
	my $cards = LoadFile $cardfile or die "$cardfile card file?";
	for my $table ( @tables ) {
	    my $topics = $responses->{ $division }->{$table};
	    for my $topic ( keys %$topics ) {
		my $forms = $topics->{$topic};
		for my $form ( keys %$forms ) {
		    my %settally;
		    my $pairwork = $forms->{$form};
		    my @players = keys %$pairwork;
		    for my $player ( @players ) {
			die
	    "Table ${table}'s $player $responses to $topic quiz, form $form,"
							unless defined $pairwork;
			my $quiz =
				 $cards->{$topic}->{compcomp}->{$form}->{quiz};
			my ($codedvalue, $n);
			for my $item ( @$quiz ) {
			    if ( $item->{option} ) {
				my $option = $item->{option};
				$codedvalue->[++$n] = { map {
					$option->[$_] => $_ } 0..$#$option };
			    }
			    else {
				$codedvalue->[++$n] =
				    { True => 'T', False => 'F' }; }
			    }
			    my $score = 0;
			    my $answers = $pairwork->{$player};
			    for my $n ( sort keys %$answers ) {
				my $myanswer = $answers->{$n} // '';
				my $theanswer =
				    $quiz->[$n-1] && $quiz->[$n-1]->{answer}?
				    $codedvalue->[$n]->{
						    $quiz->[$n-1]->{answer} }:
				    '';
				unless ($myanswer eq 'T' or $myanswer eq 'F') {
				    warn
	    "Table $table, $topic $form set quiz, $player, qn $n: $myanswer,";
				    next;
				}
				unless ($theanswer eq 'T' or $theanswer eq 'F')
				{
				    die
		"Right answer is $theanswer, on set question $n" .
					    " in $topic $form quiz?";
				}
				$score++ if $myanswer eq $theanswer;
			    }
			    $scores->{$table}->{$player} += $score;
		    }
		}
	    }
	}
    }
}

Bless( $scores )->keys([ @tables ]);

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


