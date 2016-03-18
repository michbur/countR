
AER::dispersiontest(all_fits[[8]][["fit"]], alternative = "greater")[["p.value"]]

qcc::qcc.overdispersion.test(repeat_list[[8]])[, "p-value"]

#epiR::epi.bohning
