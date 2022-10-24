#!/usr/bin/perl

# Last Edit: 2022 Oct 24, 11:46:34 AM
# $Id: /dic/branches/ctest/dic.pl 1263 2007-06-23T12:37:20.810966Z greg  $

use strict;
use warnings;

use Getopt::Long;
use Pod::Usage;
use List::Util qw/sample sum/;
use List::MoreUtils qw/natatime/;

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

my %roman = (
        0 => "Zero", 1 => "I", 2 => "II", 3 =>"III"
        , 4 => "IV", 5 => "V", 6 => "VI", 7 =>"VII"
        , 8 => "VIII", 9 => "IX", 10 => "X", 11 =>"XI" 
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
\\textblockorigin{0.00cm}{0.00cm}
% \\usepackage{soul}
\\pagestyle{empty}
\\setlength{\\unitlength}{1cm}

START_LATEX

# my @form = split ',', $f;
# 
# for my $f (@form) {
	my $card_name = 'battleship' . ucfirst $s . $roman{$f} . 'Card';
	$latexString .= <<"CARD_COMMAND";
\\newcommand{\\$card_name}[2]{%
        \\vspace{0.1cm}
        \\small #1
        \\par
        \\parbox[t][0.475\\paperheight][t]{0.46\\paperwidth}{%
        \\hspace{0.1cm} \\Large#2\\\\
        }
}

CARD_COMMAND
# }

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

# for my $f ( @form ) {
	my $prompt = $story->{$type}->{$f}->{identifier};
	$prompt =~ s/_/ /;
	my $prompt_name = "battleship" . ucfirst $s . $roman{$f} . 'Prompt';
	$latexString .= "\\newcommand{\\$prompt_name}[0]{$prompt\n}\n\n";
	if ($type eq "match" && exists $story->{match} && exists $story->{match}->{$f} ) {
		$battleship = $story->{match}->{$f};
	}
	elsif ($type eq "flash" && exists $story->{flash} && exists $story->{flash}->{$f} ) {
		$battleship = $story->{flash}->{$f};
	}
	else { die "No '$type' battleship for $s story, form $f" }
# }
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
        die "Unequal x, y numbers in form $f match. Also check order"
                unless ( @x == @y );
}
elsif ( ref $battleship eq 'HASH' ) {
       @y = keys %$battleship;
       my @x = values %$battleship;
       die "Unequal x, y numbers in form $f flash. Also check order"
               unless ( @x == @y );
}
else {
	my $ref = ref $battleship;
	die "battleship $ref ref not a HASH";
}
my $xn = $#x + 1;
my $yn = $#y + 1;
my $column_width = 0.3/$xn . '\\paperwidth';
my $row_height = 1/$yn;

for my $card ( 0 .. $n-1 ) {
        $latexString .=
"\\TPshowboxestrue
\\begin{textblock}{8}($latex->[$paging]->{xy})
\\textblocklabel{picture$latex->[$paging]->{xy}}
\\$card_name {\\$prompt_name}{
\\begin{tabular}{l | *{$xn}{ | p{$column_width}}}";

	$latexString .= 'Y\\textbackslash X & ';
	$latexString .= join " & ", @x;
	$latexString .= "\\\\ \\hline \n";

	for my $y ( @y ) {
		$latexString .= $y;
		$latexString .= join " \& ", ('') x $yn;
		$latexString .= "\\\\ \\hline \n";
	}
		$latexString .= "\\end{tabular}\n";
		$latexString .= "}\n\\end{textblock}\n \\TPshowboxesfalse \n";
		&paging;
	}

$latexString .= "\\end{document}\n";

my $bio = io "$ARGV[0]/battleship_${s}_$f.tex";
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
