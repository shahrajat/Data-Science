#Input: algorithm and numberOfSimulations(optional, default = 100)
#Example: RScript greedy 10
set.seed(0)
#Read Bidder Dataset and Queries list
bidder_dataset <- read.csv("C:/Users/Rajat/Google Drive/CSC 591 ADBI/Assignments/07.Topic-7.Project-7.AdWordsPlacement.BipartiteGraphMatching/bidder_dataset.csv")
Originalqueries <- read.delim("C:/Users/Rajat/Google Drive/CSC 591 ADBI/Assignments/07.Topic-7.Project-7.AdWordsPlacement.BipartiteGraphMatching/queries.txt", header=FALSE, quote="", stringsAsFactors=FALSE)

#Create mapping from Keyword (query) to Advertiser for faster lookup
combine <- function(arg){
  paste(as.numeric(arg),collapse=",",sep="")
}
query_to_bidders <- aggregate(Advertiser ~ Keyword, bidder_dataset, combine)

# Create Budgets Dataframe (mapping from advertiser -> budget)
Originalbudgets <- data.frame(0:99, 100*c(0))
colnames(Originalbudgets) <- c("Advertiser", "Budget")
for(i in 0:99){
  Originalbudgets[Originalbudgets$Advertiser==i,]$Budget <- bidder_dataset[bidder_dataset$Advertiser==i,][1,]$Budget
}

#Note: What happens in case of a tie? Since I have aggregated the values 
#in query_to_bidders data frame, it has bidders in sorted ids, and I only update
#highest bidder's variable in case it has higher bid
#this way tie is handled as expected in the problem.
adwords <- function(algo, numSimulations){
  revenues = c()
  OPT = sum(bidder_dataset[!is.na(bidder_dataset$Budget), ]$Budget)
  #Run simulations
  for(i in 1:numSimulations){
    revenue = 0.0
    queries <- as.data.frame.character(Originalqueries[sample(nrow(Originalqueries)),])
    budgets = Originalbudgets
    for(i in 1:nrow(queries)){
      q <- as.character(queries[i,])
      biddersString <- query_to_bidders[query_to_bidders$Keyword == q,]$Advertiser
      bidders <- as.numeric(unlist(strsplit(biddersString, ",")))
      highestBidder = -1
      highestBidderValue = -1
      
      if(algo=="greedy"){
        #Find the best bidder
        for(bidder in bidders){
          bidderBudget = budgets[budgets$Advertiser==bidder, ]$Budget
          bidderValue = bidder_dataset[bidder_dataset$Advertiser==bidder & bidder_dataset$Keyword==q, ]$Bid.Value
          
          if(bidderBudget > 0.0 && bidderValue > highestBidderValue){
            highestBidder = bidder
            highestBidderValue = bidderValue
          }
        }
        #Calculate revenue and update budget for the selected bidder
        if(highestBidder > -1){
          budgets[budgets$Advertiser==highestBidder, ]$Budget = budgets[budgets$Advertiser==highestBidder, ]$Budget - highestBidderValue
          revenue =  revenue + highestBidderValue
        }
      }
      else if(algo=="msvv"){
        #Find the best bidder
        for(bidder in bidders){
          bidderBudget = budgets[budgets$Advertiser==bidder, ]$Budget
          bidderValue = bidder_dataset[bidder_dataset$Advertiser==bidder & bidder_dataset$Keyword==q, ]$Bid.Value
          bidderOriginalBudget = bidder_dataset[bidder_dataset$Advertiser==bidder, ][1,]$Budget
          bidderBudgetSpent = bidderOriginalBudget - bidderBudget
          xu = bidderBudgetSpent/bidderOriginalBudget
          phi_xu = 1- exp(xu - 1)
          if(bidderBudget > 0.0 && bidderValue*phi_xu > highestBidderValue){
            highestBidder = bidder
            highestBidderValue = bidderValue*phi_xu
          }
        }
        #Calculate revenue and update budget for the selected bidder
        if(highestBidder > -1){
          bidderValue = bidder_dataset[bidder_dataset$Advertiser==highestBidder & bidder_dataset$Keyword==q, ]$Bid.Value
          budgets[budgets$Advertiser==highestBidder, ]$Budget = budgets[budgets$Advertiser==highestBidder, ]$Budget - bidderValue
          revenue =  revenue + bidderValue
        }
        compRatio = 1
      }
      else if(algo=="balance"){
        #Find the best bidder
        for(bidder in bidders){
          bidderBudget = budgets[budgets$Advertiser==bidder, ]$Budget
          if(bidderBudget > 0.0 && bidderBudget > highestBidderValue){
            highestBidder = bidder
            highestBidderValue = bidderBudget
          }
        }
        #Calculate revenue and update budget for the selected bidder
        if(highestBidder > -1){
          bidderValue = bidder_dataset[bidder_dataset$Advertiser==highestBidder & bidder_dataset$Keyword==q, ]$Bid.Value
          budgets[budgets$Advertiser==highestBidder, ]$Budget = budgets[budgets$Advertiser==highestBidder, ]$Budget - bidderValue
          revenue =  revenue + bidderValue
        }
      }
      else{
        print("Something went wrong, did you pass correct args?")
        return(1)
      }
    }
    revenues = c(revenues, revenue)
  }
  cat(mean(revenues), "\n", mean(revenues)/OPT)
}

#algorithms = c("greedy", "msvv", "balance")
args = commandArgs(trailingOnly=TRUE)
numSimulations = 100
if(length(args) == 2){
  numSimulations = args[2]
}
adwords(args[1], numSimulations)
