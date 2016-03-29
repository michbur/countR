library(dplyr)
source("load_all.R")


load("healthy_list.RData")

patient_id <- names(healthy_list) %>% 
  strsplit("_") %>%
  sapply(last)

patient_concordance <- lapply(unique(patient_id), function(single_patient_id) {
  replicate_names <- names(healthy_list[patient_id == single_patient_id])
  
  dat <- lapply(replicate_names, function(i) data.frame(count_name = i, value = healthy_list[[i]])) %>%
    do.call(rbind, .)
  
  calc_concordance <- function(model, dat) 
    switch(model,
           pois = {
             fit <- glm(value ~ count_name, data = dat, family = poisson(link = "log"))
             coefs_rest <- summary(fit)[["coefficients"]][, "Pr(>|z|)"][-1]
             c(prop05 = mean(coefs_rest > 0.05), prop001 = mean(coefs_rest > 0.001), 
               BIC = AIC(fit, k = log(sum(!is.na(dat[["value"]])))))
           },
           nb = {
             fit <- MASS::glm.nb(value ~ count_name, data = dat)
             coefs_rest <- summary(fit)[["coefficients"]][, "Pr(>|z|)"][-1]
             c(prop05 = mean(coefs_rest > 0.05), prop001 = mean(coefs_rest > 0.001), 
               BIC = AIC(fit, k = log(sum(!is.na(dat[["value"]])))))
           },
           zip = {
             fit <- zeroinfl2(value ~ count_name, data = dat, dist = "poisson")
             coefs_rest <- summary(fit)[["coefficients"]][["count"]][, "Pr(>|z|)"][-1]
             c(prop05 = mean(coefs_rest > 0.05), prop001 = mean(coefs_rest > 0.001), 
               BIC = AIC(fit, k = log(sum(!is.na(dat[["value"]])))))
           },
           zinb = {
             fit <- zeroinfl2(value ~ count_name, data = dat, dist = "negbin")
             id_intercept_theta <- c(1, nrow(summary(fit)[["coefficients"]][["count"]]))
             coefs_rest <- summary(fit)[["coefficients"]][["count"]][, "Pr(>|z|)"][-id_intercept_theta]
             c(prop05 = mean(coefs_rest > 0.05), prop001 = mean(coefs_rest > 0.001), 
               BIC = AIC(fit, k = log(sum(!is.na(dat[["value"]])))))
           }
    )
  
  lapply(c("pois", "nb", "zip", "zinb"), function(single_model) {
    data.frame(model = single_model, t(calc_concordance(single_model, dat)))
  }) %>%
    do.call(rbind, .) %>%
    cbind(patient_id = single_patient_id, .)
}) %>%
  do.call(rbind, .)

library(ggplot2)

ggplot(patient_concordance, aes(x = patient_id, y = prop05, fill = model)) +
  geom_bar(position = "dodge", stat = "identity")

