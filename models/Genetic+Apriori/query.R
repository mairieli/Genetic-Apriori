library("arules")
library("Metrics")

query <- function(train, support, confidence, commits, k){
  if(length(train) < 1){
    return(0)
  }

  ap <- vector('numeric')
  num_transactions <- nrow(commits)
  n <- 1
  while(n <= num_transactions){
    query <-  commits$V2[n];
    files_query <- strsplit(query, ",")[[1]]
    files_exp <-  commits$V3[n];
    other_files <- strsplit(files_exp, ",")[[1]]

    ap[n] <- NA
    hits <- NA
    errors <- NA
    rules_list <- NA
    num_predicted <- 0
    
    exist <- as.vector(files_query) %in% train@itemInfo$labels
    if(all(exist == TRUE)){
      max_len <- length(files_query) + 1
      rules_apri <- apriori(train, 
                            parameter = list(supp = support, conf = confidence, minlen = 2, maxlen = max_len),
                            appearance = list(lhs=as.vector(files_query), default="rhs")) 
      if(length(rules_apri) > 0){
        rules = data.frame(
          lhs = labels(lhs(rules_apri)),
          rhs = labels(rhs(rules_apri)), 
          rule_name = paste0(labels(lhs(rules_apri)), "=>", labels(rhs(rules_apri))),
          rules_apri@quality)
        
        pre <- paste(sort(as.vector(files_query)), collapse = ',')
        precedent_rules <- subset(rules, rules$lhs == paste0("{",pre,"}"))
        num_predicted <- nrow(precedent_rules)
        if(num_predicted > 0){
          predicted <- precedent_rules[order(precedent_rules$support, precedent_rules$confidence, decreasing = TRUE),]
          predicted_rules <- gsub(".* ", "", as.vector(predicted$rhs))
          predicted_rules <- gsub("[{}]", "", predicted_rules)
          ap[n] <- apk(k, as.vector(other_files), predicted_rules)
          rules_list <- unlist(as.character(predicted$rule_name))
          hits <- length(intersect(as.vector(other_files), predicted_rules))
          errors <- length(other_files) - hits
        }
      }
    }
    
    n <- n + 1
  }
  
  map <- sum(ap, na.rm = TRUE) / num_transactions
  
  return(map)
}