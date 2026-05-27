library(RSQLite)
library(DBI)
library(dplyr)
library(stringr)
library(readr)
library(here)

here::i_am("scripts/assembly_qc.R")

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





# Disconnect from database
dbDisconnect(con)

