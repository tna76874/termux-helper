#!/bin/bash

SCRIPT_DIR=$(dirname "$0")
MAXDEPTH=${1:-1}

function set_touch_date() {
  # Exif-Daten auslesen
  exifdatum=$(exiftool -s -s -s -d "%Y%m%d%H%M.%S" -DateTimeOriginal "$1")

  echo "Processing: $1"

  # Änderungsdatum setzen
  touch -m -t "${exifdatum:0:12}" "$1"
}
export -f set_touch_date

function move_to_folder() {
  file="$1"
  base_file=$(basename "$file")

  datum=$(date -r "$file" "+%Y-%m")

  mkdir -p "${datum}"

  if [[ "${file}" -ef "${datum}/$base_file" ]]; then
      :
  else
      mv "${file}" "${datum}/$base_file"
  fi
}
export -f move_to_folder

##########################
find . -maxdepth "$MAXDEPTH" -type f -not -newermt 2000-01-01 -exec bash -c 'set_touch_date "$0" ||:' {} \;

find . -maxdepth "$MAXDEPTH" -type f \( -name "*.jpg" -o -name "*.mp4" \) -exec bash -c 'move_to_folder "$0"' {} \;

find . -maxdepth "$MAXDEPTH" -empty -type d -delete