#!/usr/bin/perl

# Last Edit: 2013 Oct 13, 03:27:41 PM
# $Id: /dic/branches/ctest/dic.pl 1263 2007-06-23T12:37:20.810966Z greg  $

use strict;
use warnings;

use Getopt::Long;
use Pod::Usage;
use Algorithm::Numerical::Sample qw/sample/;

my $man = 0;
my $help = 0;
my $n = 7;

GetOptions (
	'help|?' => \$help, man => \$man, 'n=i' => \$n) or pod2usage(2);
pod2usage(1) if $help;
pod2usage(-exitstatus => 0, -verbose => 2) if $man;

use IO::All;
use YAML qw/LoadFile DumpFile/;
use List::Util qw/shuffle/;

my $latexString;
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


my $cards = LoadFile "$ARGV[0]/cards.yaml";

for my $s ( keys %$cards ) {
	my $story = $cards->{$s};
	next unless ref $story eq 'HASH';
	my $identifier = $s;
	my $bingo = $story->{bingo};
	my $f = 0;
	for my $words ( @$bingo ) {
		my @words = split m/ /, $words;
		my @clinchers = sample( set => \@words, sample_size => 2 );
		my $winner = sample( set => \@clinchers );
		my @call =	grep
						{ my $word = $_; grep { $_ eq $word } @clinchers }
					@words;
		my $bio = io "$ARGV[0]/bingo_${s}_+$f.tex";

		$latexString = <<"END_LATEX";

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

\\newcommand{\\myIdentifier}[0]{
$identifier
}

\\newcommand{\\mycard}[5]{%
	\\vspace{0.1cm}
	\\small #1 #2
	\\par
	\\parbox[t][6.7cm][c]{9.5cm}{%
	\\hspace{0.1cm} \\Large#3\\\\
	\\normalsize#4 #5
	}
}

\\begin{document}
\\fontfamily{hlst}\\fontseries{b}\\fontshape{n}\\selectfont
% \\begin{picture}(15,20)(+4.8,-22.05)
% \\begin{tabular}[t]{*{2}{|p{10.05cm}}|}

\\begin{textblock}{8}(0,0)
\\textblocklabel{picture1}
\\mycard{}{\\myIdentifier}{
}
{\\parbox{9.0cm}{

END_LATEX

		$latexString .= "$_ \\hfill " for @words;

		$latexString .= 
			"}}{} 
		\end{textblock}\n";
		for my $card ( 0 .. $n-1 ) {
			my $candidate = sample( set => \@clinchers );
			my @presented = shuffle (@words, $candidate);

			$latexString .= 
				"\\begin{textblock}{8}($latex[$paging]->{xy})
				\\textblocklabel{picture$latex[$paging]->{xy}}
				\\mycard{";
			$latexString .= "$_ \\hfill " for @words;
				"\\end{textblock}\n";

			&paging;
		$latexString .= "\\end{document}\n";
		$bio->print( $latexString );
		}



	}

}

sub paging
{       if ($paging == 3 or $paging == 7 or $paging == 11 )
        {
                $latexString .= "
\\begin{tiny}" . ($threepages + $latex[$paging]->{page}) .                      +"\\end{tiny}\\newpage\n\n";
        }
        if ($paging == 11) { $threepages = $threepages+3; $paging = 0; }
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
