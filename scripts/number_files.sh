#!/bin/bash

LIST="order_list.txt"

total=$(grep -c . "$LIST")
width=${#total}

i=1
while IFS= read -r filename || [[ -n "$filename" ]]; do
  [[ -z "$filename" ]] && continue

  match=$(find . -maxdepth 1 -name "*${filename}" -o -maxdepth 1 -name "${filename}" | head -1)

  if [[ -z "$match" ]]; then
    echo "Warning: '$filename' not found, skipping."
    ((i++))
    continue
  fi

  padded=$(printf "%0${width}d" "$i")
  mv -- "$match" "${padded}_${filename}"
  echo "Renamed: $match -> ${padded}_${filename}"
  ((i++))
done < "$LIST"
