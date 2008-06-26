package Cloze;  # assumes Some/Module.pm

# Last Edit: 2007 Jun 01, 04:49:18 PM
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
	my @lines = @_;
	my %text = ();
	our (%score, $score);
	($score{A}, $score{B}, $score) = (0) x 3;

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
                        my $unclozeables = qr/(?:Chen|SuiBian|ABian|George|Bush|Tom|Cruise|Nicole|Kidman|Chen|Ma|YingJiu|Jim|Bea+n|Johnnie|Walker|Professor|Einstein|Britney|Spears|JianCheng|Mike|John)/;
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
		pass: <reject: $inWord> m/($unclozeables|--|\w)$punctuation/
			{
				$Cloze::clozeline{$writer} .= $item[2];
				$Cloze::clozeline{$reader} .= $item[2];
			}
		firstletter: <reject: $inWord> m/[A-Za-z0-9]/ 
			{ $inWord=1; $index = 0; @cword = ();
				$Cloze::score++;
				# $Cloze::clozeline{$writer} .= "\\\\1{$Cloze::score}";
				push @cword, $item[2];
			}
		middleletter: <reject: not $inWord> m/$letter(?!$punctuation)/
			{
				$index++;
				$Cloze::score++;
				# $Cloze::clozeline{$writer} .= "\\\\1{$Cloze::score}";
				push @cword, $item[2];
			}
		lastletter: <reject: not $inWord> m/$letter(?=$punctuation)/
			{
				$inWord=0;
				$index++;
				$Cloze::score++;
				# $Cloze::clozeline{$writer} .= "\\\\1{$Cloze::score}";
				push @cword, $item[2];
				$Cloze::clozeline{$writer} .= join '', (@cword[0..$#cword/2], map {"\\\\1{@{[$Cloze::score-$_]}}"} reverse 0 .. $#cword-($#cword-1)/2-1);
				$Cloze::clozeline{$reader} .= join '', (@cword[0..$#cword/2], map {"\\\\1{@{[$Cloze::score-$_]}}"} reverse 0 .. $#cword-($#cword-1)/2-1);
			}
		punctuation: <reject: $inWord> m/$punctuation/
			{
				$Cloze::clozeline{$writer} .= $item[2];
				$Cloze::clozeline{$reader} .= $item[2];
			}
		end: m/^\Z/
	]; 

	my $letterParser = Parse::RecDescent->new($letterGrammar);
	defined $letterParser->string($line) or die "letterparse died: $?\n";
	$text{A} .= $clozeline{A};
	$text{B} .= $clozeline{B};
		$lineN++;
	}
	return \%text;

}

1;  # don’t forget to return a true value from the file
