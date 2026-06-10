#!/bin/bash

source define_paths.sh
mkdir -p "$ANALYSIS_DIR"/file_lists_for_panaroo

for SAMPLE_LIST_PATH in "$ANALYSIS_DIR"/sample_lists_for_panaroo/*.txt; do
	SAMPLE_LIST_NAME="${SAMPLE_LIST_PATH##*/}"
	FILE_LIST_PATH="$ANALYSIS_DIR"/file_lists_for_panaroo/"$SAMPLE_LIST_NAME"
	while IFS= read -r SAMPLE; do
		echo "$ANNOTATION_DIR"/"$SAMPLE".gff3
	done < "$SAMPLE_LIST_PATH" > "$FILE_LIST_PATH"
done

