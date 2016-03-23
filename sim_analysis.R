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
filter(sim_dat, !is.na(prop)) %>%
  group_by(theta, lambda, replicate) %>%
  summarize(all_models = length(prop) == 4) %>%
  filter(all_models) %>%
  summarize(proper_fits = length(all_models)/100) %>%
  ggplot(aes(x = factor(theta), y = factor(lambda), fill = proper_fits, 
             label = formatC(proper_fits, digits = 2, format = "f"))) +
  geom_tile(color = "black") +
  geom_text(color = "red")
# no, for some combinations of theta and lambda models cannot be fitted


# which model is the hardest to fit?
filter(sim_dat, !is.na(prop)) %>%
  group_by(theta, lambda, model) %>%
  summarize(len = length(prop)/100) %>%
  ggplot(aes(x = factor(theta), y = factor(lambda), fill = len, 
             label = formatC(len, digits = 2, format = "f"))) +
  geom_tile(color = "black") +
  geom_text(color = "red") +
  facet_wrap(~ model)
# ZINB, other models are comparable


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


