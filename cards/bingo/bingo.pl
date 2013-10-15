#!/usr/bin/perl

# Last Edit: 2013 Oct 15, 12:19:40 PM
# $Id: /dic/branches/ctest/dic.pl 1263 2007-06-23T12:37:20.810966Z greg  $

use strict;
use warnings;

use Getopt::Long;
use Pod::Usage;
use Algorithm::Numerical::Sample qw/sample/;

my $man = 0;
my $help = 0;
my $n = 7;
my $s = '';
my $f = 0;

GetOptions (
	'help|?' => \$help, man => \$man,
	'n=i' => \$n, 's=s' => \$s, 'f=i' => \$f)
		or pod2usage(2);
pod2usage(1) if $help;
pod2usage(-exitstatus => 0, -verbose => 2) if $man;

use IO::All;
use YAML qw/LoadFile DumpFile/;
use List::Util qw/shuffle/;

my $latexString = <<"START_LATEX";
\\documentclass[a4paper]{article}
\\usepackage[T1]{fontenc}
% \\usepackage[absolute,noshowtext,showboxes]{textpos}
\\usepackage[absolute,showboxes]{textpos}
% \\textblockorigin{-0.02cm}{0.07cm} %HPDeskJet5160
% \\textblockorigin{0.00cm}{0.00cm} %HPDeskJet5160
% \\textblockorigin{-0.05cm}{0.13cm} %HPDeskJet5160
\\textblockorigin{0.00cm}{0.00cm} %HPLaserJet5000LE
\\usepackage{texdraw}
\\usepackage{multicol}
\\usepackage{soul}
\\pagestyle{empty}
\\setlength{\\unitlength}{1cm}

\\newcommand{\\mycard}[5]{%
	\\vspace{0.1cm}
	\\small #1 #2
	\\par
	\\parbox[t][6.7cm][c]{9.5cm}{%
	\\hspace{0.1cm} \\Large#3\\\\
	\\normalsize#4 #5
	}
}

START_LATEX

my @latex = (
		{ page => 1, xy => "0,0" },
		{ page => 1, xy => "0,4" },
		{ page => 1, xy => "8,0" },
		{ page => 1, xy => "8,4" },
		{ page => 1, xy => "0,8" },
		{ page => 1, xy => "0,12" },
		{ page => 1, xy => "8,8" },
		{ page => 1, xy => "8,12" },
		{ page => 2, xy => "0,0" },
		{ page => 2, xy => "0,4" },
		{ page => 2, xy => "8,0" },
		{ page => 2, xy => "8,4" },
		{ page => 2, xy => "0,8" },
		{ page => 2, xy => "0,12" },
		{ page => 2, xy => "8,8" },
		{ page => 2, xy => "8,12" },
		{ page => 3, xy => "0,0" },
		{ page => 3, xy => "0,4" },
		{ page => 3, xy => "8,0" },
		{ page => 3, xy => "8,4" },
		{ page => 3, xy => "0,8" },
		{ page => 3, xy => "0,12" },
		{ page => 3, xy => "8,8" },
		{ page => 3, xy => "8,12" },
	);
my $paging = 0;
my $threepages = 0;


my $cards = LoadFile "$ARGV[0]/cards.yaml";

my $story = $cards->{$s};
die "No $s story bingo" unless ref $story eq 'HASH' and
	exists $story->{bingo} and ref $story->{bingo} eq 'ARRAY';
my $identifier = $s;
$identifier =~ s/_/ /;
$latexString .= "\\newcommand{\\myIdentifier}[0]{$identifier\n}";
my $bingo = $story->{bingo}->[$f];
$latexString .= "\\begin{document}\n";

my @words = split m/ /, $bingo;
my @clinchers = sample( set => \@words, sample_size => 2 );
my @winner = sample( set => \@clinchers );
my @loser = grep { $_ ne $winner[0] } @clinchers;
my %words; @words{ @words } = (); delete @words{@clinchers};
my @pruned = keys %words;
my @call =	(@pruned, @winner);

$latexString .=
"\\begin{textblock}{8}($latex[$paging]->{xy})
\\textblocklabel{picture$latex[$paging]->{xy}}
\\mycard{}{\\myIdentifier}{}
{\\parbox{9.0cm}{";
$latexString .= (s/_/\\_/g, "$_ \\hfill ") for @call;
$latexString .= "\\st{ $_ } \\hfill " for @loser;
$latexString .= "}}{} \n \\end{textblock}\n";
&paging;

for my $card ( 0 .. $n-1 ) {
	my @candidate = sample( set => \@clinchers );
	my @presented = sample( set => \@pruned, sample_size => @pruned/2);
	my @shuffled = shuffle (@presented, @candidate);

	$latexString .= 
"\\begin{textblock}{8}($latex[$paging]->{xy})
\\textblocklabel{picture$latex[$paging]->{xy}}
\\mycard{}{\\myIdentifier}{\\parbox{9.0cm}{";
	for my $word ( @shuffled ) {
		$word =~ tr/_/~/;
		$latexString .= "$word \\hfill ";
	}
	$latexString .= "}}{}{} \n \\end{textblock}\n";
	&paging;
}
$latexString .= "\\end{document}\n";

my $bio = io "$ARGV[0]/bingo_${s}_$f.tex";
$bio->print( $latexString );

sub paging
{       if ($paging == 7 or $paging == 15 or $paging == 23 )
        {
                $latexString .= "
\\begin{tiny}" . ($threepages + $latex[$paging]->{page}) .                      +"\\end{tiny}\\newpage\n\n";
        }
        if ($paging == 23) { $threepages = $threepages+3; $paging = 0; }
        else { $paging++; }
}

__END__

=head1 NAME

Ctest-clozed format for exam-type pair dictation

=head1 SYNOPSIS

./dic.pl

./form.pl

./scoresheet.pl

./grade

=head1 DESCRIPTION

B<dic.pl> generates parallel forms for 2 or 3 conversations from a multiple number of files in directories corresponding to the conversations.

This makes it suitable for a number of different short conversations making up one pair dictation exam sheet.

B<Ctest> clozes only the second half of the word.

B<form.pl> makes up the form for the other side of the piece of paper.

B<scoresheet.pl> creates B<scores.yaml>, a YAML-style template file that can be filled in with the number of letters correct.

B<grade> grades the scores and writes a report.

=cut
