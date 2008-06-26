package Cloze;  # assumes Some/Module.pm

# Last Edit: 2007 Apr 06, 10:31:18 PM
# $Id$

use strict;
use warnings;

BEGIN {
    use Exporter   ();
    our ($VERSION, @ISA, @EXPORT, @EXPORT_OK, %EXPORT_TAGS);

    $VERSION     = 0.01;
    @ISA         = qw(Exporter);
    # @EXPORT      = qw(&func1 &func2 &func4);
    %EXPORT_TAGS = ( );     # eg: TAG => [ qw!name1 name2! ],
    @EXPORT_OK   = qw(&cloze);
}
our @EXPORT_OK;

use Parse::RecDescent;

sub cloze
{
	our %score;
	@score{qw/A B/} = (shift, shift);
	our $unclozed = 2;
	my @lines = @_;
	my %text = ();

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
			my $punctuation = qr/[^A-Za-z0-9']+/;
			my $name = qr/[A-Z][-A-Za-z0-9']*/; # qr/\u\w\w*\b/;
			my ($a, $b) = (qr/^A: /, qr/^B: /);
			my $unclozeables = qr/(?: Taipei|Tokyo|Hong Kong|Boston|New York|Mexico City|Los Angeles|Germany)/;
			my $letter = qr/[A-Za-z0-9']/;
			my $skip = '';
			my @cword;
			my ($index, $inCloze, $clozedletters) = (0) x 3;
		}
		string: token(s) end | <error>
		# token: a | b | unclozedword | clozeletter(s)
		token: a | b | unclozedword | clozedword
		# token: a | b | clozeletter(s)
		a: m/$a/ {
			($reader, $writer) = ('A','B');
			$Cloze::clozeline{$reader} .= $item[1];
			$Cloze::clozeline{$writer} .= $item[1]; }
		b: m/$b/ {
			($reader, $writer) = ('B','A');
			$Cloze::clozeline{$reader} .= $item[1];
			$Cloze::clozeline{$writer} .= $item[1]; }
		#unclozedword: <reject: $clozed> m/[A-Za-z0-9']+$punctuation/ {
		unclozedword: <reject: not $Cloze::unclozed> m/[A-Za-z0-9']+[^-A-Za-z0-9']+/ {
			$Cloze::unclozed--;
			$Cloze::clozeline{$reader} .= $item[2];
			$Cloze::clozeline{$writer} .= $item[2];
			}
		clozedword: <reject: $Cloze::unclozed> pass | clozeletter(s) | punctuation
		clozeletter:  firstletter | middleletter | lastletter
		# clozeletter: <reject: not $clozed> pass | firstletter | middleletter | lastletter | punctuation
		pass: <reject: $inCloze> m/($unclozeables|--|\w)[^-A-Za-z0-9']+/
			{
				$Cloze::clozeline{$reader} .= $item[2];
				$Cloze::clozeline{$writer} .= $item[2];
			}
		firstletter: <reject: $inCloze> m/[A-Za-z0-9](?!$punctuation)/ 
			{ $inCloze=1; $index = 0; @cword = ();
				$Cloze::clozeline{$reader} .= $item[2];
				push @cword, $item[2];
			}
		middleletter: <reject: not $inCloze> m/$letter(?!$punctuation)/
			{
				$index++;
				$Cloze::clozeline{$reader} .= $item[2];
				push @cword, $item[2];
			}
		lastletter: <reject: not $inCloze> m/$letter(?=$punctuation)/
			{
				$inCloze=0;
				$Cloze::unclozed=2;
				$index++;
				$Cloze::clozeline{$reader} .= $item[2];
				push @cword, $item[2];
				$clozedletters = int $#cword-($#cword-1)/2;
				$Cloze::score{$writer} += $clozedletters;
				$Cloze::clozeline{$writer} .= join '', (@cword[0..$#cword/2], map {"\\\\1{@{[$Cloze::score{$writer}-$_]}}"} reverse 0 .. $clozedletters-1);
			}
		punctuation: m/$punctuation/
			{
				$Cloze::clozeline{$writer} .= $item[1];
				$Cloze::clozeline{$reader} .= $item[1];
			}
		end: m/^\Z/
	]; 

	my $letterParser = Parse::RecDescent->new($letterGrammar);
	defined $letterParser->string($line) or die "letterparse died: $?\n";
	$text{A} .= $clozeline{A};
	$text{B} .= $clozeline{B};
		$lineN++;
	}
	return @score{qw/A B/}, \%text;

}

1;  # don’t forget to return a true value from the file
