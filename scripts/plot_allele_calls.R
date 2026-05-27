library(data.table)

# ── 1. Convert to data.table (if not already) ─────────────────────────────────
dt <- as.data.table(allele_calls_qc)
sample_col <- names(dt)[1]
locus_cols <- names(dt)[-1]

# ── 2. Clean INF-XXX → XXX (by reference, no copy) ───────────────────────────
for (j in locus_cols) {
  set(dt, j = j, value = sub("^INF-", "", dt[[j]]))
}

# ── 3. Classify & count in one matrix pass — never pivot to long ──────────────
# Convert locus columns to a plain character matrix for fast vectorised ops
m <- as.matrix(dt[, ..locus_cols])

is_numeric_mat <- matrix(
  !is.na(suppressWarnings(as.numeric(m))),
  nrow = nrow(m), ncol = ncol(m),
  dimnames = dimnames(m)
)

# All unique non-numeric codes across the whole dataset
all_codes <- sort(unique(m[!is_numeric_mat]))

# ── 4. Count per locus (colSums on logical matrix — very fast) ────────────────
numeric_counts <- colSums(is_numeric_mat)

# Count each error code per locus
code_counts <- vapply(all_codes, function(code) {
  colSums(m == code, na.rm = TRUE)
}, numeric(length(locus_cols)))
# Result: matrix [loci × error_codes]

error_total <- rowSums(code_counts)

# ── 5. Filter loci by threshold ───────────────────────────────────────────────
threshold <- 2000
keep <- names(error_total)[error_total >= threshold]

code_counts_filtered <- code_counts[keep, , drop = FALSE]
numeric_filtered     <- numeric_counts[keep]

# ── 6. Build summary data.table for ggplot ────────────────────────────────────
plot_dt <- as.data.table(code_counts_filtered, keep.rownames = "locus")
plot_dt[, Numeric := numeric_filtered]

plot_long <- melt(plot_dt,
                  id.vars       = "locus",
                  variable.name = "category",
                  value.name    = "n")
plot_long <- plot_long[n > 0]  # drop zero-count combinations

# ── 7. Colour palette ─────────────────────────────────────────────────────────
error_codes <- setdiff(unique(plot_long$category), "Numeric")
palette <- c(
  setNames(scales::hue_pal()(length(error_codes)), error_codes),
  Numeric = "#CCCCCC"
)

# ── 8. Plot ───────────────────────────────────────────────────────────────────
library(ggplot2)

ggplot(plot_long, aes(x = locus, y = n, fill = category)) +
  geom_bar(stat = "identity") +
  scale_fill_manual(values = palette, name = "Call type") +
  labs(title = paste0("Loci with ≥ ", threshold, " non-numeric calls"),
       x = "Locus", y = "Count") +
  theme_minimal(base_size = 13) +
  theme(axis.text.x = element_text(angle = 45, hjust = 1))