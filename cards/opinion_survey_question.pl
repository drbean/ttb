#!/usr/bin/perl

# Last Edit: 2016 Jan 07, 12:02:16
# $Id: /dic/branches/ctest/dic.pl 1263 2007-06-23T12:37:20.810966Z greg  $

use strict;
use warnings;
use utf8;

use Getopt::Long;
use Pod::Usage;

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

my %romanize = (
	0 => "Zero", 1 => "One", 2 => "Two", 3 =>"Three"
	, 4 => "Four", 5 => "Five", 6 => "Six", 7 =>"Seven"
	, 8 => "Eight", 9 => "Nine", 10 => "Ten", 11 =>"Eleven" 
);

my $latexString = <<"START_LATEX";
\\documentclass[a4paper]{article}
\\usepackage[T1]{fontenc}
\\usepackage[usenames]{xcolor}
\\usepackage{xeCJK}
\\setCJKmainfont{WenQuanYi Zen Hei}
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

\\newcommand{\\opinionX${s}X$romanize{$f}Xcard}[5]{%
	\\vspace{0.1cm}
	\\small #1 #2
	\\par
	\\parbox[t][6.7cm][c]{9.5cm}{%
	\\hspace{0.1cm} \\Large#3\\\\
	\\large #4 #5
	}
}

% \\newcommand{\\vote}[1]{\\leaders\\hbox{#1}\\hfill\\kern3pt\\n}
% \\newcommand{\\vote}[1]{#1\\hspace*{\\fill}}
\\newcommand\\vote{\\leavevmode\\xleaders\\hbox{\\Huge{\\textcolor{gray}{正}}}\\hfill\\kern2pt}

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
die "No $s story questions" unless ref $story eq 'HASH' # and 
	# exists $story->{opinion} and ref $story->{opinion} eq 'ARRAY'
	;
my $identifier = "$s $f";
$identifier =~ s/_/ /;
$latexString .= "\\newcommand{\\opinionX${s}X$romanize{$f}XIdentifier}[0]{$identifier\n}\n\n";
my $question = $story;
$latexString .= "\\begin{document}\n\n";

for my $surveyor ( keys %$story ) {
	my $questions = $story->{$surveyor};
	for my $question (0 .. $#$questions) {
		$latexString .= 
	"\\TPshowboxestrue
	\\begin{textblock}{8}($latex[$paging]->{xy})
	\\textblocklabel{picture$latex[$paging]->{xy}}
	\\opinionX${s}X$romanize{$f}Xcard{}{\\opinionX${s}X$romanize{$f}XIdentifier $surveyor}{\\parbox{9.0cm}{";
		$latexString .= "\\bfseries{Question:} $story->{$surveyor}->[$question]->{question} \\\\ }}";
		$latexString .= "{\\bfseries{Answers}
							\\begin{itemize}
							\\item $story->{$surveyor}->[$question]->{option}->[0] \\vote{.}
							\\item $story->{$surveyor}->[$question]->{option}->[1] \\vote{.}
							\\item $story->{$surveyor}->[$question]->{option}->[2] \\vote{.}
							\\end{itemize} }
							{} \n \\end{textblock}\n \\TPshowboxesfalse \n";
		&paging;
	}
}
$latexString .= "\\end{document}\n";

my $bio = io "$ARGV[0]/opinion_${s}_$f.tex";
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

opinion.pl - Create opinion cards from list in cards.yaml

=head1 SYNOPSIS

perl ttb/cards/opinion/opinion.pl -n 15 -s cell_phones -f 0 topics/phones

=head1 DESCRIPTION

Makes n cards from fth bingo sequence in cell_phones mapping in topics/phones/cards.yaml. If 20 words, 10 are presented. 2 clinchers are reserved: one winner, one loser. The loser is shown by strikeout.

If word, call fields (mappings) exist in fth sequence in cards.yaml, or if the sequence is made up of calls of the form, "a prompt _including not an underscore_ in a string," a prompt is presented, instead of (in addition to) the word in the caller's card.

=cut
