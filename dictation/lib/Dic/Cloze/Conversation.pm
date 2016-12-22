package Dic::Cloze::Conversation;  # assumes Some/Module.pm

# Last Edit: 2016 Dec 21, 01:41:11 PM
# $Id: /cloze/branches/ctest/Cloze.pm 1234 2007-06-03T00:32:38.953757Z greg  $

use strict;
use warnings;

BEGIN {
    use Exporter   ();
    our ($VERSION, @ISA, @EXPORT, @EXPORT_OK, %EXPORT_TAGS);

    $VERSION     = 0.03;
    @ISA         = qw(Exporter);
    # @EXPORT      = qw(&func1 &func2 &func4);
    %EXPORT_TAGS = ( );     # eg: TAG => [ qw!name1 name2! ],
    @EXPORT_OK   = qw(&cloze);
}
our @EXPORT_OK;

use Parse::RecDescent;

our %onlastletter;
$onlastletter{ctest} = q [
	$Dic::Cloze::Conversation::clozeline .= join '', @cword[0..( $#cword - 1 )/2], "\\\\1{$Dic::Cloze::Conversation::word_score}" , "\\\\1{}\\\\-" x ( $#cword/2 );
	];
$onlastletter{firstlast} = q [
	if ( $#cword >= 2 ) {
		$Dic::Cloze::Conversation::clozeline{$writer} .= join '', @cword[0], "\\\\1{$Dic::Cloze::Conversation::word_score}" , "\\\\1{}\\\\-" x ( $#cword-2 ), $cword[-1];
		$Dic::Cloze::Conversation::clozeline{$reader} .= join '', @cword, "\\\\hspace{0.05cm}", "\\\\textsubscript{\\\\tiny $Dic::Cloze::Conversation::word_score}";
	}
	if ( $#cword == 1 ) {
		$Dic::Cloze::Conversation::clozeline{$writer} .= join '', @cword[0], "\\\\1{$Dic::Cloze::Conversation::word_score}";
		$Dic::Cloze::Conversation::clozeline{$reader} .= join '', @cword, "\\\\hspace{0.05cm}", "\\\\textsubscript{\\\\tiny $Dic::Cloze::Conversation::word_score}";
	}
	];
$onlastletter{ctestpluslast} = q [
	if ( $#cword > 2 ) {
		$Dic::Cloze::Conversation::clozeline .= join '', (@cword[0..$#cword/2], "\\\\1{$Dic::Cloze::Conversation::word_score}"
			, map {"\\\\1{}"} reverse 2 .. $#cword-($#cword-1)/2-1)
		, $cword[-1];
	}
	else {
		$Dic::Cloze::Conversation::clozeline .= join '', (@cword[0..$#cword/2], "\\\\1{$Dic::Cloze::Conversation::word_score}" , map {"\\\\1{}"} reverse 1 .. $#cword-($#cword-1)/2-1);
	}
	];
$onlastletter{total} = q [
	$Dic::Cloze::Conversation::clozeline .= join '', ("\\\\1{$Dic::Cloze::Conversation::word_score}"
			, map {"\\\\1{}"} 1 .. $#cword);
	];

sub cloze
{
	$::RD_HINT=1;
	my $cloze_style = shift;
	my $unclozeables = shift;
	chomp $unclozeables;
	our @unclozeable = split '\|', $unclozeables;
	our $first = shift @unclozeable;
	our $unclozeable = $unclozeables? qr/(?:$first)/: undef;
	my @lines = @_;
	my %text = ();
	our (%letter_score, $letter_score);
	our (%word_score, $word_score);
	($letter_score{A}, $letter_score{B}, $letter_score) = (0) x 3;
	($word_score{A}, $word_score{B}, $word_score) = (0) x 3;

	my @players = ( 'A' .. 'B' );

	my $lineN = 0;

	foreach my $line ( @lines )
	{
	our %clozeline;
@clozeline{'A', 'B' } = ('') x 2;
	my $letterGrammar = q[
		{
	my $reader = 'A';
	my $writer = 'B';
			my $punctuation = qr/[^-A-Za-z0-9']+/;
			my $name = qr/[A-Z][-A-Za-z0-9']*/; # qr/\u\w\w*\b/;
			my ($a, $b) = (qr/^M: /, qr/^W: /);
			my $letter = qr/[A-Za-z0-9']/;
			my $skip = '';
			my @cword;
			my ($index, $inWord) = (0) x 2;
		}
		string: token(s) end | <error>
		token: a | b | unclozeable | singularletter | firstletter | middleletter | lastletter | blankline | punctuation 
		a: m/$a/ {
			($reader, $writer) = ('A','B');
			$Dic::Cloze::Conversation::clozeline{$writer} .= $item[1];
			$Dic::Cloze::Conversation::clozeline{$reader} .= $item[1]; }
		b: m/$b/ {
			($reader, $writer) = ('B','A');
			$Dic::Cloze::Conversation::clozeline{$writer} .= $item[1];
			$Dic::Cloze::Conversation::clozeline{$reader} .= $item[1]; }
		firstletter: <reject: $inWord> m/[A-Za-z0-9]/ 
			{ $inWord=1; $index = 0; @cword = ();
				$Dic::Cloze::Conversation::word_score++;
				$Dic::Cloze::Conversation::letter_score++;
				push @cword, $item[2];
			}
		middleletter: <reject: not $inWord> m/$letter(?!$punctuation)/
			{
				$index++;
				$Dic::Cloze::Conversation::letter_score++;
				push @cword, $item[2];
			}
		lastletter: <reject: not $inWord> m/$letter(?=$punctuation)/
			{
				$inWord=0;
				$index++;
				$Dic::Cloze::Conversation::letter_score++;
				push @cword, $item[2];
		];
		$letterGrammar .= $onlastletter{$cloze_style};
		$letterGrammar .= q [
		}
		blankline: <reject: $inWord> m/^$/
			{
				$Dic::Cloze::Conversation::clozeline .= "~\\\\\\\\";
			}
		end: m/^\Z/
		singularletter: <reject: $inWord> m/(\w)(?=$punctuation)/m
			{
				$Dic::Cloze::Conversation::word_score++;
				$Dic::Cloze::Conversation::clozeline{$writer} .= $item[2];
				$Dic::Cloze::Conversation::clozeline{$reader} .= $item[2];
			}
		punctuation: <reject: $inWord> m/$punctuation/
			{
				$Dic::Cloze::Conversation::clozeline{$writer} .= $item[2];
				$Dic::Cloze::Conversation::clozeline{$reader} .= $item[2];
			}
		end: m/^\Z/
	]; 
	if ( $unclozeables ) {
		$letterGrammar .= q[
		unclozeable: <reject: $inWord> m/($Dic::Cloze::Conversation::unclozeable)(?=$punctuation)/m
			{
				$Dic::Cloze::Conversation::word_score++;
				$Dic::Cloze::Conversation::clozeline{$writer} .= $item[2];
				$Dic::Cloze::Conversation::clozeline{$reader} .= $item[2];
				$Dic::Cloze::Conversation::unclozeable = shift @Dic::Cloze::Conversation::unclozeable;
			}
		];
	}
	else {
		$letterGrammar .= q[
		];
	}

	my $letterParser = Parse::RecDescent->new($letterGrammar);
	defined $letterParser->string($line) or die "letterparse died: $?\n";
	$text{A} .= "\\hspace{0cm} \\\\" . $clozeline{A};
	$text{B} .= "~\\\\" . $clozeline{B};
		$lineN++;
	}
	return \%text;

}

1;  # don’t forget to return a true value from the file
