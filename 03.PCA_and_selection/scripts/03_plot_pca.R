# 03_plot_pca.R — PCA visualisation for Yelkouan Shearwater population structure
# =============================================================================
# Input:  covariance matrix from PCAngsd (ys50_autosome.cov)
#         population cluster file (pop.clst)
# Output: PCA_combined.png — PC1v2 and PC2v3 side by side
#         scree_plot.png   — variance explained per principal component
#
# Dependencies: ggplot2, ggpubr
# Tested with R 4.x
# =============================================================================

library(ggplot2)
library(ggpubr)

# -----------------------------------------------------------------------------
# Paths — sourced from environment variables set by run_pca_pipeline.sh
# or edit directly for interactive use
# -----------------------------------------------------------------------------
wd          <- Sys.getenv("WD",        unset = "/path/to/working/directory")
cov_path    <- Sys.getenv("COV_MATRIX",unset = file.path(wd, "pca/ys50_autosome.cov"))
clst_path   <- Sys.getenv("POP_CLST",  unset = file.path(wd, "pop.clst"))
out_plots   <- Sys.getenv("OUT_PLOTS", unset = file.path(wd, "pca/plots"))
n_ind       <- as.integer(Sys.getenv("N_IND", unset = "188"))

dir.create(out_plots, recursive = TRUE, showWarnings = FALSE)

# Population color codes
# Order matches population levels: CZA FLE FPC FPQ FRI GGY ICA IMO ILA ISD IST ITA MCO MGO MMA TZE
color_codes <- c("brown", "#2b6fbb", "#6e4dc2", "#4c5cc5",
                 "#1c8c9a", "#000000", "#f48eb7", "#f9b5cf",
                 "#ec0089", "#ffdae8", "#c9cac8", "#d30075",
                 "#fecb00", "#ffe9b6", "#ff8112", "#08d43d")

# -----------------------------------------------------------------------------
# Load data
# -----------------------------------------------------------------------------
annot <- read.table(clst_path, sep = " ", header = TRUE)
covar <- read.table(cov_path, stringsAsFactors = FALSE)

# -----------------------------------------------------------------------------
# Eigendecomposition of covariance matrix
# -----------------------------------------------------------------------------
eig <- eigen(covar, symmetric = TRUE)
eig$val <- eig$val / sum(eig$val)
cat("Variance explained per PC (%):\n")
cat(signif(eig$val, digits = 3) * 100, "\n")

# -----------------------------------------------------------------------------
# Scree plot — variance explained per principal component
# -----------------------------------------------------------------------------
screeplot_df <- data.frame(
  prin_comp = seq_len(n_ind),
  var_expl  = signif(eig$val, digits = 3) * 100
)

scree_plot <- ggplot(screeplot_df, aes(prin_comp, var_expl)) +
  geom_point(alpha = 0.75) +
  labs(x = "Principal Component", y = "% Variance Explained") +
  theme_bw() +
  theme(panel.grid.major = element_blank(),
        panel.grid.minor = element_blank())

ggsave(file.path(out_plots, "scree_plot.png"),
       scree_plot, width = 8, height = 5, dpi = 300)
cat("Scree plot saved\n")

# -----------------------------------------------------------------------------
# Prepare PC data frame
# -----------------------------------------------------------------------------
PC <- as.data.frame(eig$vectors)
colnames(PC) <- gsub("V", "PC", colnames(PC))
PC$Pop <- factor(annot$CLUSTER)
PC$Tra <- factor(annot$IID)
PC$Lab <- factor(annot$FID)

# -----------------------------------------------------------------------------
# Shared theme for PCA plots
# -----------------------------------------------------------------------------
pca_theme <- theme_bw() +
  theme(panel.background  = element_blank(),
        panel.border      = element_rect(fill = NA),
        panel.grid.major  = element_blank(),
        panel.grid.minor  = element_blank(),
        strip.background  = element_blank(),
        axis.text.x       = element_text(colour = "black"),
        axis.text.y       = element_text(colour = "black"),
        axis.ticks        = element_line(colour = "black"),
        plot.margin       = unit(c(1, 1, 1, 1), "line"),
        plot.title        = element_text(hjust = 0.5, size = 16, face = "bold"),
        axis.title        = element_text(size = 12, face = "bold"),
        legend.position   = "none")

# -----------------------------------------------------------------------------
# Helper function to generate a PCA plot for any pair of PCs
# -----------------------------------------------------------------------------
plot_pca <- function(pc_x, pc_y, PC, eig, color_codes, pca_theme) {
  x_col <- paste0("PC", pc_x)
  y_col <- paste0("PC", pc_y)
  ggplot(data = PC,
         aes_string(x = x_col, y = y_col, fill = "Pop")) +
    geom_point(shape = 21, colour = "black", size = 3) +
    xlab(paste0("PC", pc_x, " (", signif(eig$val[pc_x], digits = 3) * 100, "%)")) +
    ylab(paste0("PC", pc_y, " (", signif(eig$val[pc_y], digits = 3) * 100, "%)")) +
    scale_fill_manual(values = color_codes) +
    labs(fill = "Populations") +
    pca_theme
}

# -----------------------------------------------------------------------------
# Generate PC1v2 and PC2v3 plots
# -----------------------------------------------------------------------------
pca_12 <- plot_pca(1, 2, PC, eig, color_codes, pca_theme)
pca_23 <- plot_pca(2, 3, PC, eig, color_codes, pca_theme)

# -----------------------------------------------------------------------------
# Save combined figure
# -----------------------------------------------------------------------------
combined <- ggarrange(pca_12, pca_23,
                      ncol = 2, nrow = 1,
                      common.legend = TRUE,
                      legend = "right",
                      labels = c("A", "B"))

ggsave(file.path(out_plots, "PCA_combined.png"),
       combined, width = 18, height = 6, dpi = 300, units = "in")
cat("Combined PCA plot saved\n")
