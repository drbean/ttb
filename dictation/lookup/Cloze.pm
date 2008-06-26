package Cloze;  # assumes Some/Module.pm

# Last Edit: 2007 Oct 28, 03:27:20 PM
# $Id: /cloze/branches/lookup/Cloze.pm 1542 2007-10-28T07:32:25.305379Z greg  $

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
	my $score = shift;
	our %score;
	@score{qw/A B/} = ( $score->{A}, $score->{B} );
	my $unclozeables = join '|', @{shift()};
        our $unclozeable = qr/(?:$unclozeables)/;
	my @lines = @_;
	my %text = ();
	foreach my $line ( @lines )
	{
		our %clozeline;
		@clozeline{'A', 'B' } = ('') x 2;
		our %dic = ();
		my $letterGrammar = q[
			{
		my $reader = '';
		my $writer = '';
			my $punctuation = qr/[^-A-Za-z0-9']+/;
			my $name = qr/[A-Z][-A-Za-z0-9']*/; # qr/\u\w\w*\b/;
			my ($a, $b) = (qr/^\d+: /, qr/^\d+: /);
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
			pass: <reject: $inWord> m/($Cloze::unclozeable|--|\w)$punctuation/
			{
				$Cloze::clozeline{$writer} .= $item[2];
				$Cloze::clozeline{$reader} .= $item[2];
			}
		firstletter: <reject: $inWord> m/[A-Za-z0-9]/ 
			{ $inWord=1; $index = 0; @cword = ($item[2]);
				# $Cloze::clozeline{$writer} .= "\\\\1{$Cloze::score}";
				$Cloze::clozeline{$writer} .= $item[2];
				$Cloze::clozeline{$reader} .= $item[2];
			}
		middleletter: <reject: not $inWord> m/$letter(?!$punctuation)/
			{
				$index++;
				push @cword, $item[2];
				$Cloze::score{A}++;
				$Cloze::score{B}++;
				$Cloze::clozeline{$writer} .= "\\\\1{$Cloze::score{A}}";
				$Cloze::clozeline{$reader} .= "\\\\1{$Cloze::score{B}}";
			}
		lastletter: <reject: not $inWord> m/$letter(?=$punctuation)/
			{
				$inWord=0;
				$index++;
				push @cword, $item[2];
				$Cloze::dic{join '', @cword}++;# if @cword > 2;
				if ( @cword <= 2 )
				{
					$Cloze::score{A}++;
					$Cloze::score{B}++;
					$Cloze::clozeline{$writer} .=
						"\\\\1{$Cloze::score{A}}";
					$Cloze::clozeline{$reader} .=
						"\\\\1{$Cloze::score{B}}";
				}
				else
				{				
					$Cloze::clozeline{$writer} .= $item[2];
					$Cloze::clozeline{$reader} .= $item[2];
				}
			}
		punctuation: <reject: $inWord> m/$punctuation/
			{
				$Cloze::clozeline{$writer} .= $item[2];
				$Cloze::clozeline{$reader} .= $item[2];
			}
		end: m/^\Z/
		]; 

		my $letterParser = Parse::RecDescent->new($letterGrammar);
		defined $letterParser->string($line) or die "letterparse NOK.";
		$text{A} .= $clozeline{A};
		$text{B} .= $clozeline{B};
		for my $word ( keys %dic )
		{
			$text{dic}{$word} += $dic{$word};
		}
	}
	return \%score, \%text;

}

1;  # don’t forget to return a true value from the file
