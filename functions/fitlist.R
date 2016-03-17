

get_count_names <- function(fitlist) {
  model_names <- strsplit(names(fitlist), "_")
  vapply(model_names, function(single_name) paste0(single_name[-length(single_name)], collapse = "_"), "a")
}

summary_fitlist <- function(fitlist) {
  BICs <- vapply(fitlist, function(single_fit) single_fit[["BIC"]], 0)
  lambdas <- vapply(fitlist, function(single_fit) single_fit[["coefficients"]]["lambda"], 0)
  CIs <- t(vapply(fitlist, function(single_fit) single_fit[["confint"]]["lambda", ], c(0, 0)))
  models <- vapply(fitlist, function(single_fit) single_fit[["model"]], "a")
  data.frame(count = get_count_names(fitlist), lambda = lambdas, CIs, BIC = BICs, model = models)
}

plot_fitlist <- function(fitlist) {
  summ <- summary_fitlist(fitlist)
  ggplot(summ, aes(x = count, y = lambda, ymax = upper, ymin = lower, color = model)) +
    geom_point() +
    geom_errorbar() +
    facet_wrap(~ model, ncol = 1)
}
