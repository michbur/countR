# function that needs both input data and fits

fast_tabulate <- function(x) {
  # + 1, since we also count zeros
  tabs <- tabulate(x + 1)
  data.frame(x = 0L:(length(tabs) - 1), n = tabs)
}

# returns density function
get_density_fun <- function(single_fit) {
  switch(single_fit[["model"]],
         pois = function(x) dpois(x, lambda = single_fit[["coefficients"]][["lambda"]]), 
         nb = function(x) dnbinom(x, size = single_fit[["coefficients"]][["size"]], 
                                  mu = single_fit[["coefficients"]][["lambda"]]),
         zip = function(x) dZIP(x, lambda = single_fit[["coefficients"]][["lambda"]], 
                                p = single_fit[["coefficients"]][["p"]]),
         zinb = function(x) dZINB(x, size = single_fit[["coefficients"]][["size"]], 
                                  lambda = single_fit[["coefficients"]][["lambda"]], 
                                  p = single_fit[["coefficients"]][["p"]])
  )
}


compare_fit_single <- function(single_count, fitlist) {
  #occurences
  occs <- fast_tabulate(single_count)
  
  fits <- do.call(cbind, lapply(fitlist, function(single_fit) 
    get_density_fun(single_fit)(occs[["x"]])
  )) * sum(single_count)
  colnames(fits) <- vapply(fitlist, function(single_fit) single_fit[["model"]], "a")
  
  cbind(occs, fits)
}

compare_fit <- function(count_list, fitlist = fit_counts(count_list, model = "all")) {
  summ <- summary_fitlist(fitlist)
  
  count_ids <- lapply(names(count_list), function(single_count_name) which(summ[["count"]] == single_count_name))
  
  all_cmps <- lapply(1L:length(count_list), function(single_count_id)
    compare_fit_single(count_list[[single_count_id]], fitlist[count_ids[[single_count_id]]])
  )
  names(all_cmps) <- names(count_list)
  
  all_cmps
}