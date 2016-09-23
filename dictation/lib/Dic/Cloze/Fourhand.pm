package Dic::Cloze::Fourhand;  # assumes Some/Module.pm

# Last Edit: 2016 Sep 23, 11:47:24 AM
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
	$::RD_HINT=1;
	my $cloze_style = shift;
	my $unclozeables = shift;
	chomp $unclozeables;
	our $unclozeable = $unclozeables? qr/(?:$unclozeables)/: undef;
	my @lines = @_;
	my %text = ();
	our (%letter_score, $letter_score);
	our (%word_score, $word_score);
	($letter_score{A}, $letter_score{B}, $letter_score{C}, $letter_score{D}, $letter_score) = (0) x 3;
	($word_score{A}, $word_score{B}, $word_score{C}, $word_score{D}, $word_score) = (0) x 3;

	our @player = ( 'A' .. 'D' );

	our $lineN = 0;
	our $reader = $player[$lineN];
	our @writers = grep !/$reader/, @player;

$DB::single=1;

	foreach my $line ( @lines )
	{
		$reader = $player[$lineN];
		@writers = grep !/$reader/, @player;
		our %clozeline;
		@clozeline{'A', 'B', 'C', 'D' } = ('') x 4;
		my $letterGrammar = q[
			{
				my $punctuation = qr/[^-A-Za-z0-9']+/;
				my $name = qr/[A-Z][-A-Za-z0-9']*/; # qr/\u\w\w*\b/;
				my ($a, $b) = (qr/^G: /, qr/^B: /);
				my $letter = qr/[A-Za-z0-9']/;
				my $skip = '';
				my @cword;
				my ($index, $inWord) = (0) x 2;
			}
			string: token(s) end | <error>
			token: pass | firstletter | middleletter | lastletter | punctuation
			punctuation: <reject: $inWord> m/$punctuation/
				{
					$Dic::Cloze::Fourhand::clozeline{$_} .= $item[2] for @Dic::Cloze::Fourhand::writers;
					$Dic::Cloze::Fourhand::clozeline{$Dic::Cloze::Fourhand::reader} .= $item[2];
				}
			end: m/^\Z/
			firstletter: <reject: $inWord> m/[A-Za-z0-9]/ 
				{ $inWord=1; $index = 0; @cword = ();
					$Dic::Cloze::Fourhand::word_score++;
					$Dic::Cloze::Fourhand::letter_score++;
					# $Cloze::clozeline{$_} .= "\\\\1{$Cloze::word_score}" for @writers;
					push @cword, $item[2];
				}
			middleletter: <reject: not $inWord> m/$letter(?!$punctuation)/
				{
					$index++;
					$Dic::Cloze::Fourhand::letter_score++;
					# $Cloze::clozeline{$writer} .= "\\\\1{}";
					push @cword, $item[2];
				}
		]; 
		if ( $cloze_style ne 'firstlast' ) {
			$letterGrammar .= q[
			lastletter: <reject: not $inWord> m/$letter(?=$punctuation)/
				{
					$inWord=0;
					$index++;
					$Dic::Cloze::Fourhand::letter_score++;
					# $Cloze::clozeline{$writer} .= "\\\\1{}";
					push @cword, $item[2];
					if ( $#cword > 2 ) {
						$Dic::Cloze::Fourhand::clozeline{$_} .= join '', (@cword[0..$#cword/2], "\\\\1{$Dic::Cloze::Fourhand::word_score}"
							, map {"\\\\1{}"} reverse 2 .. $#cword-($#cword-1)/2-1)
							, $cword[-1] for @Dic::Cloze::Fourhand::writers;
					}
					else {
						$Dic::Cloze::Fourhand::clozeline{$_} .= join '', (@cword[0..$#cword/2], "\\\\1{$Dic::Cloze::Fourhand::word_score}" , map {"\\\\1{}"} reverse 1 .. $#cword-($#cword-1)/2-1) for @Dic::Cloze::Fourhand::writers;
					}
					$Dic::Cloze::Fourhand::clozeline{$Dic::Cloze::Fourhand::reader} .= join '', @cword, "\\\\hspace{0.05cm}", "\\\\textsubscript{\\\\tiny $Dic::Cloze::Fourhand::word_score}";
				}
			]; 
		}
		if ( $cloze_style eq 'firstlast' ) {
			$letterGrammar .= q[
			lastletter: <reject: not $inWord> m/$letter(?=$punctuation)/
				{
					$inWord=0;
					$index++;
					$Dic::Cloze::Fourhand::letter_score++;
					# $Cloze::clozeline{$writer} .= "\\\\1{}";
					push @cword, $item[2];
					if ( $#cword > 2 ) {
						$Dic::Cloze::Fourhand::clozeline{$_} .= join '', (@cword[0], "\\\\1{$Dic::Cloze::Fourhand::word_score}"
							, map {"\\\\1{}"} 0 .. ( $#cword - 3 ) )
							, $cword[-1] for @Dic::Cloze::Fourhand::writers;
					}
					else {
						$Dic::Cloze::Fourhand::clozeline{$_} .= join '', (@cword[0..$#cword/2], "\\\\1{$Dic::Cloze::Fourhand::word_score}" , map {"\\\\1{}"} reverse 1 .. $#cword-($#cword-1)/2-1) for @Dic::Cloze::Fourhand::writers;
					}
					$Dic::Cloze::Fourhand::clozeline{$Dic::Cloze::Fourhand::reader} .= join '', @cword, "\\\\hspace{0.05cm}", "\\\\textsubscript{\\\\tiny $Dic::Cloze::Fourhand::word_score}";
				}
			]; 
		}
		else {
			$letterGrammar .= q[
			lastletter: <reject: not $inWord> m/$letter(?=$punctuation)/
				{
					$inWord=0;
					$index++;
					$Dic::Cloze::Fourhand::letter_score++;
					# $Cloze::clozeline{$writer} .= "\\\\1{}";
					push @cword, $item[2];
					if ( $#cword > 2 ) {
						$Dic::Cloze::Fourhand::clozeline{$_} .= join '', (@cword[0..$#cword/2], "\\\\1{$Dic::Cloze::Fourhand::word_score}"
							, map {"\\\\1{}"} reverse 2 .. $#cword-($#cword-1)/2-1)
							, $cword[-1] for @Dic::Cloze::Fourhand::writers;
					}
					else {
						$Dic::Cloze::Fourhand::clozeline{$_} .= join '', (@cword[0..$#cword/2], "\\\\1{$Dic::Cloze::Fourhand::word_score}" , map {"\\\\1{}"} reverse 1 .. $#cword-($#cword-1)/2-1) for @Dic::Cloze::Fourhand::writers;
					}
					$Dic::Cloze::Fourhand::clozeline{$Dic::Cloze::Fourhand::reader} .= join '', @cword, "\\\\hspace{0.05cm}", "\\\\textsubscript{\\\\tiny $Dic::Cloze::Fourhand::word_score}";
				}
			];
		} 
		if ( $unclozeables ) {
			$letterGrammar .= q[
			pass: <reject: $inWord> m/($Dic::Cloze::Fourhand::unclozeable|\w)(?=$punctuation)/m
				{
					$Dic::Cloze::Fourhand::word_score++;
					$Dic::Cloze::Fourhand::clozeline{$_} .= $item[2] for @Dic::Cloze::Fourhand::writers;
					$Dic::Cloze::Fourhand::clozeline{$Dic::Cloze::Fourhand::reader} .= $item[2];
				}
			];
		}
		else {
			$letterGrammar .= q[
			pass: <reject: $inWord> m/(\w)(?=$punctuation)/m
				{
					$Dic::Cloze::Fourhand::word_score++;
					$Dic::Cloze::Fourhand::clozeline{$_} .= $item[2] for @Dic::Cloze::Fourhand::writers;
					$Dic::Cloze::Fourhand::clozeline{$Dic::Cloze::Fourhand::reader} .= $item[2];
				}
			];
		}

		my $letterParser = Parse::RecDescent->new($letterGrammar);
		defined $letterParser->string($line) or die "letterparse died: $?\n";
		$text{A} .= "\\hspace{0cm} \\\\" . $clozeline{A};
		$text{B} .= "~\\\\" . $clozeline{B};
		$text{C} .= "~\\\\" . $clozeline{C};
		$text{D} .= "~\\\\" . $clozeline{D};
		$lineN = ++$lineN % 4;
	}
	return \%text;

}

1;  # don’t forget to return a true value from the file
