#!/usr/bin/perl

# Last Edit: 2015 Sep 29, 16:31:01
# $Id: /dic/branches/ctest/dic.pl 1263 2007-06-23T12:37:20.810966Z greg  $

use strict;
use warnings;

use Getopt::Long;
use Pod::Usage;
use Algorithm::Numerical::Sample qw/sample/;
use List::Util qw/sum/;

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

my %romanize = (
	0 => "Zero", 1 => "One", 2 => "Two", 3 =>"Three"
	, 4 => "Four", 5 => "Five", 6 => "Six", 7 =>"Seven"
	, 8 => "Eight", 9 => "Nine", 10 => "Ten", 11 =>"Eleven" 
);

my $latexString = <<"START_LATEX";
\\documentclass[a4paper]{article}
\\usepackage[T1]{fontenc}
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

\\newcommand{\\bingoX${s}X$romanize{$f}Xcard}[5]{%
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
my $identifier = "$s $f";
$identifier =~ s/_/ /;
$latexString .= "\\newcommand{\\bingoX${s}X$romanize{$f}XIdentifier}[0]{$identifier\n}\n\n";
my $bingo = $story->{bingo}->[$f];
$latexString .= "\\begin{document}\n\n";

my (@words, %prompts);
if ( ref $bingo eq 'HASH' and exists $bingo->{word} and exists $bingo->{call} ) {
	@words = split m/ /, $bingo->{word};
	my @prompts = @{ $bingo->{call} };
	@prompts{@words} = @prompts;
	die "Unequal word, call numbers. Also check order"
		unless ( @words == @prompts );
}
else {
	@words = split m/ /, $bingo;
	@prompts{@words} = @words;
}

my %word_count;
$word_count{$_}++ for @words;
for my $word ( @words ) {
	die "'$word' present $word_count{$word} times"
		unless $word_count{$word} == 1;
}
	
warn "There are " . (sum values %word_count ) . " words\n";
my @clinchers = sample( set => \@words, sample_size => 2 );
my @winner = sample( set => \@clinchers );
my @loser = grep { $_ ne $winner[0] } @clinchers;
my %words; @words{ @words } = (); delete @words{@clinchers};
my @pruned = keys %words;
my @call;
if ( ref $bingo eq 'HASH' and exists $bingo->{call} ) {
	push @call, "$_: $prompts{$_}" for (@pruned, @winner);
}
else {
	@call = @prompts{ @pruned, @winner };
}

$latexString .=
"\\begin{textblock}{8}($latex[$paging]->{xy})
\\textblocklabel{picture$latex[$paging]->{xy}}
\\bingoX${s}X$romanize{$f}Xcard{}{\\bingoX${s}X$romanize{$f}XIdentifier}{}
{\\parbox{9.0cm}{";
$latexString .= (s/_/\\_/g, "$_ \\hfill ") for @call;
$latexString .= (s/_/\\_/g, "\\st{ $_ } \\hfill ") for @loser;
$latexString .= "}}{} \n \\end{textblock}\n";
&paging;

for my $card ( 0 .. $n-1 ) {
	my @candidate = sample( set => \@clinchers );
	my @presented = sample( set => \@pruned, sample_size => @pruned/2);
	my @shuffled = shuffle (@presented, @candidate);

	$latexString .= 
"\\begin{textblock}{8}($latex[$paging]->{xy})
\\textblocklabel{picture$latex[$paging]->{xy}}
\\bingoX${s}X$romanize{$f}Xcard{}{\\bingoX${s}X$romanize{$f}XIdentifier}{\\parbox{9.0cm}{";
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

bingo.pl - Create bingo cards from list in cards.yaml

=head1 SYNOPSIS

perl ttb/cards/bingo/bingo.pl -n 15 -s cell_phones -f 0 topics/phones

=head1 DESCRIPTION

Makes n cards from fth bingo sequence in cell_phones mapping in topics/phones/cards.yaml. If 20 words, 10 are presented. 2 clinchers are reserved: one winner, one loser. The loser is shown by strikeout.

If word, call fields (mappings) exist in fth sequence in cards.yaml, a prompt is presented, instead of (in addition to) the word.

=cut
