#!/usr/bin/perl

# Last Edit: 2005 Nov 07, 02:49:05 PM

use strict;
use warnings;

use List::Util qw/shuffle/;
use IO::All;
use YAML qw/LoadFile DumpFile/;
use Parse::RecDescent;
use Text::Template;

my $textSource = '/home/greg/li/m/1.txt';

my $e = io $textSource;
my $txt = $e->all;

our $blanks;
our @text;
our %dic;
our $entry;


my $players = 4;
my $blanksPerPlayer = 24;
my $blanksPerTable = $players * $blanksPerPlayer;

our $RD_HINT=1;

my $letterGrammar = q[
	{ my $skip = ''; my $inword = 0 }
	string: token(s) end | <error>
	token: punctuation | firstletter | followingletter | name
	punctuation: m/[^A-Za-z0-9']+/ { $inword=0; push @::text, $item[1]; }
	name: m/[A-Z][A-Za-z0-9'-]*/ { push @::text, $item[1]}
	firstletter: <reject: $inword> m/[a-z0-9]/ 
					{ $inword=1;push @::text, $item[2]; }
	followingletter: <reject: not $inword> m/[a-z0-9']/
		{
			$::blanks++;
			push @::text, $item[2];
		}
	end: m/^\Z/
]; 

my $wordGrammar = q[
	string: token(s) end | <error>
	token: punctuation | word | name
	punctuation: m/[^A-Za-z0-9']+/ 
	name: m/[A-Z][A-Za-z0-9'-]*/
	word: m/[a-z0-9][a-z0-9']*/ { $::dic{ $item[1] }++; }
	end: m/^\Z/
]; 

my $letterParser = Parse::RecDescent->new($letterGrammar);
defined $letterParser->string($txt) or die "letterparse died: $?\n";

my $wordParser = Parse::RecDescent->new($wordGrammar);
defined $wordParser->string($txt) or die "wordparse died: $?\n";

die 'not enough blanks' unless $blanks >= $blanksPerTable;

$blanksPerPlayer = int $blanks / $players;

my $quiz;
my %prompText;
my %blankedText;
my $position = 0;
my %blanksAlloted;
@blanksAlloted{'A','B','C','D' } = (0,0,0,0);
my $startNextPlayer = ( $blanks - $blanksPerPlayer ) / ($players-1);
my @players = ( 'A' .. 'D' );

my $punctuation = qr/[^A-Za-z0-9']+/;
my $name = qr/\u\w\w*\b/;
my $letter = qr/[a-z0-9']/;
my $inword = 0;

# A is Black is A & C
# B is Red is B & D
my %dicBlack;
my %dicRed;
@dicBlack{keys %dic} = (0) x (keys %dic);
@dicRed{keys %dic} = (0) x (keys %dic);
my $scoreBlack = 0;
my $scoreRed = 0;

foreach my $player ( @players )
{
	$blanksPerPlayer = (int $blanks/2 - $blanksAlloted{A}) if ($player eq 'C' );
	$blanksPerPlayer = (int $blanks/2 - $blanksAlloted{B}) if ($player eq 'D' );
	
	push @{$blankedText{$player}}, '-' if $inword;
	push @{$prompText{$player}}, '-' if $inword;
	my $word = '';
	my %playerDic;
	@playerDic{keys %dic} = (0) x (keys %dic);
	$inword = 0;
	until ( $blanksAlloted{$player} >= $blanksPerPlayer )
	{
		push @{$prompText{$player}}, $text[ $position ];
		if ( $text[$position] =~ $punctuation )
		{
			push @{$blankedText{$player}}, $text[ $position ];
			$inword = 0;
			$playerDic{$word}-- if $word;
			$dicBlack{$word}-- if ($word and ($player eq 'A' or $player eq 'C'));
			$dicRed{$word}-- if ($word and ($player eq 'B' or $player eq 'D'));
			$word = '';
		}
		elsif ( $text[ $position ] =~ $letter and $inword == 0 )
		{
			push @{$blankedText{$player}}, $text[ $position ];
			$inword = 1;
			$word = $text[ $position ];
		}
		elsif ($text[ $position ] =~ $letter )
		{
			$blanksAlloted{$player}++;
			push @{$blankedText{$player}}, '\x' if $inword == 1;
			push @{$blankedText{$player}}, 'x' if $inword == 2;
			$inword = 2;
			$word = join '', ($word, $text[ $position ]);
			$scoreBlack++ unless ($player eq 'A' or $player eq 'C');
			$scoreRed++ unless ($player eq 'B' or $player eq 'D');
		}
		elsif ($text[ $position ] =~ $name )
		{
			push @{$blankedText{$player}}, $text[ $position ];
			$inword = 0;
		}
		$position++;
		last if not defined $text[$position];
	}
	push @{$prompText{$player}}, '-' if $inword;
	$quiz->{"prompText$player"} = join '', @{$prompText{$player}};
	$quiz->{"blankedText$player"} = join '', @{$blankedText{$player}};
	$quiz->{"dic$player"} = '';
	$quiz->{"dicBlack"} = '';
	$quiz->{"dicRed"} = '';
	foreach my $word (sort keys %dic)
	{
		$quiz->{"dic$player"} = join ' ', ($quiz->{"dic$player"}, 
				"$word(@{[$dic{$word}+$playerDic{$word}]})") 
					if $dic{$word} + $playerDic{$word};
	}
}
$quiz->{"scoreBlack"} = $scoreBlack;
$quiz->{"scoreRed"} = $scoreRed;
foreach my $word (sort keys %dic)
{
	$quiz->{"dicBlack"} = join ' ', ($quiz->{"dicBlack"}, 
			"$word(@{[$dic{$word}+$dicBlack{$word}]})") 
				if $dic{$word} + $dicBlack{$word};
	$quiz->{"dicRed"} = join ' ', ($quiz->{"dicRed"}, 
			"$word(@{[$dic{$word}+$dicRed{$word}]})") 
				if $dic{$word} + $dicRed{$word};
}

($quiz->{cardIdentifier} = $textSource ) =~ s|.*/(\S+/\S+).txt$|$1|;

$quiz->{autogen} = "% This file, pair/cards.tex was autogenerated on " . localtime() . "by pair/dic.pl out of pair/cards.tmpl";

my $template = Text::Template->new(TYPE => 'FILE', SOURCE => 'cards.tmpl'
				, DELIMITERS => [ '<TMPL>', '</TMPL>' ] );
open TEX, ">cards.tex";
print TEX $template->fill_in( HASH => $quiz );
