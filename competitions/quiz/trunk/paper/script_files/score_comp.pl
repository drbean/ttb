#!/usr/bin/perl 

# Created: 西元2010年10月31日 19時06分22秒
# Last Edit: 2010 12月 10, 11時03分57秒
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
my $config = LoadFile "$dir/$round/round.yaml";
my $responses = LoadFile "$dir/$round/response.yaml";

my $scores;
for my $table ( keys %$responses ) {
    my %tally;
    my $topics = $responses->{$table};
    for my $topic ( keys %$topics ) {
	my $forms = $topics->{$topic};
	for my $form ( keys %$forms ) {
	    my $sources = $forms->{$form};
	    for my $source ( keys %$sources ) {
		my $pairwork = $sources->{$source};
		die
		"Table ${table}'s responses to $source $topic quiz, form $form,"
						unless defined $pairwork;
		my @players = keys %$pairwork;
		if ( $source eq 'free' ) {
		    for my $player ( @players ) {
			my $play = $pairwork->{$player};
			$tally{$player} += sum ( values( %{ $play->{q} } ),
					values( %{ $play->{a} } ) );
		    }
		}
		elsif ( $source eq 'set' ) {
		    my $cardfile = $config->{text};
		    my $cards = LoadFile $cardfile or die "$cardfile?";
		    my $quiz =
			     $cards->{$topic}->{compcomp}->{$form}->{quiz};
		    my ($codedvalue, $n);
		    for my $item ( @$quiz ) {
			if ( $item->{option} ) {
			    my $option = $item->{option};
			    $codedvalue->[$n++] = { map {
				    $option->[$_] => $_ } 0..$#$option };
			}
			else {
			    $codedvalue->[$n++] =
				{ True => 'T', False => 'F' }; }
			}
			for my $id ( @players ) {
			    my $score = 0;
			    for my $n ( 0 .. $#$quiz ) {
				my $myanswer = $pairwork->{$id}->{$n+1} //
					'??';
				my $theanswer = $codedvalue->[$n]->{
					$quiz->[$n]->{answer} };
				unless ($myanswer eq 'T' or $myanswer eq 'F') {
				    warn
		"${id}'s answer, $myanswer, to question " . ($n+1) .
			    " in " . $topic . $form . " quiz at Table $table,";
				    next;
				}
				unless ($theanswer eq 'T' or $theanswer eq 'F')
				{
				    die
		"Right answer is $theanswer, on question " . ($n+1) .
					    " in " . $topic . $form . " quiz?";
				}
				$score++ if $myanswer eq $theanswer;
			    }
			    $tally{$id} += $score;
		        }
		   }
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


