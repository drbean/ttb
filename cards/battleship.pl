#!/usr/bin/perl

# Last Edit: 2022 Oct 22, 10:29:32 PM
# $Id: /dic/branches/ctest/dic.pl 1263 2007-06-23T12:37:20.810966Z greg  $

use strict;
use warnings;

use Getopt::Long;
use Pod::Usage;
use List::Util qw/sample sum/;
use List::MoreUtils qw/natatime/;
use Lingua::Han::PinYin;

my $man = 0;
my $help = 0;
my $n = 7;
my $s = '';
my $f = 0;
my $reverse = '';
my $swap = '';
my $type = '';
my $paper = 'a7';

GetOptions (
        'help|?' => \$help, man => \$man
        , 'n=i' => \$n, 's=s' => \$s, 'f=s' => \$f
        , 'swap' => \$swap, 'reverse' => \$reverse
        , 'type=s' => \$type, 'paper=s' => \$paper
                ) or pod2usage(2);
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
\\usepackage{fontspec}
\\usepackage{xltxtra}
\\setmainfont{Linux Libertine O}[Scale=MatchLowercase]
\\usepackage{xeCJK}
\\setCJKmainfont{NotoSansCJK-Regular.ttc}[
        Path = /usr/share/fonts/noto/,
]
% \\usepackage[absolute,noshowtext,showboxes]{textpos}
\\usepackage[absolute,showboxes]{textpos}
\\textblockorigin{0.00cm}{0.00cm} %HPLaserJet5000LE
% \\usepackage{soul}
\\pagestyle{empty}
\\setlength{\\unitlength}{1cm}

START_LATEX

my @form = split ',', $f;

for my $f (@form) {
	$latexString .= <<"CARD_COMMAND"
\\newcommand{\\battleshipX${s}X$romanize{$f}Xcard}[5]{%
        \\vspace{0.1cm}
        \\small #1 #2
        \\par
        \\parbox[t][0.475\\paperheight][t]{0.46\\paperwidth}{%
        \\hspace{0.1cm} \\Large#3\\\\
        \\normalsize#4 #5
        }
}

CARD_COMMAND
}

my $layout = { a7 => { latex => [
                        { page => 1, x => "0", y => "0" , xy => "0,0" },
                        { page => 1, x => "8", y => "0" , xy => "8,0" },
                        { page => 1, x => "0", y => "4" , xy => "0,4" },
                        { page => 1, x => "8", y => "4" , xy => "8,4" },
                        { page => 1, x => "0", y => "8" , xy => "0,8" },
                        { page => 1, x => "8", y => "8" , xy => "8,8" },
                        { page => 1, x => "0", y => "12", xy => "0,12" },
                        { page => 1, x => "8", y => "12", xy => "8,12" },
                ],
                i => 3},
        a6 => { latex => [
                        { page => 1, xy => "8,0" },
                        { page => 1, xy => "0,0" },
                        { page => 1, xy => "8,8" },
                        { page => 1, xy => "0,8" },
                ],
                i => 5}
};

my $latex = $layout->{$paper}->{latex};

my $paging = 0;
my $page_number = 0;


my $cards = LoadFile "$ARGV[0]/cards.yaml";

my $story = $cards->{$s};
die "No $s story" unless ref $story eq 'HASH';
my $battleship;

for my $f ( @form ) {
	my $prompt = $story->{$f}->{identifier};
	$prompt =~ s/_/ /;
	$latexString .= "\\newcommand{\\battleshipX${s}X$romanize{$f}XPrompt}[0]{$prompt\n}\n\n";
	if ($type eq "match" && exists $story->{match} && exists $story->{match}->{$f} ) {
		$battleship = $story->{match}->{$f};
	}
	elsif ($type eq "flash" && exists $story->{flash} && exists $story->{flash}->{$f} ) {
		$battleship = $story->{flash}->{$f};
	}
	else { die "No '$type' battleship for $s story, form $f" }
}
$latexString .= "\\begin{document}\n\n";

my (@x, @y);
if ( ref $battleship eq 'HASH' and exists $battleship->{pair} ) {
        my $pair = $battleship->{pair};
        if ( $swap ) {
                push @y, $pair->[$_]->[0] for (0..$#$pair);
                push @x, $pair->[$_]->[1] for (0..$#$pair);
        }
        else {
                push @x, $pair->[$_]->[1] for (0..$#$pair);
                push @y, $pair->[$_]->[0] for (0..$#$pair);
        }
        die "Unequal x, y numbers. Also check order"
                unless ( @x == @y );
}
elsif ( ref $battleship eq 'HASH' ) {
       @y = keys %$battleship;
       my @x = values %$battleship;
       die "Unequal x, y numbers. Also check order"
               unless ( @x == @y );
}
else {
	my $ref = ref $battleship;
	die "battleship $ref ref not a HASH";
}

my $prompt_n = $reverse? $n-2 : 0 ;
for my $prompt ( 0 .. $prompt_n ) {
        $latexString .=
"\\TPshowboxestrue
\\begin{textblock}{8}($latex->[$paging]->{xy})
\\textblocklabel{picture$latex->[$paging]->{xy}}
\\bingoX${s}X$romanize{$f}Xcard{}{\\bingoX${s}X$romanize{$f}XIdentifier}{}{";
	if ( $reverse ) {
		my @call_all = (@call, @lost_call);
		if ( $five or $four ) {
			for my $pos ( 0 .. $#call_all ) {
				my $cell = ( $latex->[$paging]->{x}
					+ $grid->[$pos]->{x} ) . "," .
					( $latex->[$paging]->{y}
					+ $grid->[$pos]->{y} );
				my $width = $five ? 1.6 : 2;
				my $height = $five ? 0.016 : 0.02;
				$latexString .=
				"\\begin{textblock}{$width}($cell)
				\\vspace*{$height\\paperheight}
				\\center $call_all[$pos]
				\\vspace*{$height\\paperheight}
				\\vfill
				\\end{textblock}";
				}
		}
		else {
			$latexString .= "\\large\n" if $reverse;
			$latexString .= "\\begin{multicols}{4}";
			$latexString .= (s/_/\\_/g, "- $_\\\\") for sort @call_all;
			$latexString .= "\\end{multicols}";
		}
	}
	else {
		$latexString .= (s/_/\\_/g, "$_ ") for @call;
		$latexString .= (s/_/\\_/g, "XX${_}XX ") for @lost_call;
	}
        $latexString .= "}{} \n \\end{textblock}\n \\TPshowboxesfalse \n";
        &paging;
}

my $card_n = $reverse? 0 : $n-2;
for my $card ( 0 .. $card_n ) {
        my @candidate = sample( set => \@clinchers );
        my @presented = sample( set => \@pruned, sample_size => @pruned/2);
        my ( @ordered, $it );
        if  ( $card % 2 == 0 ) {
                @ordered = sort {$a cmp $b} (@presented, @candidate);

        }
        else {
                @ordered = sort {$b cmp $a} (@presented, @candidate);
        }
        $it = natatime 3, @ordered;

        $latexString .= 
"\\TPshowboxestrue
\\begin{textblock}{8}($latex->[$paging]->{xy})
\\textblocklabel{picture$latex->[$paging]->{xy}}
\\bingoX${s}X$romanize{$f}Xcard{}{\\bingoX${s}X$romanize{$f}XIdentifier}{\\parbox{9.0cm}{";
        while ( my @word = $it->() ) {
                tr/_/~/ for @word;
		$latexString .= "\\begin{multicols}{4}";
		if ( $word[2] ) {
			$latexString .= "- $word[0] \\\\ - $word[1] \\\\ - $word[2] \\hspace{0pt}\\\\";
		}
		elsif ( $word[1] ) {
			$latexString .= "- $word[0] \\\\ - $word[1] \\hspace{0pt}\\\\";
		}
		else {
			$latexString .= "- $word[0] \\hspace{0pt}\\\\";

		}
		$latexString .= "\\end{multicols}";
        }
        $latexString .= "}}{}{} \n \\end{textblock}\n \\TPshowboxesfalse \n";
        &paging;
}
$latexString .= "\\end{document}\n";

my $bio = io "$ARGV[0]/bingo_${s}_$f.tex";
$bio->print( $latexString );

sub paging
{       
        if ( $paper eq 'a7' ) {
                if ($paging == 7 or $paging == 15 or $paging == 23 ) {
                        $latexString .= "
                \\begin{tiny}" . ($page_number + $latex->[$paging]->{page}) .
                        "\\end{tiny}\\newpage\n\n";
                        }
                if ($paging == 7) { $page_number++; $paging = 0; }
                else { $paging++; }
        }
        if ( $paper eq 'a6' ) {
                if ($paging == 3 or $paging == 7 or $paging == 11 or $paging == 15 ) {
                        $latexString .= "
                \\begin{tiny}" . ($page_number + $latex->[$paging]->{page}) .
                        "\\end{tiny}\\newpage\n\n";
                        }
                if ($paging == 3) { $page_number++; $paging = 0; }
                else { $paging++; }
        }
}

__END__

=head1 NAME

battleships.pl - Create battleships cards from list in cards.yaml

=head1 SYNOPSIS

perl ttb/cards/battleships.pl -n 16 -s cell_phones -f 0 topics/phones

=head1 DESCRIPTION

Makes n battleship cards from fth match sequence in cell_phones mapping in topics/phones/cards.yaml. If f is an integer comma-separated string, makes multiple battleship grids.

The identifier in the fth match, of the form, 'Is Y calling, or will Y call, X?' is used as prompt.

The keys (first values) in the fth match sequence pairs go down the Y axis on the left, and the values (the second values of the pairs) go along the X axis at the top.

The swap option (--swap) swaps first and second values of the match pairs, so the first values go along the X axis and the second ones go down the Y axis.

The reverse battleships option (--reverse) is reserved for some future use.

=cut
