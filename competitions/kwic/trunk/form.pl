#!/usr/bin/perl

# Last Edit: 2007 Jun 08, 12:06:03 PM

use strict;
use warnings;

use Text::Template;
use YAML qw/ LoadFile /;
use Games::Tournament::RoundRobin;
use Games::League::Member;


my $round = LoadFile( "round.yaml" );
my $league = LoadFile( "../league.yaml" );
my @members = @{$league->{member}};
my %ids = map { $_->{name} => $_->{id} } @members;
my %names = map { $_->{id} => $_->{name} } @members;

my $assistants = $round->{assistant};
my $byes;

use IO::All;

my $io = io 'form.tmpl';
my $tmplString = $io->all;

my $groups = $round->{group};
my @latex = (
		{ page => 1, xy => "0,8" },
		{ page => 1, xy => "0,0" },
		{ page => 1, xy => "8,8" },
		{ page => 1, xy => "8,0" },
		{ page => 2, xy => "0,8" },
		{ page => 2, xy => "0,0" },
		{ page => 2, xy => "8,8" },
		{ page => 2, xy => "8,0" },
		{ page => 3, xy => "0,8" },
		{ page => 3, xy => "0,0" },
		{ page => 3, xy => "8,8" },
		{ page => 3, xy => "8,0" },
	);
my $paging = 0;
my $threepages = 0;

foreach my $group ( keys %$groups )
{
		next if $group eq 'Bye';
	if (grep {$_ eq 'Bye'} keys %{$groups->{$group}})
	{	
		push @$byes, values %{$groups->{$group}};
	}
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
				, DELIMITERS => [ '<TMPL>', '</TMPL>' ] );

$round->{autogen} = "% This file, form.tex was autogenerated on " . localtime() . "by form.pl";

my $tmplHash = $round;
$tmplHash->{league} = $league->{league};
$tmplHash->{bye} = $byes;
@{$tmplHash->{byeId}} = map { $ids{$_} } @$byes
			if ($byes and ref $byes eq 'ARRAY');
@{$tmplHash->{assistantId}} = map { $ids{$_} } @$assistants if $assistants;
if ($assistants and ref($assistants) eq 'HASH')
{
	$tmplHash->{assistant} = [keys %$assistants];
	@{$tmplHash->{assistantId}} = map { $ids{$_} } keys %$assistants;
}

open TEX, ">form.tex";
print TEX $template->fill_in( HASH => $tmplHash );

