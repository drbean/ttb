#!/usr/bin/perl

# Last Edit: 2008 11月 04, 13時13分15秒
# $Id: /dic/branches/ctest/dic.pl 1263 2007-06-23T12:37:20.810966Z greg  $

use strict;
use warnings;

use Getopt::Long;
use Pod::Usage;
use Algorithm::Numerical::Sample qw/sample/;
use List::Util qw/shuffle/;

my $man = 0;
my $help = 0;

GetOptions (
	'help|?' => \$help, man => \$man) or pod2usage(2);
pod2usage(1) if $help;
pod2usage(-exitstatus => 0, -verbose => 2) if $man;

use IO::All;
use YAML qw/LoadFile DumpFile/;
use Text::Template;
use Cloze qw/cloze/;
use List::Util qw/max/;

our $RD_HINT = 1;

my $round = LoadFile( "round.yaml" );
my $league = LoadFile( "../league.yaml" );
my @members = @{$league->{member}};
my %ids = map { $_->{name} => $_->{id} } @members;
my %names = map { $_->{id} => $_->{name} } @members;

my $textSources = $round->{texts};
my $next = iteratorgenerator(@$textSources);
my $questionN = $round->{questions};
my $qNumber = max @$questionN;

my $tmpl = io 'dic.tmpl';
my $tmplString = $tmpl->all;

my $groups = $round->{group};

my @latex = (
		{ page => 1, xy => "8,0" },
		{ page => 1, xy => "0,0" },
		{ page => 1, xy => "8,8" },
		{ page => 1, xy => "0,8" },
		{ page => 2, xy => "8,0" },
		{ page => 2, xy => "0,0" },
		{ page => 2, xy => "8,8" },
		{ page => 2, xy => "0,8" },
		{ page => 3, xy => "8,0" },
		{ page => 3, xy => "0,0" },
		{ page => 3, xy => "8,8" },
		{ page => 3, xy => "0,8" },
	);
my $paging = 0;
my $threepages = 0;

foreach my $group ( keys %$groups )
{
	my %group =  %{$groups->{$group}}; 
	my $file = $next->();
	my $questions = LoadFile $file;
	for my $player ( values %group )
	{
		$tmplString .= "
\\begin{textblock}{8}($latex[$paging]->{xy})
\\textblocklabel{picture$latex[$paging]->{xy}}
";
		my $n = 0;
		$tmplString .= "\\myblock\n" .
		(join "\n", map {
"{\\myshortquestion
{" . ( $_+1 ) . ". $questions->[$_]->[0]}
{$questions->[$_]->[1]}
{$questions->[$_]->[2]}
{$questions->[$_]->[3]}
{$questions->[$_]->[4]}}" } 0..3 ) . "\n" .
			(join "\n", map {
"{\\myquestion
{" . ( $_+1 ) . ". $questions->[$_]->[0]}
{$questions->[$_]->[1]}
{$questions->[$_]->[2]}
{$questions->[$_]->[3]}}" } 4..8 ) . "\n";
		$tmplString .= "\\par\n";
		$tmplString .= "\\end{textblock}\n";

			&paging;
	}
}

$tmplString .= '
\end{document}
';

my $quiz;
# $quiz->{cardIdentifier} = join ' ', map { s{.*/(\w+)$}{$1} } @$textSources;
$quiz->{cardIdentifier} = join ' ', map { m{^/.*?/.*?/(.*)$};$1 } @$textSources;
# ($quiz->{cardIdentifier} = $textSources ) =~ 
				# s{.*/(\w+/\w+)/?$}{$1};
				# s{.*/(\w+/(?:dic|cloze|book)\d?)\.txt$}{$1};
				# s|.*/(\S+/\S+).txt$|$1|;
$quiz->{autogen} = "% This file, cards.tex was autogenerated on " . localtime() . "by dic.pl out of dic.tmpl";
$quiz->{questionN} = $qNumber;
$quiz->{questions} = join "\n", map { "\\item #$_\n\\vspace{-0.1cm}"
	} 1..$qNumber;

my $template = Text::Template->new(TYPE => 'STRING', SOURCE => $tmplString
				, DELIMITERS => [ '<TMPL>', '</TMPL>' ] );
open TEX, ">cards.tex";
print TEX $template->fill_in( HASH => $quiz );

sub paging
{       if ($paging == 3 or $paging == 7 or $paging == 11 )
        {
                $tmplString .= "
\\begin{tiny}" . ($threepages + $latex[$paging]->{page}) .                      +"\\end{tiny}\\newpage\n\n";
        }
        if ($paging == 11) { $threepages = $threepages+3; $paging = 0; }
        else { $paging++; }
}

sub iteratorgenerator
{
	my @files = @_;
	my $number = @files;
	my $index = 0;
	my $nextText;
	return sub
	{
		my $nextFile = $files[$index];
		if (++$index == $number)
		{
			$index = 0;
			@files[0..$number-1] = @files[shuffle(0..$number-1)];
		}
		return $nextFile;
	}
}

__END__

=head1 NAME

Answer sheet for 4-player relation/identity determination exercise

=head1 SYNOPSIS

./dic.pl

./form.pl

./scoresheet.pl

./grade

=head1 DESCRIPTION

B<dic.pl> generates answers from questions of form
 -
   - "What is the relation of A and B?"
   - "A is part of B, or vice versa."
   - "A is part of something which is part of B."
   - "A and B are both part of something else."

These questions are in a file referenced in round.yaml, questions.

B<form.pl> makes up the form for the other side of the piece of paper.

B<scoresheet.pl> creates B<scores.yaml>, a YAML-style template file that can be filled in with the number of letters correct.

B<grade> grades the scores and writes a report.

=cut
