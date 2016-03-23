

get_count_names <- function(fitlist) {
  model_names <- strsplit(names(fitlist), "_")
  vapply(model_names, function(single_name) paste0(single_name[-length(single_name)], collapse = "_"), "a")
}

summary_fitlist <- function(fitlist) {
  CIs <- t(sapply(fitlist, function(single_fit) single_fit[["confint"]]["lambda", ]))
  data.frame(count = get_count_names(fitlist), 
             lambda = unlist(lapply(fitlist, function(single_fit) single_fit[["coefficients"]][["lambda"]])), 
             CIs, 
             BIC = unlist(lapply(fitlist, function(single_fit) single_fit[["BIC"]])), 
             theta = unlist(lapply(fitlist, function(single_fit) single_fit[["coefficients"]]["theta"])),
             r = unlist(lapply(fitlist, function(single_fit) single_fit[["coefficients"]]["r"])),
             model = vapply(fitlist, function(single_fit) single_fit[["model"]], "a"),
             nice_model = nice_model_names[vapply(fitlist, function(single_fit) single_fit[["model"]], "a")])
}

plot_fitlist <- function(fitlist, model_names = c("pois", "nb", "zip", "zinb")) {
  summ <- summary_fitlist(fitlist)

  plot_dat <- do.call(rbind, lapply(levels(summ[["count"]]), function(single_count) {
    single_count_dat <- summ[summ[["count"]] == single_count, ]
    data.frame(single_count_dat, 
               lowest_BIC = ifelse(1L:nrow(single_count_dat) == which.min(single_count_dat[["BIC"]]), TRUE, FALSE))
  }))
  
  ggplot(droplevels(plot_dat[plot_dat[["model"]] %in% model_names, ]), 
         aes(x = nice_model, y = lambda, ymax = upper, ymin = lower, color = lowest_BIC)) +
    geom_point() +
    geom_errorbar() +
    facet_wrap(~ count) +
    scale_x_discrete("Model") +
    scale_y_continuous(expression(lambda)) + 
    scale_color_discrete("The lowest BIC") +
    my_theme
}
