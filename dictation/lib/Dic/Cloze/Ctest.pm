package Dic::Cloze::Ctest;  # assumes Some/Module.pm

# Last Edit: 2016 Jun 27, 10:25:21 AM
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

sub cloze
{
	my $unclozeables = shift;
	chomp $unclozeables;
	our $unclozeable = $unclozeables? qr/(?:$unclozeables)/: undef;
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
	my $reader = '';
	my $writer = '';
			my $punctuation = qr/[^-A-Za-z0-9']+/;
			my $name = qr/[A-Z][-A-Za-z0-9']*/; # qr/\u\w\w*\b/;
			my ($a, $b) = (qr/^A: /, qr/^B: /);
			my $letter = qr/[A-Za-z0-9']/;
			my $skip = '';
			my @cword;
			my ($index, $inWord) = (0) x 2;
		}
		string: token(s) end | <error>
		token: a | b | pass | firstletter | middleletter | lastletter | punctuation
		a: m/$a/ {
			($reader, $writer) = ('A','B');
			$Cloze::clozeline{$writer} .= $item[1];
			$Cloze::clozeline{$reader} .= $item[1]; }
		b: m/$b/ {
			($reader, $writer) = ('B','A');
			$Cloze::clozeline{$writer} .= $item[1];
			$Cloze::clozeline{$reader} .= $item[1]; }
		firstletter: <reject: $inWord> m/[A-Za-z0-9]/ 
			{ $inWord=1; $index = 0; @cword = ();
				$Cloze::word_score++;
				$Cloze::letter_score++;
				# $Cloze::clozeline{$writer} .= "\\\\1{$Cloze::word_score}";
				push @cword, $item[2];
			}
		middleletter: <reject: not $inWord> m/$letter(?!$punctuation)/
			{
				$index++;
				$Cloze::letter_score++;
				# $Cloze::clozeline{$writer} .= "\\\\1{}";
				push @cword, $item[2];
			}
		lastletter: <reject: not $inWord> m/$letter(?=$punctuation)/
			{
				$inWord=0;
				$index++;
				$Cloze::letter_score++;
				# $Cloze::clozeline{$writer} .= "\\\\1{}";
				push @cword, $item[2];
				$Cloze::clozeline{$writer} .= join '', (@cword[0..$#cword/2], "\\\\1{$Cloze::word_score}" , map {"\\\\1{}"} reverse 1 .. $#cword-($#cword-1)/2-1);
				$Cloze::clozeline{$reader} .= join '', (@cword[0..$#cword/2], "\\\\1{$Cloze::word_score}" , map {"\\\\1{}"} reverse 1 .. $#cword-($#cword-1)/2-1);
			}
		punctuation: <reject: $inWord> m/$punctuation/
			{
				$Cloze::clozeline{$writer} .= $item[2];
				$Cloze::clozeline{$reader} .= $item[2];
			}
		end: m/^\Z/
	]; 
	if ( $unclozeables ) {
		$letterGrammar .= q[
		pass: <reject: $inWord> m/($Cloze::unclozeable|\w)(?=$punctuation)/m
			{
				$Cloze::word_score++;
				$Cloze::clozeline{$writer} .= $item[2];
				$Cloze::clozeline{$reader} .= $item[2];
			}
		];
	}
	else {
		$letterGrammar .= q[
		pass: <reject: $inWord> m/(\w)(?=$punctuation)/m
			{
				$Cloze::word_score++;
				$Cloze::clozeline{$writer} .= $item[2];
				$Cloze::clozeline{$reader} .= $item[2];
			}
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
