# macOS Local Setup

This is the smallest practical dependency set for building the rulebook locally on macOS.

## Already Present On A Normal Mac

The build scripts use these command-line tools, which are normally provided by macOS, Xcode Command Line Tools, or Homebrew:

- `git`
- `rsync`
- `ed`
- `sed`
- `perl`
- `python3`
- `pip3`

## Required For The English Rulebook

To run:

```sh
make rulebook
```

you need:

- `pdflatex`
- `latexmk`
- the LaTeX packages used by `src/preamble.tex`

The least bulky practical TeX install is BasicTeX plus only the packages this repo uses:

```sh
brew install --cask basictex
eval "$(/usr/libexec/path_helper)"
sudo tlmgr update --self
sudo tlmgr install latexmk latex-bin graphics tools koma-script lm ulem import wrapfig pict2e pgf pgfplots tikz-dimline comment multirow enumitem carlisle minitoc tocloft bookmark hyperref xstring eso-pic
```

If BasicTeX package chasing becomes annoying, use the no-GUI MacTeX distribution instead:

```sh
brew install --cask mactex-no-gui
eval "$(/usr/libexec/path_helper)"
```

That is larger, but still avoids the GUI apps from full MacTeX.

## Required For Diff PDFs

To run:

```sh
make diff
```

you also need:

- `latexdiff`
- `latexdiff-vc`
- access to the branches listed in `diff-branches`

Install the TeX Live package:

```sh
sudo tlmgr install latexdiff
```

The repository includes copies under `dependencies/latexdiff`, but the scripts call `latexdiff-vc` directly, so installing it into the TeX path is simpler for local builds.

## Required For Translated PDFs

To run:

```sh
make translation
```

you also need:

- `po4a`
- `po4a-updatepo`
- `tx`
- a Transifex API token exported as `TRANSIFEX_API_TOKEN`

Install po4a with Homebrew:

```sh
brew install po4a
```

The translation script uses the current Transifex CLI config format, which includes the organization slug. Install the current CLI from Transifex:

```sh
curl -o- https://raw.githubusercontent.com/transifex/cli/master/install.sh | bash
```

Then restart your terminal, or make sure the installed `tx` binary is on your `PATH`.

```sh
tx --version
```

Finally, export the token before running the build:

```sh
export TRANSIFEX_API_TOKEN="..."
make translation
```

## Current Status On This Machine

Checked on macOS 26.4.1:

- Installed: `git`, `rsync`, `ed`, `sed`, `perl`, `python3`, `pip3`, `po4a`, `po4a-updatepo`
- Missing: `pdflatex`, `latexmk`, `tlmgr`, `latexdiff`, `latexdiff-vc`, `latexdiff-so`, `tx`

So the next install steps for this machine are:

```sh
brew install --cask basictex
eval "$(/usr/libexec/path_helper)"
sudo tlmgr update --self
sudo tlmgr install latexmk latex-bin graphics tools koma-script lm ulem import wrapfig pict2e pgf pgfplots tikz-dimline comment multirow enumitem carlisle minitoc tocloft bookmark hyperref xstring eso-pic latexdiff
curl -o- https://raw.githubusercontent.com/transifex/cli/master/install.sh | bash
```

`po4a` is already installed here, so you do not need to reinstall it.
