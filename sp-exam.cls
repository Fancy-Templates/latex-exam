% we by default support three modes
\newif\ifexam        \examtrue
\newif\ifsolution    \solutionfalse
\newif\ifcorrection  \correctionfalse

% Moreover, our default/convenience macros consider these as special modes
\DeclareOption{exam}{\examtrue\solutionfalse\correctionfalse}
\DeclareOption{solution}{\examfalse\solutiontrue\correctionfalse}
\DeclareOption{correction}{\examfalse\solutiontrue\correctiontrue}

% code support loads everything to present code with the minted package
% using it requires python, pygments, and the `--shell-escape`
\newif\if@sp@code@support@
\DeclareOption{code}{\@sp@code@support@true}

% this loads tikz and makes rounded rectangles
\newif\if@sp@rounded@support@
\DeclareOption{rounded}{\@sp@rounded@support@true}

% pass unknown options to article
\DeclareOption*{\PassOptionsToClass{\CurrentOption}{article}}

\ProcessOptions*

\providecommand\sp@documentclass{
   \PassOptionsToClass{11pt,a4paper}{article}
   \LoadClass{article}
}
\sp@documentclass

% load the bare minimum of default packages ==============================

\PassOptionsToPackage{T1}{fontenc}
\RequirePackage{fontenc}
\PassOptionsToPackage{utf8}{inputenc}
\RequirePackage{inputenc}
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
\RequirePackage{comment}

\if@sp@rounded@support@
   \RequirePackage{tikz}
\fi

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
\def\sp@missing#1{%
   \textbf{\color{red}\texttt{\textbackslash #1\{??\}}}%
   \ClassError{sp-exam}{Please use \expandafter\string\csname #1\endcsname{??} to configure the '#1' which is required}{If you do not provide '#1', we have a problem (it is required after all)!}%
}

% comfort overload for `\sp@make@cmd` for macros which are required
\def\sp@make@required@cmd#1{\sp@make@cmd{#1}{\sp@missing{#1}}}

% immediately persist the value #2 in #1 to be active on the next run
\def\sp@persist#1=#2;{%
   % with csgdef we can include numbers!
   \immediate\write\@auxout{%
      \string\csgdef{#1}{#2}%
   }%
}

% hyperlinks =============================================================

\PassOptionsToPackage{hidelinks,pdfusetitle}{hyperref}

\RequirePackage{hyperref}

% setup fonts ============================================================

\RequirePackage{lmodern}
\RequirePackage{newtxtt} % ttfamily
\RequirePackage{sfmath}

\def\familydefault{\sfdefault}

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

\sp@make@cmd{solutionmarker}{\textsf{\textbf{\textcolor{sp@solution@color}{---~Lösung~---}}}}

\pagestyle{fancy}
\headheight=13.6\p@
\lhead{\sp@@examname}
\ifsolution
   \chead{%
      \smash{\parbox[b]{3cm}{\centering
         \sp@@solutionmarker\\
         \sp@@examcount
      }}%
   }
\else
   \chead{\sp@@examcount}
\fi
\rhead{\sp@@date}
\lfoot{}
\cfoot{\textsf{\thepage}}
\rfoot{}

% configure lists ========================================================

\setlist[itemize]{leftmargin=2em,itemsep=\smallskipamount}

\def\sp@subtask@item#1{\sp@item \Subtask{#1}\ignorespaces}
\def\sp@subtask@error{\ClassError{sp-exam}{You cannot use \string\item\space in a subtasks environment. Please use \string\subtask{<points>}\space instead!}{Otherwise, why would you use the subtasks list?}}

% so that other, nested lists work, we have to recover item within then explicitly
\let\sp@item\item\relax
\setlist{first*=\let\item\sp@item}

\newlist{subtasks}{enumerate}{2}
% within task, every `\item` takes in a subtask argument
\setlist[subtasks]{%
   leftmargin=*,%
   font=\normalfont\bfseries,%
   first*=\let\item\sp@task@error\relax\let\subtask\sp@subtask@item%
}
\setlist[subtasks,1]{label=\alph*),itemsep=\bigskipamount}% its up for the exam-creator to set the desired spacing
\setlist[subtasks,2]{label=\alph{enumi}.\roman*),itemsep=\medskipamount}

% separate pages =========================================================

% we reduce one as every task inserts a clearpage at the end
\sp@make@cmd{finalpageoffset}{-1}

% we allow the '\appendix' command to be used in the document to separate
% additional pages from those for the main exam
\newif\ifsp@in@appendix
\def\appendix{%
   % we store the number of pages in a macro to test for single pages
   \xdef\sp@main@end{\the\numexpr\arabic{page}+\sp@@finalpageoffset}%
   \clearpage
   \global\sp@in@appendixtrue
   \pagenumbering{roman}%
   \lfoot{Zusatzblatt}%
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
\sp@make@required@cmd{examnumber}
\sp@make@required@cmd{examname}
\sp@make@required@cmd{examiner}
\sp@make@required@cmd{year}
\sp@make@required@cmd{semester}
\sp@make@required@cmd{date}
\sp@make@required@cmd{time}
\sp@make@required@cmd{duration}

\def\allowhandwrittensheet{Sie dürfen ein beidseitig, handbeschriebenes DIN-A4-Blatt verwenden.}
\def\allowcheatsheet{Sie dürfen das Cheat-Sheet der Veranstaltung mit handschriftlichen Ergänzungen verwenden.}
\def\allownothing{Es sind keine Hilfsmittel erlaubt.}

\sp@make@cmd{permittedmaterial}{\allownothing}

% create a one-way compatibility mapping for the default latex macros
% this makes hyperref work as well
\AtEndPreamble{
   \author{\sp@@examiner}
   \title{\sp@@examname}
}

% for the coverimage we provide a convenience command `\framedcoverimage` which directly takes a path
% to an image and wraps it in a frame with the wanted sizes
\sp@make@cmd{coverimage}{}
\def\framedcoverimage#1{%
   \coverimage{\fbox{\begin{minipage}[b][41mm][c]{70mm}
      \centering\def\sp@tmp{#1}\ifx\sp@tmp\@empty~\else\includegraphics[width=\linewidth,height=41mm,keepaspectratio]{#1}\fi
   \end{minipage}}}%
}
\framedcoverimage{}

% all of these commands could be redefined just the same but we not require the user to
% in other words, the defaults should be satisfactory for most users
% the following lines define them roughly from top to bottom regarding their appearance on the (exam/solution) title page
\sp@make@cmd{examcount}{\sp@@examnumber. Klausur}
\sp@make@cmd{examlineA}{\strut\sp@@examcount{} zur Veranstaltung}
\sp@make@cmd{examlineB}{\textbf{\Large\strut\LARGE\sp@@examname\Large\strut}}
\sp@make@cmd{examinerline}{{\raggedright\strut\sp@@examiner\strut\endgraf}}

\sp@make@cmd{whenline}{im \sp@@semester semester \sp@@year}
\sp@make@cmd{institute}{Institut für Softwaretechnik und Programmiersprachen}
\sp@make@cmd{instituteline}{\sp@@institute}

\sp@make@cmd{examdateline}{\sp@@date, \sp@@time}
\sp@make@cmd{examdurationline}{Bearbeitungszeit: \sp@@duration\;min}

\sp@make@cmd{additionalsheets}{\ifcsname sp@appendix@end\endcsname Sie dürfen \ifnum\sp@appendix@end=1\relax das Zusatzblatt\else die Zusatzblätter\fi\space herauslösen.\fi}


% we assume that, by default, user's will give th relative path to the cls
% so we can make use of \CurrentFilePathUsed

\ifx\CurrentFilePathUsed\@empty
   \sp@make@cmd{rootpath}{}
\else
   \edef\sp@cur@file@used@e{\CurrentFilePathUsed}
   \sp@make@cmd{rootpath}{\sp@cur@file@used@e/}
   \AtEndPreamble{%
      % this way, users are no longer surprised regarding *where* the other template
      % files live
      \appto\Ginput@path{{\sp@cur@file@used@e/}}%
      \appto\input@path{{\sp@cur@file@used@e/}}%
   }%
\fi

\sp@make@cmd{logolocation}{img/}
\sp@make@cmd{logowidth}{73mm}
\sp@make@cmd{logoline}{%
\raisebox{-\height}{\parbox\linewidth{\strut\hfill\includegraphics[width=\sp@@logowidth]{\sp@@logolocation logo-uulm.pdf}}}%
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
   \multicolumn{2}{|l|}{\sp@table@field{Studiengang und angestrebter Abschluss (B.\,Sc./M.\,Sc.):}}&\sp@table@field{Fachsemester:}\\
   \multicolumn{2}{|l|}{\sp@space@v}&\\\hline

   \multicolumn{3}{|p{\dimexpr.95\textwidth-\sp@table@indent}|}{%
      \vskip-5\p@\sp@table@field{\parbox[t]{\linewidth}{Hiermit erkläre ich, dass ich prüfungsfähig bin.\newline
      Sollte ich nicht auf der Liste der angemeldeten Studierenden aufgeführt sein, dann nehme ich
      hiermit zur Kenntnis, dass diese Prüfung nicht gewertet werden wird. \newline\bigskip\newline
      \rule{10cm}{.5\p@}\\[-2.66\p@]%
      \strut Datum, Unterschrift}}} \\\hline
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
   \item Bearbeiten Sie die Aufgaben direkt auf den Aufgabenblättern. Wenn Sie mehr Platz benötigen, verwenden Sie zuerst die Rückseiten der Blätter. \sp@@additionalsheets
   \item \sp@@permittedmaterial
   \item Aufgaben, welche nicht mit einem dokumentenechten Stift in den Farben blau oder schwarz bearbeitet worden sind, werden nicht bewertet.
   \sp@@morehints
}

\sp@make@cmd{additionalpaper}{Zusätzliches benötigtes Paper wird Ihnen von der Aufsicht zur Verfügung gestellt.}

% the task/points magic ==============================================

\newcounter{task}
\def\sp@format@counter#1{\hbox{\textbf{#1}}}
\robustify\sp@format@counter
\def\thetask{\sp@format@counter{\arabic{task}}}
% we automatically scope subtasks to the current task they are in!
\newcounter{subtask}[task]
\def\thesubtask{\sp@format@counter{\arabic{task}.\alph{subtask})}}
\def\sp@tasks@totalcount{0}% default value of total tasks

% to avoid the need for xfp or other calc libraries (we rely on etex only), we add a '\sp@pt' marker to allow for
% dimexpr when calculating (i.e., expand to points/pt) but hide it when presenting the points to the user
\def\sp@pt{pt}
% we "robustify" the macro so that it is written to the aux file as-is and not expanded (this way we can hide pt suffixes as we please)
\robustify\sp@pt
\def\sp@res{@res}

\def\sp@get@points@of@task#1#2{%
   % this is the macro-name to evaluate (and cache with the \sp@res suffix)
   % we store it here to safe on tokens (and space) in the following
   \edef\sp@tmp{sp@task@#2@formula}%
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

\sp@make@cmd{taskname}{Aufgabe}
% we allow the user to configure the style of tasks with the number in the
% task counter and the name in taskname
\sp@make@cmd{taskformat}{\textbf{\Large \sp@@taskname~\arabic{task}~--- \large\taskname}}
\appto\extrasngerman{\let\taskautorefname\sp@@taskname}

\errorcontextlines=999
% \textbf{\Large Aufgabe~\arabic{task}~--- \large#1}
% #1 name of the task
\def\sp@task#1{\par
   % first, we step the number of total tasks
   \refstepcounter{task}%
   % for convenience, we add an automatic label to each task, with this we can link it in the points table!
   \label{sp@@ex:\arabic{task}}%
   \let\@currentname\sp@@taskname\relax
   \let\@currentlabel\thetask\relax
   \hyper@makecurrent{task}%
   \edef\sp@current@task@formula{sp@task@\arabic{task}@formula}%
   \edef\sp@current@task@subtask{sp@task@\arabic{task}@subtaskcount}%
   \begingroup
      \raggedleft
      \begin{tabularx}{\linewidth}{@{}Xr@{}}%
         \def\taskname{#1}%
         \sp@@taskformat &
         % if the command pointed to by '\sp@current@task@formula' exists, we display its formula and the result
         % we add +\z@ to compensate faulty formulas
         \expandafter\ifcsname\sp@current@task@formula\endcsname
            \sp@get@points@of@task\sp@result{\arabic{task}}%
            \let\sp@pt\space% hide the pt marker
            % currently we avoid math-mode
            \textbf{%
               % we only print the formula if there is more than one subtask!
               \ifnum\csname\sp@current@task@subtask\endcsname>\@ne
                  \csname\sp@current@task@formula\endcsname=\space
               \fi
               \sp@result\space Punkt\ifdim\sp@result\p@=\p@\else e\fi}%
            % if the user has specified the expected number of points we check if they match
            \ifcsname sp@current@task@expected@points\endcsname
               % we check if the expected points are equal to the calculated points
               \def\sp@tmp{\csname sp@current@task@expected@points\endcsname}%
               \ifdim\sp@result\p@=\sp@tmp\p@ \else
                  % otherwise we issue a warning
                  \ClassWarning{sp-exam}{This warning is expected when you just changed the points/on the first run as two passes are required to get stable points. So please, first rerun latex to see if the problem persists. The expected points for task \arabic{task} do not match the calculated points! You wanted '\sp@tmp' but the subtask only sum to \sp@result. Please check the expected points and the points given to the subtasks! If you think this is an error, contact the maintainer and remove the expected points}%
                  \rlap{\textbf{\color{red}(vs.\,\sp@tmp)}}%
               \fi
            \fi
         \fi
      \end{tabularx}\smallskip\par
   \endgroup
   % update the point macros for the next round
   \expandafter\let\csname\sp@current@task@formula\endcsname\@empty\relax
   % initialize the subtask count storage
   \expandafter\def\csname\sp@current@task@subtask\endcsname{0}%
   % reduce the width of an task
   \begin{enumerate}[leftmargin=10\p@,rightmargin=20\p@]
		\item[]\relax
}

\sp@make@cmd{subtaskpointwidth}{9mm}
\sp@make@cmd{subtaskpointheight}{7.33mm}
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
   \expandafter\ifx\csname\sp@current@task@formula\endcsname\@empty
      \csgdef\sp@current@task@formula{#1\sp@pt}%
   \else
      \csgappto\sp@current@task@formula{+\space#1\sp@pt}%
   \fi
}

% TODO: use pgf directly for the node instead of the tikz layer?
\if@sp@rounded@support@
   \def\sp@box#1{%
      \tikz[baseline={(@.base)}]{\node[rounded corners=3\p@,draw,line width=\fboxrule,inner sep=\fboxsep] (@) {#1};}%
   }
\else
   \let\sp@box\fbox
\fi

% place a marker into the margin
\ifsolution
   \def\sp@subtask@marker#1{\marginnote{\tiny\bfseries\solutionstyle#1 Punkt\ifdim#1\p@=\p@\else e\fi}}
\else
   \def\sp@subtask@marker#1{%
      \ifdim#1\p@=\z@\relax\else
      \marginnote{\fboxsep=.5\p@
         \sp@box{%
            \begin{minipage}[b][\sp@@subtaskpointheight]{\sp@@subtaskpointwidth}
               \raggedleft\tiny\bfseries/#1\relax
            \end{minipage}~\strut
         }%
      }\fi
   }
\fi

% #1 box configuration, #2 content
\def\sp@task@point@marker@{%
   % total points of task
   \sp@get@points@of@task\sp@result{\arabic{task}}
   \ifdim\sp@result\p@=\z@\relax\else
   \marginnote{\fboxsep=.5\p@\relax\fboxrule=1.66\p@
      \smash{\raisebox{.5\height}{\sp@box{%
         \begin{minipage}[b][\sp@@exampointheight]{\sp@@exampointwidth}
            \raggedleft\tiny\bfseries/\sp@result\relax
         \end{minipage}~\strut
      }}}%
   }\fi
}%

% by default we clear the page and write the total number of pages in the margin
% for the solution, we do not want point marker
\ifsolution
   \sp@make@cmd{endoftask}{\clearpage\rfoot{}}
\else
   \sp@make@cmd{endoftask}{%
      \rfoot{\sp@task@point@marker@}%
      \clearpage
      \rfoot{}%
   }
\fi

% at the end of the task we persist the formula to calculate the points for this task (to present to the students)
% and the number of subtasks
% please note, that we name this `endsp@task` to be theoretically compatible with the latex environments
% to be used as `\begin{task} ... \end{task}`
\def\endsp@task{%
   \end{enumerate}%
   % define the expected points first if none given
   \ifnum\value{subtask}=\z@\relax
      \expandafter\def\csname\sp@current@task@formula\endcsname{\sp@current@task@expected@points\sp@pt}%
   \fi
   \expandafter\sp@persist\sp@current@task@formula=\csname\sp@current@task@formula\endcsname;%
   \expandafter\sp@persist sp@task@\arabic{task}@subtaskcount=\arabic{subtask};%
   % every task gets it's own page
   \sp@@endoftask
}

% at the end of the document we must persist all counts for the next round!
\AtEndDocument{%
   \sp@persist sp@tasks@totalcount=\arabic{task};%
}

% sp cover page points table =============================================

% this iterates from 1 to the total number of tasks using an increment
% of 1 and executes #1 with `\i` set to the current step.
\def\sp@points@iter#1{%
   % if life gives you do-while, but you want while-do, make lemonade!
   \ifnum\sp@tasks@totalcount>\z@
      \begingroup
         \count@=\z@
         \loop
            \advance\count@ by\@ne\relax
            \edef\i{\the\count@}%
            #1%
         \ifnum\count@<\sp@tasks@totalcount\repeat
      \endgroup
   \fi
}

\def\sp@hyperto@do{\hyperref[\sp@hyperto]}
% #1 link target to ref everything to, if empty we do not link
% #2 symbol/string to place at the top
% #3 symbol/string to place at the bottom
\def\sp@points@row@entry#1#2#3{%
   \def\sp@hyperto{#1}\ifx\@empty\sp@hyperto\else\expandafter\sp@hyperto@do\fi
   {\parbox\linewidth{%
      \Large\strut#2\strut\\[2.25ex]
      \hbox{\footnotesize\strut#3\strut}%
   }}%
}

\def\sp@pointstable@last@wrapper#1{
\multicolumn{\sp@total@columns}{|c|}{{\LARGE\strut}\let\and\qquad#1}\\[4\p@]\hline}

\def\nachkorrektur{Einsichtnahme $\bigcirc$ mit / $\bigcirc$ ohne Nachkorrektur}

\def\notenbonus{$\bigcirc$ mit / $\bigcirc$ ohne Notenbonus}

\def\sp@pointstable@last{}
\def\addtopointstable#1{%
   \appto\sp@pointstable@last{\sp@pointstable@last@wrapper{#1}}%
}

\sp@make@cmd{pointstable}{%
\sp@tablereset
% additionally, we need two columns for the total sum of points and the grade
\edef\sp@total@columns{\the\numexpr\sp@tasks@totalcount+2}%
% to calculate the sum of all points
\def\sp@total{0}%
% we define the header of the line to enter the points and the fields for the correctors
\def\sp@numbers{}\def\sp@correctors{}%
\sp@points@iter{%
   \sp@get@points@of@task\sp@result{\i}%
   \xappto\sp@numbers{\noexpand\sp@points@row@entry{sp@@ex:\i}{\i}{von \sp@result} & }%
   \xdef\sp@total{\expandafter\strip@pt\dimexpr\sp@total\p@+\sp@result\p@}%
   \xappto\sp@correctors{&}%
}%
\begin{tabularx}{\linewidth}{|*{\sp@tasks@totalcount}{X|}X||X|}
   \hline
   \multicolumn{\sp@total@columns}{|c|}{{\LARGE\strut}\textit{Punkteverteilung}}\\
   \hline
   \sp@numbers \sp@points@row@entry\@empty{$\sum$}{von \sp@total} & \sp@points@row@entry\@empty{{\LARGE\strut}\textbf{Note}}{} \\ \hline
   \rule\z@{2\ht\strutbox}\sp@correctors & \tiny Korrektur\\ \hline
   \sp@pointstable@last
\end{tabularx}%
}


\sp@make@cmd{titleandlogo}{%
\rlap{\smash{\sp@@logoline}}%
   \begingroup
      % this is somewhat historically grown from a time in which the logo had
      % its own line
      \rlap{\parbox\linewidth{%
         \parbox{\dimexpr\linewidth-\sp@@logowidth-1cm}{%
            \raggedright
            \sp@@examlineA\\[5\p@]
            \sp@@examlineB\\[1ex]
            \sp@@whenline}%
      }}%
   \endgroup
}

% the sp cover page ======================================================
\sp@make@cmd{coverpage@exam}{%
\begin{center}
   \parskip\z@\relax\parindent\z@\relax
   % header --------------------------------------------------------------
   \sp@@titleandlogo
   % date and time -------------------------------------------------------
   \vskip2.5em\par\begingroup
      \strut\hfill\sp@@examdateline\hfill\sp@@examdurationline\hfill\strut
   % examiner/institute line ---------------------------------------------
   \endgroup\vskip2em\par\begingroup
      \parbox[t]{.5\linewidth}{\sp@@examinerline}\hfill%
      \parbox[t]{.45\linewidth}{\raggedleft\sp@@instituteline}%
   % student data table --------------------------------------------------
   \endgroup\vskip2em\par\begingroup
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
\end{center}%
}


\sp@make@cmd{coverpage@solution}{%
\begin{center}
   \parskip\z@\relax\parindent\z@\relax
   \sp@@titleandlogo
   \vskip2.5em\par\begingroup
      \textit{\sp@@examinerline}
   % date and time -------------------------------------------------------
   \endgroup\vskip1.5em\par\begingroup
      \strut\sp@@examdateline,\quad\sp@@examdurationline\strut
   % marker --------------------------------------------------
   \endgroup\par\vfill\vfill\par\begingroup
      \huge\bfseries\solutionstyle
      Musterlösung
      \ifcorrection\\\normalsize mit Korrekturhinweisen\fi
   \vfill\strut
   \endgroup
\end{center}%
}

\ifsolution
   \sp@make@cmd{coverpage}{\sp@@coverpage@solution}
\else
   \sp@make@cmd{coverpage}{\sp@@coverpage@exam}
\fi

\def\maketitle{%
   \newgeometry{top=1cm,bottom=1cm,left=2cm,right=2cm,ignorehead}%
   \thispagestyle{empty}%
   \sp@@coverpage
   \restoregeometry\newpage
}

% solution colors ========================================================

\colorlet{sp@solution@color}{cyan!80!purple}
\def\SolutionColor#1{\colorlet{sp@solution@color}{#1}}
\def\solutionstyle{\color{sp@solution@color}}

% code support ===========================================================

\sp@make@cmd{outputdir}{./}

\if@sp@code@support@

\PassOptionsToPackage{outputdir=\sp@@outputdir}{minted}
\RequirePackage{minted}

\setminted{
   numbersep=8pt,
   breaklines=true,
}

% define a new minted key which if given indents them
\define@key{minted@opt@cmd}{numbered}[1.33em]{%
   \setminted{linenos,xleftmargin=#1}
}

% default language definitions as desired:
% #1 macro and #2 language name
\def\sp@new@mintinline#1->#2\@nil{%
   \newmintinline[#1]{#2}{}%
}
\@for\lang:={%
   java->java,%
   ts->typescript,%
   js->javascript,%
   haskell->haskell,%
   prolog->prolog,%
   css->css,%
   xml->xml,%
   html->html%
}\do{
   \expandafter\sp@new@mintinline\lang\@nil
}

\typeout{Load code setup}
\ifsolution
   \usemintedstyle{tango}
   \def\theFancyVerbLine{\sffamily\textcolor{gray}{\scriptsize\arabic{FancyVerbLine}}}
\else
   \typeout{Load code setup}
   % we avoid colors in the exam
   \usemintedstyle{bw}
   \def\theFancyVerbLine{\sffamily\scriptsize\arabic{FancyVerbLine}}
\fi

\fi

% user commands for tasks ============================================

% #1: you can give the points here directly, if the task has subtasks,
%     they must sum up to this number
% #2: name of the task
\newenvironment{task}[2][]{\begingroup
   % test if the optional argument is given
   \edef\@tmp{#1}\ifx\@tmp\@empty\else
      % we have to get exactly these points!
      \def\sp@current@task@expected@points{#1}%
   \fi
   \sp@task{#2}%
}{\endsp@task\endgroup\bigskip}

% #1: number of points
\def\Subtask{\@ifstar\sp@Subtask@star\sp@Subtask@}
\def\sp@Subtask@star#1{\strut\sp@subtask{#1}}
\def\sp@Subtask@#1{\strut\sp@subtask{#1}\sp@subtask@marker{#1}}

\setbox0=\hbox{$\bigcirc$}
\newdimen\sp@square@size
\sp@square@size=\dimexpr.95\wd0-.5\p@
\def\sp@bigsquare{{\fboxsep\z@\raisebox{-.15\height}{\sp@box{\rule\sp@square@size\z@\relax\rule\z@\sp@square@size}}}}
\newlist{radioboxes}{itemize}{1}
\newlist{checkboxes}{itemize}{1}

\def\sp@place@solution@cross#1{\hbox{\setbox0=\hbox{#1}\clap{\raisebox{-.215\height}{\scalebox{2.25}{\solutionstyle$\times$}}}\clap{\copy0}\kern.5\wd0}}

\sp@make@cmd{radioboxlabel}{$\bigcirc$}
\sp@make@cmd{checkboxlabel}{\sp@bigsquare\kern\p@\relax}
\ifsolution
      \sp@make@cmd{radioboxcorrectlabel}{\sp@place@solution@cross{\sp@@radioboxlabel}}%
      \sp@make@cmd{checkboxcorrectlabel}{\sp@place@solution@cross{\sp@@checkboxlabel\kern-\p@\relax}\kern\p@\relax}%
\else
      \sp@make@cmd{radioboxcorrectlabel}{\sp@@radioboxlabel}%
      \sp@make@cmd{checkboxcorrectlabel}{\sp@@checkboxlabel}%
\fi

\setlist[checkboxes,radioboxes]{itemsep=2\p@\@plus1\p@\@minus1\p@}
\setlist[radioboxes]{%
   label=\sp@@radioboxlabel,
   first*=\def\correct{\item[\sp@@radioboxcorrectlabel]}%
}
\setlist[checkboxes]{
   label=\sp@@checkboxlabel,
   first*=\def\correct{\item[\sp@@checkboxcorrectlabel]}%
}

% #1 height
% #2 depth offset
\def\sp@custom@hrulefill#1#2{%
   \leavevmode\leaders\hrule\@height#1\@depth\dimexpr#2-#1\hfill\kern\z@
}
\def\sp@vertical@hrulefill{\sp@custom@hrulefill{.7ex}{.5pt}}

\newenvironment{solutionbox}{\begingroup\par
   \solutionstyle\parbox{1cm}{\sp@vertical@hrulefill}~\textbf{Lösung:}~\sp@vertical@hrulefill\par
}{\nopagebreak\par\nopagebreak\sp@vertical@hrulefill\nopagebreak\endgroup\par\medskip}

\newenvironment{correctionbox}{\begingroup\par
   \solutionstyle\parbox{1cm}{\sp@vertical@hrulefill}~\textbf{Korrekturhinweis:}~\sp@vertical@hrulefill\par
}{\nopagebreak\par\nopagebreak\sp@vertical@hrulefill\nopagebreak\endgroup\par\medskip}

% we use this to strut space for students to write one
\def\StudentStrut{\rule[-2.5\dp\strutbox]{0pt}{3\ht\strutbox}}

\newdimen\sp@lines@space \sp@lines@space=1cm
\newdimen\sp@lines@width \sp@lines@width=.42\p@
\def\IndentGuidesDistance#1{\setlength\sp@lines@space{#1}}

\colorlet{sp@lines@color}{gray!80!white}
\def\IndentGuidesColor#1{\colorlet{sp@lines@color}{#1}}
% used below to create multiple lines
\def\sp@lines@rule#1{\color{sp@lines@color}\rule\sp@lines@width{#1}\hspace*{\sp@lines@space}}

% #1 is the number of lines, #2 is the height using arbitrary units
\newcommand*\IndentGuides[2][5]{\begingroup
   \@tempcnta\z@%
   % your average for i loop
   \loop
      \sp@lines@rule{#2}%
      \advance\@tempcnta by\@ne\relax
      \ifnum\the\@tempcnta<#1\relax
   \repeat
\endgroup}

% this is a classic number check which checks if #1 is a number with now additional fluff
% (e.g., no space, units...) and if so, executes #2, otherwise #3
\def\sp@isnum#1#2#3{%
  \if!\ifnum9<1#1!\fi
     #2\relax
  \else#3\fi}

\ifsolution
   % a simple environment to wrap the actual solution and correction
   \specialcomment{solution}{\begin{solutionbox}}{\end{solutionbox}}
   % #1 holds the solution that we want to be there
   \newcommand*\StudentLine[1]{\StudentStrut{\rlap{\solutionstyle#1}\color{gray}\hrulefill}}
   % #1 relative weight of the space if you place multiple
   % the space is only active in the task mode
   \newcommand*\VerticalSpace[1][]{\vspace*{\z@}}
\else
   \excludecomment{solution}
   \newcommand*\StudentLine[1]{\StudentStrut{\hrulefill}}
   \newcommand*\VerticalSpace[1][1]{%
      \sp@isnum{#1}{\vspace*{\z@\@plus#1fill}}{\vspace*{#1}}%
   }
\fi

\ifcorrection
   \specialcomment{correction}{\begin{correctionbox}}{\end{correctionbox}}
\else
   \excludecomment{correction}
\fi
