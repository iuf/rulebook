#!/usr/bin/env bash
set -euo pipefail

BRANCH=$(git rev-parse --abbrev-ref HEAD)

if [[ "$BRANCH" = "master" ]]; then
  BRANCH="2019"
fi

TRANSIFEX_ORGANIZATION=${TRANSIFEX_ORGANIZATION:-iuf}
TRANSIFEX_PROJECT=${TRANSIFEX_PROJECT:-rulebook-$BRANCH}
TRANSIFEX_PREVIOUS_PROJECT=${TRANSIFEX_PREVIOUS_PROJECT:-rulebook-2019}
TRANSIFEX_TOKEN=${TRANSIFEX_API_TOKEN:-${TRANSIFEX_API_TOKEN_2019:-}}
TRANSLATION_LANGUAGES=${TRANSLATION_LANGUAGES:-fr,de,es}
WORKDIR=${WORKDIR:-tmp/import_previous_translations}

show_help() {
cat << EOF
Usage: ${0##*/} [-h] [-n] [-l LANGS] [-p PROJECT] [-P PREVIOUS_PROJECT] [-o ORGANIZATION]

Import existing translations from a previous Transifex project into the current
Transifex project. This is intended for copying older rulebook translations into
a new rulebook project when Translation Memory Groups are unavailable.

Options:
    -h                    display this help and exit
    -n                    dry run: pull previous translations and copy files locally,
                          but do not push translations to Transifex
    -l LANGS              comma-separated target languages, default: fr,de,es
    -p PROJECT            target Transifex project, default: rulebook-<branch>
    -P PREVIOUS_PROJECT   source Transifex project, default: rulebook-2019
    -o ORGANIZATION       Transifex organization, default: iuf

Environment:
    TRANSIFEX_API_TOKEN   API token for the current Transifex CLI
    TRANSIFEX_API_TOKEN_2019 is also accepted for compatibility

Example:
    TRANSIFEX_API_TOKEN=... ${0##*/} -P rulebook-2019 -p rulebook-2025 -l fr,de,es
EOF
}

DRY_RUN=0

OPTIND=1
while getopts :hnl:p:P:o: opt; do
  case $opt in
    h)
      show_help
      exit 0
      ;;
    n)
      DRY_RUN=1
      ;;
    l)
      TRANSLATION_LANGUAGES=$OPTARG
      ;;
    p)
      TRANSIFEX_PROJECT=$OPTARG
      ;;
    P)
      TRANSIFEX_PREVIOUS_PROJECT=$OPTARG
      ;;
    o)
      TRANSIFEX_ORGANIZATION=$OPTARG
      ;;
    \?)
      show_help >&2
      exit 1
      ;;
  esac
done
shift "$((OPTIND-1))"

if [[ -z "$TRANSIFEX_TOKEN" ]]; then
  echo "Error: Set TRANSIFEX_API_TOKEN before importing translations."
  echo "For compatibility, TRANSIFEX_API_TOKEN_2019 is also accepted."
  exit 1
fi

if ! command -v tx >/dev/null 2>&1; then
  echo "Error: tx was not found on PATH."
  exit 1
fi

if ! command -v msgmerge >/dev/null 2>&1; then
  echo "Error: msgmerge was not found on PATH."
  exit 1
fi

if ! command -v msgattrib >/dev/null 2>&1; then
  echo "Error: msgattrib was not found on PATH."
  exit 1
fi

sanitize_po_file() {
  local po_file=$1
  local tmp_file

  tmp_file=$(mktemp)

  awk '
    function clear_msgstr(text) {
      split(text, lines, "\n")
      output = ""
      in_msgstr = 0

      for (i = 1; i <= length(lines); i++) {
        if (lines[i] ~ /^msgstr/) {
          output = output "msgstr \"\"\n"
          in_msgstr = 1
          continue
        }

        if (in_msgstr && lines[i] ~ /^"/) {
          continue
        }

        in_msgstr = 0
        if (lines[i] != "") {
          output = output lines[i] "\n"
        }
      }

      return output
    }

    function flush_entry() {
      if (entry != "") {
        if (entry ~ /TEST/) {
          entry = clear_msgstr(entry)
        }
        printf "%s", entry
      }
      entry = ""
    }
    /^$/ {
      entry = entry $0 "\n"
      flush_entry()
      next
    }
    {
      entry = entry $0 "\n"
    }
    END {
      flush_entry()
    }
  ' "$po_file" > "$tmp_file"

  mv "$tmp_file" "$po_file"
}

if [[ ! -f .tx/config ]]; then
  echo "Error: .tx/config was not found."
  echo "Run make translation first so the target project resources are configured."
  exit 1
fi

if [[ ! -d tmp/po ]]; then
  echo "Error: tmp/po was not found."
  echo "Run make translation first so the target project PO directories exist."
  exit 1
fi

mkdir -p "$WORKDIR"
rm -rf "$WORKDIR/previous" "$WORKDIR/target-po-backup"
mkdir -p "$WORKDIR/previous/.tx"

cp .tx/config "$WORKDIR/previous/.tx/config"
cp -a tmp/po "$WORKDIR/target-po-backup"

perl -pi -e "s#p:\Q$TRANSIFEX_PROJECT\E:#p:$TRANSIFEX_PREVIOUS_PROJECT:#g; s#tmp/po/#old_po/#g" "$WORKDIR/previous/.tx/config"

echo "Pulling previous translations"
echo "  Organization: $TRANSIFEX_ORGANIZATION"
echo "  From project: $TRANSIFEX_PREVIOUS_PROJECT"
echo "  Languages:    $TRANSLATION_LANGUAGES"

(
  cd "$WORKDIR/previous"
  tx --token="$TRANSIFEX_TOKEN" pull --languages "$TRANSLATION_LANGUAGES"
)

if [[ ! -d "$WORKDIR/previous/old_po" ]]; then
  echo "Error: No previous PO files were downloaded."
  exit 1
fi

echo "Copying previous translations into tmp/po"
while IFS= read -r PREVIOUS_PO; do
  RELATIVE_PO=${PREVIOUS_PO#"$WORKDIR/previous/old_po/"}
  RESOURCE=${RELATIVE_PO%/*}
  TARGET_PO="tmp/po/$RELATIVE_PO"
  TARGET_TEMPLATE="tmp/po/$RESOURCE/template.pot"

  if [[ ! -f "$TARGET_TEMPLATE" ]]; then
    echo "Skipping $RELATIVE_PO because $TARGET_TEMPLATE does not exist."
    continue
  fi

  echo "  $RELATIVE_PO"
  mkdir -p "$(dirname "$TARGET_PO")"
  msgmerge --quiet --no-fuzzy-matching --output-file="$TARGET_PO" "$PREVIOUS_PO" "$TARGET_TEMPLATE"
  msgattrib --no-obsolete --clear-previous --output-file="$TARGET_PO" "$TARGET_PO"
  sanitize_po_file "$TARGET_PO"
done < <(find "$WORKDIR/previous/old_po" -type f -name '*.po' | sort)

if [[ $DRY_RUN -eq 1 ]]; then
  echo "Dry run complete. Target translations were copied locally, but not pushed."
  echo "Backup of original tmp/po is at: $WORKDIR/target-po-backup"
  exit 0
fi

echo "Pushing imported translations"
echo "  To project: $TRANSIFEX_PROJECT"
tx --token="$TRANSIFEX_TOKEN" push --translation --languages "$TRANSLATION_LANGUAGES"

echo "Done."
echo "Backup of original tmp/po is at: $WORKDIR/target-po-backup"
