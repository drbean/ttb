#!/usr/bin/perl

# Last Edit: 2007 Mar 17, 06:55:50 PM
# $Id: /cloze/branches/ctest/dic.pl 1134 2007-03-17T11:05:37.500624Z greg  $

use strict;
use warnings;

use IO::All;
use YAML qw/LoadFile/;
use Parse::RecDescent;
use Text::Template;
use Cloze qw/cloze/;
use List::Util qw/shuffle/;

our $RD_HINT = 1;

my $round = LoadFile( "round.yaml" );
my $league = LoadFile( "../league.yaml" );
my @members = @{$league->{member}};
my %ids = map { $_->{name} => $_->{id} } @members;
my %names = map { $_->{id} => $_->{name} } @members;

my $textSources = $round->{texts};

my @io = map {io $_} @$textSources;
my %texts;
my %next;
for my $directory (@io) 
{
	my $i = 0;
	while ( my $file = $directory->next )
	{
		next unless $file =~ m/\.txt$/;
		my @lines = $file->getlines;
		$texts{$directory}[$i++] = cloze(@lines);
	}
	$next{$directory} = nextText($texts{$directory});
}

my $tmpl = io 'dic.tmpl';
my $tmplString = $tmpl->all;

my $groups = $round->{group};

my @latex = (
		{ page => 1, xy => "8,0" },
		{ page => 1, xy => "0,0" },
		{ page => 1, xy => "8,8" },
		{ page => 1, xy => "0,8" },
		{ page => 2, xy => "8,0" },
		{ page => 2, xy => "0,0" },
		{ page => 2, xy => "8,8" },
		{ page => 2, xy => "0,8" },
		{ page => 3, xy => "8,0" },
		{ page => 3, xy => "0,0" },
		{ page => 3, xy => "8,8" },
		{ page => 3, xy => "0,8" },
	);
my $paging = 0;
my $threepages = 0;

foreach my $group ( keys %$groups )
{
	next unless $round->{group}->{$group};
	my @group =  map { { name => $_, id => $ids{$_} } }
				values %{$round->{group}->{$group}}; 
	my @text = map { $next{$textSources->[$_]}->() } 0..$#$textSources;
	if ( $#group == 1 ) 
	{
		$tmplString .= "
\\begin{textblock}{8}($latex[$paging]->{xy})
\\textblocklabel{picture$latex[$paging]->{xy}}
\\mycard
{$text[0]}
\\end{textblock}\n";
		&paging;
		$tmplString .= "
\\begin{textblock}{8}($latex[$paging]->{xy})
\\textblocklabel{picture$latex[$paging]->{xy}}
\\mycard
{$text[1]}
\\end{textblock}\n";
		&paging;
	}
	elsif ( $#group == 2 ) 
	{
		$tmplString .= "
\\begin{textblock}{8}($latex[$paging]->{xy})
\\textblocklabel{picture$latex[$paging]->{xy}}
\\mycard
{$group[0]->{name}}
{$group[1]->{name} \\& $group[2]->{name}}
{$text[0]}
{$text[3]}
{$text[5]}
{$text[6]}
{$text[9]}
{$text[11]}
\\end{textblock}\n";
		&paging;
		$tmplString .= "
\\begin{textblock}{8}($latex[$paging]->{xy})
\\textblocklabel{picture$latex[$paging]->{xy}}
\\mycard
{$group[1]->{name}}
{$group[2]->{name} \\& $group[0]->{name}}
{$text[1]}
{$text[2]}
{$text[5]}
{$text[7]}
{$text[8]}
{$text[11]}
\\end{textblock}\n";
		&paging;
		$tmplString .= "
\\begin{textblock}{8}($latex[$paging]->{xy})
\\textblocklabel{picture$latex[$paging]->{xy}}
\\mycard
{$group[2]->{name}}
{$group[1]->{name} \\& $group[0]->{name}}
{$text[1]}
{$text[3]}
{$text[4]}
{$text[7]}
{$text[9]}
{$text[10]}
\\end{textblock}\n";
		&paging;
	}
	elsif ($group eq 'Bye')
	{	
		my $byes = $round->{group}->{Bye};
		foreach my $byer ( @$byes )
		{
			$tmplString .= "
\\begin{textblock}{8}($latex[$paging]->{xy})
\\textblocklabel{picture$latex[$paging]->{xy}}
\\mycard
{$byer $ids{$byer}}
{$byer $ids{$byer}}
{$byer! No homework needed. Take a break this week. You win 3 points. \\rule{8.5cm}{1pt}}
{No homework needed. Take a break this week. You win 3 points. \\rule{8.5cm}{1pt}}
{No homework needed. Take a break this week. You win 3 points.}
\\end{textblock}\n";

			&paging;
		}
	}
}

$tmplString .= '
\end{document}
';

my $quiz;
# $quiz->{cardIdentifier} = join ' ', map { m{^/.*/.*/(.*)$};$1 } @$textSources;
$quiz->{cardIdentifier} = join ' ', map { m/([^\/]*)$/ } (glob $$textSources[0] . "/*.txt");
$quiz->{autogen} = "% This file, cards.tex was autogenerated on " . localtime() . "by dic.pl out of cards.tmpl";

my $template = Text::Template->new(TYPE => 'STRING', SOURCE => $tmplString
				, DELIMITERS => [ '<TMPL>', '</TMPL>' ] );
open TEX, ">cards.tex";
print TEX $template->fill_in( HASH => $quiz );

sub nextText
{
	my $texts = shift;
	my $number = @$texts;
	my $index = 0;
	my ($nextText, $nextFile);
	return sub
	{
		$nextText = $texts->[$index];
                if (++$index == $number)
                {
                        $index = 0;
                        $texts->[0..$number-1] = $texts->[shuffle(0..$number-1)];
                }
		# $index = int rand( $number );
		return ( $nextText->{A}, $nextText->{B} );
	};
}

sub paging
{	if ($paging == 3 or $paging == 7 or $paging == 11 )
	{
		$tmplString .= "
\\begin{tiny}" . ($threepages + $latex[$paging]->{page}) . "\\end{tiny}\\newpage\n\n";
	}
	if ($paging == 11) { $threepages = $threepages+3; $paging = 0; }
	else { $paging++; }
}
