input <- read.csv("example_counts.csv")
input[3L:4, 3] <- NA

input[240L:250, 1L:3] <- NA

tmp <- process_counts(input)

load("repeat_list.RData")
load("healthy_list.RData")
summary_counts(healthy_list)[["mean"]]
healthy_list_fitc


all_fits_separate <- fit_counts(healthy_list[1L:6], separate = TRUE, model = "all", level = 1)
all_fits_whole <- fit_counts(healthy_list[1L:6], separate = FALSE, model = "all")

max_len <- max(lengths(healthy_list[1L:6]))

write.csv(do.call(cbind, lapply(healthy_list[1L:6], function(i)
  c(i, rep(NA, max_len - length(i))))), file = "six_replicates.csv", row.names = FALSE)

library(ggplot2)

plot_occs(get_occs(tmp))

plot_fitlist(all_fits_whole)

all_compared <- compare_fit(healthy_list[1L:6], all_fits_whole)

ggplot(all_compared, aes(x = x, y = value)) +
  geom_bar(stat = "identity", fill = NA, color = "black") +
  facet_grid(model ~ count) +
  geom_point(aes(x = x, y = n))

patient_id <- names(healthy_list) %>% 
  strsplit("_") %>%
  sapply(last)

all_fits_fitc <- lapply(unique(patient_id), function(single_patient) {
  fit_counts(healthy_list_fitc[patient_id == single_patient], separate = FALSE, model = "all")
})

all_fits_apc <- lapply(unique(patient_id), function(single_patient) {
  fit_counts(healthy_list_apc[patient_id == single_patient], separate = TRUE, model = "all")
})

summary_fitlist(all_fits_apc[[1]])

lapply(all_fits_fitc, summary_fitlist)

max_len <- max(lengths(healthy_list[patient_id == 72]))

write.csv(do.call(cbind, lapply(healthy_list[patient_id == 72], function(i)
  c(i, rep(NA, max_len - length(i))))), file = "six_replicates_bad.csv", row.names = FALSE)

compare_fit(healthy_list_fitc[patient_id == 72], fit_counts(healthy_list[patient_id == 72], separate = TRUE, model = "all"))
