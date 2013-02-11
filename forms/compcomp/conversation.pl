	\raggedright
	\normalsize Story: \rule{1.4cm}{0.3pt} \hfill \\
	\vspace{-0.05cm}
	\large Champions (Letter \rule{0.5cm}{0.3pt}):\\
	\vspace{0.09cm}
	\normalsize I. \rule{1.1cm}{0.3pt} Champion: \rule{1.3cm}{0.3pt}\\
	\vspace{0.25cm}
	\normalsize II. \rule{1.0cm}{0.3pt} Champion: \rule{1.3cm}{0.3pt}\\
	\vspace{0.25cm}
	\large Winner: \rule{2.1cm}{0.3pt}\\
	\large Votes:\\
	\normalsize I. \rule{1.2cm}{0.3pt} Names: \rule{1.1cm}{0.3pt}, \rule{1.1cm}{0.3pt}, \rule{1.1cm}{0.3pt}\\
	\vspace{0.25cm}
	\normalsize II. \rule{1.1cm}{0.3pt} Names: \rule{1.1cm}{0.3pt}, \rule{1.1cm}{0.3pt}, \rule{1.1cm}{0.3pt}\\
	\large Reasons:\\
	\normalsize Winner's Supporters\\
	\tiny Name: \rule{1.0cm}{0.3pt} \normalsize Reason: \rule{3.7cm}{0.3pt}\\
	\vspace{0.25cm}
	\tiny Name: \rule{1.0cm}{0.3pt} \normalsize Reason: \rule{3.7cm}{0.3pt}\\
	\vspace{0.25cm}
	\tiny Name: \rule{1.0cm}{0.3pt} \normalsize Reason: \rule{3.7cm}{0.3pt}\\
	\normalsize Loser's Supporters\\
	\tiny Name: \rule{1.0cm}{0.3pt} \normalsize Reason: \rule{3.7cm}{0.3pt}\\
	\Large Points:\\
	\large 3 points: \rule{1.6cm}{0.3pt} 2 points: \rule{1.8cm}{0.3pt}\\
\end{minipage}
	\end{textblock}
\TPMargin{0.0cm}
	
	\TPshowboxestrue
	\begin{textblock}{1.2}(#2)
	\normalsize In \& Out
	\vspace{-0.2cm}
	\begin{description}
	\item [Absent] \hfill \\
	\item [Joining] \hfill \\
	\end{description}
	\vspace{0.2cm}
	\end{textblock}
	\TPshowboxesfalse
	}

\begin{document}
% \fontfamily{hlst}\fontseries{b}\fontshape{n}\selectfont

\mycard{0,0}{2.8,1.0} \mycard{4,0}{6.8,1.0} \mycard{8,0}{10.8,1.0} \mycard{12,0}{14.8,1.0}
\mycard{0,8}{2.8,9.0} \mycard{4,8}{6.8,9.0} \mycard{8,8}{10.8,9.0} \mycard{12,8}{14.8,9.0}

			% crosshairs cutting guide marks
			\begin{textblock}{1}(3.64,8)\rule{3mm}{0.1mm}%
			\end{textblock}
			\begin{textblock}{1}(7.64,8)\rule{3mm}{0.1mm}%
			\end{textblock}
			\begin{textblock}{1}(11.64,8)\rule{3mm}{0.1mm}%
			\end{textblock}

			\begin{textblock}{1}(3.70,4)\rule{0.1mm}{3mm}%
			\end{textblock}
			\begin{textblock}{1}(3.70,12)\rule{0.1mm}{3mm}%
			\end{textblock}

			\begin{textblock}{1}(7.70,4)\rule{0.1mm}{3mm}%
			\end{textblock}
			\begin{textblock}{1}(7.70,12)\rule{0.1mm}{3mm}%
			\end{textblock}

			\begin{textblock}{1}(11.70,4,92)\rule{0.1mm}{3mm}%
			\end{textblock}
			\begin{textblock}{1}(11.70,12)\rule{0.1mm}{3mm}%
			\end{textblock}

\null\newpage

\end{document}

#!/usr/bin/perl 

use strict;
use warnings;

use YAML qw/LoadFile DumpFile/;
use IO::All;

use Getopt::Long;
use Pod::Usage;

my $man = 0;
my $help = 0;
my ($league, $session, $week, $letter, $tables);

GetOptions (
	"league=s" => \$league, "session=s" => \$session, "round=s" => \$week,
	"player=s" => \$letter, "tables=s" => \$tables,
	'help|?' => \$help, man => \$man) or pod2usage(2);
pod2usage(1) if $help;
pod2usage(-exitstatus => 0, -verbose => 2) if $man;

my $league = LoadFile "/home/greg/$league/league.yaml"
					or die "No register.yaml: $!";
my @tables = split /,/, $tables;
my $groups = LoadFile "/home/greg/$league/$series/teams.yaml";

my @latex = (
                { page => 1, xy => "0,0" },
                { page => 1, xy => "8,0" },
                { page => 1, xy => "0,4" },
                { page => 1, xy => "8,4" },
                { page => 1, xy => "0,8" },
                { page => 1, xy => "8,8" },
                { page => 1, xy => "0,12" },
                { page => 1, xy => "8,12" },
                { page => 2, xy => "0,0" },
                { page => 2, xy => "8,0" },
                { page => 2, xy => "0,4" },
                { page => 2, xy => "8,4" },
                { page => 2, xy => "0,8" },
                { page => 2, xy => "8,8" },
                { page => 2, xy => "0,12" },
                { page => 2, xy => "8,12" },
        );
my $paging = 0;
my $threepages = 0;


my $texString = 
'\documentclass[a4paper]{article}
\newcommand{\printlandscape}{\special{landscape}}
\printlandscape
\usepackage[landscape]{geometry}
\usepackage{multicol}
\usepackage[usenames,dvipsnames]{color}
\usepackage[absolute]{textpos}
% \usepackage[absolute,showboxes]{textpos}
% \textblockorigin{0.00cm}{+0.15cm} %HP DeskJet 5160
\textblockorigin{0.00cm}{0.00cm} %HPDeskJet5160
% \textblockorigin{0.00cm}{0.50cm} %HPDeskJet5160
% \textblockorigin{0.15cm}{0.00cm} %HPDeskJet5160
\pagestyle{empty}
\setlength{\unitlength}{1cm}

\newcommand{\mycard}[2]{%
\TPMargin{0.0cm}
	\begin{textblock}{4}(#1)
% \textblockrulecolor{red}
	\textblocklabel{picture1}
	\vspace{0.25cm}
\begin{minipage}{7.0cm}%
';

$texString .= 
"\raggedleft \large Conversation competition \hfill \normalsize \raisebox{-0.2cm}{Week: $week} \\
\vspace{-0.05cm}
";

foreach my $team ( keys %$teams ) 
{
	$texString .= 
"\\begin{textblock}{8}($latex[$paging]->{xy})
\\textblocklabel{picture1}
\\mycard{evalform}{$team}{$week}
";
	my $arguments = 2;
	my $members = $teams->{$team};
	foreach my $member ( @$members ) 
	{
		# my $name = $teams->{$team}->[$member];
		$texString .= "{\\myeval{$member}}";
		$arguments++;
	}
	$texString .= '{}' while $arguments++ < 5;
	$texString .= "\n\\end{textblock}\n\n";
	&paging;
}

$texString .= '\end{document}';

$texString > io "evalform.tex";

sub paging
{       if ($paging == 7 )
        {
                $texString .= "
\\begin{tiny}" . ($threepages + $latex[$paging]->{page}) . "\\end{tiny}\\newpage
\n\n";
        }
        if ($paging == 15) { $threepages = $threepages+3; $paging = 0; }
        else { $paging++; }
}

__END__

=head1 NAME

conversation.pl - Create Conversation Competition forms for 2 groups' champions

=head1 SYNOPSIS

conversation.pl -l FLA0016 -s 1 -r 3 -p A -g Black::Blue,Brown::Gray,Orange

=head1 OPTIONS

=over 8

--help            This help message
--man            A man page

--league FLA0016	The league 
--round 3		The week
--player A		The designated champion's letter
--table  Black::Blue,Brown::Gray,Orange	The unpaired group being assistants/bye

=back

=head1 DESCRIPTION

B<conversation.pl> generates a latex form for the 4 members of two up-to-3-member teams to choose a champion and give the reason that champion is the winner.

=cut
