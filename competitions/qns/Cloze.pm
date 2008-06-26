package Cloze;  # assumes Some/Module.pm

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

	our (%score, $score);
	($score{A}, $score{B}, $score) = (0) x 3;

	our $RD_HINT=1;

	my %text = ();
use orz;

	my @lines = @_;
# @text{'A', 'B' } = ('') x 2;
	our $reader = '';

	my $lineGrammar = q[
		{ my $inA = 0; }
		string: token(s) end | <error>
		token: header | footer | a | b | sentenceA | sentenceB
		header: m/Conversation \d/ { $Cloze::reader = 'AB'; }
		footer: m/\\\\/ { $Cloze::reader = 'AB' }
		a: m/(Hannah|James|Suzy|Waitress|Clerk|Agent): .*$/ { $Cloze::reader = 'A'; }
		b: m/(Customer|Susie|Barry|David): .*$/ { $Cloze::reader = 'B'; }
		sentenceA: <reject: $inA> m/^A:.*$/ {$inA=1; $Cloze::reader='A';}
		sentenceB:  m/^B:.*$/ {$inA=0; $Cloze::reader='B';}
		end: m/^\Z/
	]; 

	foreach my $line ( @lines )
	{
		my $lineParser = Parse::RecDescent->new($lineGrammar);
		defined $lineParser->string($line) or die "lineparse died at $line: $?\n";

		foreach our $player ( @players )
		{
			if ( $reader =~ m/$player/ )
			{
no orz;

	my @players = ( 'A' .. 'B' );
my $player = 'B';
	my $lineN = 0;

my ($q, $as) = @_;

				push @{$text{A}},
					'\normalsize '.$q;
			#}	
			#else
			#{


	our $writer = 'B';
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
		token: pass | firstletter | secondletter | otherletters | lastletterplus
		pass: <reject: $inWord> m/(Hong Kong|Japan|Boston|Mexico City|San Francisco|\w)$punctuation/
			{ push @Cloze::blankedText, $item[2]}
		firstletter: <reject: $inWord> m/[A-Za-z0-9]/ 
			{ $inWord=1;push @Cloze::blankedText,
						$item[2]; }
		secondletter: <reject: $inLatex> m/$letter(?!$punctuation)/
			{
				$inLatex = 1;
				$Cloze::score{$Cloze::writer}++;
				push @Cloze::blankedText, "\\\\1{$Cloze::score{$Cloze::writer}}";
			}
		otherletters: <reject: not $inLatex> m/$letter(?!$punctuation)/
			{
				$Cloze::score{$Cloze::writer}++;
				push @Cloze::blankedText, "\\\\1{$Cloze::score{$Cloze::writer}}";
				# push @Cloze::blankedText, "\\\\textref h:L v:B \\\\htext{\\\\tiny $Cloze::score{$Cloze::writer}}", '\1';
			}
		lastletterplus: <reject: not $inWord> m/$letter[^-A-Za-z0-9']+/
			{
				$inWord=0;
				$inLatex = 0;
				push @Cloze::blankedText, $item[2];
			}
		end: m/^\Z/
	]; 

	my $letterParser = Parse::RecDescent->new($letterGrammar);
	defined $letterParser->string($q) or die "letterparse died: $?\n";
	push @{$text{$player}}, '\large ' . (join '', @blankedText). "\\normalsize
	\\begin{description}
	\\vspace{-0.2cm}
	\\item [a:] $as->[0]
	\\vspace{-0.2cm}
	\\item [b:] $as->[1]
	\\end{description}";
	#}
		#}
		$lineN++;
#}
	return \%text;

}

1;  # don’t forget to return a true value from the file
