# The SP exam template

This is the exam template of the _Institute of Software Engineering and Programming Languages_ at the University of Ulm, composed in the single file [_sp-exam.cls_](sp-exam.cls) (supplementary images are located in [_img/_](img/)).
It is currently in its draft phase and open for comments. See the [CHANGELOG.md](CHANGELOG.md) for a list of changes.

- [The SP exam template](#the-sp-exam-template)
  - [Quickstart Guide](#quickstart-guide)
  - [What This Template Offers](#what-this-template-offers)
    - [Class Options](#class-options)
    - [Configuring the Exam](#configuring-the-exam)
  - [More Nice Things](#more-nice-things)

## Quickstart Guide

There are just a handful of steps required to get started.

**TODO**. See [the example exam](_main.tex) for now.

## What This Template Offers

### Class Options

Essentially, there are three main modes that you can load the template with[^1]:

* `\documentclass[exam]{sp-exam}`: This is the default mode. It hides all solutions and additional hints for corrections.
* `\documentclass[solution]{sp-exam}`: This mode shows all solutions.
* `\documentclass[correction]{sp-exam}`: This mode shows all solutions and additional hints for corrections.

Besides the mode, you can pass `code` to automatically set up [_minted_](https://ctan.org/pkg/minted).

Instead of passing the options directly to the document class,
we use `\PassOptionsToClass{exam}{sp-exam}` to pass the options to the document class (this simplifies the files that we create per-mode).

### Configuring the Exam

There are plenty of configuration options, but only a few of them are required (and if you fail to provide them, displayed quite prominently in the layout and shown as warnings).

## More Nice Things

* Wem alles zu langsam geht: wir unterstützten latex formats

   ```shell
   $ etex -ini -initialize -save-size=20000 -stack-size=20000 -jobname="sp-class-exam-fmt" "&pdflatex" mylatexformat.ltx """exam.tex"""

   $ pdflatex -jobname exam -fmt sp-class-exam-fmt --shell-escape _main.tex
   ```

[^1]: In theory, you can simply create your _own_ mode by defining `\spexammode` with a value of your choice. If this mode should be a solution mode, you should add it to `\sp@modes@show@solutions` as well.
