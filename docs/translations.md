# Translations

The rulebook translation pipeline uses three pieces:

- `po4a` extracts translatable strings from the LaTeX source and later rebuilds translated LaTeX files from PO files.
- The Transifex CLI (`tx`) uploads source POT templates and downloads translated PO files.
- `latexmk` builds the translated LaTeX trees into PDFs.

The main entry point is:

```sh
make translation
```

That target runs `scripts/build/translation.sh`.

## Required Tools

You need the normal rulebook build dependencies plus:

- `po4a`
- Transifex CLI providing the `tx` command
- A Transifex API token in `TRANSIFEX_API_TOKEN`

The existing Travis setup installed `po4a` from apt and installed the older `transifex-client` Python package. For current Transifex projects, use the newer Go-based Transifex CLI. First check which Transifex CLI your project uses by running:

```sh
tx --version
```

The script expects the current CLI configuration format:

```ini
[main]
host = https://app.transifex.com

[o:iuf:p:rulebook-2025:r:general]
source_file = tmp/po/general/template.pot
file_filter = tmp/po/general/<lang>.po
source_lang = en
type = PO
```

## How Source Files Are Created For Transifex

Transifex receives POT template files, not the original `.tex` files. The translation script creates them in `tmp/po`.

For each top-level chapter file in `tmp/src_translation/chapters`, the script:

1. Copies `src` to `tmp/src_translation`.
2. Copies `config/base_strings.tex` to `tmp/src_translation/chapters/00_base_strings.tex`.
3. Rewrites some conditional chapter includes so po4a sees both competitor/organizer/officials text.
4. Prepends `config/po4a-escape.tex`, which teaches po4a about project-specific LaTeX commands and environments.
5. Runs `po4a-updatepo`.

The generated source template for a chapter is:

```text
tmp/po/<chapter-slug>/template.pot
```

For example:

```text
tmp/po/general/template.pot
tmp/po/track_races/template.pot
```

Those `template.pot` files are what `tx push --source` uploads to Transifex as source files.

The Transifex project defaults to:

```text
rulebook-<branch>
```

The Transifex organization defaults to:

```text
iuf
```

You can override either value:

```sh
TRANSIFEX_ORGANIZATION=iuf TRANSIFEX_PROJECT=rulebook-2025 make translation
```

Individual resource names are generated as:

```text
o:<transifex-organization>:p:<transifex-project>:r:<chapter-slug>
```

There is one Transifex resource per chapter. The `master` branch is special-cased to use `2019` as the branch name for Transifex resources. For the `2025` branch, the default project is `rulebook-2025`.

## Transifex Project Setup

Before running `make translation` for a new rulebook year, make sure Transifex has a project whose slug matches the value used by the script.

For the `2025` branch, either:

- Create or use a Transifex project with slug `rulebook-2025`.
- Or point the script at an existing project:

```sh
TRANSIFEX_ORGANIZATION=<organization-slug> TRANSIFEX_PROJECT=<project-slug> make translation
```

The API token must belong to a user who can create or update source files/resources in that project. The command-line client can create missing resources during `tx push`, but it does not create missing projects.

If `tx push --source` prints a large Transifex 404 HTML page followed by:

```text
tx ERROR: Request Forbidden
tx ERROR: Could not upload source file.
```

check these first:

- The project slug exists and matches `TRANSIFEX_PROJECT`.
- The token user is a project maintainer, administrator, or otherwise has permission to upload/update source files.
- The token belongs to the same Transifex organization that owns the project.
- You are using the current Transifex CLI, not the legacy Python `transifex-client`.

## How To Obtain Local PO Files

Run:

```sh
make translation
```

During the run, the script pushes the latest POT templates, then pulls translations from Transifex. After `tx pull --all`, translated PO files are available locally at:

```text
tmp/po/<chapter-slug>/<language>.po
```

For example:

```text
tmp/po/general/de.po
tmp/po/track_races/de.po
```

These files are temporary build artifacts. They are recreated under `tmp` each time the translation build runs and are not currently committed.

To inspect only the extraction side while debugging, run:

```sh
scripts/build/translation.sh -d -v
```

The `-d` flag limits the script to the first chapter (`01_general.tex`), which is much faster.

## How Translated Rulebooks Are Built

After pulling PO files, the script detects available languages by looking in one chapter directory under `tmp/po`.

For each language, it creates a translated source tree:

```text
tmp/src_<language>
```

Then it runs `po4a` using `config/po4a.cfg` to apply the PO translations to each chapter:

```text
tmp/src_<language>/chapters/<chapter-file>.tex
```

Finally, it builds one PDF per language with:

```sh
scripts/build/pdf.sh -s tmp/src_<language> -o iuf-rulebook-<branch>-<language>.pdf iuf-rulebook.tex
```

The translated PDFs are written to:

```text
pdf/iuf-rulebook-<branch>-<language>.pdf
```

## Importing Previous Translations

If Transifex Translation Memory Groups are unavailable, you can import previous PO translations from an older project into the current project.

First, run the normal translation build far enough to create/update the current project's `.tx/config` and `tmp/po` directories:

```sh
make translation
```

Then import previous translations:

```sh
TRANSIFEX_API_TOKEN=... scripts/translation/import-previous-translations.sh
```

By default, this imports `fr`, `de`, and `es` from `rulebook-2019` into the current branch's project, such as `rulebook-2025`.

You can override the source project, target project, organization, or language list:

```sh
TRANSIFEX_API_TOKEN=... scripts/translation/import-previous-translations.sh \
  -o iuf \
  -P rulebook-2019 \
  -p rulebook-2025 \
  -l fr,de,es
```

To test without pushing anything to Transifex:

```sh
TRANSIFEX_API_TOKEN=... scripts/translation/import-previous-translations.sh -n
```

The script backs up the current `tmp/po` directory to `tmp/import_previous_translations/target-po-backup` before copying imported translations locally.

## Current Limitations

- `make translation` builds every language pulled from Transifex. It does not currently support building only one locale.
- The script accepts `TRANSIFEX_API_TOKEN`. For compatibility with the old CI setup, `TRANSIFEX_API_TOKEN_2019` is also accepted.
- Title page and preamble translation are marked as TODO in the script. Most content translation happens at the chapter level.
- `tmp/po` and `tmp/src_<language>` are temporary generated directories. Copy PO files elsewhere if you need to inspect or archive them outside a build run.
