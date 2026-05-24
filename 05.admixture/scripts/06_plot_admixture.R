# =============================================================================
# 06_plot_admixture.R — Admixture proportion visualisation using pophelper
# =============================================================================
# Input:  qopt files from NGSadmix (best reps from 04_find_bestreps.sh)
#         admix_sample.list.txt — individual sample IDs
#         admixture_groups.list.txt — population and region group labels
#         pop.list — population names (shared from 02.genotype_likelihoods/data/)
# Output: admixture_ys_autosome.png — stacked bar plots for all K
#         admixture_ys_autosome_K3.png — detailed plot for optimal K
#
# Dependencies: pophelper, ggplot2, gridExtra
#
# Note: best run indices in alignK() were determined from evalAdmix
#       residual correlation output (03_run_evaladmix.sh).
#       Update BEST_RUN_INDICES in config.sh if re-running with different data.
# =============================================================================

library(pophelper)
library(ggplot2)
library(gridExtra)

# -----------------------------------------------------------------------------
# Paths
# -----------------------------------------------------------------------------
wd           <- Sys.getenv("WD",              unset = "/path/to/working/directory")
bestreps_dir <- Sys.getenv("OUT_BESTREPS",    unset = file.path(wd, "admixture/bestReps"))
out_plots    <- Sys.getenv("OUT_PLOTS",       unset = file.path(wd, "admixture/plots"))
sample_file  <- Sys.getenv("SAMPLE_LIST",     unset = file.path(wd, "info/admix_sample.list.txt"))
groups_file  <- Sys.getenv("GROUPS_LIST",     unset = file.path(wd, "info/admixture_groups.list.txt"))
pop_list     <- Sys.getenv("POP_LIST",        unset = file.path(wd,
                           "../02.genotype_likelihoods/data/pop.list"))
best_indices <- as.integer(strsplit(
                 Sys.getenv("BEST_RUN_INDICES",
                            unset = "10,16,23,38,46,58,70,76,89,98,101,114,127,137"),
                 ",")[[1]])

dir.create(out_plots, recursive = TRUE, showWarnings = FALSE)

# -----------------------------------------------------------------------------
# Read population order from shared pop.list
# (02.genotype_likelihoods/data/pop.list — one population name per line)

# -----------------------------------------------------------------------------
if (!file.exists(pop_list)) {
  stop("pop.list not found at: ", pop_list,
       "\nCheck POP_LIST environment variable or PIPELINE_ROOT in config.sh")
}
pop_order <- readLines(pop_list)
pop_order <- pop_order[nzchar(trimws(pop_order))]  # remove any blank lines
cat("Population order read from pop.list:\n")
cat(paste(pop_order, collapse = " "), "\n\n")

# -----------------------------------------------------------------------------
# Load qopt files and sample/group metadata
# -----------------------------------------------------------------------------
sfiles <- list.files(path = bestreps_dir, pattern = "qopt", full.names = TRUE)
input  <- readQ(files = sfiles)
inds   <- read.delim(sample_file,  header = FALSE)
groups <- read.delim(groups_file,  header = TRUE, stringsAsFactors = FALSE)

# Colony-level group labels (column 2)
onelabset1 <- groups[, 2, drop = FALSE]
# Colony and region group labels (columns 2-3)
onelabset2 <- groups[, 2:3, drop = FALSE]

# Assign individual sample IDs as rownames
if (length(unique(sapply(input, nrow))) == 1) {
  input <- lapply(input, "rownames<-", inds$V1)
}

# -----------------------------------------------------------------------------
# Align clusters across K values using best run indices
# Indices determined from evalAdmix residual correlation output
# -----------------------------------------------------------------------------
input_align <- alignK(input[best_indices])

# -----------------------------------------------------------------------------
# Plot all K values together
# -----------------------------------------------------------------------------
p_all <- plotQ(input_align,
               imgoutput      = "join",
               returnplot     = TRUE,
               basesize       = 13,
               showyaxis      = FALSE,
               showticks      = TRUE,
               panelspacer    = 0.3,
               showindlab     = FALSE,
               useindlab      = TRUE,
               sharedindlab   = FALSE,
               grplab         = onelabset1,
               grplabsize     = 4,
               pointsize      = 6,
               linesize       = 7,
               linealpha      = 0.2,
               pointcol       = "white",
               grplabpos      = 0.5,
               linepos        = 0.5,
               grplabheight   = 0.75,
               grplabcol      = "black",
               ordergrp       = TRUE,
               selgrp         = "Region",
               sortind        = "all",
               divgrp         = "Region",
               divcol         = "black",
               divtype        = 1,
               divsize        = 1,
               splab          = paste0("K", seq_along(best_indices)),
               splabcol       = "black",
               splabface      = "bold",
               splabangle     = 0,
               theme          = "theme_bw",
               outputfilename = "admixture_ys_autosome",
               imgtype        = "png",
               height         = 2,
               width          = 30,
               exportplot     = TRUE,
               exportpath     = out_plots)

grid.arrange(p_all$plot[[1]])

# -----------------------------------------------------------------------------
# Plot optimal K (K3) in detail
# subsetgrp uses pop_order read from shared pop.list
# Update index in alignK() if optimal K changes after evalAdmix assessment
# -----------------------------------------------------------------------------
input_align_K3 <- alignK(input[c(which(best_indices == 23))])

p_K3 <- plotQ(input_align_K3,
              returnplot     = TRUE,
              basesize       = 13,
              showyaxis      = FALSE,
              showticks      = FALSE,
              showindlab     = FALSE,
              useindlab      = FALSE,
              indlabheight   = 0,
              showlegend     = TRUE,
              legendrow      = 1,
              legendkeysize  = 8,
              legendtextsize = 10,
              legendpos      = "left",
              grplab         = onelabset1,
              ordergrp       = FALSE,
              subsetgrp      = pop_order,
              sortind        = "all",
              grplabsize     = 3.5,
              grplabpos      = 0.5,
              grplabheight   = 0.2,
              pointsize      = 2,
              divgrp         = "Colony",
              divcol         = "black",
              divtype        = 1,
              divsize        = 1,
              splab          = "K3",
              splabcol       = "black",
              splabface      = "bold",
              splabangle     = 90,
              outputfilename = "admixture_ys_autosome_K3",
              imgtype        = "png",
              height         = 8,
              width          = 30,
              exportplot     = TRUE,
              exportpath     = out_plots)

grid.arrange(p_K3$plot[[1]])
