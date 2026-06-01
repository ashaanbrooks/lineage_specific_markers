#!/bin/bash

# Renumber scripts based on list order
i=1
while IFS= read -r filename || [[ -n "$filename" ]]; do
  [[ -z "$filename" ]] && continue

  match=$(find . -maxdepth 1 -name "*_${filename}" | head -1)

  if [[ -z "$match" ]]; then
    echo "Warning: '$filename' not found, skipping."
    ((i++))
    continue
  fi

  mv -- "$match" "${i}_${filename}"
  echo "Renamed: $filename -> ${i}_${filename}"
  ((i++))
done < order_list.txt

