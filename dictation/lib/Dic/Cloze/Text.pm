package Dic::Cloze::Text;  # assumes Some/Module.pm

# Last Edit: 2022 Oct 05,  2:58:23 PM
# $Id:60 /cloze/branches/ctest/Cloze.pm 1234 2007-06-03T00:32:38.953757Z greg  $

use strict;
use warnings;

BEGIN {
    use Exporter   ();
    our ($VERSION, @ISA, @EXPORT, @EXPORT_OK, %EXPORT_TAGS);

    $VERSION     = 0.03;
    @ISA         = qw(Exporter);
    # @EXPORT      = qw(&func1 &func2 &func4);
    %EXPORT_TAGS = ( );     # eg: TAG => [ qw!name1 name2! ],
    @EXPORT_OK   = qw(&no_cloze &simple_cloze &cloze);
}
our @EXPORT_OK;

use Parse::RecDescent;
use Scalar::Util qw/looks_like_number/;
use POSIX qw/floor ceil/;

my %onlastletter;
$onlastletter{ctest} = q [
	push @Dic::Cloze::Text::clozeline, join '', "\\\\ttfamily\\\\Large ", @cword[0..( $#cword - 1 )/2], "\\\\1{$Dic::Cloze::Text::word_score}" , "\\\\1{}\\\\-" x ( $#cword/2 ), " \\\\rmfamily\\\\large ";
	push @Dic::Cloze::Text::word, join '', @cword;
	];
$onlastletter{first} = q [
	push @Dic::Cloze::Text::clozeline, join '', "\\\\ttfamily\\\\Large ", @cword[0], "\\\\1{$Dic::Cloze::Text::word_score}" , "\\\\1{}\\\\-" x ( $#cword-1 ), " \\\\rmfamily\\\\large ";
	];
$onlastletter{firstlast} = q [
	if ( $#cword >= 2 ) {
		push @Dic::Cloze::Text::clozeline, join '', "\\\\ttfamily\\\\Large ", @cword[0], "\\\\1{$Dic::Cloze::Text::word_score}" , "\\\\1{}\\\\-" x ( $#cword-2 ), $cword[-1], " \\\\rmfamily\\\\large ";
	}
	if ( $#cword == 1 ) {
		push @Dic::Cloze::Text::clozeline, join '', "\\\\ttfamily\\\\Large ", @cword[0], "\\\\1{$Dic::Cloze::Text::word_score}", " \\\\rmfamily\\\\large ";
	}
	];
$onlastletter{ctestpluslast} = q [
	if ( $#cword > 2 ) {
		push @Dic::Cloze::Text::clozeline, join '', "\\\\ttfamily\\\\Large ", (@cword[0..$#cword/2], "\\\\1{$Dic::Cloze::Text::word_score}"
			, map {"\\\\1{}"} reverse 2 .. $#cword-($#cword-1)/2-1)
		, $cword[-1], " \\\\rmfamily\\\\large ";
	}
	else {
		push @Dic::Cloze::Text::clozeline, join '', "\\\\ttfamily\\\\Large ", (@cword[0..$#cword/2], "\\\\1{$Dic::Cloze::Text::word_score}"
		, map {"\\\\1{}"} reverse 1 .. $#cword-($#cword-1)/2-1), " \\\\rmfamily\\\\large ";
	}
	];
$onlastletter{total} = q [
	push @Dic::Cloze::Text::clozeline, join '', ("\\\\1{$Dic::Cloze::Text::word_score}"
			, map {"\\\\1{}"} 1 .. $#cword);
	push @Dic::Cloze::Text::word, join '', @cword;
	];
$onlastletter{pos} = q [
	push @Dic::Cloze::Text::clozeline, join '', ("\\\\1{$Dic::Cloze::Text::word_score}"
			, map {"\\\\1{}"} 1 .. 4);
	push @Dic::Cloze::Text::word, join '', @cword;
	];

sub cloze
{
	$::RD_HINT=1;
	my $cloze_style = shift;
	our $unclozeables = shift;
	chomp $unclozeables;
	our @unclozeable = split '\|', $unclozeables;
	our $first = shift @unclozeable;
	our $unclozeable = $unclozeables? qr/(?:$first)/: undef;
	my @lines = @_;
	my %text = ();
	our (%letter_score, $letter_score);
	our (@word, $word_score);

	my $lineN = 0;

	foreach my $line ( @lines )
	{
	our @clozeline = ();
	# $Parse::RecDescent::skip = '';
	my $letterGrammar = q[
		{
			my $punctuation = qr/[^-A-Za-z0-9']+/;
			my $name = qr/[A-Z][-A-Za-z0-9']*/; # qr/\u\w\w*\b/;
			my $letter = qr/[A-Za-z0-9']/;
			my $word = qr/[-_'[:alnum:]]+/;
			my $skip = '';
			my @cword;
			my ($index, $inWord) = (0) x 2;
			my $cloze_up = 0;
		}
		string: token(s) end | <error>
		token: unclozeable | singularletter | firstletter | middleletter | lastletter | blankline | punctuation 
		firstletter: <reject: $inWord> m/[A-Za-z0-9]/ 
			{ $inWord=1; $index = 0; @cword = ();
				$Dic::Cloze::Text::word_score++;
				$Dic::Cloze::Text::letter_score++;
				push @cword, $item[2];
			}
		middleletter: <reject: not $inWord> m/$letter(?!$punctuation)/
			{
				$index++;
				$Dic::Cloze::Text::letter_score++;
				push @cword, $item[2];
			}
		lastletter: <reject: not $inWord> m/$letter(?=$punctuation)/
			{
				$cloze_up=0;
				$inWord=0;
				$index++;
				$Dic::Cloze::Text::letter_score++;
				push @cword, $item[2];
		];
		$letterGrammar .= $onlastletter{$cloze_style};
		$letterGrammar .= q [
		}
		blankline: <reject: $inWord> m/^$/
			{
				push @Dic::Cloze::Text::clozeline, "~\\\\\\\\";
			}
		end: m/^\Z/
		singularletter: <reject: $inWord> m/(\w)(?=$punctuation)/m
			{
				# $Dic::Cloze::Text::word_score++;
				push @Dic::Cloze::Text::clozeline, $item[2];
			}
		punctuation: <reject: $inWord> m/$punctuation/
			{
				push @Dic::Cloze::Text::clozeline, $item[2];
			}
		end: m/^\Z/
	]; 
	if ( looks_like_number($Dic::Cloze::Text::unclozeables) ) {
		$letterGrammar .= q[
		unclozeable: <reject: $cloze_up> m/((\b$letter+\b)$punctuation){$Dic::Cloze::Text::unclozeables}/
			{
				push @Dic::Cloze::Text::clozeline, $item[2];
				$cloze_up=1;
			}
		];
	}
	elsif ( $Dic::Cloze::Text::unclozeable and not looks_like_number($Dic::Cloze::Text::unclozeables)) {
		$letterGrammar .= q[
		unclozeable: <reject: $inWord> m/($Dic::Cloze::Text::unclozeable)(?=$punctuation)/m
			{
				push @Dic::Cloze::Text::clozeline, $item[2];
				$Dic::Cloze::Text::unclozeable = shift @Dic::Cloze::Text::unclozeable;
			}
		];
	}
	else {
		$letterGrammar .= q[
		];
	}

	my $letterParser = Parse::RecDescent->new($letterGrammar);
	defined $letterParser->string($line) or die "letterparse died: $?\n";
	push @{$text{A}}, @clozeline;
	push @{$text{B}}, @clozeline;
		$lineN++;
	$text{word} = \@word if @word;
	# $text{word} = [qw{night medal medal team team time ceremony have been doing stayed watch won had watch saw tired late gold silver women's great men's women's  about so}];
	# $text{word} = [qw/summer baseball swimming lessons baseball team game weekend park time have doing been come watch play do play don't come watch play know let starts to maybe you/];
	}
	return \%text;

}

sub simple_cloze
{
	$::RD_HINT=1;
	my $cloze_style = shift;
	our $clozes = shift;
	chomp $clozes;
	our @clozes = split ' ', $clozes;
	our $pos = shift;
	my $hint = shift;
	our $cloze_match = shift @clozes;
	my @lines = @_;
	my %text = ();
	our (%letter_score, $letter_score);
	our (@word, $word_score);

	my $lineN = 1;

	foreach my $line ( @lines )
	{
	our @clozeline = ();
	# $Parse::RecDescent::skip = '';
	my $grammar = q[
		{
			my $word = qr/[-_'.!?:,[:alnum:]]+/;
			my @cword;
		}
		string: token(s) end | <error>
		token: cloze | unclozed
		cloze: m/$Dic::Cloze::Text::cloze_match/i {
			my $cloze=$item[1];
			my $length = length $cloze;
			my $short = POSIX::floor $length/2;
			my $long = POSIX::ceil $length/2;
			push @Dic::Cloze::Text::word, $cloze;
			$Dic::Cloze::Text::word_score++;
		];
	 if ( $cloze_style eq 'pos' ) {
		 if ( $hint ) {
			 $grammar .= q[push @Dic::Cloze::Text::clozeline, [ $Dic::Cloze::Text::pos->{$cloze}, "\\\\2{$Dic::Cloze::Text::word_score}", ' '] ;];
		 }
		 else {
			 $grammar .= q[push @Dic::Cloze::Text::clozeline, join '', "\\\\2{$Dic::Cloze::Text::word_score}", "\\\\2{}" x 1, ' ';];
		 }
	 }
	$grammar .= q[push @Dic::Cloze::Text::clozeline, join '', "\\\\2{$Dic::Cloze::Text::word_score}", "\\\\2{}" x ($length-1), ' ';] if $cloze_style eq 'total';
	$grammar .= q[push @Dic::Cloze::Text::clozeline, join '', (substr $cloze, 0, $short), "\\\\1{$Dic::Cloze::Text::word_score}", "\\\\1{}" x ($short-1), ' ';] if $cloze_style eq 'ctest';
	$grammar .= q[		$Dic::Cloze::Text::cloze_match = shift @Dic::Cloze::Text::clozes;
		}
		unclozed: m/$word/ {
			push @Dic::Cloze::Text::clozeline, "$item[1] ";
			}
		end: m/^\Z/
		];
	my $parser = Parse::RecDescent->new($grammar);
	defined $parser->string($line) or die "simple_cloze parse died: $?\n";
	push @{$text{A}}, @clozeline,  "\\hspace{0cm} \\\\";
	push @{$text{B}}, @clozeline,  "~\\\\";
		$lineN++;
	$text{word} = \@word if @word;
	# $text{word} = [qw{night medal medal team team time ceremony have been doing stayed watch won had watch saw tired late gold silver women's great men's women's  about so}];
	# $text{word} = [qw/summer baseball swimming lessons baseball team game weekend park time have doing been come watch play do play don't come watch play know let starts to maybe you/];
	}
	return \%text;

}

sub no_cloze
{
	$::RD_HINT=1;
	my $cloze_style = shift;
	our $no_cloze = shift;
	my @lines = @_;
	my %text = ();
	our (%letter_score, $letter_score);
	our (@word, $word_score);

	my $lineN = 1;

	foreach my $line ( @lines )
	{
	our @clozeline = ();
	# $Parse::RecDescent::skip = '';
	my $grammar = q[
		string: token(s) end | <error>
		token: cloze | unclozed
		cloze: <reject: not $Dic::Cloze::Text::no_cloze> m/^.*$/ {
			push @Dic::Cloze::Conversation::clozeline, "$Dic::Cloze::Conversation::lineN $item[1]";
		}
		unclozed: m/^.*$/ {
			push @Dic::Cloze::Text::clozeline, "$item[1] ";
			}
		end: m/^\Z/
		];
	my $parser = Parse::RecDescent->new($grammar);
	defined $parser->string($line) or die "no_cloze parse died: $?\n";
	push @{$text{A}}, @clozeline;
	push @{$text{B}}, @clozeline;
		$lineN++;
	}
	return \%text;

}
1;  # don’t forget to return a true value from the file
