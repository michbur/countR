# omit NAs, convert table into list --------------------
process_counts <- function(input) {
  count_list <- lapply(1L:ncol(input), function(single_column) as.vector(na.omit(input[, single_column])))
  names(count_list) <- colnames(input)
  count_list
}

# summary counts -----------------------------------------
summary_counts <- function(count_list) {
  summaries <- data.frame(vapply(c(mean, median, sd, mad, max, min, length), function(single_fun)
    vapply(count_list, single_fun, 0), 
    rep(0, length(count_list))))
  colnames(summaries) <- c("mean", "median", "sd", "mad", "max", "min", "length")
  cbind(name = names(count_list), summaries)
  summaries
}
