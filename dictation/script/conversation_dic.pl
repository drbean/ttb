#!/usr/bin/env perl

# Last Edit: 2022 Jan 05,  1:10:04 PM
# $Id: /cloze/branches/ctest/dic.pl 1134 2007-03-17T11:05:37.500624Z greg  $

use strict;
use warnings;

sub usage_desc { "dic conversation -c CTEST -t TOPIC -s STORY -f FORM -p PAPER -u 
	UNCLOZEABLE" }

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

use lib qq{$ENV{HOME}/ttb/dictation/lib/};

use YAML qw/LoadFile/;
use Parse::RecDescent;
use Text::Template;
use Dic::Cloze::Conversation qw/simple_cloze cloze/;
use List::Util qw/any shuffle/;

our $RD_HINT = 1;

# my $round = LoadFile( "round.yaml" );
# my $league = LoadFile( "../league.yaml" );
# my @members = @{$league->{member}};
# my %ids = map { $_->{name} => $_->{id} } @members;
# my %names = map { $_->{id} => $_->{name} } @members;

my ($course, $cloze_style, $topic, $story, $form, $size, $unclozeable) = @ARGV;

# my ($course, $cloze_style, $topic, $story, $form, $size) = @$opt{qw/c z t s f p/};
my ($text_list, $question) = LoadFile
	"/home/$ENV{USER}/curriculum/$course/$topic/dic.yaml";

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

my $tmpl_handle = undef;
my $encoding = ":encoding(UTF-8)";
my $tmpl = "/home/$ENV{USER}/ttb/dictation/tmpl/preamble.tmpl";
open($tmpl_handle, "< $encoding", $tmpl) || die "$0: can't open $tmpl in read mode: $!";

my $tmplString;
$tmplString .= $_ while <$tmpl_handle>;

my $identifier;
my %romanize = (
	0 => "Zero", 1 => "One", 2 => "Two", 3 =>"Three"
	, 4 => "Four", 5 => "Five", 6 => "Six", 7 =>"Seven"
	, 8 => "Eight", 9 => "Nine", 10 => "Ten", 11 =>"Eleven" 
);

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
# my %word = ( A => $text->{Aword}, B => $text->{Bword} );
my %word;
# print "clozed Awords=@{$word{A}} Bwords=@{$word{B}}\n";
my %words; @words{'A', 'B' } = ('') x 2;
my $words;
if ( $text[0][6] and ref $text[0][6] eq 'HASH') {
	my $check = $text[0][6];
	my @pos = keys %$check;
	for my $pos ( @pos ) {
		next unless $check->{$pos};
		$hashed_check{$pos}{$_}++, $count_check++
			for split ' ', $check->{$pos};
		for my $a_or_b (qw/A B/) {
			for my $word ( @{$word{$a_or_b}} ) {
				my $Word = lc $word;
				push @{$binned{$a_or_b}{$pos}}, $Word if
				$hashed_check{$pos}{$Word};
			}
			die 
"No pos checks for pos=$pos of @pos, word=@{$word{$a_or_b}}, text=$text->{A}?" unless
			ref $binned{$a_or_b}{$pos} eq 'ARRAY';
			$words{$a_or_b} .= "\\textit{$pos}: " . join ' ', sort @{$binned{$a_or_b}{$pos}};
			$words{$a_or_b} .= "\\\\";
		}
	}
}
elsif ( %tag_bin ) {
	for my $a_or_b (qw/A B/) {
		my %a_or_b_bin;
		for my $word ( @{$word{$a_or_b}} ) {
			my $Word =lc $word;
			for my $pos ( keys %tag_bin ) {
				push @{$a_or_b_bin{$pos}}, $word 
					if any {$_ eq $Word} @{$tag_bin{$pos}};
			}
		}
		for my $pos ( keys %tag_bin ) {
			$words{$a_or_b} .= "\\textit{$pos}: " . (join ' ', 
				sort @{$a_or_b_bin{$pos}}) . "\\\\"
			if $a_or_b_bin{$pos};
		}
	}
}
#warn "pos check_count=$count_check, but clozed Awords= @{$word{A}} 
#	 Bwords=@{$word{B}}";

for my $j ( 0) {
	for my $i ( 0 .. $paper->{$size}->{i}) {
		$tmplString .= "
		\\begin{textblock}{8}($latex->[$j+2*$i]->{xy})
		\\textblocklabel{picture$latex->[$j+2*$i]->{xy}}
		\\dicX${story}X$romanize{$form}Xcard
		{ $textA}
		\\end{textblock}\n";
		$tmplString .= "
		\\begin{textblock}{8}($latex->[$j+2*$i+1]->{xy})
		\\textblocklabel{picture$latex->[$j+2*$i+1]->{xy}}
		\\dicX${story}X$romanize{$form}Xcard
		{ $textB}
		\\end{textblock}\n";
	}
	$tmplString .= "
	\\begin{tiny}" . ( $j+1 ) . "\\end{tiny}\\newpage\n\n";
}
$tmplString .= '
\end{document}
';

my $quiz;
# $quiz->{cardIdentifier} = join ' ', map { m{^/.*/.*/(.*)$};$1 } @$textSources;
$quiz->{cardIdentifier} = "$identifier";
$quiz->{story} = $story;
$quiz->{form} = $romanize{ $form };
$quiz->{autogen} = "% This file, dic_${story}_$form.tex was autogenerated on " . localtime() . "by dic.pl out of cards.tmpl";

my $template = Text::Template->new(TYPE => 'STRING', SOURCE => $tmplString
	, DELIMITERS => [ '<TMPL>', '</TMPL>' ] );
open TEX, ">/home/$ENV{USER}/curriculum/$course/$topic/dic_${story}_$form.tex" or die "No open on $topic: " . $!;
print TEX $template->fill_in( HASH => $quiz );

#system "xelatex --output-directory=/home/$ENV{USER}/curriculum/$course/$topic \
#	/home/$ENV{USER}/curriculum/$course/$topic/dic_${story}_$form.tex && \
#	lftp -c 'open greg\@web.nuu.edu.tw && cd public_html/$course && \
#	put ./$topic/dic_${story}_$form.pdf'";
1;
