#!/usr/bin/perl

# Last Edit: 2022 Jun 10,  4:34:11 PM
# $Id: /dic/branches/ctest/dic.pl 1263 2007-06-23T12:37:20.810966Z greg  $

use strict;
use warnings;

use Getopt::Long;
use Pod::Usage;
use List::Util qw/shuffle sample any/;

my $man = 0;
my $help = 0;
my $n = 8;
my $t = 1;
my $s = '';
my $f = 0;
my $nine = '';
my $sixteen = '';
my $pair = '';
my $type = '';

GetOptions (
	'help|?' => \$help, man => \$man,
	't=i' => \$t, 'n=i' => \$n, 's=s' => \$s, 'f=i' => \$f
	, 'nine' => \$nine, 'sixteen' => \$sixteen, 'pair' => \$pair
        , 'type=s' => \$type
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

my ($landscape, $word_box, $pic_box);
$landscape = $nine ? "\\usepackage[landscape]{geometry}\n" : '';
$pic_box = $nine ? "\\parbox[t][6.3cm][c]{6.5cm}{%" :
		$sixteen? "\\parbox[t][0.232\\paperheight][b]{0.20\\paperwidth}{%" :
		"\\parbox[b][0.25\\paperheight][c]{9.5cm}{%";

my $latexString = <<"START_LATEX";
\\documentclass[a4paper]{article}
\\usepackage{fontspec}
\\usepackage{xeCJK}
$landscape
\\setmainfont{Linux Libertine O}[Scale=MatchLowercase]
\\setCJKmainfont{NotoSansCJK-Regular.ttc}[
	       Path = /usr/share/fonts/noto/,
	       ]
% \\usepackage[absolute,noshowtext,showboxes]{textpos}
\\usepackage[absolute,showboxes]{textpos}
% \\usepackage[absolute]{textpos}
% \\textblockorigin{-0.02cm}{0.07cm} %HPDeskJet5160
% \\textblockorigin{0.00cm}{0.00cm} %HPDeskJet5160
% \\textblockorigin{-0.05cm}{0.13cm} %HPDeskJet5160
\\textblockorigin{0.00cm}{0.00cm} %HPLaserJet5000LE
%\\usepackage{texdraw}
\\usepackage{multicol}
% \\usepackage{soul}
\\pagestyle{empty}
\\setlength{\\unitlength}{1cm}
\\usepackage{graphicx}
\\graphicspath{ {/home/$ENV{USER}/curriculum/topics/$ENV{TOPIC}/pic} }
\\pagestyle{empty}

\\newcommand{\\pictureX${s}X$romanize{$f}Xcard}[2]{%
	\\vspace{0.5cm}
	\\small #1
	\\par
	\\vspace{-0.5cm}
	$pic_box
	\\hspace{0.1cm} #2\\\\
	}
}

\\newcommand{\\pictureX${s}X$romanize{$f}Xtile}[2]{%
	\\vspace{0.5cm}
	\\small #1
	\\par
	\\vspace{-3.0cm}
	$pic_box
	\\hspace{-0.4cm} #2\\\\
	}
}

START_LATEX

my $layout = { tile => [
	[
		{ page => 1, xy => "0,0" },
		{ page => 1, xy => "1.8,0" },
		{ page => 1, xy => "3.6,0" },
		{ page => 1, xy => "0,1.8" },
		{ page => 1, xy => "1.8,1.8" },
		{ page => 1, xy => "3.6,1.8" },
		{ page => 1, xy => "0,3.6" },
		{ page => 1, xy => "1.8,3.6" },
		{ page => 1, xy => "3.6,3.6" },
	]
	, [
		{ page => 1, xy => "5.3,0" },
		{ page => 1, xy => "7.1,0" },
		{ page => 1, xy => "8.9,0" },
		{ page => 1, xy => "5.3,1.8" },
		{ page => 1, xy => "7.1,1.8" },
		{ page => 1, xy => "8.9,1.8" },
		{ page => 1, xy => "5.3,3.6" },
		{ page => 1, xy => "7.1,3.6" },
		{ page => 1, xy => "8.9,3.6" },
	]
	, [
		{ page => 1, xy => "10.6,0" },
		{ page => 1, xy => "12.4,0" },
		{ page => 1, xy => "14.2,0" },
		{ page => 1, xy => "10.6,1.8" },
		{ page => 1, xy => "12.4,1.8" },
		{ page => 1, xy => "14.2,1.8" },
		{ page => 1, xy => "10.6,3.6" },
		{ page => 1, xy => "12.4,3.6" },
		{ page => 1, xy => "14.2,3.6" },
	]
	, [
		{ page => 1, xy => "  0,5.3" },
		{ page => 1, xy => "1.8,5.3" },
		{ page => 1, xy => "3.6,5.3" },
		{ page => 1, xy => "  0,7.1" },
		{ page => 1, xy => "1.8,7.1" },
		{ page => 1, xy => "3.6,7.1" },
		{ page => 1, xy => "  0,8.9" },
		{ page => 1, xy => "1.8,8.9" },
		{ page => 1, xy => "3.6,8.9" },
	]
	, [
		{ page => 1, xy => "5.3,5.3" },
		{ page => 1, xy => "7.1,5.3" },
		{ page => 1, xy => "8.9,5.3" },
		{ page => 1, xy => "5.3,7.1" },
		{ page => 1, xy => "7.1,7.1" },
		{ page => 1, xy => "8.9,7.1" },
		{ page => 1, xy => "5.3,8.9" },
		{ page => 1, xy => "7.1,8.9" },
		{ page => 1, xy => "8.9,8.9" },
	]
	, [
		{ page => 1, xy => "10.6,5.3" },
		{ page => 1, xy => "12.4,5.3" },
		{ page => 1, xy => "14.2,5.3" },
		{ page => 1, xy => "10.6,7.1" },
		{ page => 1, xy => "12.4,7.1" },
		{ page => 1, xy => "14.2,7.1" },
		{ page => 1, xy => "10.6,8.9" },
		{ page => 1, xy => "12.4,8.9" },
		{ page => 1, xy => "14.2,8.9" },
	]
	, [
		{ page => 1, xy => "  0,10.6" },
		{ page => 1, xy => "1.8,10.6" },
		{ page => 1, xy => "3.6,10.6" },
		{ page => 1, xy => "  0,12.4" },
		{ page => 1, xy => "1.8,12.4" },
		{ page => 1, xy => "3.6,12.4" },
		{ page => 1, xy => "  0,14.2" },
		{ page => 1, xy => "1.8,14.2" },
		{ page => 1, xy => "3.6,14.2" },
	]
	, [
		{ page => 1, xy => "5.3,10.6" },
		{ page => 1, xy => "7.1,10.6" },
		{ page => 1, xy => "8.9,10.6" },
		{ page => 1, xy => "5.3,12.4" },
		{ page => 1, xy => "7.1,12.4" },
		{ page => 1, xy => "8.9,12.4" },
		{ page => 1, xy => "5.3,14.2" },
		{ page => 1, xy => "7.1,14.2" },
		{ page => 1, xy => "8.9,14.2" },
	]
	, [
		{ page => 1, xy => "10.6,10.6" },
		{ page => 1, xy => "12.4,10.6" },
		{ page => 1, xy => "14.2,10.6" },
		{ page => 1, xy => "10.6,12.4" },
		{ page => 1, xy => "12.4,12.4" },
		{ page => 1, xy => "14.2,12.4" },
		{ page => 1, xy => "10.6,14.2" },
		{ page => 1, xy => "12.4,14.2" },
		{ page => 1, xy => "14.2,14.2" },
	]
		],
	full => [
		{ page => 1, xy => "0, 0" },
		{ page => 1, xy => "5.3, 0" },
		{ page => 1, xy => "10.6, 0" },
		{ page => 1, xy => "0, 5.3" },
		{ page => 1, xy => "5.3, 5.3" },
		{ page => 1, xy => "10.6, 5.3" },
		{ page => 1, xy => "0, 10.6" },
		{ page => 1, xy => "5.3, 10.6" },
		{ page => 1, xy => "10.6, 10.6" },
		]
};
my $paging = 0;
my $threepages = 0;
my $lastcard = 0;
my $fullpage=$nine? 9: $sixteen? 16: 8;

my $cards = LoadFile "$ARGV[0]/cards.yaml";

my $story = $cards->{$s};
die "No $s story" unless ref $story eq 'HASH';
my $identifier = "$s $f";
$identifier =~ s/_/ /;
$latexString .= "\\newcommand{\\flashcardX${s}X$romanize{$f}XIdentifier}[0]{$identifier\n}\n\n";
my $flashcard;
if ($type eq "match" && exists $story->{match} && exists $story->{match}->{$f} ) {
        $flashcard = $story->{match}->{$f};
}
elsif ($type eq "flash" && exists $story->{flash} && exists $story->{flash}->{$f} ) {
	$flashcard = $story->{flash}->{$f};
}
elsif (exists $story->{$f} and exists $story->{$f}->{flash} ) {
	$flashcard = $story->{$f}->{flash};

}
else { die "No flashcard for $s story, form $f" }

$latexString .= "\\begin{document}\n\n";

my (@pic);
$lastcard = 0;
if ( ref $flashcard eq 'HASH' and exists $flashcard->{pair} ) {
	my $pair = $flashcard->{pair};
	push @pic, $pair->[$_]->[1] for (0..$#$pair);
}
elsif ( ref $flashcard eq 'HASH' ) {
		@pic = values %$flashcard;
}
else {
	@pic = split m/ /, $flashcard;
}
if ( @pic > $n ) {
	my @sample = sample( $n, @pic );
	@pic = @sample;
}

my ( %pic, @extra, @duped, @tag );
if ( @pic < $n ) {
	@extra = sample( $n-@pic, @pic );
}
for my $dupe ( @extra ) {
	@duped = grep { $_ eq $dupe } @pic;
}
push @pic, $_ for @extra;
@pic = shuffle @pic;
@pic{0..$#pic} = @pic;
@tag = grep { my $pic=$_; any { $_ eq $pic } @extra }(0..$#pic);


my $width = $nine ? "5.3" : $sixteen ? "4" : "8";
my $pic_height = $nine ? "0.30\\paperheight" :
			$sixteen ? "0.195\\paperheight" : 
			"0.20\\paperheight";
my $pic_width = $nine ? "0.30\\paperwidth" : 
		$sixteen ? "0.20\\paperwidth" : "0.40\\paperwidth";
		
my $tile_width = "0.10\\paperwidth";
my $tile_height = "0.10\\paperheight";

#for my $word ( keys %prompts ) {
#	my $extracized_word = ( $word =~ m/^extra (.*)$/ ) ? $1 : $word;
#	if ( $prompts{$extracized_word} =~ m/^[-_[:alnum:]]+\.(png|jpg|gif)$/ ) {
#		$prompts{$word} =
#"\\includegraphics[angle=00,height=$pic_height,width=$pic_width]{$prompts{$word}}";
#	}
#}
for my $card ( @pic ) {
	my $block_width = "5.3";
			$latexString .= 
			"\\TPshowboxestrue
			\\begin{textblock}{$block_width}($layout->{full}->[$paging]->{xy})";
			if ( $card =~ m/^[-_[:alnum:]]+\.(png|jpg|gif)$/ ) {
				$latexString .= "
				\\textblocklabel{picture$layout->{full}->[$paging]->{xy}}
				\\pictureX${s}X$romanize{$f}Xcard{\\flashcardX${s}X$romanize{$f}XIdentifier}{%
				\\includegraphics[angle=00,height=$pic_height,width=$pic_width]{$card}";
			}
			#			else {
			#				$latexString .= "
			#	\\textblocklabel{word$layout[$paging]->{xy}}
			#	\\wordX${s}X$romanize{$f}Xcard{\\flashcardX${s}X$romanize{$f}XIdentifier}{%
			#	$card \\hfill";
			#			}
			$latexString .= "
			} \n \\end{textblock}\n %\\TPshowboxesfalse \n";
			# }
			&paging;
		}
		$lastcard = 1;
		$latexString .= "
		\\begin{tiny}$layout->{full}->[$paging]->{page}\\end{tiny}\\newpage\n\n" unless
		$paging == $fullpage or
		$paging == 2*$fullpage or
		$paging == 3*$fullpage;
		$paging = 0;

for my $card ( 0..$t-1 ) {
	for my $pos ( 0.. $#pic ) {
		my $block_width = "1.8";
		my $tile = $pic[$pos];

		#		if ( $sixteen and $card !~ m/^[-_[:alnum:]]+\.(png|jpg|gif)$/) {
		#			my $upside_down_xy = "$latex[$paging]->{x}," . ($latex[$paging]->{y} + 2);
		#			$latexString .= "
		#	\\TPshowboxestrue
		#	\\begin{textblock}{$width}($latex[$paging]->{xy})
		#	\\textblocklabel{playingcard$latex[$paging]->{xy}}
		#	\\playingX${s}X$romanize{$f}Xcard{\\flashcardX${s}X$romanize{$f}XIdentifier}{%
		#	$card \\hfill}
		#	%\\begin{textblock}{$width}($upside_down_xy)
		#	%\\textblocklabel{bottombox$upside_down_xy}
		#	%\\rotatebox[origin=rB]{180}{
		#	%\\wordX${s}X$romanize{$f}Xcard{}{%
		#	%$card \\hfill}} \\\\
		#	%\\vspace{0.5cm}
		#	%\\flushright \\rotatebox[origin=c]{180}{\\small \\flashcardX${s}X$romanize{$f}XIdentifier}
		#	%\\vfill
		#	\\end{textblock}\n \\TPshowboxesfalse \n";
		#		}
		#		else {
			$latexString .= 
	"\\TPshowboxestrue
	\\begin{textblock}{$block_width}($layout->{tile}->[$card]->[$pos]->{xy})";
			if ( $tile =~ m/^[-_[:alnum:]]+\.(png|jpg|gif)$/ ) {
				$latexString .= "
	\\textblocklabel{picture$layout->{tile}->[$card]->[$pos]->{xy}}
	\\pictureX${s}X$romanize{$f}Xtile{\\flashcardX${s}X$romanize{$f}XIdentifier}{%
	\\includegraphics[angle=00,height=$tile_height,width=$tile_width]{$tile}";
			}
		#			else {
		#				$latexString .= "
		#	\\textblocklabel{word$layout[$paging]->{xy}}
		#	\\wordX${s}X$romanize{$f}Xcard{\\flashcardX${s}X$romanize{$f}XIdentifier}{%
		#	$card \\hfill";
		#			}
			$latexString .= "
	} \n \\end{textblock}\n %\\TPshowboxesfalse \n";
		# }
	}
	$paging = 0;
	$lastcard = 1;
	$latexString .= "
% \\begin{tiny}$layout->{tile}->[$paging]->[$card]->{page}\\end{tiny}\\newpage\n\n" unless
		$paging == $fullpage or
		$paging == 2*$fullpage or
		$paging == 3*$fullpage;
		# &paging;
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
\\begin{tiny}$layout->{full}->[$paging]->{page}\\end{tiny}\\newpage\n\n";
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
