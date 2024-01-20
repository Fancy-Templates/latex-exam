# The SP exam template

This is the exam template of the _Institute of Software Engineering and Programming Languages_ at the University of Ulm, composed in the single file [_sp-exam.cls_](sp-exam.cls) (supplementary images are located in [_img/_](img/)).
It is currently in its draft phase and [open for comments](#open-discussion-points). See the [CHANGELOG.md](CHANGELOG.md) for a list of changes.

- [The SP exam template](#the-sp-exam-template)
  - [Quickstart Guide](#quickstart-guide)
    - [General Information](#general-information)
  - [What This Template Offers](#what-this-template-offers)
    - [Class Options](#class-options)
    - [Configuring the Exam](#configuring-the-exam)
    - [Basic Document Structure](#basic-document-structure)
    - [A First Exercise](#a-first-exercise)
      - [Solutions](#solutions)
      - [Radio- and Checkboxes](#radio--and-checkboxes)
      - [Free-Text Answers and Spacing](#free-text-answers-and-spacing)
      - [Lines for Student Code](#lines-for-student-code)
      - [Code Presentation](#code-presentation)
      - [Free-Form Subtasks](#free-form-subtasks)
    - [Outsourcing Exercises](#outsourcing-exercises)
    - [Exam Modes](#exam-modes)
      - [Conditional Content](#conditional-content)
  - [Open Discussion Points](#open-discussion-points)
  - [More Nice Things](#more-nice-things)

## Quickstart Guide

There are just a handful of steps required to get started.

**TODO**. See [the example exam](exam.tex) or [inspect the output](https://spgit.informatik.uni-ulm.de/teaching/templates/exam/-/jobs/artifacts/main/browse?job=build-pdf) for now.

### General Information

- The template requires _two_ compilations to correctly calculate all points
- For each desired version (exam, solution, correction), you need to create a separate file (see [exam modes](#exam-modes) for more information on the modes) like this, but can make `exam.tex` the default one:

   ```latex
   \PassOptionsToClass{solution}{sp-exam}
   \input{exam.tex}
   ```

- This repository contains a [_.latexmkrc_](.latexmkrc) file that can be used with [`latexmk`](https://ctan.org/pkg/latexmk/).
- You can naturally label and reference exercises and (sub-)tasks using `\label{<name>}` and `\ref{<name>}`/`\autoref{<name>}`.
- The layout is currently designed for exams in German.

## What This Template Offers

### Class Options

Essentially, there are three main modes that you can load the template with[^1]:

- `\documentclass[exam]{sp-exam}`: This is the default mode. It hides all solutions and additional hints for corrections.
- `\documentclass[solution]{sp-exam}`: This mode shows all solutions.
- `\documentclass[correction]{sp-exam}`: This mode shows all solutions and additional hints for corrections.

Besides the mode, you can pass `code` to automatically set up [_minted_](https://ctan.org/pkg/minted) and `rounded` to use rounded boxes instead of the default ones (this, however, loads [_TikZ_](https://ctan.org/pkg/pgf)).

Instead of passing the options directly to the document class,
we use `\PassOptionsToClass{exam}{sp-exam}` to pass the options to the document class (this simplifies the files that we create per-mode).

### Configuring the Exam

There are plenty of configuration options, but only a few of them are required (and if you fail to provide them, they are displayed quite prominently in the layout and shown as an error).
We show example definitions for all required options below:

```latex
\examnumber{1}                                % first exam, second, ...?
\examname{Funktionale Programmierung}         % name of the exam/lecture
\examiner{Florian Sihler, Alexander Raschke}  % name of the examiner(s)

\semester{Winter}                             % summer or wintersemester?
\year{2023/24}                                % year of the semester
\date{12. März 2024}                          % date of the exam
\time{9:00 Uhr}                               % time of the exam
\duration{90}                                 % allowed duration in minutes

% information regarding the permitted material
\permittedmaterial{\allowhandwrittensheet}
% alternatively: \allowcheatsheet, \allownothing, or free text
```

Besides these, there are probably just two more options that you are potentially interested in:

```latex
% This allows to add more information to the cover page
\morehints{
   \item Consider to avoid cheating, please!
}
% this allows to set the given image inside the stamp rectangle on the cover page
\framedcoverimage{img/nilpferd}
```

If you _really_ want to know about what you can configure besides that, you can take a look at the [source code](sp-exam.cls). Every `\sp@make@cmd{<name>}{<default value>}` indicates a configuration option that you can set via `\<name>{<new value>}`. For example, you can overwrite the institute like this:

```latex
\institute{Fluffy Penguins Research Center}
```

If you want to forbid the students to remove the additional sheets (if there are any), you can use:

```latex
\additionalsheets{Die Zusatzblätter dürfen \textbf{nicht} herausgelöst werden.}
```

### Basic Document Structure

After [loading the class](#class-options) and [configuring the exam](#configuring-the-exam), your document may have the following basic structure:

```latex
\begin{document}
   % Typeset the coverpage
   \maketitle

   % ... (exercises)

   % This is optional and only required if you have additional pages.
   % For example, to repeat definitions.
   \appendix

   % ... (optional additional pages)
\end{document}
```

### A First Exercise

Most of the time you are probably fine with one of the following two forms. You can create an exercise with a single task (i.e., no subtasks) like this:

```latex
% This exercise has 7 points
\begin{exercise}[7]{Eine interessante Aufgabe}
   Eine interessante Aufgabenbeschreibung
   % ... (solutions)
\end{exercise}
```

If you want subtasks, you can drop the optional argument and use the `tasks` environment, which allows you to specify the points for each subtask (calculating the total number of points automatically along the way):

```latex
\begin{exercise}{Eine interessante Aufgabe}
   Eine interessante Aufgabenbeschreibung
   \begin{tasks}
      \task{1} Eine Teilaufgabe
      % ... (solutions)
      \task{2} Eine weitere Teilaufgabe
      \task{4} Eine letzte Teilaufgabe
   \end{tasks}
\end{exercise}
```

#### Solutions

See [conditional content](#conditional-content) for how to present solutions.

#### Radio- and Checkboxes

If your task requires a radio- or checkbox, you can use the following environments. Within them `\correct` can be used to mark the respective (correct) answer(s):

```latex
\begin{radioboxes}
   \item    Antwortmöglichkeit 1
   \item    Antwortmöglichkeit 2
   \correct Antwortmöglichkeit 3
   \item    Antwortmöglichkeit 4
\end{radioboxes}

\begin{checkboxes}
   \correct Antwortmöglichkeit 1
   \item    Antwortmöglichkeit 2
   \correct Antwortmöglichkeit 3
   \correct Antwortmöglichkeit 4
\end{checkboxes}
```

#### Free-Text Answers and Spacing

The `\VerticalSpace` inserts effectively a `\vfill` in the exam mode (and therefore just creates blank vertical space for the students to write). An optional argument allows to (relatively) weigh the space against other `\VerticalSpace` commands. For example, if you use `\VerticalSpace[2]` and `\VerticalSpace`, the first one will be twice as large as the second one.

For a fill-in-the-blank answer, the `\StudentLine{<solution>}` macro will effectively use the remaining space on a line (use `\parbox{<width>}{\StudentLine{<solution>}}` to limit the width) and set a placeholder for the student to write in. The given solution is added in the solution mode.

#### Lines for Student Code

You can use the `\IndentGuides{<height>}` macro to create vertical lines (of length `<height>`) as indent guides. For example `\IndentGuides{5cm}` creates 5cm long lines.
You can use an optional argument if you are not satisfied with the number of lines presented. So `\IndentGuides[4]{5cm}` creates 4 lines of 5cm length.
The default distance can be changed with `\IndentGuidesDistance{<distance>}`.

#### Code Presentation

If you pass the document-class option `code` to the `sp-exam` class, it will set up `minted` for you. Now, you can use `minted` to present code to your liking:

```latex
\begin{minted}{java}
public class HelloWorld {
   public static void main(String[] args) {
      System.out.println("Hello World!");
   }
}
\end{minted}
```

As an optional argument, you can (next to all the other keys known from `minted`) pass `numbered` to get indented line numbers (`numbered` accepts an argument which controls the amount of the indent):

```latex
% or \begin{minted}[numbered=2em]{java}
\begin{minted}[numbered]{java}
public class HelloWorld {
   public static void main(String[] args) {
      System.out.println("Hello World!");
   }
}
\end{minted}
```

#### Free-Form Subtasks

Besides the `tasks` environment, you can use `\Subtask{<points>}` to create a subtask with a given number of points. The starred version `\Subtask*{<points>}` does not add a points box in the margin and therefore (theoretically) allows you to layout your exercise freely.

### Outsourcing Exercises

We recommend, that you create a separate file for each exercise, including it using `\input{<filename>}` or `\include{<filename>}`.
This not only allows easier re-use and -order exercises but also keeps the [main](exam.tex) file clean and readable.

### Exam Modes

Even though we allow for a lot of flexible constructs behind the scenes, you are probably fine with using only two environments.

***The begin and end markers for these environments must be given in their OWN line, without any leading whitespace. If, for whatever reason, you dislike that, see [conditional content](#conditional-content) for an alternative.***

```latex
\begin{examonly}
   Dieser Text erscheint nur in der Klausur, nicht in den Lösungen.
\end{examonly}

\begin{solution}
   Dieser Text erscheint nur in den Lösungen, nicht in der Klausur (zudem wird er hier in einen entsprechenden Block gefasst).
\end{solution}
```

These environments work with `minted` as well.

#### Conditional Content

At its core, you can use `\ifinmode{<modelist>} ... \else ... \fi` to conditionally insert content into the document:

```latex
\ifinmode{solution}
   Dieser Text erscheint nur in den Lösungen, nicht in der Klausur.
\else
   Dieser Text erscheint in allen anderen Modi.
\fi
```

So, `examonly` is just a shorthand for `\ifinmode{exam} ... \fi` and `solution` can be written like this:

```latex
\ifinmode{solution,correction}
   \begin{solutionbox}
      Dieser Text erscheint nur in den Lösungen, nicht in der Klausur (zudem wird er hier in einen entsprechenden Block gefasst).
   \end{solutionbox}
\fi
```

## Open Discussion Points

- [ ] How should we style the point boxes/solution blocks
- [ ] Are there other modes required/desired (in FP we had "supersize")
- [ ] Should we reduce the ways to check for a given mode. For example, we could allow for multiple modes to be active (`correction` and `solution`) so that everything is `\ifinmode{solution} ... \fi`.
- [ ] Should there be compatibility modes for old exam templates?
- [ ] What _code_ environments do we want (e.g., one with line numbers and a frame, space for the students with vertical lines)
- [ ] Do we want unified language setups for prolog, haskell, java, typescript, ...? (some exams use `\java`, ...)
- [ ] What kind of "workflow" do we want to setup the exam? (e.g., a template repository so that each exam will be a new repository in the respective group of the lecture, should the uulm logos be included in the `.cls` so that it is only one file to copy/include as a submodule/...)
- [ ] Should we force an exam structure (e.g., force to outsource exercises)
- [ ] Should there be more predefined/additional macros (e.g. for the creation of tables, usage with tikz-externalize, ...)
- [ ] Should we provide a makefile/bash script (which can replace the need for separate `.tex` files for each version)
- [ ] Do we want more additional hints for the permitted material? How should they be worded?
  - Sie dürfen ein beidseitig, handbeschriebenes DIN-A4-Blatt verwenden.
  - Sie dürfen das Cheat-Sheet der Veranstaltung mit handschriftlichen Ergänzungen verwenden.
  - Es sind keine Hilfsmittel erlaubt.
- [ ] Do we really want to enforce 50% transparency for the "Siegelkasten"
- [ ] Do we want the alternatives:
   > Für einen Abschnitt kann immer eine Gesamtpunktezahl angegeben werden, die ggf. gegen die errechnete Gesamtpunktezahl aus den Aufgaben geprüft wird.

## More Nice Things

If compilation is too slow for you, you can create a format file and use that instead:

```shell
$ etex -shell-escape -ini -initialize -save-size=20000 -stack-size=20000 -jobname="sp-class-exam-fmt" "&pdflatex" mylatexformat.ltx """exam.tex"""

# issue this twice
$ pdflatex -jobname exam -fmt sp-class-exam-fmt -shell-escape exam.tex
```

You may be able to drop the `-shell-escape` flags (if your exam does not require them).
However, please do not forget to re-create the format file if you change the template or any other configuration in the preamble.

[^1]: In theory, you can simply create your _own_ mode by defining `\spexammode` with a value of your choice. If this mode should be a solution mode, you should add it to `\sp@modes@show@solutions` as well.
