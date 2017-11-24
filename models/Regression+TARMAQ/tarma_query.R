source("tarma.R")
library("Metrics")

map <- function(train, test, k){
  num_transactions <- nrow(test)
  commits_train <- strsplit(as.character(train$V1),",")
  ap <- vector('numeric')
  n <- 1

  while(n <= num_transactions){
    files_query <-  test$V2[n];
    query <- strsplit(files_query, ",")[[1]]
    files_exp <-  test$V3[n];
    other_files <- strsplit(files_exp, ",")[[1]]
    
    ap[n] <- NA
    hits <- NA
    errors <- NA
    rules_list <- NA

    if (length(files) > 1){
      rules <- tarmaq(commits_train, query)
      num_predicted <- nrow(rules)
      if(nrow(rules) > 10)
        rules <- rules[1:10,]
      other_files <- setdiff(files, query)
      if(nrow(rules) > 0){
        ap[n] <- apk(k, as.vector(other_files), rules$consequent)
        hits <- length(intersect(other_files, rules$consequent))
        errors <- length(other_files) - hits
        rules_list <- unlist(rules$rule_name)
      }
    }
    
    resultsTest<-c(files_query, files_exp, unlist(rules_list), num_predicted, hits, errors, ap[n])
    finalResults <- data.frame(t(resultsTest))
    write.table(finalResults, "log_tarmaq_query.csv", append=TRUE, eol = "\n", sep=";", col.names = F, row.names = F)
    
    n <- n + 1
  }
  
  map <- sum(ap, na.rm = TRUE) / num_transactions

  return(map)
}