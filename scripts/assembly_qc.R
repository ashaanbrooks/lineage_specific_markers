library(RSQLite)
library(DBI)
library(dplyr)
library(stringr)
library(readr)
library(data.table)
library(ggplot2)

# Connect to ATB metadata SQLite database
con <- dbConnect(RSQLite::SQLite(), "data/atb.metadata.202505.sqlite")

# Query the ATB database to get a list of samples passing QC standards
samples_passing_qc <- dbGetQuery(con, "
SELECT 
  checkm2.*,
  assembly_stats.N_count
FROM checkm2
INNER JOIN assembly_stats USING (sample_accession)
INNER JOIN assembly USING (sample_accession)
WHERE assembly.asm_fasta_on_osf=1
AND (assembly.dataset <> 'Incr_release.202505')
AND assembly.sylph_species='Clostridioides difficile'
AND assembly.hq_filter='PASS'
AND checkm2.Contamination < 5 
AND checkm2.Completeness_Specific > 0.9
AND checkm2.Contig_N50 > 50000
AND checkm2.Genome_Size > 3600000
AND checkm2.Genome_size < 4800000;
")

# Load allele calls from chewBBACA
allele_calls <- read_tsv("analysis/chewbbaca_ridom/results_alleles.tsv")

# Subset allele calls and presence/absence to only samples passing assembly qc
allele_calls_qc <- allele_calls |> filter(FILE %in% samples_passing_qc$sample_accession)

# Convert allele calls to data table for faster processing
dt <- as.data.table(allele_calls_qc)
# Save names of sample column and loci
sample_col <- names(dt)[1]
locus_cols <- names(dt)[-1]

# Replace INF-XXX with XXX for inferred allele calls from chewBBACA
for (j in locus_cols) {
  set(dt, j = j, value = sub("^INF-", "", dt[[j]]))
}

# Convert all allele calls (not including sample names) to character matrix
m <- as.matrix(dt[, ..locus_cols])

# Create a logical matrix where TRUE represents a numeric allele call (valid)
# And FALSE represents a non-numeric allele call (error code)
is_numeric_mat <- matrix(
  !is.na(suppressWarnings(as.numeric(m))),
  nrow = nrow(m), ncol = ncol(m),
  dimnames = dimnames(m)
)

# Get a vector of the error codes present in the allele calls
all_codes <- sort(unique(m[!is_numeric_mat]))

# Count number of valid allele calls per locus
numeric_counts <- colSums(is_numeric_mat)

# Count number of each error code per locus,result: matrix [loci × error_codes]
code_counts <- vapply(all_codes, function(code) {
  colSums(m == code, na.rm = TRUE)
}, numeric(length(locus_cols)))

# Sum to get total number of invalid calls per locus
error_total <- rowSums(code_counts)

# Filter loci by threshold (each locus must have less than (threshold) invalid calls)
# Here we impose max 5% missing calls as the threshold
threshold <- ceiling(nrow(allele_calls_qc) * 0.05)
loci_to_remove <- names(error_total)[error_total >= threshold]

# Subset error code and valid allele counts for only problematic loci for plotting
code_counts_problematic <- code_counts[loci_to_remove, , drop = FALSE]
numeric_problematic     <- numeric_counts[loci_to_remove]

# Prep data for plotting - not sure how this code works, learn and fill
plot_dt <- as.data.table(code_counts_problematic, keep.rownames = "locus")
plot_dt[, Numeric := numeric_problematic]

plot_long <- melt(plot_dt,
                  id.vars       = "locus",
                  variable.name = "category",
                  value.name    = "n")
plot_long <- plot_long[n > 0]  # drop zero-count combinations

# Set colour pallette
error_codes <- setdiff(unique(plot_long$category), "Numeric")
palette <- c(
  setNames(scales::hue_pal()(length(error_codes)), error_codes),
  Numeric = "#CCCCCC")
  
# Plot stacked barplot showing numbers of each error code and valid calls
# For each problematic locus
# NOTE: might also be interesting to see how many alleles are being inferred
ggplot(plot_long, aes(x = locus, y = n, fill = category)) +
  geom_bar(stat = "identity") +
  scale_fill_manual(values = palette, name = "Call type") +
  labs(title = paste0("Loci with ≥ ", threshold, " non-numeric calls"),
       x = "Locus", y = "Count") +
  theme_minimal(base_size = 13) +
  theme(axis.text.x = element_text(angle = 45, hjust = 1))


# Remove problematic loci 
allele_calls_loci_filtered <- allele_calls_qc |> select(-all_of(loci_to_remove))

# Remove samples with less than 95% of alleles determined 
is_numeric_mat_filtered <- is_numeric_mat[, !colnames(is_numeric_mat) %in% loci_to_remove]
valid_allele_threshold <- ceiling(ncol(is_numeric_mat_filtered) * 0.95)
valid_counts <- rowSums(is_numeric_mat_filtered)
samples_to_remove <- allele_calls_qc$FILE[valid_counts < valid_allele_threshold]

# Note - this is no samples at 95% threshold
samples_passing_cgmlst <- samples_passing_qc |> filter(!sample_accession %in% samples_to_remove)

# Load list of duplicates based on MASH distance
mash_duplicates <- read_tsv("analysis/mash/duplicates.txt", 
                            col_names = c("reference", "query", "distance", "p_value", "shared_hashes"))

# Remove filenames and extensions to leave sample accessions
mash_duplicates <- mash_duplicates |> mutate(reference = tools::file_path_sans_ext(basename(reference))) |>
  mutate(query = tools::file_path_sans_ext(basename(query)))

# Filter to only duplicates that have passed QC
mash_duplicates_qc <- mash_duplicates |> filter(reference %in% samples_passing_cgmlst$sample_accession,
                                                query %in% samples_passing_cgmlst$sample_accession)

# Deduplicate - select the sample from each pair with higher N50
# Add the other to a list of duplicates to remove
duplicates_to_keep <- mash_duplicates_qc |>
  left_join(samples_passing_cgmlst, by = c("reference" = "sample_accession")) |>
  rename(n50_reference = Contig_N50) |>
  left_join(samples_passing_cgmlst, by = c("query" = "sample_accession")) |>
  rename(n50_query = Contig_N50) |>
  mutate(
    better_sample = case_when(
      n50_reference > n50_query  ~ reference,
      n50_query > n50_reference  ~ query,
      TRUE                       ~ pmin(reference, query)  # tie-break alphabetically
    ),
    worse_sample = case_when(
      n50_reference > n50_query  ~ query,
      n50_query > n50_reference  ~ reference,
      TRUE                       ~ pmax(reference, query)
    )
  ) |>
  filter(!better_sample %in% worse_sample) |>
  distinct(better_sample) |>
  pull(better_sample)

duplicates_to_remove <- c(mash_duplicates_qc$reference, mash_duplicates_qc$query) |>
  unique() |>
  setdiff(duplicates_to_keep)

samples_passing_deduplication <- samples_passing_cgmlst |> filter(!sample_accession %in% duplicates_to_remove)

# Print list of samples for further analysis
#write_lines(samples_passing_deduplication$sample_accession, "analysis/samples_for_clustering.txt")

# Print list of loci to remove before further analysis
write_lines(loci_to_remove, "analysis/loci_to_remove.txt")

# Disconnect from database
dbDisconnect(con)

