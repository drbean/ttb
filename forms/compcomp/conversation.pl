#!/usr/bin/perl 

use strict;
use warnings;

use Cwd; use File::Basename;
use YAML qw/LoadFile DumpFile/;
use IO::All;
use List::Util qw/max/;

use Getopt::Long;
use Pod::Usage;

use Grades;

my $script = Grades::Script->new_with_options;
my $tourid = $script->league || basename( getcwd );
my $leagues = "/home/drbean/041";

# ( my $leagueid = $tourid ) =~ s/^([[:alpha:]]+[[:digit:]]+).*$/$1/;
my $leagueid = $tourid;

my $league = League->new( leagues => $leagues, id => $leagueid );
my $g = Grades->new({ league => $league });
my $groupwork = $g->classwork;
my $leaguemembers = $league->members;
my %members = map { $_->{id} => $_ } @$leaguemembers;
my $session = $script->session;
my $week = $script->round;
my $story = $script->exercise;
my $letter = $script->player;
my @tables = split /\s+|,/, $script->two;

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
	\normalsize ' . $leagueid . ' Speaking competition \hfill \normalsize \raisebox{-0.2cm}{\normalsize Week: ' . $week . '} \hspace*{0.2cm} \\\\
	\vspace{-0.05cm}
	\normalsize Table \large #3. #5 \\& #8 \\\\
	\raggedright
	\normalsize Story: ' . $story . '\hfill \\\\
	\vspace{-0.05cm}
	\large Champions (Letter ' . $letter . '):\\\\
	\vspace{-0.09cm}
	\small Spokespersons: #5 B, #8 B\\\\
	\vspace{-0.09cm}
	\normalsize #4. #5 Champion: #6\\\\
	\vspace{0.25cm}
	\normalsize #7. #8 Champion: #9\\\\
	\large Votes for:\\\\
	\normalsize #4. #6  Names: \hrulefill, \hspace{0.15cm} \hrulefill, \hspace{0.15cm} \hrulefill\\\\
	\vspace{0.25cm}
	\normalsize #7. #9  Names: \hrulefill, \hspace{0.15cm} \hrulefill, \hspace{0.15cm} \hrulefill\\\\
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
	#5: \hfill \large 3 \hspace{0.2cm} 2 \hfill \Large #8: \hfill \large 3 \hspace{0.2cm} 2 \hspace*{0.2cm} \\\\
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

my $groups = $groupwork->beancan_names($session);
my $n = $script->beancan || max map { 
			$#{$groups->{$_}} + 1 } keys %$groups;
my %indexed = ( A => 0, B => 1, C => 2, D => 3 );
my $champion = $indexed{$letter};
my $spokesperson = ($champion + 1) % $n;
my ($tablen, $fst, $snd) = (0,1,2);

foreach my $table ( @tables ) {
	$tablen++;
	my @two = split /::/, $table;
	my @champion = map { $letter eq "X"? "\\hrulefill":
										$groups->{$_}->[$champion] } @two;
	my @spokesperson = map { $letter eq "X"? "\\null":
										$groups->{$_}->[$spokesperson] } @two;
	$texString .=
'\TPMargin{0.0cm}
	\begin{textblock}{4}(' . $textpos[$paging][0] . ')
% \textblockrulecolor{red}
	\textblocklabel{picture1}
	\vspace{0.25cm}
\begin{minipage}{7.0cm}%
	\normalsize ' . $leagueid . ' Speaking competition \hfill \normalsize \raisebox{-0.2cm}{\normalsize Week: ' . $week . '} \hspace*{0.2cm} \\\\
	\vspace{-0.05cm}
	\normalsize Table \large ' . $tablen . '. ' .
				$two[0] . ' \\& ' . $two[1] . '\\\\
	\raggedright
	\normalsize Story: ' . $story . '\hfill \\\\
	\vspace{-0.05cm}
	\large Champions (Letter ' . $letter . '):\\\\
	\vspace{-0.09cm}
	\small Spokespersons: ' . $spokesperson[0] . ', ' . $spokesperson[1] . '\\\\
	\vspace{-0.09cm}
	\normalsize ' . $fst . '. ' . $two[0] . ' Champion: ' . $champion[0] . '\\\\
	\vspace{0.25cm}
	\normalsize ' . $snd . '. ' . $two[1] . ' Champion: ' . $champion[1] . '\\\\
	\large Votes for:\\\\
	\normalsize ' . $fst . '. ' . $champion[0] . '  Names: \hrulefill, \hspace{0.15cm} \hrulefill, \hspace{0.15cm} \hrulefill\\\\
	\vspace{0.25cm}
	\normalsize ' . $snd . '. ' . $champion[1] . '  Names: \hrulefill, \hspace{0.15cm} \hrulefill, \hspace{0.15cm} \hrulefill\\\\
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
	' . $two[0] . ' \hfill \large 3 \hspace{0.2cm} 2 \hfill \Large ' . $two[1] . ': \hfill \large 3 \hspace{0.2cm} 2 \hspace*{0.2cm} \\\\
\end{minipage}
	\end{textblock}
\TPMargin{0.0cm}
	
	\TPshowboxestrue
	\begin{textblock}{1.2}(' . $textpos[$paging][1] . ')
	\normalsize In \& Out
	\vspace{-0.2cm}
	\begin{description}
	\item [Absent] \hfill \\
	\item [Joining] \hfill \\
	\end{description}
	\vspace{0.2cm}
	\end{textblock}
	\TPshowboxesfalse
';
	$fst += 2; $snd += 2;
	&paging;
}
$texString .= '
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
