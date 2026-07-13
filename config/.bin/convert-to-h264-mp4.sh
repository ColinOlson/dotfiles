#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<'EOF'
Usage: ./convert-to-h264-mp4.sh [options]

Find video files in the current folder and create MP4 files with H.264 video.

Options:
  -r, --recursive   Search subfolders too.
  -f, --force       Overwrite existing output files.
  -n, --dry-run     Print what would be done without running ffmpeg.
  -h, --help        Show this help.

Notes:
  - Existing MP4 files with H.264 video are skipped.
  - Non-MP4 files with H.264 video are remuxed when possible instead of
    re-encoding the video.
  - Audio is copied when MP4-compatible; otherwise it is converted to AAC.
  - Subtitle streams are not copied.
  - H.264 re-encoding prefers a hardware encoder when ffmpeg exposes one.
  - Successfully converted source files are moved to ./Processed.
EOF
}

recursive=0
force=0
dry_run=0

while (($#)); do
  case "$1" in
    -r|--recursive) recursive=1 ;;
    -f|--force) force=1 ;;
    -n|--dry-run) dry_run=1 ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      echo "Unknown option: $1" >&2
      usage >&2
      exit 2
      ;;
  esac
  shift
done

require_cmd() {
  if ! command -v "$1" >/dev/null 2>&1; then
    echo "Missing required command: $1" >&2
    exit 1
  fi
}

require_cmd ffmpeg
require_cmd ffprobe
require_cmd find

have_encoder() {
  ffmpeg -hide_banner -encoders 2>/dev/null | grep -qE "[[:space:]]$1[[:space:]]"
}

pick_h264_encoder() {
  if have_encoder h264_videotoolbox; then
    printf '%s\n' h264_videotoolbox
  elif have_encoder h264_nvenc; then
    printf '%s\n' h264_nvenc
  elif have_encoder h264_qsv; then
    printf '%s\n' h264_qsv
  elif have_encoder h264_amf; then
    printf '%s\n' h264_amf
  else
    printf '%s\n' libx264
  fi
}

video_codec() {
  ffprobe -v error -select_streams v:0 \
    -show_entries stream=codec_name \
    -of default=noprint_wrappers=1:nokey=1 \
    "$1" 2>/dev/null || true
}

audio_codec() {
  ffprobe -v error -select_streams a:0 \
    -show_entries stream=codec_name \
    -of default=noprint_wrappers=1:nokey=1 \
    "$1" 2>/dev/null || true
}

is_mp4_compatible_audio() {
  case "$1" in
    ""|aac|alac|mp3|ac3|eac3) return 0 ;;
    *) return 1 ;;
  esac
}

is_mp4_file() {
  case "$1" in
    *.[Mm][Pp]4|*.[Mm]4[Vv]) return 0 ;;
    *) return 1 ;;
  esac
}

output_path_for() {
  local input=$1
  local base=${input%.*}

  if is_mp4_file "$input"; then
    printf '%s\n' "${base}.h264.mp4"
  else
    printf '%s\n' "${base}.mp4"
  fi
}

processed_dir="Processed"

processed_path_for() {
  local input=$1
  local dest="$processed_dir/$input"
  local dir base ext candidate counter

  if [[ ! -e "$dest" ]]; then
    printf '%s\n' "$dest"
    return
  fi

  dir=$(dirname "$dest")
  base=$(basename "$dest")
  ext=

  if [[ "$base" == *.* ]]; then
    ext=".${base##*.}"
    base="${base%.*}"
  fi

  counter=1
  while :; do
    candidate="$dir/$base ($counter)$ext"
    if [[ ! -e "$candidate" ]]; then
      printf '%s\n' "$candidate"
      return
    fi
    ((counter+=1))
  done
}

move_to_processed() {
  local input=$1
  local processed_path

  processed_path=$(processed_path_for "$input")
  mkdir -p "$(dirname "$processed_path")" || return
  mv "$input" "$processed_path" || return
  echo "Moved source to: $processed_path"
}

encoder=$(pick_h264_encoder)
echo "Using H.264 encoder: $encoder"

find_args=(.)
if ((recursive)); then
  find_args+=(-path "./$processed_dir" -prune -o -type f)
else
  find_args+=(-maxdepth 1 -type f)
fi

find_args+=(
  \( -iname '*.mp4' -o -iname '*.m4v' -o -iname '*.mov' -o -iname '*.mkv'
     -o -iname '*.avi' -o -iname '*.wmv' -o -iname '*.flv' -o -iname '*.webm'
     -o -iname '*.mpg' -o -iname '*.mpeg' -o -iname '*.ts' -o -iname '*.mts'
     -o -iname '*.m2ts' \)
  -print0
)

converted=0
skipped=0
failed=0

while IFS= read -r -d '' input; do
  input=${input#./}
  vcodec=$(video_codec "$input")
  acodec=$(audio_codec "$input")

  if [[ -z "$vcodec" ]]; then
    echo "Skipping, no video stream: $input"
    ((skipped+=1))
    continue
  fi

  if is_mp4_file "$input" && [[ "$vcodec" == "h264" ]] && is_mp4_compatible_audio "$acodec"; then
    echo "Skipping, already MP4/H.264: $input"
    ((skipped+=1))
    continue
  fi

  output=$(output_path_for "$input")
  tmp="${output%.*}.tmp.$$.${output##*.}"

  if [[ -e "$output" && "$force" -eq 0 ]]; then
    echo "Skipping, output exists: $output"
    ((skipped+=1))
    continue
  fi

  ffmpeg_args=(-hide_banner -nostdin -y -i "$input" -map 0:v:0 -map 0:a? -sn)

  if [[ "$vcodec" == "h264" ]]; then
    ffmpeg_args+=(-c:v copy)
  else
    case "$encoder" in
      h264_videotoolbox)
        ffmpeg_args+=(-c:v h264_videotoolbox -b:v 6000k -tag:v avc1)
        ;;
      h264_nvenc)
        ffmpeg_args+=(-c:v h264_nvenc -preset p5 -cq 23 -tag:v avc1)
        ;;
      h264_qsv)
        ffmpeg_args+=(-c:v h264_qsv -global_quality 23 -tag:v avc1)
        ;;
      h264_amf)
        ffmpeg_args+=(-c:v h264_amf -quality quality -qp_i 23 -qp_p 23 -tag:v avc1)
        ;;
      *)
        ffmpeg_args+=(-c:v libx264 -preset medium -crf 20 -tag:v avc1)
        ;;
    esac
  fi

  if is_mp4_compatible_audio "$acodec"; then
    ffmpeg_args+=(-c:a copy)
  else
    ffmpeg_args+=(-c:a aac -b:a 192k)
  fi

  ffmpeg_args+=(-movflags +faststart "$tmp")

  echo "Converting: $input -> $output"
  if ((dry_run)); then
    printf '  ffmpeg'
    printf ' %q' "${ffmpeg_args[@]}"
    printf '\n'
    printf '  mv %q %q\n' "$input" "$(processed_path_for "$input")"
    ((skipped+=1))
    continue
  fi

  if ffmpeg "${ffmpeg_args[@]}"; then
    mv -f "$tmp" "$output"
    if move_to_processed "$input"; then
      ((converted+=1))
    else
      echo "Failed to move source to $processed_dir: $input" >&2
      ((failed+=1))
    fi
  else
    rm -f "$tmp"
    echo "Failed: $input" >&2
    ((failed+=1))
  fi
done < <(find "${find_args[@]}")

echo
echo "Done. Converted: $converted, skipped: $skipped, failed: $failed"

if ((failed > 0)); then
  exit 1
fi
