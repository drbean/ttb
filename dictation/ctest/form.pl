#!/usr/bin/perl

# Last Edit: 2007 Nov 03, 05:10:28 PM

use strict;
use warnings;

use Text::Template;
use YAML qw/ LoadFile /;
use Games::Tournament::RoundRobin;
use Games::League::Member;

use File::Spec;
use File::Basename;
my $roundN = basename( File::Spec->rel2abs('.') );
my $round = LoadFile( "round.yaml" );
my $league = LoadFile( "../../league.yaml" );
my @members = @{$league->{member}};
my %ids = map { $_->{name} => $_->{id} } @members;
my %names = map { $_->{id} => $_->{Chinese} } @members;
my (@assistants, $assistantFile);
unless ( $round->{assistant} and $round->{assistant} =~ m/No.*ne/ )
{
	$assistantFile = LoadFile( "../assistants.yaml" );
	@assistants = keys %{$assistantFile->{$roundN}};
}
my $byes = $round->{group}->{Bye};

use IO::All;

my $io = io 'form.tmpl';
my $tmplString = $io->all;

my $groups = $round->{group};
my @latex = (
		{ page => 1, xy => "0,0" },
		{ page => 1, xy => "8,0" },
		{ page => 1, xy => "0,8" },
		{ page => 1, xy => "8,8" },
		{ page => 2, xy => "0,0" },
		{ page => 2, xy => "8,0" },
		{ page => 2, xy => "0,8" },
		{ page => 2, xy => "8,8" },
		{ page => 3, xy => "0,0" },
		{ page => 3, xy => "8,0" },
		{ page => 3, xy => "0,8" },
		{ page => 3, xy => "8,8" },
	);
my $paging = 0;
my $threepages = 0;

foreach my $group ( keys %$groups )
{
	next unless $round->{group}->{$group};
	my @group =  map { { name => $_, id => $ids{$_} } }
						values %{$round->{group}->{$group}}; 
	foreach my $player ( @group )
	{
		my @partners = grep { $_ ne $player } @group;
		$tmplString .= "
\\begin{textblock}{8}($latex[$paging]->{xy})
\\textblocklabel{picture$latex[$paging]->{xy}}
\\mycard
{$group}
{$player->{name}}
{$player->{id}}
";
		 if ($partners[0])
		{
			$tmplString .= "{$partners[0]->{name}}
{$partners[0]->{id}}
";
		}						
		else {
			$tmplString .= "{}{}";
		}
		 if ($partners[1])
		{
			$tmplString .= "{$partners[1]->{name}}
{$partners[1]->{id}}
";
		}						
		else {
			$tmplString .= "{}{}";
		}
		$tmplString .= "{}";
		$tmplString .= "\\end{textblock}\n";

		if ($paging == 3 or $paging == 7 or $paging == 11 )
		{
			$tmplString .= 
"\\begin{tiny}" . ($threepages + $latex[$paging]->{page}) . "\\end{tiny}\\newpage\n\n";
		}
		if ($paging == 11) { $threepages = $threepages+3; $paging = 0; }
		else { $paging++; }
	}

}

$tmplString .= '
\end{document}
';

my $template = Text::Template->new(TYPE => 'STRING'
				, SOURCE => $tmplString
				, DELIMITERS => [ '<tmpl>', '</tmpl>' ] );

$round->{autogen} = "% This file, form.tex was autogenerated on " . localtime() . "by form.pl";

my $tmplHash = $round;
$tmplHash->{league} = $league->{league};
@{$tmplHash->{assistant}} = @assistants if @assistants;
@{$tmplHash->{assistantId}} = map { $ids{$_} } @assistants if @assistants;

open TEX, ">form.tex";
print TEX $template->fill_in( HASH => $tmplHash );

