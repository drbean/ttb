package Cloze;  # assumes Some/Module.pm

# Last Edit: 2008  9月 29, 15時15分18秒
# $Id: /dic/branches/ctest/Cloze.pm 1263 2007-06-23T12:37:20.810966Z greg  $

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
	# my $score = shift;
	@score{qw/A B C D/} = (0) x 4;
	# ( $score->{A}, $score->{B}, $score->{C}, $score->{D} );
	our ($unclozedcount, $unclozedwords);
	$unclozedcount = $unclozedwords = shift;
	my $unclozeables = join '|', @{shift()};
	our $unclozeable = qr/(?:$unclozeables)/;
	# our $unclozeable = qr/Claudio|Cecilia|Frank|Paula/;
	our $inword = 0;

	our %text = ();

	our $lines = shift;

	my @players = ( 'A' .. 'D' );

	my $lineN = 0;

	# foreach my $line ( @lines )
	# {
	our %clozeline;
@clozeline{'A', 'B', 'C', 'D' } = ('') x 2;
	my $letterGrammar = q[
		{
	my $reader = '';
	my @writers = ();
			# my $punctuation = qr/[^A-Za-z0-9']/;
			my $punctuation = qr/[.,?!\n]/;
			my $name = qr/[A-Z][-A-Za-z0-9']*/; # qr/\u\w\w*\b/;
			my ($a, $b, $c, $d) = (qr/^Claudio:/, qr/^Cecilia:/, qr/^Frank:/, qr/^Paula:/);
			my $letters = qr/[A-Za-z0-9']+/;
			# my $skip = '';
			my @cword;
			my ($index, $inCloze, $clozedletters) = (0) x 3;
		}
		text: section(s) end | <error>
		# section: vspace eol header eol line(s) eos | header eol line(s) eos | line(s) eos
		section: vspace eol header eol line(s) | header eol line(s) | line(s)
		# line: vspace m/$/ | header m/$/ | token(s) m/$/
		vspace: m/vspace{\d?.\d+cm}/ {
			$reader = undef;
			@writers = qw/A B C D/;
			@Cloze::clozeline{@writers} .= ( "\\\\$item[1]\\\\par" ) x 3;
			}
		header: m/\d\W+/ {
			$reader = undef;
			@writers = qw/A B C D/;
			@Cloze::clozeline{$_} .= $item[1] for @writers;
			}
		line: eos | token(s) eol
		eos: m/\\\\\\\\/ {
			$reader = undef;
			@writers = qw/A B C D/;
			@Cloze::clozeline{$_} .= "\\\\vspace{0.2cm}\n\\\\par\n" for @writers;
			}
		token: a | b | c | d | punctuation | word
		eol: m/\\\\\\\\/ {
			$reader = undef;
			@writers = qw/A B C D/;
			@Cloze::clozeline{$_} .= "\\\\\\\\\n" for @writers;
			}
		a: m/$a/ {
			($reader, @writers) = ('A','B', 'C', 'D');
			@Cloze::clozeline{$_} .= $item[1] for $reader, @writers;
			}
		b: m/$b/ {
			($reader, @writers) = ('B','A', 'C', 'D');
			@Cloze::clozeline{$_} .= $item[1] for $reader, @writers;
			}
		c: m/$c/ {
			($reader, @writers) = ('C','A', 'B', 'D');
			@Cloze::clozeline{$_} .= $item[1] for $reader, @writers;
			}
		d: m/$d/ {
			($reader, @writers) = ('D','A', 'B', 'C');
			@Cloze::clozeline{$_} .= $item[1] for $reader, @writers;
			}
		punctuation: m/$punctuation/ {
			@Cloze::clozeline{$_} .= $item[1] for $reader, @writers;
			}
		word: unclozedword | clozedword
		unclozedword:   m/$Cloze::unclozeable/ {
			@Cloze::clozeline{$_} .= ' ' . $item[1] for $reader, @writers;
			}
		# clozedword: letter(s) |
		clozedword: m/$letters/ {
			$Cloze::inword=1;
			$Cloze::clozeline{$reader} .= ' ' . $item[1];
			my $length = length $item[1];
			for my $writer (@writers)
			{
				@Cloze::clozeline{$writer} .= ' ' .
				join '',
					map { "\\\\1{@{[++$Cloze::score{$writer}]}}" }
						1 .. $length;
			}
			}
		# letter: m/$letter/ {
		# 	$Cloze::clozeline{$reader} .= $item[1];
		# 	@Cloze::clozeline{$_} .= '_' for @writers;
		# 	#join '',
		# 	#map { $writer = $_; 
		# 	#	map $Cloze::score{$writer}} @writers;
		# 	#$length = length $item[2];
		# 	}
			#lastletter: <reject: not $inCloze> m/$letter(?=$punctuation)/
			#{
			#	$inCloze=0;
			#	$Cloze::unclozedcount=$Cloze::unclozedwords;
			#	$index++;
			#	$Cloze::clozeline{$reader} .= $item[2];
			#	push @cword, $item[2];
			#	$clozedletters = int $#cword-($#cword-1)/2;
			#	$Cloze::score{@writers} += $clozedletters;
			#	$Cloze::clozeline{@writers} .= join '', (@cword[0..$#cword/2], map {"\\\\1{@{[$Cloze::score{@writers}-$_]}}"} reverse 0 .. $clozedletters-1);
			#	# $Cloze::clozeline{@writers} .= join '', @cword[0..$#cword/2], "<input type=\"text\" name=\"$Cloze::score{@writers}\" length=\"".(int @cword/2)."\" size=\"".(int @cword/2)."\"/>";
			#}
		end: m/^\Z/
	]; 

	my $letterParser = Parse::RecDescent->new($letterGrammar);
	# defined $letterParser->line($line) or die "letterparse died: $?\n";
	defined $letterParser->text($Cloze::lines) or die "letterparse died: $?\n";
	# }
	return %Cloze::clozeline;

}

1;  # don’t forget to return a true value from the file
