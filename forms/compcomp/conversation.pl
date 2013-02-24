#!/usr/bin/perl 

use strict;
use warnings;

use Cwd; use File::Basename;
use YAML qw/LoadFile DumpFile/;
use IO::All;

use Getopt::Long;
use Pod::Usage;

use Grades;

my $script = Grades::Script->new_with_options;
my $tourid = $script->league || basename( getcwd );
my $leagues = "/home/drbean/012";
( my $leagueid = $tourid ) =~ s/^([[:alpha:]]+[[:digit:]]+).*$/$1/;
my $league = League->new( leagues => $leagues, id => $leagueid );
my $g = Grades->new({ league => $league });
my $groupwork = $g->classwork;
my $leaguemembers = $league->members;
my %members = map { $_->{id} => $_ } @$leaguemembers;
my $session = $script->session;
my $week = $script->round;
my $story = $script->exercise;
my $letter = $script->player;
my @tables = split /,/, $script->two;

my $texString = 
'\documentclass[a4paper]{article}
% \newcommand{\printlandscape}{\special{landscape}}
% \printlandscape
\usepackage[a4paper,landscape]{geometry}
\usepackage{xeCJK}
\setCJKmainfont{WenQuanYi Zen Hei}
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

\newcommand{\mycard}[9]{%
\TPMargin{0.0cm}
	\begin{textblock}{4}(#1)
% \textblockrulecolor{red}
	\textblocklabel{picture1}
	\vspace{0.25cm}
\begin{minipage}{7.0cm}%
	\large Conversation competition \hfill \normalsize \raisebox{-0.2cm}{Week: #3} \\\\
	\vspace{-0.05cm}
	\large I. #6 \\& II. #8 \normalsize Groups\\\\
	\raggedright
	\normalsize Story: #4 \hfill \\\\
	\vspace{-0.05cm}
	\large Champions (Letter #5):\\\\
	\vspace{0.09cm}
	\normalsize I. #6 Champion: #7\\\\
	\vspace{0.25cm}
	\normalsize II. #8 Champion: #9\\\\
	\large Votes for:\\\\
	\normalsize I. #7  Names: \rule{1.1cm}{0.3pt}, \rule{1.1cm}{0.3pt}, \rule{1.1cm}{0.3pt}\\\\
	\vspace{0.25cm}
	\normalsize II. #9  Names: \rule{1.1cm}{0.3pt}, \rule{1.1cm}{0.3pt}, \rule{1.1cm}{0.3pt}\\\\
	\vspace{0.25cm}
	\large Winner: \rule{2.1cm}{0.3pt}\\\\
	\large Reasons:\\\\
	\normalsize Winner\'s Supporters\\\\
	\tiny Name: \rule{1.0cm}{0.3pt} \normalsize Reason: \rule{3.7cm}{0.3pt}\\\\
	\vspace{0.25cm}
	\tiny Name: \rule{1.0cm}{0.3pt} \normalsize Reason: \rule{3.7cm}{0.3pt}\\\\
	\vspace{0.25cm}
	\tiny Name: \rule{1.0cm}{0.3pt} \normalsize Reason: \rule{3.7cm}{0.3pt}\\\\
	\normalsize Loser\'s Supporters\\\\
	\tiny Name: \rule{1.0cm}{0.3pt} \normalsize Reason: \rule{3.7cm}{0.3pt}\\\\
	\Large Points:\\\\
	\large #6: 3 \hspace{0.2cm} 2 \hspace{0.8cm} #8: 3 \hspace{0.2cm} 2\\\\
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

';

my @textpos = (
	  [ "0,0",  "2.8,1.0" ]
	, [ "4,0",  "6.8,1.0" ]
	, [ "8,0",  "10.8,1.0" ]
	, [ "12,0", "14.8,1.0" ]
	, [ "0,8",  "2.8,9.0" ]
	, [ "4,8",  "6.8,9.0" ]
	, [ "8,8",  "10.8,9.0" ]
	, [ "12,8", "14.8,9.0" ]
	);
my $paging = 0;

my $groups = $groupwork->beancans($session);
my %indexed = ( A => 0, B => 1, C => 2, D => 3 );

foreach my $table ( @tables ) {
	my @two = split /::/, $table;
	my @champion = map { $groups->{$_}->[$indexed{$letter}] } @two;
	$texString .=
"\\mycard{$textpos[$paging][0]}{$textpos[$paging][1]}{$week}{$story}{$letter}{$two[0]}{$champion[0]}{$two[1]}{$champion[1]}
";
	&paging;
}
$texString .= '
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
';

$texString > io "$leagues/$leagueid/classwork/$session/conversation.tex";

sub paging
{       if ($paging == 7 )
        {
                $paging = 0;
		$texString .= '\null\newpage
';
        }
        else { $paging++; }
}

__END__

=head1 NAME

conversation.pl - Create Conversation Competition forms for 2 groups and champions

=head1 SYNOPSIS

conversation.pl -l FLA0016 -s 1 -r 3 -p A -t Black::Blue,Brown::Gray,Orange

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
