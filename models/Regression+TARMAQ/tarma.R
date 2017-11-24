library(hash)

tarmaq <- function(tx_store, query){
  k <- 0
  filtered_history <- list()
  
  query <- unlist(query)
  
  # filtering
  for(tx in tx_store){
    tx <- unlist(tx)
    # get interaction of transaction and query
    intersection <- intersect(tx, query)
    # check if intersection size is equal to current largest intersection size
    if (length(intersection) == k){
      filtered_history[[length(filtered_history) + 1]] <- tx
    } else if (length(intersection) > k){
      # there is a new largest querysubset
      k <- length(intersection)
      # reset the history
      filtered_history <- list()
      filtered_history[[1]] <- tx
    }
  }
  
  # rule creation
  result <- data.frame(matrix(ncol = 5, nrow = 0), stringsAsFactors = FALSE)
  colnames(result) <-  c("antecedent", "consequent", "rule_name", "support", "confidence")
  antecedents <- hash()
  
  for(tx in filtered_history){
    tx <- unlist(tx)
    antecedent <- sort(intersect(tx, query))
    consequents <- setdiff(tx, antecedent)
    
    if (length(antecedent) == 0) break
    
    # update antecedent count
    antecedent <- paste(antecedent, collapse = ",")
    if (!has.key(antecedent, antecedents)){
      antecedents[[antecedent]] <- 0
    }
    antecedents[[antecedent]] <- antecedents[[antecedent]] + 1
    
    for(consequent in consequents){
      rule_name <- paste0("{", antecedent, "} => {", consequent,"}")
      
      # support increases with 1/history_size
      rule = result[result$rule_name == rule_name, ]
      if(nrow(rule) != 0){
        new_support <- as.numeric(rule$support) + (1 / length(filtered_history))
        result[result$rule_name == rule_name, ]$support <- new_support
      } else {
        # new rule
        support <- 1 / length(filtered_history)
        new_rule <- c(antecedent, consequent, rule_name, support, 0)
        result[nrow(result) + 1, ] <- new_rule
      }
    }
    
    # update confidence of all rules with the current antecedent
    # confidence is support/support_of_antecedent
    rules_with_antecedent <- result[result$antecedent == antecedent, ]
    if(nrow(rules_with_antecedent) > 0) {
      for(i in 1:nrow(rules_with_antecedent)) {
        row <- rules_with_antecedent[i,]
        support_aux <-  as.numeric(row$support)
        new_confidence <- support_aux / (antecedents[[antecedent]] / length(filtered_history))
        result[result$rule_name == row$rule_name, ]$confidence = new_confidence
      }
    }
    
  }
  
  # sorting of rules
  result <- result[order(result$support, result$confidence, decreasing = TRUE),]
  return(result)
}