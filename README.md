# The SP exam template

This is the exam template of the _Institute of Software Engineering and Programming Languages_ at the University of Ulm, composed in the single file [_sp-exam.cls_](sp-exam.cls) (supplementary images are located in [_img/_](img/)).
It is currently in its draft phase and [open for comments](#open-discussion-points). See the [CHANGELOG.md](CHANGELOG.md) for a list of changes.

[[_TOC_]]

## Quickstart Guide

> If you encounter any problem, please write me an [email](mailto:florian.sihler@uni-ulm.de) or open an [issue](https://spgit.informatik.uni-ulm.de/teaching/templates/exam/-/issues/new)!

### Setup Steps

There are just a handful of steps required to get started. You can [inspect the output](https://spgit.informatik.uni-ulm.de/teaching/templates/exam/-/jobs/artifacts/main/browse?job=build-pdf) to see the PDFs produced.

1. Within your repository, navigate to wherever you want to create your exam.\
   The following examples will assume that the folder is empty (but this is not required).

2. <details><summary>Retrieve the respective submodule.</summary>

   - With SSH:

      ```shell
      $ git submodule add git@spgit.informatik.uni-ulm.de:teaching/templates/exam.git template
      ```

   - With HTTPS:

      ```shell
      $ git submodule add https://spgit.informatik.uni-ulm.de/teaching/templates/exam.git template
      ```

   Now, there should be a new folder `template` that contains the exam template:

   ```text
    + /
      | - template/
      |   | - sp-exam.cls
      |   | - ...
   ```

   If you have never worked with [submodules](https://git-scm.com/book/en/v2/Git-Tools-Submodules), cloning with the `--recursive` flag is usually sufficient.

   </details>

   **Note, that for submodules to work, everyone working with your repository must have access to the exam repository. In other words, if you work with students, they require access to the exam template repository as well.**

3. <details><summary> <i>(optional)</i> Create a folder for your first exam (e.g., "exam1").</summary>

   ```shell
   $ mkdir exam1
   ```

   Now, your folder structure should look like this:

   ```text
    + /
      | - exam1/
      | - template/
      |   | - sp-exam.cls
      |   | - ...
   ```

   </details>

   Although this is technically just required if you want to create multiple exams for your lecture, it is probably best to plan ahead.

4. <details><summary> Setup the default exam structure </summary>

   Copy at least `template/exam.tex`, `template/solution.tex`, and `template/correction.tex` to your exam folder (or create them from scratch) as you probably want to modify them anyway.
   Besides, create a new folder `tasks` (or copy the one from the template)

   ```shell
   $ cp template/exam.tex template/solution.tex template/correction.tex exam1/
   $ cp -r template/tasks exam1/
   ```

   If you use `latexmk` you can copy the [_.latexmkrc_](.latexmkrc) file as well.

   Now, your folder structure should look like this:

   ```text
    + /
      | - exam1/
      |   | - tasks/
      |   |   | - ...
      |   | - exam.tex
      |   | - solution.tex
      |   | - correction.tex
      | - template/
      |   | - sp-exam.cls
      |   | - ...
   ```

   </details>

   With this, the main exam lives in the `exam.tex`, while the tasks live in the `tasks` folder. Your exam/project now resides in the `exam1` folder.

5. <details><summary> Configure the exam </summary>

   See [configuring the exam](#configuring-the-exam) for more information on the options.

   Within the `exam.tex`, you first have to include the correct documentclass, by specifying the correct path to the template (which should do most of the magic from there by adding important paths to TeX's default input list (`input@path`)). If you changed nothing in the steps before, the template should check automatically, if `../template/sp-exam.cls` is present. Otherwise, make sure to give the correct relative path here.
   </details>

If you want to just get started, and you are in an empty directory, the following commands should work for you:

```shell
git submodule add https://spgit.informatik.uni-ulm.de/teaching/templates/exam.git template
mkdir exam1
cp template/exam.tex template/solution.tex template/correction.tex exam1/
cp -r template/tasks exam1/
# configure exam1/exam.tex...
```

### General Information

- The template requires _two_ compilations to correctly calculate all points
- For each desired version (exam, solution, correction), you need to create a separate file (see [exam modes](#exam-modes) for more information on the modes) like this, but can make `exam.tex` the default one:

   ```latex
   \PassOptionsToClass{solution}{sp-exam}
   \input{exam.tex}
   ```

- This repository contains a [_.latexmkrc_](.latexmkrc) file that can be used with [`latexmk`](https://ctan.org/pkg/latexmk/).
- You can naturally label and reference tasks and (sub-)tasks using `\label{<name>}` and `\ref{<name>}`/`\autoref{<name>}`.
- The layout is currently designed for exams in German.
- If you want, you can use the [_.gitlab-ci.yml_](.gitlab-ci.yml) file to automatically let the CI build the PDFs of your exam for you.

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
\semesteryear{2023/24}                        % year of the semester
\date{12. März 2024}                          % date of the exam
\starttime{9:00 Uhr}                          % time of the exam
\duration{90}                                 % allowed duration in minutes

% information regarding the permitted material
\permittedmaterial{\allowhandwrittensheet}
% alternatively: \allowcheatsheet, \allownothing, or free text
```

Besides these, there are probably just two or three more options that you are potentially interested in:

```latex
% This allows to add more information to the cover page
\morehints{
   \item Consider to avoid cheating, please!
}
% this allows to set the given image inside the stamp rectangle on the cover page
\framedcoverimage{img/nilpferd}

% allows you to freely add lines to the points table
\addtopointstable{\notenbonus}
% \addtopointstable{\nachkorrektur\and\notenbonus}, \addtopointstable{Intersting free text}
% can be given multiple times if more than one line is desired/required
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

   % ... (tasks)

   % This is optional and only required if you have additional pages.
   % For example, to repeat definitions.
   \appendix

   % ... (optional additional pages)
\end{document}
```

### A First Task

Most of the time you are probably fine with one of the following two forms. You can create an task with a single task (i.e., no subtasks) like this:

```latex
% This task has 7 points
\begin{task}[7]{Eine interessante Aufgabe}
   Eine interessante Aufgabenbeschreibung
   % ... (solutions)
\end{task}
```

If you want subtasks, you can add them like this (see below for [free-form subtasks](#free-form-subtasks)): `

```latex
% \begin{task}[7]{Eine interessante Aufgabe}
\begin{task}{Eine interessante Aufgabe}
   Eine interessante Aufgabenbeschreibung
   \begin{subtasks}
      \subtask{1} Eine Teilaufgabe
      % ... (solutions)
      \subtask{2} Eine weitere Teilaufgabe
      \subtask{4} Eine letzte Teilaufgabe
   \end{subtasks}
\end{task}
```

You can combine the optional argument with the subtasks as well, as indicated by the comment. In this scenario, the template will automatically check if the sum of the subtasks is equal to the given/expected points (i.e., it issues a warning and provides a visual hint if the points are not equal). Use this as a safeguard if, for whatever reason, a task has to have a fixed number of points.

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
Besides a unit-less number, you can use a unit that TeX can understand to get a fixed space: `\VerticalSpace[2cm]` creates a _2cm_ space.

For a fill-in-the-blank answer, the `\StudentLine{<solution>}` macro will effectively use the remaining space on a line (use `\parbox{<width>}{\StudentLine{<solution>}}` to limit the width) and set a placeholder for the student to write in. The given solution is added in the solution mode.

#### Lines for Student Code

You can use the `\IndentGuides{<height>}` macro to create vertical lines (of length `<height>`) as indent guides. For example `\IndentGuides{5cm}` creates 5cm long lines.
You can use an optional argument if you are not satisfied with the number of lines presented. So `\IndentGuides[4]{5cm}` creates 4&nbsp;lines of 5cm&nbsp;length.
The default distance can be changed with `\IndentGuidesDistance{<distance>}`. The default color can be changed using `\IndentGuidesColor{<color-name>}` (e.g., `\IndentGuidesColor{green}`).

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

Additionally, we provide several inline macros that can be used to write code for common languages:
```latex
\java{System.out.println("Hello Java!");}
\ts{console.log("Hello TypeScript!");}
\js{console.log("Hello JavaScript!");}
\haskell{main = putStrLn "Hello Haskell!"}
\prolog{main :- write('Hello Prolog!'), nl.}
\css{body:before { content: "Hello CSS"; }}
\xml{<hello>XML</hello>}
\html{<html><body>Hello HTML!</body></html>}
```

#### Examples

You can use the `examples` environment to present examples (e.g., for each subtask). The environment will automatically detect the number of examples and use the phrase `Beispiel` or `Beispiele` accordingly (yet, similarly to the point calculation, this requires a second run).

```latex
\begin{examples}
   \item \texttt{1 + 1} sollte \texttt{2} ergeben
   \item \texttt{AnnA} ist ein Palindrom
\end{examples}
```

If you want to have a different text above the list, you can use the optional argument (the number of examples is stored in `\examplescount`):

```latex
\begin{examples}[Hier ein \ifnum\examplescount=1 Beispiel\else paar Beispiele\fi:]
   \item \texttt{1 + 1} sollte \texttt{2} ergeben
   \item \texttt{AnnA} ist ein Palindrom
\end{examples}
```

#### Free-Form Subtasks

Besides the `tasks` environment, you can use `\Subtask{<points>}` to create a subtask with a given number of points. The starred version `\Subtask*{<points>}` does not add a points box in the margin and therefore (theoretically) allows you to layout your tasks freely.

### Outsourcing Tasks

We recommend, that you create a separate file for each task, including it using `\input{<filename>}` or `\include{<filename>}`.
This not only allows easier re-use and -order tasks but also keeps the [main](exam.tex) file clean and readable.

### Exam Modes

Even though we allow for a lot of flexible constructs behind the scenes, you are probably fine with using only two environments.

***The begin and end markers for the `solution` and `correction` environment must be given in their OWN line, without any leading whitespace. If, for whatever reason, you dislike that, see [conditional content](#conditional-content) for an alternative.***

```latex
\ifexam
   Dieser Text erscheint nur in der Klausur, nicht in den Lösungen.
\fi

\begin{solution}
   Dieser Text erscheint nur in den Lösungen, in einer Lösungsbox, nicht in der Klausur (zudem wird er hier in einen entsprechenden Block gefasst). Analog, existiert die `correction` Umgebung.
\end{solution}
```

These environments work with `minted` as well.

#### Conditional Content

There are three switches you can use: `\ifexam`, `\ifsolution`, and `\ifcorrection`, active in the respective modes (keep in mind, that correction implies solution). You can use them like this:

```latex
\ifsolution
   Dieser Text erscheint nur in den Lösungen, nicht in der Klausur.
\else
   Dieser Text erscheint in allen anderen Modi.
\fi
```

#### Changing the Solution-Color

Internally, the color of solution text is guided by `\SolutionColor{<color-name>}`. You can use this to change the color of the solution text (e.g., `\SolutionColor{red}`).
If you, for whatever reason want to mark something as part of the solution, you can use the `\solutionstyle` macro (although this is independent of any `\ifsolution` environment, for flexibility).

## Open Discussion Points

- [ ] How should we style the point boxes/solution blocks

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
