input <- read.csv("example_counts.csv")
input[3L:4, 3] <- NA

input[240L:250, 1L:3] <- NA

# start function here

# omit NAs, convert table into list
count_list <- lapply(1L:ncol(input), function(single_column) as.vector(na.omit(input[, single_column])))
names(count_list) <- colnames(input)

# summary counts -----------------------------------------
summaries <- data.frame(vapply(c(mean, median, sd, mad, max, min), function(single_fun)
  vapply(count_list, single_fun, 0), 
  rep(0, length(count_list))))
colnames(summaries) <- c("mean", "median", "sd", "mad", "max", "min")
cbind(name = names(count_list), summaries)
summaries
