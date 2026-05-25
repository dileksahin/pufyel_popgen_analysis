# 06_plot_fst.R — Pairwise Fst heatmap and forest plot with 95% CI
# =============================================================================
# Input:  *.fst.txt files — global weighted and unweighted Fst per pair
#         *.bootstrap files — per-window Fst for CI calculation
#         pop.list — population order (shared from 02.genotype_likelihoods)
# Output: Fst_summary_with_significance.tsv — summary table
#         fst_heatmap.png — weighted Fst heatmap
#         fst_forest.png  — forest plot with 95% CI per pair
#
# Significance criterion: 95% bootstrap CI does not include 0
#
# Dependencies: ggplot2, dplyr
# =============================================================================

library(ggplot2)
library(dplyr)

# Paths
# -----------------------------------------------------------------------------
wd       <- Sys.getenv("WD",        unset = "/path/to/working/directory")
fst_dir  <- Sys.getenv("OUT_FST",   unset = file.path(wd, "fst"))
out_plots<- Sys.getenv("OUT_PLOTS", unset = file.path(wd, "fst/plots"))
pop_list <- Sys.getenv("POP_LIST",  unset = file.path(wd,
                       "../02.genotype_likelihoods/data/pop.list"))

dir.create(out_plots, recursive = TRUE, showWarnings = FALSE)

# Read population order from shared pop.list
# -----------------------------------------------------------------------------
if (!file.exists(pop_list)) {
  stop("pop.list not found at: ", pop_list,
       "\nCheck POP_LIST environment variable or PIPELINE_ROOT in config.sh")
}
pop_order <- readLines(pop_list)
pop_order <- pop_order[nzchar(trimws(pop_order))]
cat("Population order from pop.list:\n")
cat(paste(pop_order, collapse = " "), "\n\n")

# Parse all Fst result files and bootstrap files into summary table
# -----------------------------------------------------------------------------
fst_files <- list.files(fst_dir, pattern = "\\.fst\\.txt$", full.names = TRUE)

if (length(fst_files) == 0) {
  stop("No .fst.txt files found in: ", fst_dir)
}

fst_summary <- lapply(fst_files, function(f) {
  base  <- sub("\\.fst\\.txt$", "", f)
  fname <- basename(base)
  parts <- strsplit(fname, "_")[[1]]
  pop1  <- parts[1]
  pop2  <- parts[2]

  # Read global Fst (two values: unweighted, weighted)
  fst_vals <- scan(f, quiet = TRUE)
  if (length(fst_vals) != 2) {
    warning("Skipping ", f, ": expected 2 values, found ", length(fst_vals))
    return(NULL)
  }

  # Read bootstrap windows for CI calculation
  bootfile   <- paste0(base, ".bootstrap")
  mean_val   <- NA
  low_val    <- NA
  high_val   <- NA
  signif_val <- NA

  if (file.exists(bootfile)) {
    boot_data <- read.table(bootfile, header = TRUE)
    # Last column contains per-window Fst estimates
    boot_fst   <- boot_data[, ncol(boot_data)]
    mean_val   <- mean(boot_fst, na.rm = TRUE)
    low_val    <- quantile(boot_fst, 0.025, na.rm = TRUE)
    high_val   <- quantile(boot_fst, 0.975, na.rm = TRUE)
    # Significance: 95% CI excludes zero
    signif_val <- low_val > 0
  } else {
    warning("Bootstrap file not found: ", bootfile)
  }

  data.frame(
    POP1           = pop1,
    POP2           = pop2,
    Unweighted_Fst = fst_vals[1],
    Weighted_Fst   = fst_vals[2],
    Mean_Boot      = mean_val,
    Low95          = low_val,
    High95         = high_val,
    Significant    = signif_val,
    stringsAsFactors = FALSE
  )
})

fst_summary <- do.call(rbind, Filter(Negate(is.null), fst_summary))

# Apply population order from pop.list as factor levels
fst_summary$POP1 <- factor(fst_summary$POP1, levels = pop_order)
fst_summary$POP2 <- factor(fst_summary$POP2, levels = pop_order)

# Save summary table
out_file <- file.path(out_plots, "Fst_summary_with_significance.tsv")
write.table(fst_summary, out_file,
            sep = "\t", quote = FALSE, row.names = FALSE)


# Heatmap: weighted pairwise Fst
# Population order on both axes follows pop.list
# -----------------------------------------------------------------------------
heatmap_plot <- ggplot(fst_summary, aes(POP2, POP1)) +
  geom_tile(aes(fill = Weighted_Fst), color = "white") +
  geom_text(aes(label = round(Weighted_Fst, 2)),
            size = 3.5, colour = "white") +
  scale_fill_gradient(high = "black", low = "lightgray",
                      name = "Weighted Fst") +
  scale_x_discrete(limits = pop_order) +
  scale_y_discrete(limits = pop_order, position = "left") +
  theme_bw() +
  theme(panel.border      = element_blank(),
        panel.grid.major  = element_blank(),
        axis.title.x      = element_blank(),
        axis.title.y      = element_blank(),
        axis.ticks        = element_line(colour = "black"),
        plot.margin       = unit(c(1, 1, 1, 1), "line"),
        legend.position   = c(0.15, 0.75))

ggsave(file.path(out_plots, "fst_heatmap.png"),
       heatmap_plot, width = 10, height = 9, dpi = 300, units = "in")


# Forest plot: mean bootstrap Fst with 95% CI per population pair
# Pairs coloured by significance (CI excludes 0 = significant)
# -----------------------------------------------------------------------------
fst_forest <- fst_summary %>%
  mutate(Pair = paste(POP1, POP2, sep = "-"))

forest_plot <- ggplot(fst_forest,
                      aes(x = reorder(Pair, Mean_Boot), y = Mean_Boot)) +
  geom_point(aes(color = Significant), size = 3) +
  geom_errorbar(aes(ymin = Low95, ymax = High95,
                    color = Significant), width = 0.2) +
  coord_flip() +
  scale_color_manual(values = c("TRUE"  = "firebrick",
                                "FALSE" = "gray40"),
                     name   = "Significant\n(CI excludes 0)") +
  labs(title = "Pairwise global Fst with 95% bootstrap CI",
       x     = "Population pair",
       y     = "Fst (mean ± 95% CI)") +
  theme_minimal(base_size = 14) +
  theme(legend.position    = "bottom",
        panel.grid.minor   = element_blank())

ggsave(file.path(out_plots, "fst_forest.png"),
       forest_plot,
       width = 10, height = max(8, nrow(fst_forest) * 0.2),
       dpi = 300, units = "in")
