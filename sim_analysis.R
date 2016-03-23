load("sim_dat.RData")

library(dplyr)
library(ggplot2)

# single_theta <- 10^-3
# single_lambda <- 0.5
# 
# foci <- lapply(1L:10, function(dummy) rnbinom(600, size = single_theta, mu = single_lambda))
# names(foci) <- paste0("C", 1L:10)
# 
# fit_counts(foci, separate = TRUE, model = "all")

# can all models be fitted?
filter(sim_dat, !is.na(lambda)) %>%
  group_by(theta, lambda) %>%
  summarize(proper_fits = length(replicate)/400) %>%
  ggplot(aes(x = factor(theta), y = factor(lambda), fill = proper_fits, 
             label = formatC(proper_fits, digits = 2, format = "f"))) +
  geom_tile(color = "black") +
  geom_text(color = "red")
# no, for some combinations of theta and lambda models cannot be fitted


# 
filter(sim_dat, !is.na(prop), model != "zinb") %>%
  group_by(theta, lambda, replicate) %>%
  mutate(all_models = length(prop) == 3) %>% 
  filter(all_models) %>%
  group_by(theta, lambda, model) %>% 
  summarise(prop = median(prop)) %>%
  ggplot(aes(x = factor(theta), y = factor(lambda), fill = prop, 
             label = formatC(prop, digits = 2, format = "f"))) +
  geom_tile(color = "black") +
  geom_text(color = "red") +
  facet_wrap(~ model)


