<TMPL>$autogen</TMPL>
\documentclass[a4paper]{article}
\usepackage{fontspec}
\usepackage{xltxtra}
% \setmainfont{texgyrebonum-regular.otf}[Scale=MatchLowercase]
% \setmainfont{Latin Modern Roman}[Scale=MatchLowercase]
\setmainfont{Linux Libertine O}[Scale=MatchLowercase]
% \setsansfont{Sans Regular}[Scale=MatchLowercase]
% \setmonofont{Inconsolata}[Scale=MatchLowercase]
\setmonofont{Hack}[Scale=MatchLowercase]
% \setmonofont{Deja Sans Mono}[Scale=MatchLowercase]
% \setmonofont{Droid Sans Mono}[Scale=MatchLowercase]
% \setmonofont{Source Code Pro}[Scale=MatchLowercase]
% \setmonofont{Fira Mono}[Scale=MatchLowercase]
% \setmonofont{Sans Regular}[Scale=MatchLowercase]
\usepackage{xeCJK}
\setCJKmainfont{WenQuanYi Zen Hei}
% \usepackage[absolute,noshowtext,showboxes]{textpos}
\usepackage[absolute]{textpos}
\TPMargin{0.2cm}
% \textblockorigin{0.30cm}{2.15cm}
\textblockorigin{0.30cm}{0.35cm} % HPDeskJet810C
% \textblockorigin{0.30cm}{3.35cm} % w5
% \textblockorigin{0.30cm}{4.15cm} % w5
% \textblockorigin{0.25cm}{2.45cm} % HPLaserJ5000LE
% for flash latex in bingo.tex
\usepackage{texdraw}
\usepackage{multicol}
%
\usepackage{soul}
\usepackage{tabto}
\usepackage{xcolor}
\pagestyle{empty}
\setlength{\unitlength}{1cm}
\renewcommand{\baselinestretch}{0.5}

\newcommand{\dicX<TMPL>$story</TMPL>X<TMPL>$form</TMPL>Xcard}[1]{%
\tiny <TMPL>$cardIdentifier</TMPL>\\%
\parbox[t][][t]{9.5cm}{
\hspace{0.2cm}\begin{minipage}{9.2cm}
  \large #1
\end{minipage}
}
}

\newcommand{\1}[1]{%
\begin{picture}(0.5,0.5)
\put (0,0){\colorbox{lightgray}{\makebox(0.4,0.4)[br]{}}}
\end{picture}%
}

\begin{document}

