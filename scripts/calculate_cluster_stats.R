library(readr)
library(dplyr)
library(stringr)
library(aricode)
library(cluster)
library(here)
library(parallel)

here::i_am("scripts/calculate_cluster_stats.R")

# Source script with AWC function from https://github.com/rossimk/nAWC
source(here("scripts/wallace-helper.R"))

# Load clustering assigments at all thresholds
clusters <- read_tsv(here("analysis/reportree/ridom_partitions.tsv"))

# Load distance matrix (for silhouette scores)
distances <- read_tsv(here("analysis/chewbbaca_ridom/distances_filtered.tsv"))


thresholds <- 1:(ncol(clusters) - 1)
dist_matrix  <- as.matrix(distances[, 2:ncol(distances)])
clusters_int <- lapply(seq_along(clusters)[-1], function(i) as.integer(factor(clusters[[i]])))

# Count number of clusters and number of singletons at each threshold
# Along with neighbour clustering comparison metrics + scores
cluster_stats <- mclapply(thresholds, function(t) {
  message("Processing threshold ", t, " of ", max(thresholds))
  vals     <- clusters[[t + 1]]
  vals_int <- clusters_int[[t]]
  data.frame(
    threshold       = t,
    n_clusters      = length(unique(vals[str_starts(vals, "cluster_")])),
    n_singletons    = sum(str_starts(vals, "singleton_")),
    nawc            = if (t == 1) NA else tryCatch(
      adj_wallace(clusters[[t + 2]], vals)$Adjusted_Wallace_A_vs_B,
      error = function(e) NA
    ),
    adj_rand        = tryCatch(
      ARI(clusters_int[[t + 1]], vals_int),
      error = function(e) NA
    ),
    adj_mutual_info = tryCatch(
      AMI(clusters_int[[t + 1]], vals_int),
      error = function(e) NA
    ),
    silhouette      = summary(silhouette(vals_int, dmatrix = dist_matrix))$avg.width
  )
}, mc.cores = 4) |> bind_rows()

write_csv(cluster_stats, here("analysis/cluster_stats.csv"))
