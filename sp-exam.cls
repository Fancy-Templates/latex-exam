% Theoretically we can allow _any_ mode but this *should* help in preventing
% typos. Yet, nothing hinders a user to use `\def\spexammode{foo}` and subsequently
% use '\only' with 'foo' as a desired mode.
% Moreover, our default/convenience macros consider these as special modes
\DeclareOption{exam}{\def\spexammode{exam}}
\DeclareOption{solution}{\def\spexammode{solution}}
\DeclareOption{correction}{\def\spexammode{correction}}
\providecommand\spexammode{exam}

% we provide default lists that theoretical class-hackers can use to add their own modes
\def\sp@modes@hide@solutions{solution,correction}

% pass unknown options to article
\DeclareOption*{\PassOptionsToClass{\CurrentOption}{article}}

\ProcessOptions*

\providecommand\sp@documentclass{
   \PassOptionsToClass{11pt,a4paper}{article}
   \LoadClass{article}
}
\sp@documentclass

% load the bare minimum of default packages ==============================

\RequirePackage[T1]{fontenc}
\RequirePackage[utf8]{inputenc}
\PassOptionsToPackage{ngerman}{babel}
\RequirePackage{babel}
\RequirePackage{xcolor}
\RequirePackage{tabularx}
\RequirePackage{graphicx}
\RequirePackage{fancyhdr}
% so that no-one is surprised when placing a subtask:
\RequirePackage{marginnote}
\RequirePackage{enumitem}
\RequirePackage{etoolbox}
\RequirePackage{parskip}

% modes ==========================================================

% we use this if as a helper to store if we are in a desired
% mode or not
\newif\if@sp@tmp@

% helper macros to select arguments based on if we are in a
% desired mode
\def\sp@firstoftwo#1#2{#1}
\def\sp@secondoftwo#1#2{#2}

% this sets `\@sp@tmp@true` if any of the modes in `\sp@mode@list`
% is equal to the mode selected by `\spexammode`
\def\sp@checkmode{\@sp@tmp@false
% we check if any of the modes is set
\@for\sp@mode@tmp:=\sp@mode@list\do{%
   \ifx\sp@mode@tmp\spexammode
      \@sp@tmp@true
   \fi
}}

% if we are in one of the modes given by #1, we execute #2, otherwise #3
\newcommand\ifinmode[1]{%
   \def\sp@mode@list{#1}\sp@checkmode
   \if@sp@tmp@\expandafter\sp@firstoftwo
   \else
      \expandafter\sp@secondoftwo
   \fi
}

% only activate the content if any of the modes in #2 are active
% they are expected in a comma-separated list
\newenvironment{onlyenv}[2][]{%
   \def\sp@mode@list{#1}\sp@checkmode
   \if@sp@tmp@
}{\fi}

% \only if we are in the modes given by #1, we execute #2
\newcommand\only[2]{\ifinmode{#1}{#2}\relax}

% another convenience wrapper, execute #1 for the solution and #2
% if the solution is to be hidden
\newcommand*\ifshowsolution{%
   \expandafter\ifinmode\expandafter{\sp@modes@hide@solutions}%
}

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
   % with csgdef we can include numbers!
   \immediate\write\@auxout{%
      \string\csgdef{#1}{#2}%
   }%
}

\sp@make@cmd{solutionformat}{\itshape}

% hyperlinks =============================================================

\ifshowsolution
   {\PassOptionsToPackage{colorlinks,allcolors=cyan!40!black,pdfusetitle}{hyperref}}
   {\PassOptionsToPackage{hidelinks,pdfusetitle}{hyperref}}

\RequirePackage{hyperref}

% setup fonts ============================================================

\RequirePackage{lmodern}
\RequirePackage{newtxtt} % ttfamily
\RequirePackage{sfmath}

\renewcommand\familydefault{\sfdefault}

% page layout ============================================================

\RequirePackage{microtype}

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

\sp@make@cmd{solutionmarker}{\textsf{\textbf{\textcolor{red}{---~Lösung~---}}}}

\pagestyle{fancy}
\headheight=13.6\p@
\lhead{\sp@@examname}
\ifshowsolution
   {\chead{%
      \smash{\parbox[b]{3cm}{\centering
         \sp@@solutionmarker\\
         \sp@@examcount
      }}%
   }}
   {\chead{\sp@@examcount}}
\rhead{\sp@@date}
\lfoot{}
\cfoot{\textsf{\thepage}}
\rfoot{}

% configure lists ========================================================

\setlist[itemize]{leftmargin=2em,itemsep=\smallskipamount}

\def\sp@task@item#1{\sp@item \Subtask{#1}\ignorespaces}
\def\sp@task@error{\ClassError{sp-exam}{You cannot use \string\item\space in a task environment. Please use \string\task{<points>}\space instead!}{Otherwise, why would you use the tasks list?}}

% so that other, nested lists work, we have to recover item within then explicitly
\let\sp@item\item\relax
\setlist{first=\let\item\sp@item}

\newlist{tasks}{enumerate}{2}
% within task, every `\item` takes in a subtask argument
\setlist[tasks]{%
   leftmargin=*,%
   font=\normalfont\bfseries,%
   first=\let\item\sp@task@error\relax\let\task\sp@task@item%
}
\setlist[tasks,1]{label=\alph*),itemsep=\bigskipamount}% its up for the exam-creator to set the desired spacing
\setlist[tasks,2]{label=\alph{enumi}.\roman*),itemsep=\medskipamount}

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
      \sp@persist sp@main@end=\sp@main@end;%
      \sp@persist sp@appendix@end=\arabic{page};%
   \else
      \sp@persist sp@main@end=\arabic{page};%
   \fi
}
\def\sp@main@end{-1}

% macros for the sp cover page ===========================================

% this is the collection of macros (`\examnumber`, ...) which is required
% so that we can set the titlepage with `\maketitle`.
% with \def\@x{...} we create a one-way compatibility mapping for the default latex macros
\sp@make@required@cmd{examnumber}
\sp@make@required@cmd{examname}     \def\@title{\sp@@examname}
\sp@make@required@cmd{examiner}     \def\@author{\sp@@examiner}
\sp@make@required@cmd{year}
\sp@make@required@cmd{semester}
\sp@make@required@cmd{date}         \def\@date{\sp@@date}
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
\sp@make@cmd{examcount}{\sp@@examnumber. Klausur}
\sp@make@cmd{examlineA}{\sp@@examcount{} zur Veranstaltung}
\sp@make@cmd{examlineB}{\textbf{\LARGE\sp@@examname}}
\sp@make@cmd{examinerline}{\@hangfrom{Prüfer:\space}{\strut\sp@@examiner\strut}}

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

\def\sp@table@indent{6\p@}
% blocks start and height for a word in the coverpage table
\def\sp@table@field#1{\hspace*{\sp@table@indent}\rule\z@{1.15\ht\strutbox}#1}

% we just reset tabular definitions in case someone redefines how tables look
\def\sp@tablereset{\def\arraystretch{1}}

\sp@make@cmd{studentdatatable}{%
\tabcolsep\z@\relax\sp@tablereset
\begin{tabular}{|*2{p{.375\textwidth}|}p{.25\textwidth}|}
   \hline
   \sp@table@field{Nachname:}&\sp@table@field{Vorname:}&\sp@table@field{Matrikelnummer:}\\
   \sp@space@v&&\\\hline
   \multicolumn{2}{|l|}{\sp@table@field{Studiengang und Abschluss:}}&\sp@table@field{Fachsemester:}\\
   \multicolumn{2}{|l|}{\sp@space@v}&\\\hline

   \multicolumn{3}{|p{\dimexpr.95\textwidth-\sp@table@indent}|}{%
      \vskip-5\p@\sp@table@field{\parbox[t]{\linewidth}{Hiermit erkläre ich, dass ich prüfungsfähig bin.\newline
      Sollte ich nicht auf der Liste der angemeldeten Studierenden aufgeführt sein, dann nehme ich
      hiermit zur Kenntnis, dass diese Prüfung nicht gewertet werden wird. \newline\bigskip\newline
      \rule{10cm}{.5\p@}\\[-2.66\p@]%
      \strut Datum, Unterschrift des Prüfungsteilnehmers
   }}} \\\hline
\end{tabular}
}

% now we define the hints, for the number of pages we will infer them automatically
% with the '\appendix' marker
\sp@make@cmd{hintstitle}{\textbf{Zur allgemeinen Beachtung:}\medskip}%
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
   \item Bearbeiten Sie die Aufgaben direkt auf den Aufgabenblättern. Wenn sie mehr Platz benötigen, verwenden Sie zuerst die Rückseiten der Blätter. % TODO: more, was genau soll hier noch kommen?
   \item \sp@@permittedmaterial
   \item Aufgaben, welche nicht mit einem dokumentenechten Stift in den Farben blau oder schwarz bearbeitet worden sind, werden nicht bewertet.
   \sp@@morehints
}

\sp@make@cmd{additionalpaper}{Zusätzliches benötigtes Paper wird Ihnen von der Aufsicht zur Verfügung gestellt.}

% the exercise/points magic ==============================================
\newcounter{exercise}
\def\sp@format@counter#1{\hbox{\textbf{#1}}}
\robustify\sp@format@counter
\def\theexercise{\sp@format@counter{\arabic{exercise}}}
% we automatically scope subtasks to the current exercise they are in!
\newcounter{subtask}[exercise]
\def\thesubtask{\sp@format@counter{\arabic{exercise}.\alph{subtask})}}
\def\sp@exercises@totalcount{0}% default value of total exercises

% to avoid the need for xfp or other calc libraries (we rely on etex only), we add a '\sp@pt' marker to allow for
% dimexpr when calculating (i.e., expand to points/pt) but hide it when presenting the points to the user
\def\sp@pt{pt}
% we "robustify" the macro so that it is written to the aux file as-is and not expanded (this way we can hide pt suffixes as we please)
\robustify\sp@pt
\def\sp@res{@res}

\def\sp@get@points@of@task#1#2{%
   % this is the macro-name to evaluate (and cache with the \sp@res suffix)
   % we store it here to safe on tokens (and space) in the following
   \edef\sp@tmp{sp@exercise@#2@formula}%
   % we check if there is already a macro ending with @res, if so we have already calculated the points and use the cache
   \expandafter\ifcsname\sp@tmp\sp@res\endcsname\else
      % if not, we calculate the points and store them into the macro pointed to by \sp@tmp\sp@res
      % we use an xdef so the cache remains even if we are inside a group
      \expandafter\xdef\csname\sp@tmp\sp@res\endcsname{%
         % for the calculcation we do a dimexpr (e.g. \dimexpr12pt+3pt+4pt+\z@\relax)
         % which we subsequently remove the 'pt' suffix from to get the "floating point number"
         \expandafter\strip@pt\expandafter\dimexpr\csname\sp@tmp\endcsname+\z@\relax
      }%
   \fi
   % no we can just use the cached result
   \expandafter\let\expandafter#1\csname\sp@tmp\sp@res\endcsname
}

\sp@make@cmd{exercisename}{Aufgabe}
% we allow the user to configure the style of exercises with the number in the
% exercise counter and the name in exercisename
\sp@make@cmd{exerciseformat}{\textbf{\Large \sp@@exercisename~\arabic{exercise}~--- \large\exercisename}}
\appto\extrasngerman{\let\exerciseautorefname\sp@@exercisename}


% \textbf{\Large Aufgabe~\arabic{exercise}~--- \large#1}
% #1 name of the exercise
\def\sp@exercise#1{\par
   % first, we step the number of total exercises
   \refstepcounter{exercise}%
   \let\@currentname\sp@@exercisename\relax
   \let\@currentlabel\theexercise\relax
   \edef\sp@current@exercise@formula{sp@exercise@\arabic{exercise}@formula}%
   \edef\sp@current@exercise@subtask{sp@exercise@\arabic{exercise}@subtaskcount}%
   \begingroup
      \raggedleft
      \begin{tabularx}{\linewidth}{@{}Xr@{}}%
         \def\exercisename{#1}%
         \sp@@exerciseformat &
         % if the command pointed to by '\sp@current@exercise@formula' exists, we display its formula and the result
         % we add +\z@ to compensate faulty formulas
         \expandafter\ifcsname\sp@current@exercise@formula\endcsname
            \sp@get@points@of@task\sp@result{\arabic{exercise}}%
            \let\sp@pt\space% hide the pt marker
            % currently we avoid math-mode
            \textbf{%
               % we only print the formula if there is more than one subtask!
               \ifnum\csname\sp@current@exercise@subtask\endcsname>\@ne
                  \csname\sp@current@exercise@formula\endcsname=\space
               \fi
               \sp@result\space Punkt\ifdim\sp@result\p@=\p@\else e\fi}
         \fi
      \end{tabularx}\smallskip\par
   \endgroup
   % update the point macros for the next round
   \expandafter\let\csname\sp@current@exercise@formula\endcsname\@empty\relax
   % initialize the subtask count storage
   \expandafter\def\csname\sp@current@exercise@subtask\endcsname{0}%
}

\sp@make@cmd{subtaskpointwidth}{9mm}
\sp@make@cmd{subtaskpointheight}{7.5mm}
\sp@make@cmd{exampointwidth}{9mm}
\sp@make@cmd{exampointheight}{9mm}

\sp@make@cmd{subtaskname}{Teilaufgabe}
\appto\extrasngerman{\let\subtaskautorefname\sp@@subtaskname}

% create a points-padding for a subtask
% #1 number of points for the subtask (if it is a floating point, it must be given with a dot/period, not a comma)
\def\sp@subtask#1{%
   \refstepcounter{subtask}%
   \let\@currentname\sp@@subtaskname\relax
   \let\@currentlabel\thesubtask\relax
   % if the current subtask formula is empty, we just add the given points, otherwise, we precede it with a plus sign
   \expandafter\ifx\csname\sp@current@exercise@formula\endcsname\@empty
      \csgdef\sp@current@exercise@formula{#1\sp@pt}%
   \else
      \csgappto\sp@current@exercise@formula{+\space#1\sp@pt}%
   \fi
}

% TODO: round corners if not in draft
\let\sp@box\fbox

% place a marker into the margin
\def\sp@subtask@marker#1{%
   \ifdim#1\p@=\z@\relax\else
   \marginnote{\fboxsep=.5\p@
      \sp@box{%
         \begin{minipage}[b][\sp@@subtaskpointheight]{\sp@@subtaskpointwidth}
            \raggedleft\tiny\bfseries/#1\relax
         \end{minipage}
      }%
   }\fi
}


% #1 box configuration, #2 content
\def\sp@exercise@point@marker@{%
% total points of exercise
\sp@get@points@of@task\sp@result{\arabic{exercise}}
\ifdim\sp@result\p@=\z@\relax\else
\marginnote{\fboxsep=.5\p@\fboxrule=2\p@
   \smash{\raisebox{.5\height}{\sp@box{%
      \begin{minipage}[b][\sp@@exampointheight]{\sp@@exampointwidth}
         \raggedleft\tiny\bfseries/\sp@result\relax
      \end{minipage}
   }}}%
}\fi
}

% by default we clear the page and write the total number of pages in the margin
\sp@make@cmd{endofexercise}{%
   \rfoot{\sp@exercise@point@marker@}%
   \clearpage
   \rfoot{}%
}

% at the end of the exercise we persist the formula to calculate the points for this exercise (to present to the students)
% and the number of subtasks
% please note, that we name this `endsp@exercise` to be theoretically compatible with the latex environments
% to be used as `\begin{exercise} ... \end{exercise}`
\def\endsp@exercise{%
   \expandafter\sp@persist\sp@current@exercise@formula=\csname\sp@current@exercise@formula\endcsname;%
   \expandafter\sp@persist sp@exercise@\arabic{exercise}@subtaskcount=\arabic{subtask};%
   % every exercise gets it's own page
   \sp@@endofexercise
}

% at the end of the document we must persist all counts for the next round!
\AtEndDocument{%
   \sp@persist sp@exercises@totalcount=\arabic{exercise};%
}

% sp cover page points table =============================================

% this iterates from 1 to the total number of exercises using an increment
% of 1 and executes #1 with `\i` set to the current step.
\def\sp@points@iter#1{%
   % if life gives you do-while, but you want while-do, make lemonade!
   \ifnum\sp@exercises@totalcount>\z@
      \begingroup
         \count@=\z@
         \loop
            \advance\count@ by\@ne\relax
            \edef\i{\the\count@}%
            #1%
         \ifnum\count@<\sp@exercises@totalcount\repeat
      \endgroup
   \fi
}

% #1 symbol/string to place at the top
% #2 symbol/string to place at the bottom
\def\sp@points@row@entry#1#2{%
   \parbox\linewidth{%
      \Large\strut#1\strut\\[2.25ex]
      \hbox{\footnotesize\strut#2\strut}%
   }%
}

\sp@make@cmd{pointstable}{%
\sp@tablereset
% additionally, we need two columns for the total sum of points and the grade
\edef\sp@total@columns{\the\numexpr\sp@exercises@totalcount+2}%
% to calculate the sum of all points
\def\sp@total{0}%
% we define the header of the line to enter the points and the fields for the correctors
\def\sp@numbers{}\def\sp@correctors{}%
\sp@points@iter{%
   \sp@get@points@of@task\sp@result{\i}%
   \xappto\sp@numbers{\noexpand\sp@points@row@entry{\i}{von \sp@result} & }%
   \xdef\sp@total{\expandafter\strip@pt\dimexpr\sp@total\p@+\sp@result\p@}%
   \xappto\sp@correctors{&}%
}%
\begin{tabularx}{\linewidth}{|*{\sp@exercises@totalcount}{X|}X||X|}
   \hline
   \multicolumn{\sp@total@columns}{|c|}{{\LARGE\strut}\textit{Punkteverteilung}}\\
   \hline
   \sp@numbers \sp@points@row@entry{$\sum$}{von \sp@total} & \sp@points@row@entry{{\LARGE\strut}\textbf{Note}}{} \\ \hline
   \rule\z@{2\ht\strutbox}\sp@correctors & \tiny Korrektur\\ \hline
   \multicolumn{\sp@total@columns}{|c|}{{\LARGE\strut}Einsichtnahme ohne Nachkorrektur $\bigcirc$ \hskip2cm Einsichtnahme mit Nachkorrektur $\bigcirc$}\\[4\p@]
   \hline
\end{tabularx}%
}

% the sp cover page ======================================================

\def\maketitle{%
\newgeometry{top=1cm,bottom=1cm,left=2cm,right=2cm,ignorehead}%
\thispagestyle{empty}%
\begin{center}
   \parskip\z@\relax\parindent\z@\relax
   \begingroup
      \sp@@logoline
   % header --------------------------------------------------------------
   \endgroup\par\begingroup
      \sp@@examlineA\\[5\p@]
      \sp@@examlineB\\[1ex]
      \sp@@whenline
   % examiner/institute line ---------------------------------------------
   \endgroup\vskip1.5em\par\begingroup
      \parbox[t]{.5\linewidth}{\sp@@examinerline}%
      \parbox[t]{.45\linewidth}{\raggedleft\sp@@instituteline}%
   % date and time -------------------------------------------------------
   \endgroup\vskip1.5em\par\begingroup
      \strut\hfill\sp@@examdateline\hfill\sp@@examdurationline\hfill\strut
   % student data table --------------------------------------------------
   \endgroup\vskip1.5em\par\begingroup
      \sp@@studentdatatable
   % hints ---------------------------------------------------------------
   \endgroup\vfill\par\begingroup
   \begin{minipage}{\linewidth}
      \sp@@hintstitle\\
      % we store the hints in a box to calculate the height to align the image
      \setbox0=\hbox{\parbox[c]{.48\linewidth}{%
         \begin{itemize}
            \sp@@hints
         \end{itemize}
      }}%
      \usebox0\relax
   % cover image ---------------------------------------------------------
      \hfill\begin{minipage}[c][\dimexpr\ht0+\dp0][c]{\dimexpr70mm+2\fboxsep}
         \hfill% \fboxsep=0pt is to be done with the image if desired
         \sp@@coverimage\bigskip\par
         \sp@@additionalpaper
     \end{minipage}%
   \end{minipage}
   \vfill
   % points --------------------------------------------------------------
   \sp@@pointstable
   \endgroup
\end{center}
\restoregeometry\newpage
}


% user commands for exercises ============================================

% #1: only if this exercise has no subtasks, you can give the points here directly
% #2: name of the exercise
\newenvironment{Exercise}[2][]{\begingroup
   \sp@exercise{#2}%
   % test if the optional argument is given
   \edef\@tmp{#1}\ifx\@tmp\@empty\else

      \sp@subtask{#1}%
      % if yes, we forbid further subtasks from occurring
      \def\sp@subtask##1{\ClassError{sp-exam}{You cannot use subtasks in an exercise with a given number of points}{Either remove the optional argument to \string\Exercise\space or remove the subtask!}}%
      % we manually restore the label references here, the user should not know that we handle this
      % with a subtask as well!
      \let\@currentname\sp@@exercisename\relax
      \hyper@makecurrent{exercise}%
      \let\@currentlabel\theexercise\relax
   \fi
}{\endsp@exercise\endgroup\bigskip}

% #1: number of points
\def\Subtask#1{\sp@subtask{#1}\sp@subtask@marker{#1}}

% #1 relative weight of the space if you place multiple
% the space is only active in the exercise mode
\newcommand*\VerticalSpace[1][1]{\vspace*{\z@\@plus#1fill}}

\setbox0=\hbox{$\bigcirc$}
\newdimen\sp@square@size
\sp@square@size=\dimexpr.9\wd0-.5\p@
\def\sp@bigsquare{{\fboxsep\z@\framebox[\sp@square@size]{\rule\z@\sp@square@size}}}
\newlist{radioboxes}{itemize}{1}
\newlist{checkboxes}{itemize}{1}
\setlist[checkboxes,radioboxes]{label=$\bigcirc$,itemsep=2\p@\@plus1\p@\@minus1\p@}
\setlist[checkboxes]{label=\sp@bigsquare}
% TODO: mark the correct one

% we use this to strut space for students to write one
\def\StudentStrut{\rule[-2.5\dp\strutbox]{0pt}{3\ht\strutbox}}
% #1 holds the solution that we want to be there
\ifshowsolution{
   \def\StudentLine#1{\StudentStrut{\rlap{#1}\color{gray}\hrulefill}}
}{
   \def\StudentLine#1{\StudentStrut{\hrulefill}}
}


% TODO: allow to define space for user inputs
% * space to enter code
