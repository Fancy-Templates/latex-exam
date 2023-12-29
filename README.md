# The SP exam template

This is the exam template of the _Institute of Software Engineering and Programming Languages_ at the University of Ulm, composed in the single file [_sp-exam.cls_](sp-exam.cls) (supplementary images are located in [_img/_](img/)).
It is currently in its draft phase and open for comments. See the [CHANGELOG.md](CHANGELOG.md) for a list of changes.

- [The SP exam template](#the-sp-exam-template)
  - [Quickstart Guide](#quickstart-guide)
    - [General Information](#general-information)
  - [What This Template Offers](#what-this-template-offers)
    - [Class Options](#class-options)
    - [Configuring the Exam](#configuring-the-exam)
    - [Basic Document Structure](#basic-document-structure)
    - [A First exercise](#a-first-exercise)
      - [Solutions](#solutions)
      - [Radio- and Checkboxes](#radio--and-checkboxes)
      - [Free-Text Answers and Spacing](#free-text-answers-and-spacing)
      - [Free-Form Subtasks](#free-form-subtasks)
    - [Outsourcing exercises](#outsourcing-exercises)
    - [Exam Modes](#exam-modes)
      - [Conditional Content](#conditional-content)
  - [More Nice Things](#more-nice-things)

## Quickstart Guide

There are just a handful of steps required to get started.

**TODO**. See [the example exam](_main.tex) for now.

### General Information

- The template requires _two_ compilations to correctly calculate all points
- For each desired version (exam, solution, correction), you need to create a separate file (see [exam modes](#exam-modes) for more information on the modes) like this:

   ```latex
   \PassOptionsToClass{solution}{sp-exam}
   \input{_main.tex}
   ```

- This repository contains a [_.latexmkrc_](.latexmkrc) file that can be used with [`latexmk`](https://ctan.org/pkg/latexmk/).
- You can naturally label and reference exercises and (sub-)tasks using `\label{<name>}` and `\ref{<name>}`/`\autoref{<name>}`.
- The layout is currently designed for exams in german.

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
\permittedmaterial{Sie dürfen ein beidseitig, handbeschriebenes DIN-A4-Blatt verwenden.}
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

### A First exercise

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

#### Free-Form Subtasks

Besides the `tasks` environment, you can use `\Subtask{<points>}` to create a subtask with a given number of points. The starred version `\Subtask*{<points>}` does not add a points box in the margin and therefore (theoretically) allows you to freely layout your exercise.

### Outsourcing exercises

We recommend, that you create a separate file for each exercise, including it using `\input{<filename>}` or `\include{<filename>}`.
This not only allows easier re-use and -order exercises but also keeps the [main](_main.tex) file clean and readable.

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

## More Nice Things

If compilation is too slow for you, you can create a format file and use that instead:

```shell
$ etex -ini -initialize -save-size=20000 -stack-size=20000 -jobname="sp-class-exam-fmt" "&pdflatex" mylatexformat.ltx """exam.tex"""

$ pdflatex -jobname exam -fmt sp-class-exam-fmt --shell-escape _main.tex
```

However, please do not forget to re-create the format file if you change the template or any other configuration in the preamble.

[^1]: In theory, you can simply create your _own_ mode by defining `\spexammode` with a value of your choice. If this mode should be a solution mode, you should add it to `\sp@modes@show@solutions` as well.
