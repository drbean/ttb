#!/usr/bin/perl

use strict;
use warnings;

use Text::Template;
use YAML qw/ LoadFile /;
my $leagueRound = $ARGV[0];
my $yaml = LoadFile("$leagueRound.yaml");

use IO::All;

my $io = io 'form.tmpl';
my $tmplString = $io->all;

my $n = 1;
my $tables = $yaml->{tables};
my $id = $yaml->{id};
PAGELOOP: while ( my $table = each %$tables )
{
	$tmplString .= "
\\begin{textblock}{8}(0,0)
\\textblocklabel{picture1}
\\mycard{A}
{$table}
{\\begin{Large}\\ding{220}<tmpl>$tables->{$table}->{player}->[0]</tmpl> <tmpl>$id->{$tables->{$table}->{player}->[0]}</tmpl>\\end{Large} \\begin{tiny}Signature:\\hrulefill\\end{tiny} }
{<tmpl>$tables->{$table}->{player}->[1]</tmpl> <tmpl>$id->{$tables->{$table}->{player}->[1]}</tmpl>}
{<tmpl>$tables->{$table}->{player}->[2]</tmpl> <tmpl>$id->{$tables->{$table}->{player}->[2]}</tmpl>}
{<tmpl>$tables->{$table}->{player}->[3]</tmpl> <tmpl>$id->{$tables->{$table}->{player}->[3]}</tmpl>}
\\end{textblock}

\\begin{textblock}{8}(8,0)
\\textblocklabel{picture2}
\\mycard{B}
{$table}
{\\begin{Large}\\ding{220}<tmpl>$tables->{$table}->{player}->[1]</tmpl> <tmpl>$id->{$tables->{$table}->{player}->[1]}</tmpl>\\end{Large} \\begin{tiny}Signature:\\hrulefill\\end{tiny} }
{<tmpl>$tables->{$table}->{player}->[0]</tmpl> <tmpl>$id->{$tables->{$table}->{player}->[0]}</tmpl>}
{<tmpl>$tables->{$table}->{player}->[2]</tmpl> <tmpl>$id->{$tables->{$table}->{player}->[2]}</tmpl>}
{<tmpl>$tables->{$table}->{player}->[3]</tmpl> <tmpl>$id->{$tables->{$table}->{player}->[3]}</tmpl>}
\\end{textblock}

\\begin{textblock}{8}(8,4)
\\textblocklabel{picture4}
\\mycard{C}
{$table}
{\\begin{Large}\\ding{220}<tmpl>$tables->{$table}->{player}->[2]</tmpl> <tmpl>$id->{$tables->{$table}->{player}->[2]}</tmpl>\\end{Large} \\begin{tiny}Signature:\\hrulefill\\end{tiny} }
{<tmpl>$tables->{$table}->{player}->[0]</tmpl> <tmpl>$id->{$tables->{$table}->{player}->[0]}</tmpl>}
{<tmpl>$tables->{$table}->{player}->[1]</tmpl> <tmpl>$id->{$tables->{$table}->{player}->[1]}</tmpl>}
{<tmpl>$tables->{$table}->{player}->[3]</tmpl> <tmpl>$id->{$tables->{$table}->{player}->[3]}</tmpl>}
\\end{textblock}

\\begin{textblock}{8}(0,4)
\\textblocklabel{picture3}
\\mycard{D}
{$table}
{\\begin{Large}\\ding{220}<tmpl>$tables->{$table}->{player}->[3]</tmpl> <tmpl>$id->{$tables->{$table}->{player}->[3]}</tmpl>\\end{Large} \\begin{tiny}Signature:\\hrulefill\\end{tiny} }
{<tmpl>$tables->{$table}->{player}->[0]</tmpl> <tmpl>$id->{$tables->{$table}->{player}->[0]}</tmpl>}
{<tmpl>$tables->{$table}->{player}->[1]</tmpl> <tmpl>$id->{$tables->{$table}->{player}->[1]}</tmpl>}
{<tmpl>$tables->{$table}->{player}->[2]</tmpl> <tmpl>$id->{$tables->{$table}->{player}->[2]}</tmpl>}
\\end{textblock}

";
	$table = each %$tables;
	$tmplString .= "
\\begin{textblock}{8}(0,8)
\\textblocklabel{picture5}
\\mycard{A}
{$table}
{\\begin{Large}\\ding{220}<tmpl>$tables->{$table}->{player}->[0]</tmpl> <tmpl>$id->{$tables->{$table}->{player}->[0]}</tmpl>\\end{Large} \\begin{tiny}Signature:\\hrulefill\\end{tiny} }
{<tmpl>$tables->{$table}->{player}->[1]</tmpl> <tmpl>$id->{$tables->{$table}->{player}->[1]}</tmpl>}
{<tmpl>$tables->{$table}->{player}->[2]</tmpl> <tmpl>$id->{$tables->{$table}->{player}->[2]}</tmpl>}
{<tmpl>$tables->{$table}->{player}->[3]</tmpl> <tmpl>$id->{$tables->{$table}->{player}->[3]}</tmpl>}
\\end{textblock}

\\begin{textblock}{8}(8,8)
\\textblocklabel{picture6}
\\mycard{B}
{$table}
{\\begin{Large}\\ding{220}<tmpl>$tables->{$table}->{player}->[1]</tmpl> <tmpl>$id->{$tables->{$table}->{player}->[1]}</tmpl>\\end{Large} \\begin{tiny}Signature:\\hrulefill\\end{tiny} }
{<tmpl>$tables->{$table}->{player}->[0]</tmpl> <tmpl>$id->{$tables->{$table}->{player}->[0]}</tmpl>}
{<tmpl>$tables->{$table}->{player}->[2]</tmpl> <tmpl>$id->{$tables->{$table}->{player}->[2]}</tmpl>}
{<tmpl>$tables->{$table}->{player}->[3]</tmpl> <tmpl>$id->{$tables->{$table}->{player}->[3]}</tmpl>}
\\end{textblock}

\\begin{textblock}{8}(8,12)
\\textblocklabel{picture8}
\\mycard{C}
{$table}
{\\begin{Large}\\ding{220}<tmpl>$tables->{$table}->{player}->[2]</tmpl> <tmpl>$id->{$tables->{$table}->{player}->[2]}</tmpl>\\end{Large} \\begin{tiny}Signature:\\hrulefill\\end{tiny} }
{<tmpl>$tables->{$table}->{player}->[0]</tmpl> <tmpl>$id->{$tables->{$table}->{player}->[0]}</tmpl>}
{<tmpl>$tables->{$table}->{player}->[1]</tmpl> <tmpl>$id->{$tables->{$table}->{player}->[1]}</tmpl>}
{<tmpl>$tables->{$table}->{player}->[3]</tmpl> <tmpl>$id->{$tables->{$table}->{player}->[3]}</tmpl>}
\\end{textblock}

\\begin{textblock}{8}(0,12)
\\textblocklabel{picture7}
\\mycard{D}
{$table}
{\\begin{Large}\\ding{220}<tmpl>$tables->{$table}->{player}->[3]</tmpl> <tmpl>$id->{$tables->{$table}->{player}->[3]}</tmpl>\\end{Large} \\begin{tiny}Signature:\\hrulefill\\end{tiny} }
{<tmpl>$tables->{$table}->{player}->[0]</tmpl> <tmpl>$id->{$tables->{$table}->{player}->[0]}</tmpl>}
{<tmpl>$tables->{$table}->{player}->[1]</tmpl> <tmpl>$id->{$tables->{$table}->{player}->[1]}</tmpl>}
{<tmpl>$tables->{$table}->{player}->[2]</tmpl> <tmpl>$id->{$tables->{$table}->{player}->[2]}</tmpl>}
\\end{textblock}

\\begin{tiny}$n\\end{tiny}\\\\
\\newpage
";

	$n++;
	last PAGELOOP unless $table;
}

$tmplString .= '
\end{document}
';

my $league = substr( $leagueRound, 0, 1);
my $template = Text::Template->new(TYPE => 'STRING'
				, SOURCE => $tmplString
				, DELIMITERS => [ '<tmpl>', '</tmpl>' ] );

$yaml->{autogen} = "% This file, form.tex was autogenerated on " . localtime() . "by form.pl";

open TEX, ">form.tex";
print TEX $template->fill_in( HASH => $yaml );

