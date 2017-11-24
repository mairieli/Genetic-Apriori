#$ nohup Rscript ga.R hadoop .00003 .0005 5 unfixed > ../logs/saida.out &

args = commandArgs(trailingOnly=TRUE)
if (length(args) < 5) {
  stop("Informe os parametros!", call.=FALSE)
}

library("futile.logger")
flog.info("Started!")
library("GA")
library("reshape2")
library("ggplot2")
library("scatterplot3d")
library("arules")
source("query.R")

project_name <- args[1] 
percent_test <- args[4]
type <- args[5]
dirTran <- paste0("../datasets/projects_transactions/", type, "/", percent_test , "%/", project_name, "/")
transactions_train <- read.csv(paste0(dirTran,"transactions"), header=FALSE, sep=";", stringsAsFactors=FALSE)
transactions_test <- read.csv(paste0(dirTran,"random_transactions"), header=FALSE, sep=";", stringsAsFactors=FALSE)

dirResults <- paste0("../logs/", type, "/")
if(!dir.exists(dirResults)){
  dir.create(dirResults)
}
setwd(dirResults)

dirProj <- paste0(percent_test , "%_", project_name, "/")
if(!dir.exists(dirProj)){
  dir.create(dirProj)
}
setwd(dirProj)

confidence_min <- .1
confidence_max <- 1
support_min <- as.numeric(args[2]) 
support_max <- as.numeric(args[3]) 
transaction_train_min <- .1
transaction_train_max <- 1

mins <- c(confidence_min, support_min, transaction_train_min)
maxs <- c(confidence_max, support_max, transaction_train_max)

fitnessFunc <- function(x, train, test) {
  confidence <- x[1]
  support <- x[2]
  transaction_train <- x[3]
  
  num_commits <- nrow(train)
  num_commits_train <- trunc(num_commits * transaction_train)
  pos_train_start <- (num_commits - num_commits_train) + 1
  
  commits <- train[pos_train_start:num_commits,]
  
  splitTransactions <- strsplit(commits,",")
  transactions <- as(splitTransactions, "transactions")
  
  map <- query(transactions, support, confidence, test, 10);
  
  num_commits_test <- nrow(test)
  log <- c(support, confidence, transaction_train, num_commits_train, 
           num_commits_test, map)
  finalResults <- data.frame(t(log))
  write.table(finalResults, paste0("log_map.csv"), append=TRUE, eol = "\n", sep=";", col.names = F, row.names = F)
  
  return (map)
}

monitor <- function(obj) {
  if(obj@iter == 1){
    jpeg(filename = "populacao_inicial.jpg")
    print(obj@population)
    x <- obj@population[,1]
    y <- obj@population[,2]
    z <- obj@population[,3]
    scatterplot3d(x, y, z, highlight.3d=TRUE, pch=19,
                  type="h",        
                  lty.hplot=2,
                  main="População Inicial",
                  xlab="Confiança",
                  ylab="Suporte",
                  zlab="Treino")
    dev.off()
  }
  
  if(obj@iter == 100){
    jpeg(filename = "populacao_final.jpg")
    print(obj@population)
    x <- obj@population[,1]
    y <- obj@population[,2]
    z <- obj@population[,3]
    scatterplot3d(x, y, z, highlight.3d=TRUE, pch=19,
                  type="h",        
                  lty.hplot=2,
                  main="População Final",
                  xlab="Confiança",
                  ylab="Suporte",
                  zlab="Treino")
    dev.off()
  }
}

flog.info("Project: %s - Support min: %s Support max: %s", project_name, support_min, support_max)

model <- ga(type="real-valued", fitness = fitnessFunc, transactions_train, transactions_test, min = mins, max= maxs, popSize = 200, pcrossover = 0.8, pmutation = 0.1, parallel = 12, maxiter = 100, monitor = monitor, seed = 123, run = 40)

summary(model)
out <- plot(model)

df <- melt(out[,c(1:3,5)], id.var = "iter")
levels(df$variable)[levels(df$variable)=="median"] <- "Mediana"
levels(df$variable)[levels(df$variable)=="max"] <- "Melhor"
levels(df$variable)[levels(df$variable)=="mean"] <- "Média"

ggplot(df, aes(x = iter, y = value, group = variable, colour = variable)) +
  xlab("Geração") + ylab("Valor de Aptidão") +
  geom_point(aes(shape = variable)) +
  geom_line(aes(lty = variable)) +
  scale_colour_brewer(palette = "Set1") +
  theme_bw(base_size = 20) +
  theme(legend.title = element_blank(),
        axis.title =  element_text(size=16),
        legend.position = c(0.8, 0.2)) +
  ggsave("teste.png", width=7, height=6, dpi=100)
dev.off()
flog.info("Finished!")
