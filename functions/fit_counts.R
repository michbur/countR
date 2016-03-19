fit_pois <- function(x, level, ...) {
  fit <- glm(x ~ 1, family = poisson(link = "log"), ...)
  
  confint_raw <- exp(suppressMessages(confint(fit, level =  level)))
  confint <- matrix(confint_raw, nrow = 1, dimnames = list("lambda", c("lower", "upper")))
  
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
  confint <- matrix(exp(confint_raw), nrow = 1, dimnames = list("lambda", c("lower", "upper")))
  
  
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
fit_counts <- function(counts_list, model, level = 0.95, ...) {
  # add proper name checker
  nice_model <- model
  
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
  
  all_fits
}


