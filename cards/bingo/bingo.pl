#!/usr/bin/perl

# Last Edit: 2022 Oct 21,  4:11:12 PM
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
my $four = '';
my $five = '';

GetOptions (
        'help|?' => \$help, man => \$man
        , 'n=i' => \$n, 's=s' => \$s, 'f=i' => \$f
        , 'swap' => \$swap, 'reverse' => \$reverse
        , 'type=s' => \$type, 'paper=s' => \$paper
	, 'four' => \$four, 'five' => \$five
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
% \\usepackage[T1]{fontenc}
\\usepackage{fontspec}
\\usepackage{xltxtra}
\\setmainfont{Linux Libertine O}[Scale=MatchLowercase]
\\usepackage{xeCJK}
\\setCJKmainfont{NotoSansCJK-Regular.ttc}[
        Path = /usr/share/fonts/noto/,
]
% \\usepackage[absolute,noshowtext,showboxes]{textpos}
\\usepackage[absolute,showboxes]{textpos}
% \\textblockorigin{-0.02cm}{0.07cm} %HPDeskJet5160
% \\textblockorigin{0.00cm}{0.00cm} %HPDeskJet5160
% \\textblockorigin{-0.05cm}{0.13cm} %HPDeskJet5160
\\textblockorigin{0.00cm}{0.00cm} %HPLaserJet5000LE
\\usepackage{texdraw}
\\usepackage{multicol}
% \\usepackage{soul}
\\usepackage{tabto}
\\pagestyle{empty}
\\setlength{\\unitlength}{1cm}

\\NumTabs{4}

\\newcommand{\\bingoX${s}X$romanize{$f}Xcard}[5]{%
        \\vspace{0.1cm}
        \\small #1 #2
        \\par
        \\parbox[t][0.475\\paperheight][t]{0.46\\paperwidth}{%
        \\hspace{0.1cm} \\Large#3\\\\
        \\normalsize#4 #5
        }
}

START_LATEX

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

my $grid;
if ( $four ) {
	$grid = [
		{ x => 0, y => 0 }
		, { x => 2, y => 0 }
		, { x => 4, y => 0 }
		, { x => 6, y => 0 }
		, { x => 0, y => 1 }
		, { x => 2, y => 1 }
		, { x => 4, y => 1 }
		, { x => 6, y => 1 }
		, { x => 0, y => 2 }
		, { x => 2, y => 2 }
		, { x => 4, y => 2 }
		, { x => 6, y => 2 }
		, { x => 0, y => 3 }
		, { x => 2, y => 3 }
		, { x => 4, y => 3 }
		, { x => 6, y => 3 }
	];
}
elsif ( $five ) {
	$grid = [
		{ x => 0, y => 0 }
		, { x => 1.6, y => 0 }
		, { x => 3.2, y => 0 }
		, { x => 4.8, y => 0 }
		, { x => 6.4, y => 0 }
		, { x => 0,   y => 0.8 }
		, { x => 1.6, y => 0.8 }
		, { x => 3.2, y => 0.8 }
		, { x => 4.8, y => 0.8 }
		, { x => 6.4, y => 0.8 }
		, { x => 0,   y => 1.6 }
		, { x => 1.6, y => 1.6 }
		, { x => 3.2, y => 1.6 }
		, { x => 4.8, y => 1.6 }
		, { x => 6.4, y => 1.6 }
		, { x => 0,   y => 2.4 }
		, { x => 1.6, y => 2.4 }
		, { x => 3.2, y => 2.4 }
		, { x => 4.8, y => 2.4 }
		, { x => 6.4, y => 2.4 }
		, { x => 0,   y => 3.2 }
		, { x => 1.6, y => 3.2 }
		, { x => 3.2, y => 3.2 }
		, { x => 4.8, y => 3.2 }
		, { x => 6.4, y => 3.2 }
	];
}

my $latex = $layout->{$paper}->{latex};

my $paging = 0;
my $page_number = 0;


my $cards = LoadFile "$ARGV[0]/cards.yaml";

my $story = $cards->{$s};
die "No $s story" unless ref $story eq 'HASH';
my $identifier = "$s $f";
$identifier =~ s/_/ /;
$latexString .= "\\newcommand{\\bingoX${s}X$romanize{$f}XIdentifier}[0]{$identifier\n}\n\n";
my $bingo;
if ($type eq "match" && exists $story->{match} && exists $story->{match}->{$f} ) {
        $bingo = $story->{match}->{$f};
}
elsif ($type eq "flash" && exists $story->{flash} && exists $story->{flash}->{$f} ) {
        $bingo = $story->{flash}->{$f};
}
elsif ($type eq "bingo" && exists $story->{bingo} && exists $story->{bingo}->[$f] ) {
        $bingo = $story->{bingo}->[$f];
}
elsif (exists $story->{$f} and exists $story->{$f}->{bingo} ) {
        $bingo = $story->{$f}->{bingo};

}
else { die "No '$type' bingo for $s story, form $f" }

$latexString .= "\\begin{document}\n\n";

my (@words, %prompts);
if ( ref $bingo eq 'HASH' and exists $bingo->{pair} ) {
        my $pair = $bingo->{pair};
       my @prompts;
       if ( $swap ) {
               push @words, $pair->[$_]->[0] for (0..$#$pair);
               push @prompts, $pair->[$_]->[1] for (0..$#$pair);
       }
       else {
               push @words, $pair->[$_]->[1] for (0..$#$pair);
               push @prompts, $pair->[$_]->[0] for (0..$#$pair);
       }
       @prompts{@words} = @prompts;
       die "Unequal word, call numbers. Also check order"
               unless ( @words == @prompts );
}
elsif ( ref $bingo eq 'HASH' and exists $bingo->{word} and exists $bingo->{call} ) {
       @words = split m/ /, $bingo->{word};
       my @prompts = @{ $bingo->{call} };
       @prompts{@words} = @prompts;
       die "Unequal word, call numbers. Also check order"
               unless ( @words == @prompts );
}
elsif ( ref $bingo eq 'HASH' ) {
       @words = keys %$bingo;
       my @prompts = values %$bingo;
       if ( $swap ) {
               @words = values %$bingo;
               @prompts = keys %$bingo;
       }
       @prompts{@words} = @prompts;
       die "Unequal word, call numbers. Also check order"
               unless ( @words == @prompts );
}
elsif ( ref $bingo eq 'ARRAY' ) {
        my $n;
        for my $prompt ( @$bingo ) {
                (my $word = $prompt ) =~ s/^[^_]*_(.*)_.*$/$1/;
                push @words, $word;
                die "No $word word in ${n}th, \"$prompt\" prompt"
                        unless $word;
                $n++;
                $prompts{$word} = $prompt;
        }
}
else {
        @words = split m/ /, $bingo;
        @prompts{@words} = @words;
}

my (%word_count, %part_count);
$word_count{$_}++ for @words;
for my $word ( keys %prompts ) {
        for my $other ( keys %prompts ) {
                next if $word eq $other;
                my $prompt = $prompts{$other};
                my @noise = split /[-,._\s]/, $prompt;
                my @lc_noise = map (lc, @noise);
                my @parts = split m/[_\s]/, $word;
                my @lc_parts = map (lc, @parts);
                for my $part ( @lc_parts ) {
                        for my $dupe ( @lc_noise ) {
                                $part_count{$part}++ if 
                                        (($dupe eq $part)
                                                # or ($dupe =~ m/$part/)
                                                # or ($part =~ m/$dupe/)
                        );
                        }
                }
        }
}
for my $word ( @words ) {
        die "calling '$word' word $word_count{$word} times"
                unless $word_count{$word} == 1;
}
#for my $part ( keys %part_count ) {
#       die "'$part' dupe present $part_count{$part} times"
#               unless $part_count{$part} == 0;
#}
die "No word for some prompts" unless
        values %prompts == scalar @words;
        
warn "There are " . (sum values %word_count ) . " words\n";
my @clinchers = sample 2, @words;
my @winner = sample 1, @clinchers ;
my @loser = grep { $_ ne $winner[0] } @clinchers;
my %words; @words{ @words } = (); delete @words{@clinchers};
my @pruned = keys %words;
my (@call, @lost_call);
if ( ref $bingo eq 'HASH' and exists $bingo->{call} ) {
        push @call, "$_: $prompts{$_}" for (@pruned, @winner);
        push @lost_call, "$_: $prompts{$_}" for (@loser);

}
else {
        @call = @prompts{ @pruned, @winner };
        @lost_call = @prompts{@loser};
}

my $h2p = Lingua::Han::PinYin->new( tone => 1 );

sub translit {
        my $chinese = shift ;
        # return $chinese . "[" . $h2p->han2pinyin( $chinese ) . "]";
        return $chinese;
}

my $regex = qr/([\N{U+4E00}-\N{U+9FFF}]+)/;
s/$regex/translit($1)/ge for @call;
s/$regex/translit($1)/ge for @lost_call;

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
        my @candidate = sample 1, @clinchers;
        my @presented = sample @pruned/2, @pruned;
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

bingo.pl - Create bingo cards from list in cards.yaml

=head1 SYNOPSIS

perl ttb/cards/bingo/bingo.pl -n 15 -s cell_phones -f 0 topics/phones

=head1 DESCRIPTION

Makes n cards from fth bingo sequence in cell_phones mapping in topics/phones/cards.yaml. If 20 words, 10 are presented. 2 clinchers are reserved: one winner, one loser. The loser is shown by strikeout.

If word, call fields (mappings) exist in fth sequence in cards.yaml, or if the sequence is made up of calls of the form, "a prompt _including not an underscore_ in a string," a prompt is presented, instead of (in addition to) the word in the caller's card.

The reverse bingo option (--reverse) makes n cards with the prompts and one card is the bingo card with the words (answers).

The four & five options (--four, --five) places the 16 or 25 prompts in 4x4 or 5x5 grids.

The swap option (--swap) swaps first and second values of the match pairs (not bingo ones), to go from prompt-answer (word) pairings to the reverse, answer/word-prompt pairings.

=cut
