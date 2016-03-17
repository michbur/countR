input <- read.csv("example_counts.csv")
input[3L:4, 3] <- NA

input[240L:250, 1L:3] <- NA

tmp <- process_counts(input)
summary_counts(tmp)

all_fits <- fit_counts(tmp, model = "all")
summary_fitlist(all_fits)

library(ggplot2)

plot_fitlist(all_fits)



compare_fit(tmp, all_fits)
