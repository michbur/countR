#' @param confint \code{matrix} with the number of rows equal to the number of 
#' parameters. Rownames are names of parameters. The columns contain respectively 
#' lower and upper confidence intervals.


fit_pois <- function(x, level, ...) {
  fit <- glm(x ~ 1, family = poisson(link = "identity"), ...)
  
  confint_raw <- suppressMessages(confint(fit, level =  level))
  confint <- matrix(confint_raw, nrow = 1, dimnames = list("lambda", c("lower", "upper")))
  
  summ <- summary(fit)
  
  list(fit = fit,
       coefficients = c(lambda = unname(summ[["coefficients"]][, "Estimate"])),
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
                        size = unname(summ[["theta"]])),
       confint = confint
  )
}

fit_zip <- function(x, level, ...) {
  fit <- zeroinfl2(x ~ 1, dist = "poisson", ...)
  summ <- summary(fit)
  
  list(fit = fit,
       coefficients = c(lambda = unname(exp(summ[["coefficients"]][["count"]][, "Estimate"])),
                        p = unname(1 - invlogit(summ[["coefficients"]][["zero"]][, "Estimate"]))),
       confint = transform_zi_confint(suppressMessages(confint(fit, level =  level)))
  )
}


fit_zinb <- function(x, level, ...) {
  fit <- zeroinfl2(x ~ 1, dist = "negbin", ...)
  summ <- summary(fit)
  
  coefs <- unname(exp(summ[["coefficients"]][["count"]][, "Estimate"]))
  
  list(fit = fit,
       coefficients = c(lambda = coefs[1],
                        size = coefs[2],
                        p = unname(1 - invlogit(summ[["coefficients"]][["zero"]][, "Estimate"]))),
       confint = transform_zi_confint(suppressMessages(confint(fit, level =  level)))
  )
}


fit_counts <- function(x, model, level = 0.95, ...) {
  # add later proper name checker
  nice_model <- model
  fitted_model <- switch(nice_model,
                         pois = fit_pois(x, level = level, ...),
                         nb = fit_nb(x, level = level, ...),
                         zip = fit_zip(x, level = level, ...),
                         zinb = fit_zinb(x, level = level, ...)
  )
  
  #c(fitted_model, BIC = AIC(fitted_model[["fit"]], k = log(sum(!is.na(x)))))
  list(coefficients = fitted_model[["coefficients"]], 
       confint = fitted_model[["confint"]],
       BIC = AIC(fitted_model[["fit"]], k = log(sum(!is.na(x)))))
}


transform_zi_confint <- function(confint_data) {
  rownames(confint_data) <- c("lambda", "p")
  colnames(confint_data) <- c("lower", "upper")
  
  confint_data["lambda", ] <- exp(confint_data["lambda", ])
  confint_data["p", ] <- rev(1 - invlogit(confint_data["p", ]))
  
  confint_data
}