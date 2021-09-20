package Dic::Command::conversation;

<<<<<<< .working
# Last Edit: 2020 Jul 16, 04:21:58 PM
||||||| .merge-left.r2933
# Last Edit: 2021 Aug 08,  2:32:03 PM
=======
# Last Edit: 2021 Aug 18,  2:43:43 PM
>>>>>>> .merge-right.r2949
# $Id: /cloze/branches/ctest/dic.pl 1134 2007-03-17T11:05:37.500624Z greg  $

use strict;
use warnings;

<<<<<<< .working
use Dic -command;
sub usage_desc { "dic conversation -c CTEST -t TOPIC -s STORY -f FORM -p PAPER" }
||||||| .merge-left.r2933
sub usage_desc { "dic text -c CTEST -t TOPIC -s STORY -f FORM -p PAPER" }
=======
sub usage_desc { "dic text -c CTEST -t TOPIC -s STORY -f FORM -p PAPER -u 
	UNCLOZEABLE" }
>>>>>>> .merge-right.r2949

sub opt_spec  {
	return (
		["c=s", "course"]
		, ["z=s", "cloze_style"]
		, ["t=s", "topic"]
		, ["s=s", "story"]
		, ["f=i", "form"]
		, ["p=s", "paper"]
		, ["u=s", "unclozeable/clozeable"]
	);
}

use IO::All;
use YAML qw/LoadFile/;
use Parse::RecDescent;
use Text::Template;
<<<<<<< .working
use Dic::Cloze::Conversation qw/cloze/;
use List::Util qw/shuffle/;
||||||| .merge-left.r2933
use Dic::Cloze::Text qw/cloze/;
use List::Util qw/any shuffle/;
=======
use Dic::Cloze::Text qw/simple_cloze cloze/;
use List::Util qw/any shuffle/;
>>>>>>> .merge-right.r2949

our $RD_HINT = 1;

# my $round = LoadFile( "round.yaml" );
# my $league = LoadFile( "../league.yaml" );
# my @members = @{$league->{member}};
# my %ids = map { $_->{name} => $_->{id} } @members;
# my %names = map { $_->{id} => $_->{name} } @members;

<<<<<<< .working
sub execute {
	my ($self, $opt, $args) = @_;
||||||| .merge-left.r2933
my ($course, $cloze_style, $topic, $story, $form, $size) = @ARGV;
=======
my ($course, $cloze_style, $topic, $story, $form, $size, $unclozeable) = @ARGV;
>>>>>>> .merge-right.r2949

	my ($course, $cloze_style, $topic, $story, $form, $size) = @$opt{qw/c z t s f p/};
	my ($text_list, $question) = LoadFile
		"/home/$ENV{USER}/curriculum/$course/" . $opt->{t} . "/dic.yaml";

	my $fields = shift( @$text_list );

	my $paper = { a7 => { latex => [
			{ page => 1, xy => "0,0" },
			{ page => 1, xy => "8,0" },
			{ page => 1, xy => "0,4" },
			{ page => 1, xy => "8,4" },
			{ page => 1, xy => "0,8" },
			{ page => 1, xy => "8,8" },
			{ page => 1, xy => "0,12" },
			{ page => 1, xy => "8,12" },
			],
			i => 3},
		a6 => { latex => [
			{ page => 1, xy => "8,0" },
			{ page => 1, xy => "0,0" },
			{ page => 1, xy => "8,8" },
			{ page => 1, xy => "0,8" },
			],
			i => 1}
	};

	my $latex = $paper->{$size}->{latex};

			# { page => 1, xy => "0,0" },
			# { page => 1, xy => "8,0" },
			# { page => 1, xy => "0,4" },
			# { page => 1, xy => "8,4" },
			# { page => 1, xy => "0,8" },
			# { page => 1, xy => "8,8" },
			# { page => 1, xy => "0,12" },
			# { page => 1, xy => "8,12" },
			# { page => 2, xy => "0,0" },
			# { page => 2, xy => "8,0" },
			# { page => 2, xy => "0,4" },
			# { page => 2, xy => "8,4" },
			# { page => 2, xy => "0,8" },
			# { page => 2, xy => "8,8" },
			# { page => 2, xy => "0,12" },
			# { page => 2, xy => "8,12" },
			# { page => 1, xy => "8,0" },
			# { page => 1, xy => "0,0" },
			# { page => 1, xy => "8,8" },
			# { page => 1, xy => "0,8" },
			# { page => 3, xy => "8,0" },
			# { page => 3, xy => "0,0" },
			# { page => 3, xy => "8,8" },
			# { page => 3, xy => "0,8" },

	my $paging = 0;
	my $threepages = 0;

	my $tmpl = io "/home/$ENV{USER}/ttb/dictation/tmpl/preamble.tmpl";
	my $tmplString = $tmpl->all;

	my $identifier;
	my %romanize = (
		0 => "Zero", 1 => "One", 2 => "Two", 3 =>"Three"
		, 4 => "Four", 5 => "Five", 6 => "Six", 7 =>"Seven"
		, 8 => "Eight", 9 => "Nine", 10 => "Ten", 11 =>"Eleven" 
	);

	$identifier = "$opt->{s}-$opt->{f}";
	my @text = grep { $_->[0] eq $identifier } @$text_list;
	die "No texts or more than 1 text called $identifier\n" if @text != 1;

<<<<<<< .working
	my $lines = $text[0][4];
	my @lines = split /\n/, $lines;
	my $unclozeables = $text[0][5];
	my $text = cloze($cloze_style, $unclozeables, @lines);
	my $textA = $text->{A};
	my $textB = $text->{B};
	for my $j ( 0) {
		for my $i ( 0 .. $paper->{$size}->{i}) {
			$tmplString .= "
\\begin{textblock}{8}($latex->[$j+2*$i]->{xy})
\\textblocklabel{picture$latex->[$j+2*$i]->{xy}}
\\dicX$opt->{s}X$romanize{$opt->{f}}Xcard
{$textA}
\\end{textblock}\n";
			$tmplString .= "
\\begin{textblock}{8}($latex->[$j+2*$i+1]->{xy})
\\textblocklabel{picture$latex->[$j+2*$i+1]->{xy}}
\\dicX$opt->{s}X$romanize{$opt->{f}}Xcard
{$textB}
\\end{textblock}\n";
||||||| .merge-left.r2933
$identifier = "$story-$form";
my @text = grep { $_->[0] eq $identifier } @$text_list;
die "No texts or more than 1 text called $identifier\n" if @text != 1;

my $lines = $text[0][4];
my @lines = split /\n/, $lines;
my $unclozeables = $text[0][5];
my $text = cloze($cloze_style, $unclozeables, @lines);
my $textA = $text->{A};
my $textB = $text->{B};
my $word = $text->{word};
print "words=@$word";
my $words;
if ( $text[0][6] and ref $text[0][6] eq 'HASH') {
	my $check = $text[0][6];
	my @pos = keys %$check;
	my ( %hashed_check, $count_check, %binned );
	for my $pos ( @pos ) {
		next unless $check->{$pos};
		$hashed_check{$pos}{$_}++, $count_check++
			for split ' ', $check->{$pos};
		for my $word ( @$word ) {
			push @{$binned{$pos}}, $word if
				$hashed_check{$pos}{$word};
=======
$identifier = "$story-$form";
my @text = grep { $_->[0] eq $identifier } @$text_list;
die "No texts or more than 1 text called $identifier\n" if @text != 1;

my $lines = $text[0][4];
my @lines = split /\n/, $lines;
my $text;
my ( %hashed_check, $count_check, %binned, %tag_bin );
if ( $unclozeable ) {
	my $unclozeables = $text[0][5];
	$text = cloze($cloze_style, $unclozeables, @lines);
}
else {
	my $clozes = $text[0][5];
	my $clean_clozes;
	for my $cloze ( split ' ', lc $clozes ) {
		if ( $cloze =~m/^(.*)\.(\w+)$/ ) {
			my $tagless = $1;
			my $pos = $2;
			push @{$tag_bin{$pos}}, $tagless;
			$clean_clozes .= "$tagless ";
			$count_check++;
		}
		else { $clean_clozes .= "$cloze " }
	}
	$text = simple_cloze($cloze_style, $clean_clozes, @lines);
}
my $textA = $text->{A};
my $textB = $text->{B};
my $word = $text->{word};
print "clozed words=@$word\n";
my $words;
if ( $text[0][6] and ref $text[0][6] eq 'HASH') {
	my $check = $text[0][6];
	my @pos = keys %$check;
	for my $pos ( @pos ) {
		next unless $check->{$pos};
		$hashed_check{$pos}{$_}++, $count_check++
			for split ' ', $check->{$pos};
		for my $word ( @$word ) {
			my $Word = lc $word;
			push @{$binned{$pos}}, $Word if
				$hashed_check{$pos}{$Word};
>>>>>>> .merge-right.r2949
		}
<<<<<<< .working
		$tmplString .= "
\\begin{Large}" . ( $j+1 ) . "\\end{Large}\\newpage\n\n";
||||||| .merge-left.r2933
		die "No pos checks for pos=$pos, word=@$word?" unless
			ref $binned{$pos} eq 'ARRAY';
		$words .= "$pos: " . join ' ', sort @{$binned{$pos}};
		$words .= "\\\\";
	}
	warn "pos check_count=$count_check, but words=" . @$word if
		$count_check != @$word;
}
elsif (ref $word eq 'ARRAY') {
	$words = join ' ', sort @$word;
	$words .= "\\\\";
}
=======
		die 
"No pos checks for pos=$pos of @pos, word=@$word, text=$text->{A}?" unless
			ref $binned{$pos} eq 'ARRAY';
		$words .= "\\textit{$pos}: " . join ' ', sort @{$binned{$pos}};
		$words .= "\\\\";
	}
}
elsif ( %tag_bin ) {
	$words .= "\\textit{$_}: " . (join ' ', sort @{$tag_bin{$_}}) . "\\\\"
		for keys %tag_bin;
}
elsif (ref $word eq 'ARRAY') {
	$words = join ' ', sort @$word;
	$words .= "\\\\";
}
>>>>>>> .merge-right.r2949
warn "pos check_count=$count_check, but clozed words=" . @$word;

<<<<<<< .working

||||||| .merge-left.r2933
print $words;

=======
>>>>>>> .merge-right.r2949
	}
	$tmplString .= '
\end{document}
';

	my $quiz;
	# $quiz->{cardIdentifier} = join ' ', map { m{^/.*/.*/(.*)$};$1 } @$textSources;
	$quiz->{cardIdentifier} = "$identifier";
	$quiz->{story} = $opt->{s};
	$quiz->{form} = $romanize{ $opt->{f} };
	$quiz->{autogen} = "% This file, dic_$opt->{s}_$opt->{f}.tex was autogenerated on " . localtime() . "by dic.pl out of cards.tmpl";

	my $template = Text::Template->new(TYPE => 'STRING', SOURCE => $tmplString
					, DELIMITERS => [ '<TMPL>', '</TMPL>' ] );
	open TEX, ">/home/$ENV{USER}/curriculum/$course/$opt->{t}/dic_$opt->{s}_$opt->{f}.tex" or die "No open on " . $opt->{t} . ": " . $!;
	print TEX $template->fill_in( HASH => $quiz );

<<<<<<< .working
}

||||||| .merge-left.r2933
system "xelatex --output-directory=/home/$ENV{USER}/curriculum/$course/$topic \
	/home/$ENV{USER}/curriculum/$course/$topic/dic_${story}_$form.tex && \
	lftp -c 'open greg\@web.nuu.edu.tw && cd public_html/$course && \
	put ./$topic/dic_${story}_$form.pdf'";
=======
#system "xelatex --output-directory=/home/$ENV{USER}/curriculum/$course/$topic \
#	/home/$ENV{USER}/curriculum/$course/$topic/dic_${story}_$form.tex && \
#	lftp -c 'open greg\@web.nuu.edu.tw && cd public_html/$course && \
#	put ./$topic/dic_${story}_$form.pdf'";
>>>>>>> .merge-right.r2949
1;
