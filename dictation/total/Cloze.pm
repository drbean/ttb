package Cloze;  # assumes Some/Module.pm

# Last Edit: 2006 Nov 21, 05:32:54 PM
# $Id: /cloze/branches/total/Cloze.pm 1019 2006-11-28T03:02:09.709323Z greg  $

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
	my @lines = @_;
	my %text = ();
# @text{'A', 'B' } = ('') x 2;
	our $reader = '';
	our (%score, $score);
	($score{A}, $score{B}, $score) = (0) x 3;

	our $RD_HINT=1;

	my $lineGrammar = q[
		{ my $inA = 0; }
		string: token(s) end | <error>
		token: header | footer | a | b | sentenceA | sentenceB
		header: m/Conversation \d/ { $Cloze::reader = 'AB'; }
		footer: m/\\\\/ { $Cloze::reader = 'AB' }
		a: m/(Clerk): .*$/ { $Cloze::reader = 'A'; }
		b: m/(Guest): .*$/ { $Cloze::reader = 'B'; }
		sentenceA: <reject: $inA> m/^A:.*$/ {$inA=1; $Cloze::reader='A';}
		sentenceB:  m/^(B|C):.*$/ {$inA=0; $Cloze::reader='B';}
		end: m/^\Z/
	]; 

	my @players = ( 'A' .. 'B' );

	my $lineN = 0;

	foreach my $line ( @lines )
	{
		my $lineParser = Parse::RecDescent->new($lineGrammar);
		defined $lineParser->string($line) or die "lineparse died at $line: $?\n";

		foreach our $player ( @players )
		{
			my $macro = ($reader =~ m/$player/)?
				 '2': q[1{$Cloze::score{$Cloze::player}}];

	# our $writer = $player;
	our @blankedText = ();
	my $letterGrammar = q[
		{
			my $punctuation = qr/[^-A-Za-z0-9']+/;
			my $name = qr/[A-Z][-A-Za-z0-9']*/; # qr/\u\w\w*\b/;
			my $letter = qr/[-A-Za-z0-9']/;
			my $skip = '';
			my ($inLatex, $inWord) = (0) x 2;
		}
		string: token(s) end | <error>
		token: pass | firstletter | secondletter | otherletters | lastletter | punctuation
		pass: <reject: $inWord> m/(Clerk|Guest|--|\w)$punctuation/
			{ push @Cloze::blankedText, $item[2]}
		firstletter: <reject: $inWord> m/[A-Za-z0-9]/ 
			{ $inWord=1;
			# push @Cloze::blankedText, $item[2];
				$Cloze::score{$Cloze::player}++
					unless $Cloze::reader eq $Cloze::player;
				push @Cloze::blankedText, "\\\\] . $macro  . 
					q[";
			}
		secondletter: <reject: $inLatex> m/$letter(?!$punctuation)/
			{
				$inLatex = 1;
				$Cloze::score{$Cloze::player}++
					unless $Cloze::reader eq $Cloze::player;
				push @Cloze::blankedText, "\\\\] . $macro  . 
					q[";
			}
		otherletters: <reject: not $inLatex> m/$letter(?!$punctuation)/
			{
				$Cloze::score{$Cloze::player}++
					unless $Cloze::reader eq $Cloze::player;
				push @Cloze::blankedText, "\\\\] . $macro .
					q[";
			}
		#lastletterplus: <reject: not $inWord> m/$letter[^-A-Za-z0-9']+/
		lastletter: <reject: not $inWord> m/$letter(?=$punctuation)/
			{
				$inWord=0;
				$inLatex = 0;
				$Cloze::score{$Cloze::player}++
					unless $Cloze::reader eq $Cloze::player;
				push @Cloze::blankedText, "\\\\] . $macro  . 
					q[";
			}
		punctuation: <reject: $inWord> m/$punctuation/
			{
				push @Cloze::blankedText, $item[2];
			}
		end: m/^\Z/
	]; 

	my $letterParser = Parse::RecDescent->new($letterGrammar);
	defined $letterParser->string($line) or die "letterparse died: $?\n";
	if ( $macro eq '2' )
	{push @{$text{$player}}, '\normalsize ' . (join '', @blankedText);}
	else
	{push @{$text{$player}}, '\large ' . (join '', @blankedText);}
		}
		$lineN++;
	}
	return \%text;

}

1;  # don’t forget to return a true value from the file
