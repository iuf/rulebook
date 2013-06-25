# IUF Rulebook

The official IUF Rulebook

## Building the Rulebook

### Requirements

* A latex distribution supporting **pdflatex** with the following packages installed (for example **texlive** with **texlive-latex-extra** on debian based systems like Ubuntu.):
 * inputenc
 * fontenc
 * lmodern
 * minitoc
 * hyperref
 * enumitem
 * graphicx
 * wrapfig
 * longtable
 * gitinfo
* To produce a colored PDF marking the changes: **latexdiff** and **rcs-latexdiff** (https://github.com/driquet/rcs-latexdiff)

### Building

Open a terminal in the repository root and type **make**. This will generate **out/iuf-rulebook.pdf**.
Or use your favourite LaTeX editor.

To include git revision information in the document, you need to install git hooks to extract the information from git.
Do this with **./install_hooks**. Build the document again and the information should appear.

To produce a colored PDF marking the changes, type **make diff OLDCOMMIT=2012 NEWCOMMIT=master**.
OLDCOMMIT and NEWCOMMIT can be any git references. This will generate **out/diff.pdf**.
