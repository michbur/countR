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


compare_fit_single <- function(fitlist) {
  lapply(fitlist, function(single_fit) 
    get_density_fun(single_fit)(occs[["x"]])
  )
}

compare_fit <- function(count_list, fitlist = fit_counts(count_list, model = "all")) {
  summ <- summary_fitlist(fitlist)
  
  count_ids <- lapply(names(count_list), function(single_count_name) which(summ[["count"]] == single_count_name))
  
  do.call(rbind, lapply(1L:length(count_list), function(single_count_id) {
    occs <- fast_tabulate(count_list[[single_count_id]])
    
    model_names <- unlist(lapply(as.character(summ[count_ids[[single_count_id]], "model"]),
                                 rep, times = nrow(occs)))
    
    cmp <- cbind(count = names(count_list)[single_count_id], model = model_names, 
                 do.call(rbind, lapply(fitlist[count_ids[[single_count_id]]], function(single_fit) 
                   cbind(occs, value = get_density_fun(single_fit)(occs[["x"]]) * sum(count_list[[single_count_id]]))
                 )))
    rownames(cmp) <- NULL
    
    cmp
  }))
}