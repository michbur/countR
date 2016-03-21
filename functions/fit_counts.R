fit_pois <- function(x, level, ...) {
  fit <- glm(x ~ 1, family = poisson(link = "log"), ...)
  
  confint_raw <- exp(suppressMessages(confint(fit, level =  level)))
  confint <- matrix(confint_raw, ncol = 2, dimnames = list("lambda", c("lower", "upper")))
  
  summ <- summary(fit)
  
  #AER::dispersiontest(all_fits[[8]][["fit"]], alternative = "greater")[["p.value"]]
  
  #qcc::qcc.overdispersion.test(repeat_list[[8]])[, "p-value"]
  
  list(fit = fit,
       coefficients = c(lambda = exp(unname(summ[["coefficients"]][, "Estimate"]))),
       confint = confint
  )
}

fit_nb <- function(x, level, ...) {
  fit <- MASS::glm.nb(x ~ 1, ...)
  summ <- summary(fit)
  
  confint_raw <- suppressMessages(confint(fit, level =  level))
  confint <- matrix(exp(confint_raw), ncol = 2, dimnames = list("lambda", c("lower", "upper")))
  
  
  list(fit = fit,
       coefficients = c(lambda = unname(exp(summ[["coefficients"]][1])),
                        theta = unname(summ[["theta"]])),
       confint = confint
  )
}

fit_zip <- function(x, level, ...) {
  fit <- zeroinfl2(x ~ 1, dist = "poisson", ...)
  summ <- summary(fit)
  
  list(fit = fit,
       coefficients = c(lambda = unname(exp(summ[["coefficients"]][["count"]][, "Estimate"])),
                        r = unname(invlogit(summ[["coefficients"]][["zero"]][, "Estimate"]))),
       confint = transform_zi_confint(suppressMessages(confint(fit, level =  level)))
  )
}


fit_zinb <- function(x, level, ...) {
  fit <- zeroinfl2(x ~ 1, dist = "negbin", ...)
  summ <- summary(fit)
  
  coefs <- unname(exp(summ[["coefficients"]][["count"]][, "Estimate"]))
  
  list(fit = fit,
       coefficients = c(lambda = coefs[1],
                        theta = coefs[2],
                        r = unname(invlogit(summ[["coefficients"]][["zero"]][, "Estimate"]))),
       confint = transform_zi_confint(suppressMessages(confint(fit, level =  level)))
  )
}


transform_zi_confint <- function(confint_data) {
  rownames(confint_data) <- c("lambda", "r")
  colnames(confint_data) <- c("lower", "upper")
  
  confint_data["lambda", ] <- exp(confint_data["lambda", ])
  confint_data["r", ] <- rev(invlogit(confint_data["r", ]))
  
  confint_data
}

fit_counts_single <- function(x, model, level, ...) {
  fitted_model <- switch(model,
                         pois = fit_pois(x, level = level, ...),
                         nb = fit_nb(x, level = level, ...),
                         zip = fit_zip(x, level = level, ...),
                         zinb = fit_zinb(x, level = level, ...)
  )
  
  # list(coefficients = fitted_model[["coefficients"]], 
  #      confint = fitted_model[["confint"]],
  c(fitted_model, 
    BIC = AIC(fitted_model[["fit"]], k = log(sum(!is.na(x)))),
    model = model)
}

#' @param model a single \code{character}: \code{"pois"}, \code{"nb"},  
#' \code{"zinb"}, \code{"zip"}, \code{"all"}. If \code{"all"}, dots parameters
#' are ignored.
#' @return List of fitted models. Names are names of original counts, an underline 
#' and a name of model used.
#' confint is a \code{matrix} with the number of rows equal to the number of 
#' parameters. Rownames are names of parameters. The columns contain respectively 
#' lower and upper confidence intervals.
fit_counts <- function(counts_list, single = TRUE, model, level = 0.95, ...) {
  # add proper name checker
  nice_model <- model
  
  if(single) {
    if(nice_model == "all") {
      all_fits <- unlist(lapply(c("pois", "zip", "nb", "zinb"), function(single_model)
        lapply(counts_list, fit_counts_single, model = single_model, level = level, ...)
      ), recursive = FALSE)
      names(all_fits) <- as.vector(vapply(c("pois", "zip", "nb", "zinb"), function(single_name) 
        paste0(names(counts_list), "_", single_name), rep("a", length(counts_list))))
    } else {
      all_fits <- lapply(count_list, fit_counts_single, model = nice_model, level = level, ...)
      names(all_fits) <- paste0(names(counts_list), nice_model)
    }
  } else {
    whole_data <- do.call(rbind, lapply(names(counts_list), function(single_name) 
      data.frame(count_name = single_name, value = healthy_list[[single_name]]))) 
    all_fits <- fit2fitlist(fit_zinb_whole(whole_data, level))
  }
  
  all_fits
}

fit2fitlist <- function(x) {
  BIC_val <- AIC(x[["fit"]], k = log(sum(!is.na(x[["fit"]][["data"]][["value"]]))))
  fitlist <- lapply(1L:length(x[["coefficients"]]), function(single_count) {
    list(coefficients = x[["coefficients"]][[single_count]],
         confint = x[["confint"]][[single_count]],
         BIC = BIC_val,
         model = x[["model"]])
  })
  names(fitlist) <- names(x[["coefficients"]])
  fitlist
}

fit_pois_whole <- function(x, level, ...) {
  fit <- glm(value ~ count_name - 1, data = x, family = poisson(link = "log"), ...)
  summ <- summary(fit)
  
  coefs <- exp(summ[["coefficients"]][, "Estimate"])
  names(coefs) <- sub("count_name", "", names(coefs))
  
  confint_raw <- exp(suppressMessages(confint(fit, level =  level)))
  rownames(confint_raw) <- names(coefs)
  
  list(fit = fit,
       coefficients = lapply(coefs, function(single_coef) c(lambda = single_coef)),
       confint = lapply(1L:nrow(confint_raw), 
                        function(single_row) 
                          matrix(confint_raw[single_row, ], ncol = 2, dimnames = list("lambda", c("lower", "upper")))),
       model = "pois"
  )
}

fit_nb_whole <- function(x, level, ...) {
  fit <- MASS::glm.nb(value ~ count_name - 1, data = x, ...)
  summ <- summary(fit)
  
  coefs <- exp(summ[["coefficients"]][, "Estimate"][-nrow(summ[["coefficients"]])])
  names(coefs) <- sub("count_name", "", names(coefs))
  
  confint_raw <- exp(suppressMessages(confint(fit, level =  level)))
  rownames(confint_raw) <- names(coefs)
  
  list(fit = fit,
       coefficients = lapply(coefs, function(single_coef) c(lambda = single_coef, theta = summ[["theta"]])),
       confint = lapply(1L:nrow(confint_raw), 
                        function(single_row) 
                          matrix(confint_raw[single_row, ], ncol = 2, dimnames = list("lambda", c("lower", "upper")))),
       model = "nb"
  )
}


fit_zip_whole <- function(x, level, ...) {
  fit <- zeroinfl2(value ~ count_name - 1, data = x, dist = "poisson", ...)
  summ <- summary(fit)
  
  lambdas <- unname(exp(summ[["coefficients"]][["count"]][, "Estimate"]))
  rs <- unname(invlogit(summ[["coefficients"]][["zero"]][, "Estimate"]))
  confint_raw <- suppressMessages(confint(fit, level =  level))
  
  coefs <- lapply(1L:length(lambdas), function(single_coef) 
    c(lambda = lambdas[single_coef], r = rs[single_coef]))
  names(coefs) <- sub("count_name", "", names(summ[["coefficients"]][["count"]][, "Estimate"]))

  list(fit = fit,
       coefficients = coefs,
       confint = lapply(1L:(nrow(confint_raw)/2), function(single_confint) 
         transform_zi_confint(confint_raw[c(single_confint + c(0, 6)), ])),
       model = "zip"
  )
}

fit_zinb_whole <- function(x, level, ...) {
  fit <- zeroinfl2(value ~ count_name - 1, data = x, dist = "negbin", ...)
  summ <- summary(fit)
  
  lambdas <- unname(exp(summ[["coefficients"]][["count"]][, "Estimate"]))
  rs <- unname(invlogit(summ[["coefficients"]][["zero"]][, "Estimate"]))
  confint_raw <- suppressMessages(confint(fit, level =  level))
  
  coefs <- lapply(1L:length(lambdas), function(single_coef) 
    c(lambda = lambdas[single_coef], theta = summ[["theta"]], r = rs[single_coef]))
  names(coefs) <- sub("count_name", "", names(summ[["coefficients"]][["count"]][, "Estimate"]))
  
  list(fit = fit,
       coefficients = coefs,
       confint = lapply(1L:(nrow(confint_raw)/2), function(single_confint) 
         transform_zi_confint(confint_raw[c(single_confint + c(0, 6)), ])),
       model = "zinb"
  )
}