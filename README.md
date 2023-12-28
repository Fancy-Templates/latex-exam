# The SP exam template

Current changes from the draft:

* Ist aktuell eine Dokumentklasse
* Bisher kein Makro um `weiteres` in den Hinweisen zur allgemeinen Beachtung zu setzen
* Andere Abstände (z.B. zwischen dem Bild und der Info über zusätzliches Papier)

* Wem alles zu langsam geht: wir unterstützten latex formats

   ```shell
   $ etex -ini -initialize -save-size=20000 -stack-size=20000 -jobname="sp-class-exam-fmt" "&pdflatex" mylatexformat.ltx """exam.tex"""

   $ pdflatex -fmt sp-class-exam-fmt _main.tex
   ```