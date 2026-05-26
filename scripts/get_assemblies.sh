#!/bin/bash

while IFS=$'\t' read -r name address; do
    wget -O "$name" "$address"
done < names_addresses.tsv
