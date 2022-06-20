#!/usr/bin/perl

# Last Edit: 2022 Jun 20, 12:06:40 PM
# $Id: /dic/branches/ctest/dic.pl 1263 2007-06-23T12:37:20.810966Z greg  $

use strict;
use warnings;

use Getopt::Long;
use Pod::Usage;
use List::Util qw/sum all sample/;

my $man = 0;
my $help = 0;
my $n = 8;
my $t = 1;
my $s = '';
my $f = 0;
my $nine = '';
my $sixteen = '';
my $pair = '';
my ($tl, $tm, $tr, $ml, $mm, $mr, $bl, $bm, $br) = 9 x (0);

GetOptions (
	'help|?' => \$help, man => \$man,
	't=i' => \$t, 'n=i' => \$n, 's=s' => \$s, 'f=i' => \$f
	, 'nine' => \$nine, 'sixteen' => \$sixteen, 'pair' => \$pair
	, 'bl' => $bl, 'bm' => $bm, 'br' => $br
	, 'ml' => $ml, 'mm' => $mm, 'mr' => $mr
	, 'fl' => $fl, 'fm' => $fm, 'fr' => $fr
) 
		or pod2usage(2);
pod2usage(1) if $help;
pod2usage(-exitstatus => 0, -verbose => 2) if $man;

use IO::All;
use YAML qw/LoadFile DumpFile/;

my %corner = ( 
	'bl' => $bl, 'bm' => $bm, 'br' => $br
	, 'ml' => $ml, 'mm' => $mm, 'mr' => $mr
	, 'fl' => $fl, 'fm' => $fm, 'fr' => $fr
);
my %romanize = (
	0 => "Zero", 1 => "One", 2 => "Two", 3 =>"Three"
	, 4 => "Four", 5 => "Five", 6 => "Six", 7 =>"Seven"
	, 8 => "Eight", 9 => "Nine", 10 => "Ten", 11 =>"Eleven" 
);

my $latex;
my $cards = LoadFile "$ARGV[0]/cards.yaml";

my $story = $cards->{$s};
die "No $s story" unless ref $story eq 'HASH';
my $identifier = "$s $f";
$identifier =~ s/_/ /;
$latex->{identifier} = $identifier;
my $flashcard;
if (exists $story->{match} && exists $story->{match}->{$f} ) {
        $flashcard = $story->{match}->{$f};
}
elsif (exists $story->{flash} && exists $story->{flash}->{$f} ) {
	$flashcard = $story->{flash}->{$f};
}
else { die "No match/flash $s story, form $f cards\n" }

my @pic;
if ( ref $flashcard eq 'HASH' and exists $flashcard->{pair} ) {
	my $pair = $flashcard->{pair};
	push @pic, $pair->[$_]->[1] for (0..$#$pair);
}
elsif ( ref $flashcard eq 'HASH' ) {
		@pic = values %$flashcard;
}
else { die "$s story. form $f format is match or flash?\n" }

my %picked;
for my $pick ( keys %corner ) {
	if ( $corner{$pick} ) {
		$latex->{$pick} = $corner{$pick} . ".jpg";
		$picked{$pick} = $corner{$pick};
		$n--;
	}
}
	if ( @pic > $n ) {
		my @sample = sample( $n, @pic );
		@pic = @sample;
	}
	if ( @words < $n ) {
		my @extra = sample( $n, @pic );
		push @pic, @extra;
	}

	for my $card ( keys %prompts, values %prompts ) {

		if ( $sixteen and $card !~ m/^[-_[:alnum:]]+\.(png|jpg|gif)$/) {
			my $upside_down_xy = "$latex[$paging]->{x}," . ($latex[$paging]->{y} + 2);
			$latexString .= "
	\\TPshowboxestrue
	\\begin{textblock}{$width}($latex[$paging]->{xy})
	\\textblocklabel{playingcard$latex[$paging]->{xy}}
	\\playingX${s}X$romanize{$f}Xcard{\\flashcardX${s}X$romanize{$f}XIdentifier}{%
	$card \\hfill}
	%\\begin{textblock}{$width}($upside_down_xy)
	%\\textblocklabel{bottombox$upside_down_xy}
	%\\rotatebox[origin=rB]{180}{
	%\\wordX${s}X$romanize{$f}Xcard{}{%
	%$card \\hfill}} \\\\
	%\\vspace{0.5cm}
	%\\flushright \\rotatebox[origin=c]{180}{\\small \\flashcardX${s}X$romanize{$f}XIdentifier}
	%\\vfill
	\\end{textblock}\n \\TPshowboxesfalse \n";
		}
		else {
			$latexString .= 
	"\\TPshowboxestrue
	\\begin{textblock}{$width}($latex[$paging]->{xy})";
			if ( $card =~ m/^[-_[:alnum:]]+\.(png|jpg|gif)$/ ) {
				$latexString .= "
	\\textblocklabel{picture$latex[$paging]->{xy}}
	\\pictureX${s}X$romanize{$f}Xcard{\\flashcardX${s}X$romanize{$f}XIdentifier}{%
	\\includegraphics[angle=00,height=$pic_height,width=$pic_width]{$card}";
			}
			else {
				$latexString .= "
	\\textblocklabel{word$latex[$paging]->{xy}}
	\\wordX${s}X$romanize{$f}Xcard{\\flashcardX${s}X$romanize{$f}XIdentifier}{%
	$card \\hfill";
			}
			$latexString .= "
	} \n \\end{textblock}\n %\\TPshowboxesfalse \n";
		}
		&paging;
	}
	$lastcard = 1;
	$latexString .= "
\\begin{tiny}$latex[$paging]->{page}\\end{tiny}\\newpage\n\n" unless
		$paging == $fullpage or
		$paging == 2*$fullpage or
		$paging == 3*$fullpage;
		$paging = 0;
	}
$latexString .= "\\end{document}\n";

my $bio = io "$ARGV[0]/flash_${s}_$f.tex";
$bio->print( $latexString );

sub paging
{
	my $end_check = $paging == $fullpage or
		$paging == 2*$fullpage or
		$paging == 3*$fullpage;
	if ($paging == $fullpage-1 or $paging == 2*$fullpage-1 or $paging == 3*$fullpage-1 )
	{
		$latexString .= "
\\begin{tiny}$latex[$paging]->{page}\\end{tiny}\\newpage\n\n";
		$paging++;

	}
	elsif ($paging == 3*$fullpage-1) { $paging = 0; }
	else { $paging++; }
}

__END__

=head1 NAME

flashcard.pl - Create flashcard cards from list in cards.yaml

=head1 SYNOPSIS

perl ttb/cards/flashcard.pl -t 3 -n 4 -s cell_phones -f 0 topics/phones

=head1 DESCRIPTION

Makes n cards from fth flashcard sequence in cell_phones mapping in topics/phones/cards.yaml. If n is less than the number of words in the sequence, make a random sample of them. If n is greater, add sampled extra words.

If the optional -t (team) option exists, create t different randomly-selected sets of cards.

nine option (--nine) makes 3 x 3 cards on each page, landscape-wise.

The sixteen option (--sixteen) arranges 2 x 8 cards on one page for convenient cutting for slow feeding. See http://drbean.sdf.org/SlowFeedCards.html 

=cut
