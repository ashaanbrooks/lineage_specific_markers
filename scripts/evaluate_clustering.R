library(readr)
library(dplyr)
library(stringr)
library(ggplot2)
library(aricode)
library(cluster)

# Source script with AWC function from https://github.com/rossimk/nAWC
source("scripts/wallace-helper.R")

# Load clustering assigments at all thresholds
clusters <- read_tsv("analysis/reportree/ridom_partitions.tsv")

# Load distance matrix (for silhouette scores)
distances <- read_tsv("analysis/chewbbaca_ridom/distances_filtered.tsv")


thresholds <- 1:(ncol(clusters) - 1)

# Count number of clusters and number of singletons at each threshold
# Along with neighbour clustering comparison metrics + scores
cluster_stats <- lapply(thresholds, function(t) {
  vals <- clusters[[t + 1]]
  data.frame(
    threshold       = t,
    n_clusters      = length(unique(vals[str_starts(vals, "cluster_")])),
    n_singletons    = sum(str_starts(vals, "singleton_")),
    nawc            = if (t == 1) NA else tryCatch(
      adj_wallace(clusters[[t + 2]], vals)$Adjusted_Wallace_A_vs_B,
      error = function(e) NA
    ),
    adj_rand        = tryCatch(
      ARI(as.integer(factor(clusters[[t + 2]])), as.integer(factor(vals))),
      error = function(e) NA
    ),
    adj_mutual_info = tryCatch(
      AMI(as.integer(factor(clusters[[t + 2]])), as.integer(factor(vals))),
      error = function(e) NA
    ),
    silhouette = summary(silhouette(as.integer(factor(vals)), dmatrix = as.matrix(distances[,2:ncol(distances)])))$avg.width
  )
}) |> bind_rows()
# Plot number of clusters over the thresholds
ggplot(cluster_stats, aes(x = threshold, y = n_clusters)) +
  geom_line() +
  labs(title = "Clusters per threshold", x = "Threshold", y = "Number of clusters")

# Plot number of singletons over the thresholds
ggplot(cluster_stats, aes(x = threshold, y = n_singletons)) +
  geom_line() +
  labs(title = "Singletons per threshold", x = "Threshold", y = "Number of singletons")

# Plot nAWC, nARI, nAMI over the thresholds
ggplot(cluster_stats) +
  geom_line(aes(x = threshold, y = nawc, colour = "nAWC")) +
  geom_line(aes(x = threshold, y = adj_rand, colour = "Adjusted Rand")) +
  geom_line(aes(x = threshold, y = adj_mutual_info, colour = "Adjusted Mutual Info")) +
  scale_colour_manual(values = c("nAWC" = "blue", "Adjusted Rand" = "green", "Adjusted Mutual Info" = "pink")) +
  labs(title = "Comparison metrics over all thresholds", x = "Threshold", y = "Similarity score", colour = NULL)




