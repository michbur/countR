input <- read.csv("example_counts.csv")
input[3L:4, 3] <- NA

input[240L:250, 1L:3] <- NA

tmp <- process_counts(input)

load("repeat_list.RData")
summary_counts(repeat_list)[["mean"]]

all_fits <- fit_counts(repeat_list, model = "all")


acast(get_occs(tmp), x ~ count, value.var = "n")


library(ggplot2)

plot_occs(get_occs(tmp))

plot_fitlist(all_fits)

all_compared <- compare_fit(repeat_list, all_fits)

ggplot(all_compared, aes(x = x, y = value)) +
  geom_bar(stat = "identity", fill = NA, color = "black") +
  facet_grid(model ~ count) +
  geom_point(aes(x = x, y = n))

summ <- summary_fitlist(all_fits)
library(dplyr)

group_by(summ, count) %>%
  mutate(replicate_id = substr(as.character(count), 0, 1),
         patient_id  = strsplit(as.character(count), "[[:alpha:]]")[[1]][2],
         lowest = BIC == min(BIC)) %>%
  ggplot(aes(x = model, y = BIC, fill = lowest)) +
  geom_bar(stat = "identity") +
  facet_grid(replicate_id ~ patient_id, scales = "free")
