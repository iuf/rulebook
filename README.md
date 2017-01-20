# IUF Rulebook

[![Build Status](https://travis-ci.org/iuf/rulebook.svg?branch=2017_draft)](https://travis-ci.org/iuf/rulebook)

The rulebook is written in LaTeX and version controlled with git. Find out more about the [Technology](https://github.com/iuf/rulebook/wiki/Technology).

We also have some [Working Guidelines](https://github.com/iuf/rulebook/wiki).

## Automatic Compiling with Travis CI
All commits push to Github are automatically complied with [Travis CI](https://travis-ci.org/iuf/rulebook).

The output files can be found at **unicycling.org/files/temp/upload/iuf-rulebook-$$$.pdf**.
The `$$$` varies depending on the branch and diff-branches specified.

The current 2017_draft branch produces outputs at: 
https://unicycling.org/files/temp/upload/iuf-rulebook-2017_draft.pdf

With the most recent diff at: 
https://unicycling.org/files/temp/upload/iuf-rulebook-2017_draft-diff-2016_reorg_diff.pdf



## Reporting Issues
If you find an issue or have an idea for improvement, you can directly report it here on GitHub. Here is what you need to do:
* Get a GitHub Account and sign in (https://github.com/)
* Browse to the IUF rulebook repository (https://github.com/iuf/rulebook)
* Click on “Issues” (https://github.com/iuf/rulebook/issues)
* For every issue you want to report, click “New Issue” (https://github.com/iuf/rulebook/issues/new)
* Enter a title and a description and click “Submit new issue”

## Building the Rulebook

### Requirements

* A latex distribution supporting **pdflatex** with many common packages installed (for example **texlive** with **texlive-latex-extra** on debian based systems like Ubuntu). In addition, the following packages/scripts are required and can be found in the `dependencies` directory:
 * gitinfo
 * latexdiff (with latexdiff-so and latexdiff-vc)

### Building

Open a terminal in the repository root and type **make rulebook**. This will generate **pdf/iuf-rulebook-$BRANCHNAME.pdf**.

To include git revision information in the document, you need to install git hooks to extract the information from git.
Do this with **./install_hooks**. Build the document again and the information should appear.

To produce a PDF highlighting the changes, type **make diff**.
This will generate **pdf/iuf-rulebook-$OLDBRANCH-diff-$BRANCH.pdf**.
The current branch will be combpared with the branch(es) in the `diff-branches` file.

### Gitinfo package  
If the build is failing because the gitinfo2 package cannot be found, copy the `gitinfo2.sty` from `dependencies` into the `src` directory.
