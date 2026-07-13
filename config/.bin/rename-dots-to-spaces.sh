#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<'EOF'
Usage: ./rename-dots-to-spaces.sh [--apply] [directory]

Renames regular files and folders so periods in names become spaces, wraps
unparenthesized 4-digit years in parentheses, and preserves the final extension
separator for files.

Example:
  file.name.example.mp4 -> file name example.mp4
  movie.name.with.1979.mp4 -> movie name with (1979).mp4

Runs as a dry run by default. Pass --apply to actually rename files and folders.
EOF
}

apply=false
dir="."

while (($#)); do
  case "$1" in
    --apply)
      apply=true
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    -*)
      echo "Unknown option: $1" >&2
      usage >&2
      exit 2
      ;;
    *)
      if [[ "$dir" != "." ]]; then
        echo "Only one directory argument is supported." >&2
        exit 2
      fi
      dir="$1"
      ;;
  esac
  shift
done

if [[ ! -d "$dir" ]]; then
  echo "Not a directory: $dir" >&2
  exit 1
fi

wrap_years() {
  local input=$1
  local output=""
  local i=0
  local len=${#input}
  local chunk prev next

  while ((i < len)); do
    chunk=${input:i:4}
    prev=""
    next=""

    if ((i > 0)); then
      prev=${input:i-1:1}
    fi

    if ((i + 4 < len)); then
      next=${input:i+4:1}
    fi

    if [[ ${#chunk} -eq 4 && "$chunk" =~ ^[0-9]{4}$ && ! "$prev" =~ [0-9] && ! "$next" =~ [0-9] ]]; then
      if [[ "$prev" == "(" && "$next" == ")" ]]; then
        output+="$chunk"
      else
        output+="($chunk)"
      fi

      ((i+=4))
      continue
    fi

    output+="${input:i:1}"
    ((i+=1))
  done

  printf '%s\n' "$output"
}

shopt -s nullglob dotglob

changed=0
skipped=0

for path in "$dir"/*; do
  if [[ -f "$path" ]]; then
    entry_type="file"
  elif [[ -d "$path" ]]; then
    entry_type="folder"
  else
    continue
  fi

  parent=${path%/*}
  filename=${path##*/}

  # Skip dotfiles like ".env" that do not have a normal base name.
  if [[ "$filename" == .* && "$filename" != *.*.* ]]; then
    continue
  fi

  if [[ "$entry_type" == "file" ]]; then
    if [[ "$filename" != *.* ]]; then
      continue
    fi

    extension=".${filename##*.}"
    base=${filename%.*}
    new_base=${base//./ }
    new_base=$(wrap_years "$new_base")
    new_filename="${new_base}${extension}"
  else
    if [[ "$filename" != *.* ]]; then
      continue
    fi

    new_filename=${filename//./ }
    new_filename=$(wrap_years "$new_filename")
  fi
  new_path="${parent}/${new_filename}"

  if [[ "$filename" == "$new_filename" ]]; then
    continue
  fi

  if [[ -e "$new_path" ]]; then
    echo "SKIP: '$filename' -> '$new_filename' already exists" >&2
    ((skipped+=1))
    continue
  fi

  if [[ "$apply" == true ]]; then
    mv -- "$path" "$new_path"
    echo "RENAMED ${entry_type}: '$filename' -> '$new_filename'"
  else
    echo "DRY RUN ${entry_type}: '$filename' -> '$new_filename'"
  fi

  ((changed+=1))
done

if [[ "$apply" == true ]]; then
  echo "Done. Renamed $changed item(s), skipped $skipped conflict(s)."
else
  echo "Dry run complete. $changed item(s) would be renamed, $skipped conflict(s) skipped."
  echo "Run with --apply to perform these renames."
fi
