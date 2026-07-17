#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<'USAGE'
Usage:
  ./convert-webm-to-similar-mp4.sh [options] file.webm [more.webm ...]

Converts WebM files to H.264/AAC MP4 files while targeting a similar file size.
Outputs are written beside the inputs with a .mp4 extension.

Options:
  --audio-kbps N   AAC audio bitrate to reserve when audio exists (default: 128)
  --preset NAME   libx264 preset (default: slow)
  --force         overwrite existing .mp4 outputs
  --dry-run       print the ffmpeg commands without running them
  --keep-logs     keep x264 two-pass log files
  -h, --help      show this help
USAGE
}

AUDIO_KBPS=128
PRESET=slow
FORCE=0
DRY_RUN=0
KEEP_LOGS=0
inputs=()
TEMP_OUTPUTS=()
PASS_PREFIXES=()

cleanup() {
  local path

  for path in "${TEMP_OUTPUTS[@]}"; do
    rm -f -- "$path"
  done

  if [[ "$KEEP_LOGS" == "0" ]]; then
    for path in "${PASS_PREFIXES[@]}"; do
      rm -f -- "$path" "$path.log" "$path.log.mbtree"
    done
  fi
}
trap cleanup EXIT

die() {
  printf 'Error: %s\n' "$*" >&2
  exit 1
}

require_cmd() {
  command -v "$1" >/dev/null 2>&1 || die "missing required command: $1"
}

file_size_bytes() {
  stat -f %z "$1" 2>/dev/null || stat -c %s "$1"
}

print_cmd() {
  printf '  '
  printf '%q ' "$@"
  printf '\n'
}

run_cmd() {
  print_cmd "$@"
  if [[ "$DRY_RUN" == "0" ]]; then
    "$@"
  fi
}

pick_audio_kbps() {
  local total_kbps=$1
  local requested_kbps=$2

  if (( total_kbps < 160 )); then
    printf '48\n'
  elif (( total_kbps < 260 )); then
    printf '64\n'
  elif (( total_kbps < 420 && requested_kbps > 96 )); then
    printf '96\n'
  else
    printf '%s\n' "$requested_kbps"
  fi
}

convert_one() {
  local input=$1
  local output=${input%.*}.mp4
  local tmp_output=${output%.*}.tmp.$$.mp4
  local passlog="${TMPDIR:-/tmp}/webm_to_mp4_pass.$$.${RANDOM}"
  local source_bytes duration total_kbps has_audio audio_kbps video_kbps
  local output_bytes diff_pct near_end

  [[ -f "$input" ]] || die "input does not exist: $input"
  [[ "${input##*.}" == "webm" || "${input##*.}" == "WEBM" ]] || die "input is not a .webm file: $input"

  if [[ -e "$output" && "$FORCE" == "0" ]]; then
    die "output already exists: $output (use --force to overwrite)"
  fi

  source_bytes=$(file_size_bytes "$input")
  duration=$(ffprobe -v error -show_entries format=duration -of default=noprint_wrappers=1:nokey=1 "$input")
  awk -v d="$duration" 'BEGIN { exit !(d + 0 > 0) }' || die "could not read a valid duration from: $input"

  total_kbps=$(awk -v bytes="$source_bytes" -v dur="$duration" 'BEGIN { printf "%d", (bytes * 8 / dur / 1000) }')
  has_audio=$(ffprobe -v error -select_streams a:0 -show_entries stream=index -of csv=p=0 "$input" | sed -n '1p')

  if [[ -n "$has_audio" ]]; then
    audio_kbps=$(pick_audio_kbps "$total_kbps" "$AUDIO_KBPS")
  else
    audio_kbps=0
  fi

  video_kbps=$((total_kbps - audio_kbps))
  if (( video_kbps < 80 )); then
    video_kbps=80
    printf 'Warning: %s has a very low source bitrate; the MP4 may be larger than the WebM.\n' "$input" >&2
  fi

  TEMP_OUTPUTS+=("$tmp_output")
  PASS_PREFIXES+=("$passlog")

  printf '\nInput:  %s\n' "$input"
  printf 'Output: %s\n' "$output"
  printf 'Source: %s bytes, %.3f seconds, target total %sk\n' "$source_bytes" "$duration" "$total_kbps"
  if [[ -n "$has_audio" ]]; then
    printf 'Encode: video %sk + AAC audio %sk, preset %s\n' "$video_kbps" "$audio_kbps" "$PRESET"
  else
    printf 'Encode: video %sk, no audio, preset %s\n' "$video_kbps" "$PRESET"
  fi

  run_cmd ffmpeg -y -nostdin -hide_banner -i "$input" \
    -map 0:v:0 \
    -c:v libx264 -preset "$PRESET" -b:v "${video_kbps}k" -pass 1 -passlogfile "$passlog" \
    -pix_fmt yuv420p -an -sn -f null /dev/null

  if [[ -n "$has_audio" ]]; then
    run_cmd ffmpeg -y -nostdin -hide_banner -i "$input" \
      -map 0:v:0 -map '0:a:0?' \
      -c:v libx264 -preset "$PRESET" -b:v "${video_kbps}k" -pass 2 -passlogfile "$passlog" \
      -pix_fmt yuv420p \
      -c:a aac -b:a "${audio_kbps}k" -ac 2 \
      -sn -movflags +faststart "$tmp_output"
  else
    run_cmd ffmpeg -y -nostdin -hide_banner -i "$input" \
      -map 0:v:0 \
      -c:v libx264 -preset "$PRESET" -b:v "${video_kbps}k" -pass 2 -passlogfile "$passlog" \
      -pix_fmt yuv420p \
      -an -sn -movflags +faststart "$tmp_output"
  fi

  if [[ "$DRY_RUN" == "1" ]]; then
    return
  fi

  mv -f -- "$tmp_output" "$output"

  output_bytes=$(file_size_bytes "$output")
  diff_pct=$(awk -v src="$source_bytes" -v out="$output_bytes" 'BEGIN { printf "%.2f", ((out - src) * 100 / src) }')
  printf 'Wrote:  %s bytes (%s%% vs source)\n' "$output_bytes" "$diff_pct"

  printf 'Checking first frame...\n'
  ffmpeg -v error -nostdin -i "$output" -frames:v 1 -f null -

  near_end=$(awk -v d="$duration" 'BEGIN { s = d - 5; if (s < 0) s = 0; printf "%.3f", s }')
  printf 'Checking near end at %ss...\n' "$near_end"
  ffmpeg -v error -nostdin -ss "$near_end" -i "$output" -t 1 -f null -
}

while (($#)); do
  case "$1" in
    --audio-kbps)
      shift
      [[ $# -gt 0 ]] || die "--audio-kbps requires a value"
      AUDIO_KBPS=$1
      ;;
    --preset)
      shift
      [[ $# -gt 0 ]] || die "--preset requires a value"
      PRESET=$1
      ;;
    --force)
      FORCE=1
      ;;
    --dry-run)
      DRY_RUN=1
      ;;
    --keep-logs)
      KEEP_LOGS=1
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    --)
      shift
      while (($#)); do
        inputs+=("$1")
        shift
      done
      break
      ;;
    -*)
      die "unknown option: $1"
      ;;
    *)
      inputs+=("$1")
      ;;
  esac
  shift
done

[[ ${#inputs[@]} -gt 0 ]] || {
  usage
  exit 1
}

require_cmd ffmpeg
require_cmd ffprobe
require_cmd awk
require_cmd sed
require_cmd stat

for input in "${inputs[@]}"; do
  convert_one "$input"
done
