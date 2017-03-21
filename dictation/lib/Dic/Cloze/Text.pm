package Dic::Cloze::Text;  # assumes Some/Module.pm

# Last Edit: 2017 Mar 21, 12:11:31 PM
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
	$Dic::Cloze::Text::clozeline .= join '', "\\\\ttfamily\\\\Large ", @cword[0..( $#cword - 1 )/2], "\\\\1{$Dic::Cloze::Text::word_score}" , "\\\\1{}\\\\-" x ( $#cword/2 ), " \\\\rmfamily\\\\large ";
	];
$onlastletter{firstlast} = q [
	if ( $#cword >= 2 ) {
		$Dic::Cloze::Text::clozeline .= join '', "\\\\ttfamily\\\\Large ", @cword[0], "\\\\1{$Dic::Cloze::Text::word_score}" , "\\\\1{}\\\\-" x ( $#cword-2 ), $cword[-1], " \\\\rmfamily\\\\large ";
	}
	if ( $#cword == 1 ) {
		$Dic::Cloze::Text::clozeline .= join '', "\\\\ttfamily\\\\Large ", @cword[0], "\\\\1{$Dic::Cloze::Text::word_score}", " \\\\rmfamily\\\\large ";
	}
	];
$onlastletter{ctestpluslast} = q [
	if ( $#cword > 2 ) {
		$Dic::Cloze::Text::clozeline .= join '', "\\\\ttfamily\\\\Large ", (@cword[0..$#cword/2], "\\\\1{$Dic::Cloze::Text::word_score}"
			, map {"\\\\1{}"} reverse 2 .. $#cword-($#cword-1)/2-1)
		, $cword[-1], " \\\\rmfamily\\\\large ";
	}
	else {
		$Dic::Cloze::Text::clozeline .= join '', "\\\\ttfamily\\\\Large ", (@cword[0..$#cword/2], "\\\\1{$Dic::Cloze::Text::word_score}"
		, map {"\\\\1{}"} reverse 1 .. $#cword-($#cword-1)/2-1), " \\\\rmfamily\\\\large ";
	}
	];
$onlastletter{total} = q [
	$Dic::Cloze::Text::clozeline .= join '', ("\\\\1{$Dic::Cloze::Text::word_score}"
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

	my $lineN = 0;

	foreach my $line ( @lines )
	{
	our $clozeline = '';
	my $letterGrammar = q[
		{
			my $punctuation = qr/[^-A-Za-z0-9']+/;
			my $name = qr/[A-Z][-A-Za-z0-9']*/; # qr/\u\w\w*\b/;
			my $letter = qr/[A-Za-z0-9']/;
			my $skip = '';
			my @cword;
			my ($index, $inWord) = (0) x 2;
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
				$Dic::Cloze::Text::clozeline .= "~\\\\\\\\";
			}
		end: m/^\Z/
		singularletter: <reject: $inWord> m/(\w)(?=$punctuation)/m
			{
				$Dic::Cloze::Text::word_score++;
				$Dic::Cloze::Text::clozeline .= $item[2];
			}
		punctuation: <reject: $inWord> m/$punctuation/
			{
				$Dic::Cloze::Text::clozeline .= $item[2];
			}
		end: m/^\Z/
	]; 
	if ( $unclozeables ) {
		$letterGrammar .= q[
		unclozeable: <reject: $inWord> m/($Dic::Cloze::Text::unclozeable)(?=$punctuation)/m
			{
				$Dic::Cloze::Text::word_score++;
				$Dic::Cloze::Text::clozeline .= $item[2];
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
	$text{A} .= "\\hspace{0cm} \\\\" . $clozeline;
	$text{B} .= "~\\\\" . $clozeline;
		$lineN++;
	}
	return \%text;

}

1;  # don’t forget to return a true value from the file
