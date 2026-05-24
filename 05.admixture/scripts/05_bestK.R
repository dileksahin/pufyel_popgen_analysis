# 05_bestK.R — Best K determination for NGSadmix results
# =============================================================================
# Input:  admix_ys50_autosome_runs_LH.txt (K, run, lnL for all runs)
# Output: bestK_plots.png — Pritchard mean lnL and Evanno deltaK plots
#         bestK_summary.txt — summary table of lnL and deltaK per K
#
# Methods:
#   Pritchard et al. (2000): best K = highest mean lnL across runs
#   Evanno et al. (2005): best K = highest deltaK
#     deltaK = |L''(K)| / sd(L(K))
#     where L''(K) is the second-order rate of change of lnL
#     Note: Evanno method cannot be applied to K=1 (no deltaK defined)
#
# Dependencies: ggplot2, dplyr, ggpubr
# =============================================================================

library(ggplot2)
library(dplyr)
library(ggpubr)

# Paths
# -----------------------------------------------------------------------------
wd        <- Sys.getenv("WD",         unset = "/path/to/working/directory")
lh_file   <- Sys.getenv("LH_FILE",    unset = file.path(wd, "admixture/admix_ys50_autosome_runs_LH.txt"))
out_plots <- Sys.getenv("OUT_PLOTS",  unset = file.path(wd, "admixture/plots"))

dir.create(out_plots, recursive = TRUE, showWarnings = FALSE)

# Load and validate likelihood file
# -----------------------------------------------------------------------------
Likelihoods <- read.delim(lh_file, header = TRUE)
Likelihoods$K   <- as.numeric(Likelihoods$K)
Likelihoods$run <- as.numeric(Likelihoods$run)
Likelihoods$lnL <- as.numeric(Likelihoods$lnL)

cat("Loaded", nrow(Likelihoods), "runs across",
    length(unique(Likelihoods$K)), "K values\n")

# Compute mean and SD per K
# -----------------------------------------------------------------------------
summary_lnL <- Likelihoods %>%
  group_by(K) %>%
  summarise(mean_lnL = mean(lnL),
            sd_lnL   = sd(lnL),
            n_runs   = n(),
            .groups  = "drop") %>%
  arrange(K)

print(summary_lnL)
write.table(summary_lnL,
            file.path(out_plots, "bestK_summary.txt"),
            sep = "\t", quote = FALSE, row.names = FALSE)

# Best K: Pritchard method (highest mean lnL)
# -----------------------------------------------------------------------------
best_pritchard <- summary_lnL %>%
  filter(mean_lnL == max(mean_lnL)) %>%
  pull(K)
cat("Best K (Pritchard — max mean lnL):", best_pritchard, "\n")

# Best K: Evanno method (deltaK)
# Requires K > 1; deltaK undefined at K=1 and K=K_max
# deltaK = |L''(K)| / sd(L(K))
# L'(K)  = mean_lnL(K) - mean_lnL(K-1)   first-order difference
# L''(K) = L'(K+1) - L'(K)               second-order difference
# -----------------------------------------------------------------------------
summary_evanno <- summary_lnL %>%
  filter(K > 1) %>%
  mutate(lnPrime       = mean_lnL - lag(mean_lnL),
         lnDoublePrime = lead(lnPrime) - lnPrime,
         deltaK        = abs(lnDoublePrime) / sd_lnL)

best_evanno <- summary_evanno$K[which.max(summary_evanno$deltaK)]
cat("Best K (Evanno — max deltaK):", best_evanno, "\n\n")

# Plot: Pritchard mean lnL ± SD
# -----------------------------------------------------------------------------
plot_pritchard <- ggplot(summary_lnL, aes(x = K, y = mean_lnL)) +
  geom_point(size = 3) +
  geom_line() +
  geom_errorbar(aes(ymin = mean_lnL - sd_lnL,
                    ymax = mean_lnL + sd_lnL), width = 0.2) +
  geom_vline(xintercept = best_pritchard,
             color = "red", linetype = "dashed") +
  labs(title = "Mean lnL ± SD per K (Pritchard)",
       y = "Mean lnL", x = "K") +
  theme_minimal()

# Plot: Evanno deltaK
# -----------------------------------------------------------------------------
plot_evanno <- ggplot(summary_evanno, aes(x = K, y = deltaK)) +
  geom_point(size = 3) +
  geom_line() +
  geom_vline(xintercept = best_evanno,
             color = "red", linetype = "dashed") +
  labs(title = "Evanno's deltaK method",
       x = "Number of clusters (K)",
       y = expression(Delta * K)) +
  theme_minimal(base_size = 14) +
  theme(panel.grid.minor = element_blank(),
        plot.title = element_text(hjust = 0.5))

# Save combined bestK figure
# -----------------------------------------------------------------------------
combined <- ggarrange(plot_pritchard, plot_evanno,
                      ncol = 2, nrow = 1,
                      labels = c("A", "B"))

ggsave(file.path(out_plots, "bestK_plots.png"),
       combined, width = 14, height = 6, dpi = 300, units = "in")
