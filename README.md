# IUF Rulebook

[![Build Status](https://travis-ci.org/iuf/rulebook.svg?branch=2016_reorg_travis)](https://travis-ci.org/iuf/rulebook)

The rulebook is written in LaTeX and version controlled with git. Find out more about the [Technology](https://github.com/iuf/rulebook/wiki/Technology).

We also have some [Working Guidelines](https://github.com/iuf/rulebook/wiki).

An overview about the current state:
* The old 2012 Rulebook: https://unicycling.org/files/IUF_Rules_2012_english.pdf
* The 2012 Rulebook in the new format: https://unicycling.org/files/iuf-rulebook-2012-new.pdf
* Passed proposals for the 2013 Rulebook: http://rulebook.unicycling.org/proposals/passed
* The current 2013 Rulebook with applied proposals: https://unicycling.org/files/iuf-rulebook-2013.pdf
* A document highlighting the changes: https://unicycling.org/files/iuf-rulebook-diff-2012-2013.pdf

## Reporting Issues
If you find an issue or have an idea for improvement, you can directly report it here on GitHub. Here is what you need to do:
* Get a GitHub Account and sign in (https://github.com/)
* Browse to the IUF rulebook repository (https://github.com/iuf/rulebook)
* Click on “Issues” (https://github.com/iuf/rulebook/issues)
* For every issue you want to report, click “New Issue” (https://github.com/iuf/rulebook/issues/new)
* Enter a title and a description and click “Submit new issue”

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
* To produce a PDF highlighting the changes: [latexdiff](http://latexdiff.berlios.de/) and [rcs-latexdiff](https://github.com/driquet/rcs-latexdiff)

### Building

Open a terminal in the repository root and type **make**. This will generate **out/iuf-rulebook.pdf**.
Or use your favourite LaTeX editor.

To include git revision information in the document, you need to install git hooks to extract the information from git.
Do this with **./install_hooks**. Build the document again and the information should appear.

To produce a PDF highlighting the changes, type **make diff OLDCOMMIT=2012 NEWCOMMIT=master**.
OLDCOMMIT and NEWCOMMIT can be any git references. This will generate **out/diff.pdf**.

# How to compile with Travis
Simply push a commit with a tag. This creates a release at github and then travis automatically compiles the PDF(s) and publishes them with the release.

For example:

    git add -A
    git commit -m "My commit message"
    git tag "test-1"
    git push && git push --tags

The finished released and build can then be found at `https://github.com/iuf/latex-travis-ci/releases/tag/test-1`


Please tag your build with the date and time. For example: `git tag "build-2015.09.05-18.24`

# Gitinfo package  
If the build is failing because the gitinfo2 package cannot be found, copy the `gitinfo2.sty` from `dependencies` into the `src` directory.
