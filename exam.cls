% we by default support three modes
\newif\ifexam        \examtrue
\newif\ifsolution    \solutionfalse
\newif\ifcorrection  \correctionfalse

\RequirePackage{translations}

% Moreover, our default/convenience macros consider these as special modes
\DeclareOption{exam}{\examtrue\solutionfalse\correctionfalse}
\DeclareOption{solution}{\examfalse\solutiontrue\correctionfalse}
\DeclareOption{correction}{\examfalse\solutiontrue\correctiontrue}

% language support
\def\@fancy@lang@german{\def\@fancy@language{ngerman}}
\def\@fancy@lang@english{\def\@fancy@language{english}}

\DeclareOption{english}{\@fancy@lang@english}
\DeclareOption{german}{\@fancy@lang@german}
\DeclareOption{ngerman}{\@fancy@lang@german}
\@fancy@lang@german

% code support loads everything to present code with the minted package
% using it requires python, pygments, and the `--shell-escape`
\newif\if@fancy@code@support@
\DeclareOption{code}{\@fancy@code@support@true}

% this loads tikz and makes rounded rectangles
\newif\if@fancy@rounded@support@
\DeclareOption{rounded}{\@fancy@rounded@support@true}

\newif\if@fancy@codeword@
\DeclareOption{codeword}{\@fancy@codeword@true}
% pass unknown options to article
\DeclareOption*{\PassOptionsToClass{\CurrentOption}{article}}

\ProcessOptions*

\providecommand\fancy@documentclass{
   \PassOptionsToClass{11pt,a4paper}{article}
   \LoadClass{article}
}
\fancy@documentclass

% load the bare minimum of default packages ==============================

\PassOptionsToPackage{T1}{fontenc}
\RequirePackage{fontenc}
\PassOptionsToPackage{utf8}{inputenc}
\RequirePackage{inputenc}
\PassOptionsToPackage{main=\@fancy@language,shorthands=off}{babel}
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
\RequirePackage{versions}

\if@fancy@rounded@support@
   \RequirePackage{tikz}
\fi

% meta commands ==========================================================

% just the internal prefix to namespace our sp commands
\def\fancy@prefix{fancy@}

% vertical space reserve for student inputs
\def\fancy@space@v{\rule\z@{5mm}}

% we have a lot of commands that we want to configure, so we write a small
% meta-macro which allows us to create such commands
% #1: command name
% #2: default value
\long\def\fancy@make@cmd#1#2{%
   % define a new macro `\#1`, which defines `\fancy@@#1` with the value given.
   % For example, `\fancy@make@cmd{foo}{bar}` defines the macro `\foo` and
   % `\fancy@@foo` which evaluates to `bar`. If you evaluate `\foo{baz}`,
   % `\fancy@@foo` will be `baz`.
   \expandafter\long\expandafter\def\csname #1\endcsname##1{%
      \expandafter\def\csname\fancy@prefix @#1\endcsname{##1}%
   }%
   % now, run the macro with the default value so that `\fancy@@foo`
   % starts as `bar`.
   \csname#1\endcsname{#2}%
}
% format #1 to indicate a missing value
\def\fancy@missing#1{%
   \textbf{\color{red}\texttt{\textbackslash #1\{??\}}}%
   \ClassError{exam}{Please use \expandafter\string\csname #1\endcsname{??} to configure the '#1' which is required}{If you do not provide '#1', we have a problem (it is required after all)!}%
}

% comfort overload for `\fancy@make@cmd` for macros which are required
\def\fancy@make@required@cmd#1{\fancy@make@cmd{#1}{\fancy@missing{#1}}}

% immediately persist the value #2 in #1 to be active on the next run
\def\fancy@persist#1=#2;{%
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
\RequirePackage[defaultlines=3,all]{nowidow}

\def\fancy@geometry@left{2cm}%
\def\fancy@geometry@right{2cm}%
\def\fancy@geometry@top{1cm}%
\def\fancy@geometry@bottom{2cm}%
\providecommand\fancy@geometry{
   \PassOptionsToPackage{
      left=\fancy@geometry@left,
      right=\fancy@geometry@right,
      top=\fancy@geometry@top,
      bottom=\fancy@geometry@bottom,
      includehead%
   }{geometry}
   \RequirePackage{geometry}
}
\fancy@geometry

% page head ==============================================================

\fancy@make@cmd{solutionmarker}{\textsf{\textbf{\textcolor{fancy@solution@color}{---~Lösung~---}}}}

\pagestyle{fancy}
\headheight=13.6\p@
\lhead{\fancy@@examname}
\ifsolution
   \chead{%
      \smash{\parbox[b]{3cm}{\centering
         \fancy@@solutionmarker\\
         \fancy@@examcount
      }}%
   }
\else
   \chead{\fancy@@examcount}
\fi
\rhead{\fancy@@date}
\lfoot{}
\cfoot{\textsf{\thepage}}
\rfoot{}

% configure lists ========================================================

\setlist[itemize]{leftmargin=2em,itemsep=\smallskipamount}

\def\fancy@subtask@item#1{\fancy@item \Subtask{#1}\ignorespaces}
\def\fancy@subtask@error{\ClassError{exam}{You cannot use \string\item\space in a subtasks environment. Please use \string\subtask{<points>}\space instead!}{Otherwise, why would you use the subtasks list?}}

% so that other, nested lists work, we have to recover item within then explicitly
\let\fancy@item\item\relax
\setlist{first*=\let\item\fancy@item}
\appto\trivlist{\let\item\fancy@item}

\newlist{subtasks}{enumerate}{2}
% within task, every `\item` takes in a subtask argument
\setlist[subtasks]{%
   leftmargin=*,%
   font=\normalfont\bfseries,%
   first*=\let\item\fancy@task@error\relax\let\subtask\fancy@subtask@item%
}
\setlist[subtasks,1]{label=\alph*),itemsep=\bigskipamount}% its up for the exam-creator to set the desired spacing
\setlist[subtasks,2]{label=\alph{enumi}.\roman*),itemsep=\medskipamount}

% separate pages =========================================================

% we reduce one as every task inserts a clearpage at the end
\fancy@make@cmd{finalpageoffset}{-1}

% we allow the '\appendix' command to be used in the document to separate
% additional pages from those for the main exam
\newif\iffancy@in@appendix
\def\appendix{%
   % we store the number of pages in a macro to test for single pages
   \xdef\fancy@main@end{\arabic{page}}%
   \clearpage
   \global\fancy@in@appendixtrue
   \pagenumbering{roman}%
   \lfoot{Zusatzblatt}%
   \setcounter{page}{1}%
}

% at the end of the document we just store the current page(s)
\AtEndDocument{%
   \iffancy@in@appendix
      \fancy@persist fancy@main@end=\the\numexpr\fancy@main@end+\fancy@@finalpageoffset;%
      \fancy@persist fancy@appendix@end=\arabic{page};%
   \else
   % use latex last page 
      \fancy@persist fancy@main@end=\@abspage@last;
   \fi
}
\def\fancy@main@end{-1}

% macros for the sp cover page ===========================================

% this is the collection of macros (`\examnumber`, ...) which is required
% so that we can set the titlepage with `\maketitle`.
\fancy@make@required@cmd{examnumber}
\fancy@make@required@cmd{examname}
\fancy@make@required@cmd{examiner}
\fancy@make@required@cmd{semesteryear}
\fancy@make@required@cmd{semester}
\fancy@make@required@cmd{date}
\fancy@make@required@cmd{starttime}
\fancy@make@required@cmd{duration}

\def\allowhandwrittensheet{Sie dürfen ein beidseitig, handbeschriebenes DIN-A4-Blatt verwenden.}
\def\allowcheatsheet{Sie dürfen das Cheat-Sheet der Veranstaltung mit handschriftlichen Ergänzungen verwenden.}
\def\allownothing{Es sind keine Hilfsmittel erlaubt.}

\fancy@make@cmd{permittedmaterial}{\allownothing}

% create a one-way compatibility mapping for the default latex macros
% this makes hyperref work as well
\AtEndPreamble{
   \author{\fancy@@examiner}
   \title{\fancy@@examname}
}

% for the coverimage we provide a convenience command `\framedcoverimage` which directly takes a path
% to an image and wraps it in a frame with the wanted sizes
\fancy@make@cmd{coverimage}{}
\def\framedcoverimage#1{%
   \coverimage{\fbox{\begin{minipage}[b][41mm][c]{70mm}
      \centering\def\fancy@tmp{#1}\ifx\fancy@tmp\@empty~\else\includegraphics[width=\linewidth,height=41mm,keepaspectratio]{#1}\fi
   \end{minipage}}}%
}
\framedcoverimage{}

% all of these commands could be redefined just the same but we not require the user to
% in other words, the defaults should be satisfactory for most users
% the following lines define them roughly from top to bottom regarding their appearance on the (exam/solution) title page
\NewTranslation{ngerman}{exam}{Klausur}
\NewTranslation{english}{exam}{Exam}
\fancy@make@cmd{examcount}{\fancy@@examnumber. \GetTranslation{exam}}
\fancy@make@cmd{examlineA}{\strut\fancy@@examcount{} zur Veranstaltung}
\fancy@make@cmd{examlineB}{\textbf{\Large\strut\LARGE\fancy@@examname\Large\strut}}
\fancy@make@cmd{examinerline}{{\raggedright\strut\fancy@@examiner\strut\endgraf}}

\fancy@make@cmd{whenline}{im \fancy@@semester semester \fancy@@semesteryear}
\fancy@make@cmd{institute}{Institut für Softwaretechnik und Programmiersprachen}
\fancy@make@cmd{instituteline}{\fancy@@institute}

\fancy@make@cmd{examdateline}{\fancy@@date, \fancy@@starttime}
\fancy@make@cmd{examdurationline}{Bearbeitungszeit: \fancy@@duration\;min}

\fancy@make@cmd{codeword}{Codewort}

\fancy@make@cmd{additionalsheets}{\ifcsname fancy@appendix@end\endcsname Sie dürfen \ifnum\fancy@appendix@end=1\relax das Zusatzblatt\else die Zusatzblätter\fi\space herauslösen.\fi}


% we assume that, by default, user's will give th relative path to the cls
% so we can make use of \CurrentFilePathUsed

\ifx\CurrentFilePathUsed\@empty
   \fancy@make@cmd{rootpath}{}
\else
   \edef\fancy@cur@file@used@e{\CurrentFilePathUsed}
   \fancy@make@cmd{rootpath}{\fancy@cur@file@used@e/}
   \AtEndPreamble{%
      % this way, users are no longer surprised regarding *where* the other template
      % files live
      \appto\Ginput@path{{\fancy@cur@file@used@e/}}%
      \appto\input@path{{\fancy@cur@file@used@e/}}%
   }%
\fi

\fancy@make@cmd{logolocation}{img/}
\fancy@make@cmd{logowidth}{73mm}
\fancy@make@cmd{logoline}{%
\raisebox{-\height}{\parbox\linewidth{\strut\hfill\includegraphics[width=\fancy@@logowidth]{\fancy@@logolocation logo-uulm.pdf}}}%
}

\def\fancy@table@indent{6\p@}
% blocks start and height for a word in the coverpage table
\def\fancy@table@field#1{\hspace*{\fancy@table@indent}\rule\z@{1.15\ht\strutbox}#1}

% we just reset tabular definitions in case someone redefines how tables look
\def\fancy@tablereset{\def\arraystretch{1}}


\fancy@make@cmd{studentdatatableintrotext}{Hiermit erkläre ich, dass ich prüfungsfähig bin.\newline
Sollte ich nicht auf der Liste der angemeldeten Studierenden aufgeführt sein, dann nehme ich
hiermit zur Kenntnis, dass diese Prüfung nicht gewertet werden wird.}
\fancy@make@cmd{studentdatatable}{%
\tabcolsep\z@\relax\fancy@tablereset
\begin{tabular}{|*2{p{.375\textwidth}|}p{.25\textwidth}|}
   \hline
   \fancy@table@field{Nachname:}&\fancy@table@field{Vorname:}&\fancy@table@field{Matrikelnummer:}\\
   \fancy@space@v&&\\\hline
   \multicolumn{2}{|l|}{\fancy@table@field{Studiengang und angestrebter Abschluss (B.\,Sc./M.\,Sc.):}}&\fancy@table@field{Fachsemester:}\\
   \multicolumn{2}{|l|}{\fancy@space@v}&\\\hline

   \multicolumn{3}{|p{\dimexpr.95\textwidth-\fancy@table@indent}|}{%
      \vskip-5\p@\fancy@table@field{\parbox[t]{\linewidth}{\fancy@@studentdatatableintrotext\newline\bigskip\newline
      \rule{10cm}{.5\p@}\\[-2.66\p@]%
      \strut Datum, Unterschrift}}} \\\hline
\end{tabular}
}

% now we define the hints, for the number of pages we will infer them automatically
% with the '\appendix' marker
\fancy@make@cmd{hintstitle}{\textbf{Zur allgemeinen Beachtung:}\medskip}%
% morehints can be used to add more hints using `\item` prefixes, at the bottom of the list.
% we make no attempts to make more space for them!
\fancy@make@cmd{morehints}{}

\fancy@make@cmd{onnotenoughspace}{Wenn Sie mehr Platz benötigen, verwenden Sie zuerst die Rückseiten der Blätter.}

\fancy@make@cmd{wheretosolve}{\item Bearbeiten Sie die Aufgaben direkt auf den Aufgabenblättern. \fancy@@onnotenoughspace\space \fancy@@additionalsheets}

\fancy@make@cmd{whattouse}{\item Aufgaben, welche nicht mit einem dokumentenechten Stift in den Farben blau oder schwarz bearbeitet worden sind, werden nicht bewertet.}

\fancy@make@cmd{hints}{%
   \item Füllen Sie das Deckblatt vollständig und korrekt aus.
   \if@fancy@codeword@\fancy@@codewordtext\fi
   \item Lesen Sie sich zunächst die Klausur sorgfältig durch (sie besteht aus \ifnum\fancy@main@end=1\relax \textbf{einer} Seite\else\textbf{\fancy@main@end}~Seiten\fi%
   % now we have to check if there are additional pages
   \ifcsname fancy@appendix@end\endcsname
      \space und \ifnum\fancy@appendix@end=1\relax \textbf{einer} Zusatzseite\else\textbf{\fancy@appendix@end}~Zusatzseiten\fi
   \fi).
   \fancy@@wheretosolve  
   \item \fancy@@permittedmaterial
   \fancy@@whattouse
   \fancy@@morehints
}

\fancy@make@cmd{additionalpaper}{Zusätzliches benötigtes Papier wird Ihnen von der Aufsicht zur Verfügung gestellt.}

% the task/points magic ==============================================

\newcounter{task}
\def\fancy@format@counter#1{\hbox{\textbf{#1}}}
\robustify\fancy@format@counter
\def\thetask{\fancy@format@counter{\arabic{task}}}
% we automatically scope subtasks to the current task they are in!
\newcounter{subtask}[task]
\def\thesubtask{\fancy@format@counter{\arabic{task}.\alph{subtask})}}
\def\fancy@tasks@totalcount{0}% default value of total tasks

% to avoid the need for xfp or other calc libraries (we rely on etex only), we add a '\fancy@pt' marker to allow for
% dimexpr when calculating (i.e., expand to points/pt) but hide it when presenting the points to the user
\def\fancy@pt{pt}
% we "robustify" the macro so that it is written to the aux file as-is and not expanded (this way we can hide pt suffixes as we please)
\robustify\fancy@pt
\def\fancy@res{@res}

\def\fancy@get@points@of@task#1#2{%
   % this is the macro-name to evaluate (and cache with the \fancy@res suffix)
   % we store it here to safe on tokens (and space) in the following
   \edef\fancy@tmp{fancy@task@#2@formula}%
   % we check if there is already a macro ending with @res, if so we have already calculated the points and use the cache
   \expandafter\ifcsname\fancy@tmp\fancy@res\endcsname\else
      % if not, we calculate the points and store them into the macro pointed to by \fancy@tmp\fancy@res
      % we use an xdef so the cache remains even if we are inside a group
      \expandafter\xdef\csname\fancy@tmp\fancy@res\endcsname{%
         % for the calculcation we do a dimexpr (e.g. \dimexpr12pt+3pt+4pt+\z@\relax)
         % which we subsequently remove the 'pt' suffix from to get the "floating point number"
         \expandafter\strip@pt\expandafter\dimexpr\csname\fancy@tmp\endcsname+\z@\relax
      }%
   \fi
   % no we can just use the cached result
   \expandafter\let\expandafter#1\csname\fancy@tmp\fancy@res\endcsname
}

\fancy@make@cmd{taskname}{Aufgabe}
% we allow the user to configure the style of tasks with the number in the
% task counter and the name in taskname
\fancy@make@cmd{taskformat}{\textbf{\Large \fancy@@taskname~\arabic{task}~--- \large\taskname}}
\appto\extrasngerman{\let\taskautorefname\fancy@@taskname}

\errorcontextlines=999
% \textbf{\Large Aufgabe~\arabic{task}~--- \large#1}
% #1 name of the task
\def\fancy@task#1{\par
   % first, we step the number of total tasks
   \refstepcounter{task}%
   % for convenience, we add an automatic label to each task, with this we can link it in the points table!
   \label{fancy@@ex:\arabic{task}}%
   \let\@currentname\fancy@@taskname\relax
   \let\@currentlabel\thetask\relax
   \hyper@makecurrent{task}%
   \edef\fancy@current@task@formula{fancy@task@\arabic{task}@formula}%
   \edef\fancy@current@task@subtask{fancy@task@\arabic{task}@subtaskcount}%
   \begingroup
      \raggedleft
      \begin{tabularx}{\linewidth}{@{}Xr@{}}%
         \def\taskname{#1}%
         \fancy@@taskformat &
         % if the command pointed to by '\fancy@current@task@formula' exists, we display its formula and the result
         % we add +\z@ to compensate faulty formulas
         \expandafter\ifcsname\fancy@current@task@formula\endcsname
            \fancy@get@points@of@task\fancy@result{\arabic{task}}%
            \let\fancy@pt\space% hide the pt marker
            % currently we avoid math-mode
            \textbf{%
               % we only print the formula if there is more than one subtask!
               \ifnum\csname\fancy@current@task@subtask\endcsname>\@ne
                  \csname\fancy@current@task@formula\endcsname=\space
               \fi
               \fancy@result\space Punkt\ifdim\fancy@result\p@=\p@\else e\fi}%
            % if the user has specified the expected number of points we check if they match
            \ifcsname fancy@current@task@expected@points\endcsname
               % we check if the expected points are equal to the calculated points
               \def\fancy@tmp{\csname fancy@current@task@expected@points\endcsname}%
               \ifdim\fancy@result\p@=\fancy@tmp\p@ \else
                  % otherwise we issue a warning
                  \ClassWarning{exam}{This warning is expected when you just changed the points/on the first run as two passes are required to get stable points. So please, first rerun latex to see if the problem persists. The expected points for task \arabic{task} do not match the calculated points! You wanted '\fancy@tmp' but the subtask only sum to \fancy@result. Please check the expected points and the points given to the subtasks! If you think this is an error, contact the maintainer and remove the expected points}%
                  \rlap{\textbf{\color{red}(vs.\,\fancy@tmp)}}%
               \fi
            \fi
         \fi
      \end{tabularx}\smallskip\par
   \endgroup
   % update the point macros for the next round
   \expandafter\let\csname\fancy@current@task@formula\endcsname\@empty\relax
   % initialize the subtask count storage
   \expandafter\def\csname\fancy@current@task@subtask\endcsname{0}%
   % reduce the width of an task
   \begin{enumerate}[leftmargin=10\p@,rightmargin=20\p@]
		\item[]\relax
}

\fancy@make@cmd{subtaskpointwidth}{9mm}
\fancy@make@cmd{subtaskpointheight}{7.33mm}
\fancy@make@cmd{exampointwidth}{9mm}
\fancy@make@cmd{exampointheight}{9mm}

\fancy@make@cmd{subtaskname}{Teilaufgabe}
\appto\extrasngerman{\let\subtaskautorefname\fancy@@subtaskname}

% create a points-padding for a subtask
% #1 number of points for the subtask (if it is a floating point, it must be given with a dot/period, not a comma)
\def\fancy@subtask#1{%
   \refstepcounter{subtask}%
   \let\@currentname\fancy@@subtaskname\relax
   \let\@currentlabel\thesubtask\relax
   % if the current subtask formula is empty, we just add the given points, otherwise, we precede it with a plus sign
   \expandafter\ifx\csname\fancy@current@task@formula\endcsname\@empty
      \csgdef\fancy@current@task@formula{#1\fancy@pt}%
   \else
      \csgappto\fancy@current@task@formula{+\space#1\fancy@pt}%
   \fi
}

% TODO: use pgf directly for the node instead of the tikz layer?
\if@fancy@rounded@support@
   \def\fancy@box#1{%
      \tikz[baseline={(@.base)}]{\node[rounded corners=3\p@,draw,line width=\fboxrule,inner sep=\fboxsep] (@) {#1};}%
   }
\else
   \let\fancy@box\fbox
\fi

% place a marker into the margin
\ifsolution
   \def\fancy@subtask@marker#1{\marginnote{\tiny\bfseries\solutionstyle#1 Punkt\ifdim#1\p@=\p@\else e\fi}}
\else
   \def\fancy@subtask@marker#1{%
      \ifdim#1\p@=\z@\relax\else
      \marginnote{\fboxsep=.5\p@
         \fancy@box{%
            \begin{minipage}[b][\fancy@@subtaskpointheight]{\fancy@@subtaskpointwidth}
               \raggedleft\tiny\bfseries/#1\relax
            \end{minipage}~\strut
         }%
      }\fi
   }
\fi

% #1 box configuration, #2 content
\def\fancy@task@point@marker@{%
   % total points of task
   \fancy@get@points@of@task\fancy@result{\arabic{task}}
   \ifdim\fancy@result\p@=\z@\relax\else
   \marginnote{\fboxsep=.5\p@\relax\fboxrule=1.66\p@
      \smash{\raisebox{.5\height}{\fancy@box{%
         \begin{minipage}[b][\fancy@@exampointheight]{\fancy@@exampointwidth}
            \raggedleft\tiny\bfseries/\fancy@result\relax
         \end{minipage}~\strut
      }}}%
   }\fi
}%

% by default we clear the page and write the total number of pages in the margin
% for the solution, we do not want point marker
\ifsolution
   \fancy@make@cmd{endoftask}{\clearpage\rfoot{}}
\else
   \fancy@make@cmd{endoftask}{%
      \rfoot{\fancy@task@point@marker@}%
      \clearpage
      \rfoot{}%
   }
\fi

% at the end of the task we persist the formula to calculate the points for this task (to present to the students)
% and the number of subtasks
% please note, that we name this `endfancy@task` to be theoretically compatible with the latex environments
% to be used as `\begin{task} ... \end{task}`
\def\endfancy@task{%
   \end{enumerate}%
   % define the expected points first if none given
   \ifnum\value{subtask}=\z@\relax
      \ifcsname fancy@current@task@expected@points\endcsname
         \expandafter\def\csname\fancy@current@task@formula\endcsname{\fancy@current@task@expected@points\fancy@pt}%
      \fi
   \fi
   \expandafter\fancy@persist\fancy@current@task@formula=\csname\fancy@current@task@formula\endcsname;%
   \expandafter\fancy@persist fancy@task@\arabic{task}@subtaskcount=\arabic{subtask};%
   % every task gets it's own page
   \fancy@@endoftask
}

% at the end of the document we must persist all counts for the next round!
\AtEndDocument{%
   \fancy@persist fancy@tasks@totalcount=\arabic{task};%
}

% sp cover page points table =============================================

% this iterates from 1 to the total number of tasks using an increment
% of 1 and executes #1 with `\i` set to the current step.
\def\fancy@points@iter#1{%
   % if life gives you do-while, but you want while-do, make lemonade!
   \ifnum\fancy@tasks@totalcount>\z@
      \begingroup
         \count@=\z@
         \loop
            \advance\count@ by\@ne\relax
            \edef\i{\the\count@}%
            #1%
         \ifnum\count@<\fancy@tasks@totalcount\repeat
      \endgroup
   \fi
}

\def\fancy@hyperto@do{\hyperref[\fancy@hyperto]}
% #1 link target to ref everything to, if empty we do not link
% #2 symbol/string to place at the top
% #3 symbol/string to place at the bottom
\def\fancy@points@row@entry#1#2#3{%
   \def\fancy@hyperto{#1}\ifx\@empty\fancy@hyperto\else\expandafter\fancy@hyperto@do\fi
   {\parbox\linewidth{%
      \Large\strut#2\strut\\[2.25ex]
      \hbox{\footnotesize\strut#3\strut}%
   }}%
}

\def\fancy@pointstable@last@wrapper#1{
\multicolumn{\fancy@total@columns}{|c|}{{\LARGE\strut}\let\and\qquad#1}\\[4\p@]\hline}

\def\nachkorrektur{Einsichtnahme $\bigcirc$ mit / $\bigcirc$ ohne Nachkorrektur}

\def\notenbonus{$\bigcirc$ mit / $\bigcirc$ ohne Notenbonus}

\def\fancy@pointstable@last{}
\def\addtopointstable#1{%
   \appto\fancy@pointstable@last{\fancy@pointstable@last@wrapper{#1}}%
}

\def\printpoints#1{von #1}

\fancy@make@cmd{pointstable}{%
\fancy@tablereset
% additionally, we need two columns for the total sum of points and the grade
\edef\fancy@total@columns{\the\numexpr\fancy@tasks@totalcount+2}%
% to calculate the sum of all points
\def\fancy@total{0}%
% we define the header of the line to enter the points and the fields for the correctors
\def\fancy@numbers{}\def\fancy@correctors{}%
\fancy@points@iter{%
   \fancy@get@points@of@task\fancy@result{\i}%
   \xappto\fancy@numbers{\noexpand\fancy@points@row@entry{fancy@@ex:\i}{\i}{\printpoints{\fancy@result}} & }%
   \xdef\fancy@total{\expandafter\strip@pt\dimexpr\fancy@total\p@+\fancy@result\p@}%
   \xappto\fancy@correctors{&}%
}%
\begin{tabularx}{\linewidth}{|*{\fancy@tasks@totalcount}{X|}X||p{3.5em}|}
   \hline
   \multicolumn{\fancy@total@columns}{|c|}{{\LARGE\strut}\textit{Punkteverteilung}}\\
   \hline
   \fancy@numbers \fancy@points@row@entry\@empty{$\sum$}{\printpoints{\fancy@total}} & \fancy@points@row@entry\@empty{{\LARGE\strut}\textbf{Note}}{} \\ \hline
   \rule\z@{2\ht\strutbox}\fancy@correctors & \tiny Korrektur\\ \hline
   \fancy@pointstable@last
\end{tabularx}%
}


\fancy@make@cmd{titleandlogo}{%
\rlap{\smash{\fancy@@logoline}}%
   \begingroup
      % this is somewhat historically grown from a time in which the logo had
      % its own line
      \rlap{\parbox\linewidth{%
         \parbox{\dimexpr\linewidth-\fancy@@logowidth-1cm}{%
            \raggedright
            \fancy@@examlineA\\[5\p@]
            \fancy@@examlineB\\[1ex]
            \fancy@@whenline}%
      }}%
   \endgroup
}

\fancy@make@cmd{dateandmeta}{%
   % date and time -------------------------------------------------------
   \vskip2.5em\par\begingroup
      \strut\hfill\fancy@@examdateline\hfill\fancy@@examdurationline\hfill\strut
   % examiner/institute line ---------------------------------------------
   \endgroup\vskip2em\par\begingroup
      \parbox[t]{.5\linewidth}{\fancy@@examinerline}\hfill%
      \parbox[t]{.45\linewidth}{\raggedleft\fancy@@instituteline}%
}

% the sp cover page ======================================================

\fancy@make@cmd{codewordtext}{%
   \item Die Angabe eines Codewortes (rechts) ermöglicht es Ihnen, Ihr Ergebnis anonym und vorzeitig über Moodle zu erfahren. 
}

\fancy@make@cmd{coverpage@exam}{%
\begin{center}
   \parskip\z@\relax\parindent\z@\relax
   % header --------------------------------------------------------------
   \fancy@@titleandlogo
   \fancy@@dateandmeta
   % student data table --------------------------------------------------
   \endgroup\vskip2em\par\begingroup
      \fancy@@studentdatatable
   % hints ---------------------------------------------------------------
   \endgroup\vfill\par\begingroup
   \begin{minipage}{\linewidth}
      \fancy@@hintstitle\\
      % we store the hints in a box to calculate the height to align the image
      \setbox0=\hbox{\parbox[c]{.48\linewidth}{%
         \small\begin{itemize}
            \fancy@@hints
         \end{itemize}
      }}%
      \usebox0\relax
   % cover image ---------------------------------------------------------
      \hfill\begin{minipage}[c][\dimexpr\ht0+\dp0][c]{\dimexpr70mm+2\fboxsep}
         \if@fancy@codeword@
         \begingroup\fboxrule1.75pt\relax
         \fbox{\begin{minipage}[t][16mm][t]{70mm}
            \strut\fancy@@codeword\\\hfill
            \rule[-6mm]{\linewidth}{.5\p@}
         \end{minipage}}\par\vspace*{2em}\par
         \endgroup\fi
         \hfill% \fboxsep=0pt is to be done with the image if desired
         \fancy@@coverimage\bigskip\par
         \fancy@@additionalpaper
     \end{minipage}%
   \end{minipage}
   \vfill
   % points --------------------------------------------------------------
   \fancy@@pointstable
   \endgroup
\end{center}%
}


\fancy@make@cmd{coverpage@solution}{%
\begin{center}
   \parskip\z@\relax\parindent\z@\relax
   \fancy@@titleandlogo
   \fancy@@dateandmeta
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
   \fancy@make@cmd{coverpage}{\fancy@@coverpage@solution}
\else
   \fancy@make@cmd{coverpage}{\fancy@@coverpage@exam}
\fi

\def\maketitle{%
   \newgeometry{top=1cm,bottom=1cm,left=2cm,right=2cm,ignorehead}%
   \thispagestyle{empty}%
   \fancy@@coverpage
   \restoregeometry\newpage
}

% solution colors ========================================================

\colorlet{fancy@solution@color}{cyan!80!purple}
\def\SolutionColor#1{\colorlet{fancy@solution@color}{#1}}
\def\solutionstyle{\color{fancy@solution@color}}

% code support ===========================================================

\fancy@make@cmd{outputdir}{./}

\if@fancy@code@support@

\IfFileExists{minted2.sty}{%
\typeout{Load minted3 compatibility setup}
\RequirePackage{minted2}
}{}
\PassOptionsToPackage{outputdir=\fancy@@outputdir}{minted}
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
\def\fancy@new@mintinline#1->#2\@nil{%
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
   \expandafter\fancy@new@mintinline\lang\@nil
}

\typeout{Load code setup}
\ifsolution
   \usemintedstyle{tango}
\else
   \typeout{Load code setup}
   % we avoid colors in the exam
   \usemintedstyle{bw}
\fi
\def\theFancyVerbLine{\sffamily\textcolor{gray}{\scriptsize\arabic{FancyVerbLine}}}

\fi

% user commands for tasks ============================================

% #1: you can give the points here directly, if the task has subtasks,
%     they must sum up to this number
% #2: name of the task
\newenvironment{task}[2][]{\begingroup
   % test if the optional argument is given
   \edef\@tmp{#1}\ifx\@tmp\@empty\else
      % we have to get exactly these points!
      \def\fancy@current@task@expected@points{#1}%
   \fi
   \fancy@task{#2}%
}{\endfancy@task\endgroup\bigskip}

% #1: number of points
\def\Subtask{\@ifstar\fancy@Subtask@star\fancy@Subtask@}
\def\fancy@Subtask@star#1{\strut\fancy@subtask{#1}}
\def\fancy@Subtask@#1{\strut\fancy@subtask{#1}\fancy@subtask@marker{#1}}

\setbox0=\hbox{$\bigcirc$}
\newdimen\fancy@square@size
\fancy@square@size=\dimexpr.95\wd0-.5\p@
\def\fancy@bigsquare{{\fboxsep\z@\raisebox{-.15\height}{\fancy@box{\rule\fancy@square@size\z@\relax\rule\z@\fancy@square@size}}}}
\newlist{radioboxes}{itemize}{1}
\newlist{checkboxes}{itemize}{1}

\def\fancy@place@solution@cross#1{\hbox{\setbox0=\hbox{#1}\clap{\raisebox{-.215\height}{\scalebox{2.25}{\solutionstyle$\times$}}}\clap{\copy0}\kern.5\wd0}}

\fancy@make@cmd{radioboxlabel}{$\bigcirc$}
\fancy@make@cmd{checkboxlabel}{\fancy@bigsquare\kern\p@\relax}
\ifsolution
      \fancy@make@cmd{radioboxcorrectlabel}{\fancy@place@solution@cross{\fancy@@radioboxlabel}}%
      \fancy@make@cmd{checkboxcorrectlabel}{\fancy@place@solution@cross{\fancy@@checkboxlabel\kern-\p@\relax}\kern\p@\relax}%
\else
      \fancy@make@cmd{radioboxcorrectlabel}{\fancy@@radioboxlabel}%
      \fancy@make@cmd{checkboxcorrectlabel}{\fancy@@checkboxlabel}%
\fi

\setlist[checkboxes,radioboxes]{itemsep=2\p@\@plus1\p@\@minus1\p@}
\setlist[radioboxes]{%
   label=\fancy@@radioboxlabel,
   first*=\def\correct{\item[\fancy@@radioboxcorrectlabel]}%
}
\setlist[checkboxes]{
   label=\fancy@@checkboxlabel,
   first*=\def\correct{\item[\fancy@@checkboxcorrectlabel]}%
}

% #1 height
% #2 depth offset
\def\fancy@custom@hrulefill#1#2{%
   \leavevmode\leaders\hrule\@height#1\@depth\dimexpr#2-#1\hfill\kern\z@
}
\def\fancy@vertical@hrulefill{\fancy@custom@hrulefill{.7ex}{.5pt}}

\newenvironment{solutionbox}{\begingroup\par
\solutionstyle\parbox{1cm}{\fancy@vertical@hrulefill}~\textbf{Lösung:}~\fancy@vertical@hrulefill\par}{\parskip\z@\nopagebreak\par\nopagebreak\fancy@vertical@hrulefill\nopagebreak\endgroup\par\medskip}

\newenvironment{solution}{\solutionshowenv\solutionbox}{\endsolutionbox\endsolutionshowenv}

\newenvironment{correctionbox}{\begingroup\par
\solutionstyle\parbox{1cm}{\fancy@vertical@hrulefill}~\textbf{Korrekturhinweis:}~\fancy@vertical@hrulefill\par
}{\parskip\z@\nopagebreak\par\nopagebreak\fancy@vertical@hrulefill\nopagebreak\endgroup\par\medskip}

\newenvironment{correction}{\correctionshowenv\correctionbox}{\endcorrectionshowenv\endcorrectionbox}

% we use this to strut space for students to write one
\def\StudentStrut{\rule[-2.5\dp\strutbox]{0pt}{3\ht\strutbox}}

\newdimen\fancy@lines@space \fancy@lines@space=1cm
\newdimen\fancy@lines@width \fancy@lines@width=.42\p@
\def\IndentGuidesDistance#1{\setlength\fancy@lines@space{#1}}

\colorlet{fancy@lines@color}{gray!80!white}
\def\IndentGuidesColor#1{\colorlet{fancy@lines@color}{#1}}
% used below to create multiple lines
\def\fancy@lines@rule#1{\color{fancy@lines@color}\rule\fancy@lines@width{#1}\hspace*{\fancy@lines@space}}

\newcounter{fancy@example}% used to uniquely identify an
\newcounter{fancy@count}  % temporary count
\def\fancy@example@id{fancy@example@\arabic{fancy@example}@count}
\newenvironment{examples}[1][\textbf{Beispiel\ifnum\examplescount>1 e\fi:}]{%
   \begingroup\parskip=\medskipamount
   \par\noindent
   \setcounter{fancy@count}{0}%
   \stepcounter{fancy@example}%
   \def\examplescount{0}%
   \ifcsname\fancy@example@id\endcsname\edef\examplescount{\csname\fancy@example@id\endcsname}\fi
   % automatic use plural if more than one example
   #1\vspace*{-\parskip}
   \begin{itemize}[nosep,first*=\preto\item{\stepcounter{fancy@count}}]%
}{%
   % persist the number of examples
   \fancy@persist\fancy@example@id=\arabic{fancy@count};%
   \end{itemize}\endgroup
}

% #1 is the number of lines, #2 is the height using arbitrary units
\newcommand*\IndentGuides[2][5]{\begingroup
   \@tempcnta\z@%
   % your average for i loop
   \loop
      \fancy@lines@rule{#2}%
      \advance\@tempcnta by\@ne\relax
      \ifnum\the\@tempcnta<#1\relax
   \repeat
\endgroup}

% this is a classic number check which checks if #1 is a number with now additional fluff
% (e.g., no space, units...) and if so, executes #2, otherwise #3
\def\fancy@isnum#1#2#3{%
  \if!\ifnum9<1#1!\fi
     #2\relax
  \else#3\fi}

% cares for the width
\def\fancy@studentline@wrap#1{\def\@tempa{#1}\ifx\@tempa\@empty\else\expandafter\fancy@studentline@wrap@active\fi}
\def\fancy@studentline@wrap@active{\parbox[t]{\@tempa}}

\ifsolution
   % a simple environment to wrap the actual solution and correction
   \includeversion{solutionshowenv}
   % #1 holds the solution that we want to be there
   \newcommand*\StudentLine[2][]{\fancy@studentline@wrap{#1}{\StudentStrut{\rlap{\solutionstyle#2}\color{gray}\hrulefill}}}
   % #1 relative weight of the space if you place multiple
   % the space is only active in the task mode
   \newcommand*\VerticalSpace[1][]{\vspace*{\z@}}
\else
   \excludeversion{solutionshowenv}
   \newcommand*\StudentLine[2][]{\fancy@studentline@wrap{#1}{\StudentStrut{\hrulefill}}}
   \newcommand*\VerticalSpace[1][1]{%
      \fancy@isnum{#1}{\vspace*{\z@\@plus#1fill}}{\vspace*{#1}}%
   }
\fi

\ifcorrection
   \includeversion{correctionshowenv}
\else
   \excludeversion{correctionshowenv}
\fi
