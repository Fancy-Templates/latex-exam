\errorcontextlines=10000

\providecommand\sp@documentclass{
   \PassOptionsToClass{11pt,a4paper}{article}
   \LoadClass{article}
}
\sp@documentclass

% meta commands ==========================================================

% just the internal prefix to namespace our sp commands
\def\sp@prefix{sp@}

% vertical space reserve for student inputs
\def\sp@space@v{\rule\z@{5mm}}

% we have a lot of commands that we want to configure, so we write a small
% meta-macro which allows us to create such commands
% #1: command name
% #2: default value
\long\def\sp@make@cmd#1#2{%
   % define a new macro `\#1`, which defines `\sp@@#1` with the value given.
   % For example, `\sp@make@cmd{foo}{bar}` defines the macro `\foo` and
   % `\sp@@foo` which evaluates to `bar`. If you evaluate `\foo{baz}`,
   % `\sp@@foo` will be `baz`.
   \expandafter\long\expandafter\def\csname #1\endcsname##1{%
      \expandafter\def\csname\sp@prefix @#1\endcsname{##1}%
   }%
   % now, run the macro with the default value so that `\sp@@foo`
   % starts as `bar`.
   \csname#1\endcsname{#2}%
}
% format #1 to indicate a missing value
\def\sp@missing#1{\textbf{\color{red}#1}}

% comfort overload for `\sp@make@cmd` for macros which are required
\def\sp@make@required@cmd#1{\sp@make@cmd{#1}{\sp@missing{\texttt{\textbackslash #1\{??\}}}}}

% immediately persist the value #2 in #1 to be active on the next run
\def\sp@persist#1=#2;{%
   \immediate\write\@auxout{%
      \string\gdef\string#1{#2}%
   }%
}

% load the bare minimum of default packages ==============================
\RequirePackage[T1]{fontenc}
\RequirePackage[utf8]{inputenc}
\PassOptionsToPackage{ngerman}{babel}
\RequirePackage{babel}
\RequirePackage{xcolor}
\RequirePackage{array}
\RequirePackage{graphicx}
\RequirePackage{fancyhdr}

\RequirePackage{microtype}

% setup fonts ============================================================

\RequirePackage{newtxtt} % ttfamily
\RequirePackage{sfmath}  % TODO: find better sf font
\renewcommand\familydefault{\sfdefault}

% page layout ============================================================

\def\sp@geometry@left{2cm}%
\def\sp@geometry@right{2cm}%
\def\sp@geometry@top{1cm}%
\def\sp@geometry@bottom{2cm}%
\providecommand\sp@geometry{
   \PassOptionsToPackage{
      left=\sp@geometry@left,
      right=\sp@geometry@right,
      top=\sp@geometry@top,
      bottom=\sp@geometry@bottom,
      includehead%
   }{geometry}
   \RequirePackage{geometry}
}
\sp@geometry

% page head ==============================================================

\pagestyle{fancy}
\headheight=13.6pt

% separate pages =========================================================

% we allow the '\appendix' command to be used in the document to separate
% additional pages from those for the main exam
\newif\ifsp@in@appendix
\def\appendix{%
   \xdef\sp@main@end{\arabic{page}}% we store the number of pages in a macro to test for single pages
   \clearpage
   \global\sp@in@appendixtrue
   \pagenumbering{arabic}%
   \setcounter{page}{1}%
}
% at the end of the document we just store the current page(s)
\AtEndDocument{%
   \ifsp@in@appendix
      \sp@persist\sp@main@end=\sp@main@end;%
      \sp@persist\sp@appendix@end=\arabic{page};%
   \else
      \sp@persist\sp@main@end=\arabic{page};%
   \fi
}
\def\sp@main@end{-1}


% macros for the sp cover page ===========================================

% this is the collection of macros (`\examnumber`, ...) which is required
% so that we can set the titlepage with `\maketitle`.
\sp@make@required@cmd{examnumber}
\sp@make@required@cmd{examname}
\sp@make@required@cmd{examiner}
\sp@make@required@cmd{year}
\sp@make@required@cmd{semester}
\sp@make@required@cmd{date}
\sp@make@required@cmd{time}
\sp@make@required@cmd{duration}
\sp@make@required@cmd{permittedmaterial}
\sp@make@required@cmd{coverimage}

% for the coverimage we provide a convenience command `\framedcoverimage` which directly takes a path
% to an image and wraps it in a frame with the wanted sizes
\def\framedcoverimage#1{%
   \sp@make@cmd{coverimage}{\fbox{\begin{minipage}[b][41mm][c]{70mm}
      \centering\includegraphics[width=\linewidth,height=41mm,keepaspectratio]{#1}\relax
   \end{minipage}}}%
}

% all of these commands could be redefined just the same but we not require the user to
% in other words, the defaults should be satisfactory for most users
% the following lines define them roughly from top to bottom regarding their appearance on the (exam/solution) title page
\sp@make@cmd{examlineA}{\sp@@examnumber. Klausur zur Veranstaltung}
\sp@make@cmd{examlineB}{\textbf{\LARGE\sp@@examname}}
\sp@make@cmd{examinerline}{\@hangfrom{Prüfer: }{\sp@@examiner}}

\sp@make@cmd{whenline}{im \sp@@semester semester \sp@@year}
\sp@make@cmd{institute}{Institut für Softwaretechnik und Programmiersprachen}
\sp@make@cmd{instituteline}{\sp@@institute}

\sp@make@cmd{examdateline}{\sp@@date, \sp@@time}
\sp@make@cmd{examdurationline}{\textbf{Bearbeitungszeit: \sp@@duration\;min}}

\sp@make@cmd{logolocation}{img/}
\sp@make@cmd{logoline}{%
\begin{tabular}{@{}m{.5\linewidth}@{}m{.5\linewidth}@{}}
	\includegraphics[scale=.55]{\sp@@logolocation logo-icon} &\raggedleft\arraybackslash\includegraphics[scale=.55]{\sp@@logolocation logo-text}%
\end{tabular}\vskip-4mm\relax
}

\def\sp@table@indent{6pt}
% blocks start and height for a word in the coverpage table
\def\sp@table@field#1{\hspace*{\sp@table@indent}\rule\z@{1.15\ht\strutbox}#1}

\sp@make@cmd{studentdatatable}{%
% we just reset tabular definitions in case someone redefines how tables look
\tabcolsep\z@\relax\def\arraystretch{1}%
\begin{tabular}{|*2{p{.375\textwidth}|}p{.25\textwidth}|}
   \hline
   \sp@table@field{Nachname:}&\sp@table@field{Vorname:}&\sp@table@field{Matrikelnummer:}\\
   \sp@space@v&&\\\hline
   \multicolumn{2}{|l|}{\sp@table@field{Studiengang und Abschluss:}}&\sp@table@field{Fachsemester:}\\
   \multicolumn{2}{|l|}{\sp@space@v}&\\\hline

   \multicolumn{3}{|p{\dimexpr.95\textwidth-\sp@table@indent}|}{%
      \vskip-5pt\sp@table@field{\parbox[t]{\linewidth}{Hiermit erkläre ich, dass ich prüfungsfähig bin.\newline
      Sollte ich nicht auf der Liste der angemeldeten Studierenden aufgeführt sein, dann nehme ich
      hiermit zur Kenntnis, dass diese Prüfung nicht gewertet werden wird. \newline\bigskip\newline
      \rule{10cm}{0.5pt}\\[-2.66pt]%
      \strut Datum, Unterschrift des Prüfungsteilnehmers
   }}} \\\hline
\end{tabular}
}

% now we define the hints, for the number of pages we will infer them automatically
% with the '\appendix' marker
\sp@make@cmd{hintstitle}{\textbf{Zur allgemeinen Beachtung:}}%
% morehints can be used to add more hints using `\item` prefixes, at the bottom of the list.
% we make no attempts to make more space for them!
\sp@make@cmd{morehints}{}
\sp@make@cmd{hints}{%
   \item Füllen Sie das Deckblatt vollständig und korrekt aus.
   \item Lesen Sie sich zunächst die Klausur sorgfältig durch (sie besteht aus \ifnum\sp@main@end=1\relax \textbf{einer} Seite\else\textbf{\sp@main@end}~Seiten\fi%
   % now we have to check if there are additional pages
   \ifcsname sp@appendix@end\endcsname
      \space und \ifnum\sp@appendix@end=1\relax \textbf{einer} Zusatzseite\else\textbf{\sp@appendix@end}~Zusatzseiten\fi
   \fi)
   \item Bearbeiten Sie die Aufgaben direkt auf den Aufgabenblättern. Wenn sie mehr Platz benötigen, verwenden Sie zuerst die Rückseiten der Blätter. % TODO: [TODO: more], was genau soll hier noch kommen?
   \item \sp@@permittedmaterial
   \item Aufgaben, welche nicht mit einem dokumentenechten Stift in den Farben blau oder schwarz bearbeitet worden sind, werden nicht bewertet.
   \sp@@morehints
}

\sp@make@cmd{additionalpaper}{Zusätzliches benötigtes Paper wird Ihnen von der Aufsicht zur Verfügung gestellt.}

% the exercise/points magic ==============================================
\newcounter{exercise}
\def\sp@exercises@totalcount{0}% default value of total exercises


% #1 name of the exercise
\def\sp@exercise#1{%
   % first, we step the number of total exercises
   \refstepcounter{exercise}%
}

% at the end of the exercise we persist two things:
% 1. the number of total points for this exercise
% 2. the formula to calculate the points for this exercise (to present to the students)
% please note, that we name this `endsp@exercise` to be theoretically compatible with the latex environments
% to be used as `\begin{exercise} ... \end{exercise}`
\def\endsp@exercise{%
\immediate\write\@auxout{%
      \string\gdef\string\sp@exercise@\the\numexpr\sp@exercises@totalcount\relax @points{\sp@exercise@points}%
      \string\gdef\string\sp@exercise@\the\numexpr\sp@exercises@totalcount\relax @formula{\sp@exercise@formula}%
   }%
}


% at the end of the document we must persist all counts for the next round!
\AtEndDocument{%
   \sp@persist\sp@exercises@totalcount=\arabic{exercise};%
}

% the sp cover page ======================================================

% TODO: add solution
\def\maketitle{%
\newgeometry{top=1cm,bottom=1cm,left=2cm,right=2cm,ignorehead}%
\begin{center}
   \parskip\z@\relax\parindent\z@\relax
   \thispagestyle{empty}%
   \begingroup
      \sp@@logoline
   % header ==============================================================
   \endgroup\par\begingroup
      \sp@@examlineA\\[5pt]
      \sp@@examlineB\\[1ex]
      \sp@@whenline
   % examiner/institute line =============================================
   \endgroup\vskip1.5em\par\begingroup
      \parbox[t]{.5\linewidth}{\sp@@examinerline}%
      \parbox[t]{.45\linewidth}{\raggedleft\sp@@instituteline}%
   % date and time =======================================================
   \endgroup\vskip1.5em\par\begingroup
      \strut\hfill\sp@@examdateline\hfill\sp@@examdurationline\hfill\strut
   % student data table ==================================================
   \endgroup\vskip1.5em\par\begingroup
      \sp@@studentdatatable
   % hints ===============================================================
   \endgroup\vfill\par\begingroup
   % TODO: multciolumn
   \begin{minipage}{\linewidth}
      \sp@@hintstitle\\
      % we store the hints in a box to calculate the height to align the image
      \setbox0=\hbox{\parbox[c]{.48\linewidth}{%
         \begin{itemize}
            \sp@@hints
         \end{itemize}
      }}%
      \usebox0\relax
      \hfill\begin{minipage}[c][\dimexpr\ht0+\dp0][c]{\dimexpr70mm+2\fboxsep}
         \hfill% \fboxsep=0pt
         \sp@@coverimage\bigskip%

         \sp@@additionalpaper
     \end{minipage}%
   \end{minipage}
   \vfill\strut
   \endgroup
\end{center}
\restoregeometry\newpage
}