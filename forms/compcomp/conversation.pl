\documentclass[a4paper]{article}
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
	\raggedleft \large Conversation competition \hfill \normalsize \raisebox{-0.2cm}{Week: \rule{1.0cm}{0.3pt}} \\
	\vspace{-0.05cm}
	\large I. \rule{2.0cm}{0.3pt} \& II. \rule{2.0cm}{0.3pt} Groups\\
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

eval 'exec /usr/bin/perl  -S $0 ${1+"$@"}'
    if 0; # not running under some shell

use strict;
use warnings;

use YAML qw/LoadFile DumpFile/;
use IO::All;

use Getopt::Long;
use Pod::Usage;

my $man = 0;
my $help = 0;
my ($league, $series, $week);

GetOptions (
	"league=s" => \$league, "series=s" => \$series, "week=s" => \$week,
	'help|?' => \$help, man => \$man) or pod2usage(2);
pod2usage(1) if $help;
pod2usage(-exitstatus => 0, -verbose => 2) if $man;

my $register = LoadFile "/home/greg/$league/register.yaml"
					or die "No register.yaml: $!";
my $teams = LoadFile "/home/greg/$league/$series/teams.yaml";

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
% \usepackage[T1]{fontenc}
% \usepackage[absolute,noshowtext,showboxes]{textpos}
\usepackage[absolute,showboxes]{textpos}
% \textblockorigin{0.00cm}{0.05cm}
\textblockorigin{0.00cm}{1.05cm}
\pagestyle{empty}
\setlength{\unitlength}{1cm}
\newcommand{\myeval}[1]{%
	\begin{description}
		\item Writer: #1 \hfill Title: \rule{4.5cm}{0.3pt} 
		% \vspace{-0.3cm}
		\item #1\'s Pick: \hspace{0.25cm}1\hspace{0.25cm}2\hspace{0.25cm}3\hspace{0.25cm}4\hspace{0.25cm}5\hfill Group\'s Pick: \hspace{0.25cm}1\hspace{0.25cm}2\hspace{0.25cm}3\hspace{0.25cm}4\hspace{0.25cm}5\hspace{0.25cm}
		% \vspace{-0.2cm}
		\item Best Bet: \hspace{0.25cm}1\hspace{0.25cm}2\hspace{0.25cm}3\hspace{0.25cm}4\hspace{0.25cm}5\hfill Bean\'s Grade: \hspace{0.25cm}0\hspace{0.25cm}1\hspace{0.25cm}2\hspace{0.25cm}3\hspace{0.25cm}4\hspace{0.25cm}5\hspace{0.25cm}
		% \vspace{+0.3cm}
	\end{description}
}
\newcommand{\mycard}[6]{%
	% \vspace{0.1cm}
	\small #1
	\vspace{-0.5cm}
	\normalsize \begin{center} #2 Team Pick-A-Number Week #3\end{center}
	\vspace{-1.75cm}
	\parbox[t][8.05cm][c]{9.6cm}{%\vfill
	\normalsize
	#4
	#5
	#6
	}
}

\begin{document}
% \fontfamily{hlst}\fontseries{b}\fontshape{n}\selectfont

';

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

evalform - Create Latex Team Self-Evaluation Forms

=head1 SYNOPSIS

evalform [options] 

Options:

--help            This help message

--man            A man page


--series first	The series

--league m/j	The league 

=head1 OPTIONS

=over 8

=item B<-week>

The week. This helps when we have old cards floating around.

=item B<-league>

The league

=item B<-series>

The series, so we know who the members of the team actually are.

=back

=head1 DESCRIPTION

B<evalform> generates a latex form for up-to-3-member teams to evaluate their essays, and win beans if their evaluation coincides with the teacher's. Fields are: Writer's pick, Group's Pick, Best Bet and Grade.

=cut
