#!/usr/bin/perl

# Last Edit: 2021 Aug 19, 12:08:25 PM
# $Id: /dic/branches/ctest/dic.pl 1263 2007-06-23T12:37:20.810966Z greg  $

use strict;
use warnings;

use Getopt::Long;
use Pod::Usage;
use Algorithm::Numerical::Sample qw/sample/;
use List::Util qw/sum all/;

my $man = 0;
my $help = 0;
my $n = 8;
my $t = 1;
my $s = '';
my $f = 0;
my $nine = '';
my $slow8 = '';

GetOptions (
	'help|?' => \$help, man => \$man,
	't=i' => \$t, 'n=i' => \$n, 's=s' => \$s, 'f=i' => \$f
	, 'nine' => \$nine, 'slow8' => \$slow8)
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

my ($landscape, $parbox);
$landscape = $nine ? "\\usepackage[landscape]{geometry}\n" : '';
$parbox = $nine ? "\\parbox[t][6.3cm][c]{6.5cm}{%" :
		$slow8? "\\parbox[t][6.7cm][c]{4.75cm}{%" :
		"\\parbox[t][6.7cm][c]{9.5cm}{%";

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
% \\usepackage[absolute,showboxes]{textpos}
\\usepackage[absolute]{textpos}
% \\textblockorigin{-0.02cm}{0.07cm} %HPDeskJet5160
% \\textblockorigin{0.00cm}{0.00cm} %HPDeskJet5160
% \\textblockorigin{-0.05cm}{0.13cm} %HPDeskJet5160
\\textblockorigin{0.00cm}{0.00cm} %HPLaserJet5000LE
\\usepackage{texdraw}
\\usepackage{multicol}
% \\usepackage{soul}
\\pagestyle{empty}
\\setlength{\\unitlength}{1cm}
\\usepackage{graphicx}
\\graphicspath{ {/home/$ENV{USER}/curriculum/topics/$ENV{TOPIC}/pic/} }
\\pagestyle{empty}

\\newcommand{\\flashcardX${s}X$romanize{$f}Xcard}[5]{%
	\\vspace{0.8cm}
	\\small #1 #2
	\\par
	\\vspace{-0.7cm}
	$parbox
	\\hspace{0.1cm} \\Huge#3\\\\
	\\normalsize#4 #5
	}
}

START_LATEX

my @latex;
if ( $slow8 ) {
	@latex = (
		{ page => 1, xy => "0,0" },
		{ page => 1, xy => "0,4" },
		{ page => 1, xy => "8,8" },
		{ page => 1, xy => "0,12" },

		{ page => 1, xy => "4,0" },
		{ page => 1, xy => "12,4" },
		{ page => 1, xy => "4,8" },
		{ page => 1, xy => "4,12" },

		{ page => 1, xy => "8,4" },
		{ page => 1, xy => "8,0" },
		{ page => 1, xy => "8,12" },
		{ page => 1, xy => "0,8" },

		{ page => 1, xy => "12,0" },
		{ page => 1, xy => "12,8" },
		{ page => 1, xy => "4,4" },
		{ page => 1, xy => "12,12" },
	);
}
elsif ( $nine ) {
	@latex = (
		{ page => 1, xy => "0, 0" },
		{ page => 1, xy => "5.3, 0" },
		{ page => 1, xy => "10.6, 0" },
		{ page => 1, xy => "0, 5.3" },
		{ page => 1, xy => "5.3, 5.3" },
		{ page => 1, xy => "10.6, 5.3" },
		{ page => 1, xy => "0, 10.6" },
		{ page => 1, xy => "5.3, 10.6" },
		{ page => 1, xy => "10.6, 10.6" },
		{ page => 2, xy => "10.6, 0" },
		{ page => 2, xy => "5.3, 0" },
		{ page => 2, xy => "0, 0" },
		{ page => 2, xy => "10.6, 5.3" },
		{ page => 2, xy => "5.3, 5.3" },
		{ page => 2, xy => "0, 5.3" },
		{ page => 2, xy => "10.6, 10.6" },
		{ page => 2, xy => "5.3, 10.6" },
		{ page => 2, xy => "0, 10.6" },
		{ page => 3, xy => "0, 0" },
		{ page => 3, xy => "5.3, 0" },
		{ page => 3, xy => "10.6, 0" },
		{ page => 3, xy => "0, 5.3" },
		{ page => 3, xy => "5.3, 5.3" },
		{ page => 3, xy => "10.6, 5.3" },
		{ page => 3, xy => "0, 10.6" },
		{ page => 3, xy => "5.3, 10.6" },
		{ page => 3, xy => "10.6, 10.6" },
		{ page => 4, xy => "10.6, 0" },
		{ page => 4, xy => "5.3, 0" },
		{ page => 4, xy => "0, 0" },
		{ page => 4, xy => "10.6, 5.3" },
		{ page => 4, xy => "5.3, 5.3" },
		{ page => 4, xy => "0, 5.3" },
		{ page => 4, xy => "10.6, 10.6" },
		{ page => 4, xy => "5.3, 10.6" },
		{ page => 4, xy => "0, 10.6" },
	);
} else {
	@latex = (
		{ page => 1, xy => "0,0" },
		{ page => 1, xy => "8,0" },
		{ page => 1, xy => "0,4" },
		{ page => 1, xy => "8,4" },
		{ page => 1, xy => "0,8" },
		{ page => 1, xy => "8,8" },
		{ page => 1, xy => "0,12" },
		{ page => 1, xy => "8,12" },
		{ page => 2, xy => "8,0" },
		{ page => 2, xy => "0,0" },
		{ page => 2, xy => "8,4" },
		{ page => 2, xy => "0,4" },
		{ page => 2, xy => "8,8" },
		{ page => 2, xy => "0,8" },
		{ page => 2, xy => "8,12" },
		{ page => 2, xy => "0,12" },
		{ page => 3, xy => "0,0" },
		{ page => 3, xy => "8,0" },
		{ page => 3, xy => "0,4" },
		{ page => 3, xy => "8,4" },
		{ page => 3, xy => "0,8" },
		{ page => 3, xy => "8,8" },
		{ page => 3, xy => "0,12" },
		{ page => 3, xy => "8,12" },
		{ page => 4, xy => "8,0" },
		{ page => 4, xy => "0,0" },
		{ page => 4, xy => "8,4" },
		{ page => 4, xy => "0,4" },
		{ page => 4, xy => "8,8" },
		{ page => 4, xy => "0,8" },
		{ page => 4, xy => "8,12" },
		{ page => 4, xy => "0,12" },
	);
}
my $paging = 0;
my $threepages = 0;
my $lastcard = 0;
my $fullpage=$nine?9:8;

my $cards = LoadFile "$ARGV[0]/cards.yaml";

my $story = $cards->{$s};
die "No $s story" unless ref $story eq 'HASH';
my $identifier = "$s $f";
$identifier =~ s/_/ /;
$latexString .= "\\newcommand{\\flashcardX${s}X$romanize{$f}XIdentifier}[0]{$identifier\n}\n\n";
my $flashcard;
if (exists $story->{match} && exists $story->{match}->{$f} ) {
        $flashcard = $story->{match}->{$f};
}
elsif (exists $story->{flash} && exists $story->{flash}->{$f} ) {
	$flashcard = $story->{flash}->{$f};
}
elsif (exists $story->{$f} and exists $story->{$f}->{flash} ) {
	$flashcard = $story->{$f}->{flash};

}
else { die "No flashcard for $s story, form $f" }

$latexString .= "\\begin{document}\n\n";

for my $set ( 0..$t-1 ) {
	my (@words, %prompts, @prompts, @extra);
	$lastcard = 0;
	if ( ref $flashcard eq 'HASH' and exists $flashcard->{pair} ) {
		my $pair = $flashcard->{pair};
		push @words, $pair->[$_]->[1] for (0..$#$pair);
		push @prompts, $pair->[$_]->[0] for (0..$#$pair);
	}
	elsif ( ref $flashcard eq 'HASH' and exists $flashcard->{word} and exists $flashcard->{call} ) {
	       @words = split m/ /, $flashcard->{word};
	       @prompts = @{ $flashcard->{call} };
	       die "Unequal word, call numbers. Also check order"
		       unless ( @words == @prompts );
	}
	elsif ( ref $flashcard eq 'HASH' ) {
			@words = keys %$flashcard;
			@prompts = values %$flashcard;
	}
	elsif ( ref $flashcard eq 'ARRAY' ) {
		my $n;
		for my $prompt ( @$flashcard ) {
			(my $word = $prompt ) =~ s/^[^_]*_(.*)_.*$/$1/;
			push @words, $word;
			die "No $word word in ${n}th, \"$prompt\" prompt"
				unless $word;
			$n++;
			$prompts{$word} = $prompt;
		}
	}
	else {
		@words = split m/ /, $flashcard;
		@prompts = @words;
	}
	if ( @words > $n ) {
		my @sample = sample( set => [0..$#words], sample_size => $n );
		@words = @words[@sample];
		@prompts = @prompts[@sample];
	}
	die "Undefined prompts"
	       unless all { defined $prompts{$_} } keys %prompts;
	if ( @words < $n ) {
		@extra = sample( set => \@words, sample_size => $n-@words );
		$prompts{"extra ${_}"} = $prompts{$_} for @extra;
	}
	@prompts{@words} = @prompts;

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
	#	die "'$part' dupe present $part_count{$part} times"
	#		unless $part_count{$part} == 0;
	#}
	die "No word for some prompts" unless
		(values %prompts) - @extra == scalar @words;
		
	warn "There are " . (sum values %word_count ) . " words\n";
	my @clinchers = sample( set => \@words, sample_size => 2 );
	my @winner = sample( set => \@clinchers );
	my @loser = grep { $_ ne $winner[0] } @clinchers;
	my %words; @words{ @words } = (); delete @words{@clinchers};
	my @pruned = keys %words;

	my $width = $nine ? "5.3" : "8";
	my $pic_height = $nine ? "0.30\\paperheight" : "0.20\\paperheight";
	my $pic_width = $nine ? "0.30\\paperwidth" : 
			$slow8 ? "0.20\\paperwidth" : "0.40\\paperwidth";
	for my $word ( keys %prompts ) {
		my $extracized_word = ( $word =~ m/^extra (.*)$/ ) ? $1 : $word;
		if ( $prompts{$extracized_word} =~ m/^[-_[:alnum:]]+\.(png|jpg|gif)$/ ) {
			$prompts{$word} =
	"\\includegraphics[angle=00,height=$pic_height,width=$pic_width]{$prompts{$word}}";
		}
	}

	my (@call, @lost_call);
	if ( ref $flashcard eq 'HASH' and exists $flashcard->{call} ) {
		push @call, "$_: $prompts{$_}" for (@pruned, @winner);
		push @lost_call, "$_: $prompts{$_}" for (@loser);

	}
	elsif ( ref $flashcard eq 'HASH' ) {
		push @call, keys %prompts;
		push @call, values %prompts;
	}
	else {
		@call = @prompts{ @pruned, @winner };
		@lost_call = @prompts{@loser};
	}

	# $latexString .=
	# "\\TPshowboxestrue
	# \\begin{textblock}{8}($latex[$paging]->{xy})
	# \\textblocklabel{picture$latex[$paging]->{xy}}
	# \\flashcardX${s}X$romanize{$f}Xcard{}{\\flashcardX${s}X$romanize{$f}XIdentifier}{}
	# {\\parbox{9.0cm}{";
	# $latexString .= (s/_/\\_/g, "$_ \\hfill ") for @call;
	# $latexString .= (s/_/\\_/g, "\\st{ $_ } \\hfill ") for @lost_call;
	# $latexString .= "}}{} \n \\end{textblock}\n \\TPshowboxesfalse \n";
	# &paging;

	for my $card ( 0 .. 2*$n-1 ) {

		$latexString .= 
	"\\TPshowboxestrue
	\\begin{textblock}{$width}($latex[$paging]->{xy})
	\\textblocklabel{picture$latex[$paging]->{xy}}
	\\flashcardX${s}X$romanize{$f}Xcard{}{\\flashcardX${s}X$romanize{$f}XIdentifier}{\\parbox{9.0cm}{";
		$latexString .= "$call[$card] \\hfill ";
		$latexString .= "}}{}{} \n \\end{textblock}\n \\TPshowboxesfalse \n";
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
\\begin{tiny}$latex[$paging]->{page}\\end{tiny}\\newpage\n\n" unless $slow8;
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

The slow8 option (--slow8) arranges 2 x 8 cards on one page for convenient cutting for slow feeding. See http://drbean.sdf.org/SlowFeedCards.html 

=cut
