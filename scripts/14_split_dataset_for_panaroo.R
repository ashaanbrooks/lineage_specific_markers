here::i_am("scripts/split_dataset_for_panaroo.R")
library(dplyr)
library(purrr)
library(readr)
library(here)

# Load clusters 
clusters <- read_tsv(here("analysis/reportree/ridom_partitions.tsv"))

# Using a distance threshold of 1000, get any cluster with more than 500 members
large_clusters <- clusters |>
  count(`single-1000x1.0`) |>
  filter(n >= 500) |>
  pull(`single-1000x1.0`)

# Build sample lists for large clusters, and one for all samples not in a large cluster
sample_lists <- clusters |>
  mutate(
    cluster_group = if_else(
      `single-1000x1.0` %in% large_clusters,
      as.character(`single-1000x1.0`),
      "cluster_other"
    )
  ) |>
  group_by(cluster_group) |>
  summarise(
    sample_ids = list(sequence),
    .groups = "drop"
  )

# Write each list to a file
walk2(
  sample_lists$sample_ids,
  sample_lists$cluster_group,
  \(ids, grp) {
    write_lines(
      ids,
      here("analysis", "sample_lists_for_panaroo", paste0(grp, ".txt"))
    )
  }
)
