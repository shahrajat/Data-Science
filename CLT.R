#Rajat Shah
#Proving Central Limit Theorem

valid_input = 1		#later set to 0 if the input distribution type is not either normal or poisson

#Read all the parameters from user
dist <- readline(prompt="Distribution Type? ")
sample_size <- readline(prompt="Sample Size? ")
sample_size <- as.integer(sample_size)
num_samples <- readline(prompt="Number of samples? ")
num_samples <- as.integer(num_samples)

#Initialize data structures required
samples <-matrix(as.integer(), nrow=num_samples, ncol=sample_size) #matrix to store samples
means <- array()
stddev <- array()
pop_mean = 0
pop_std = 1

if(dist != "normal" & dist != "uniform")
{
	cat("Distribution can be either normal or uniform\n")
	valid_input = 0
}

if(valid_input == 1)
{
	#creating samples
	for(i in 1:num_samples)
	{
		if(dist=="normal"){
			samples[i,] = rnorm(sample_size)
		}
		else if(dist=="uniform"){
			samples[i,] = runif(sample_size)
			pop_mean=0.5
			pop_std = 0.28867513459
		}
		means[i] = mean(samples[i,])
		stddev[i] = sd(samples[i,]) 
	}
	
	#printing required information
	cat("Population parameters\n")
	cat("\tDistribution: \t",dist,"\n")
	cat("\tMean: \t\t",pop_mean,"\n")
	cat("\tStd Deviation: \t",pop_std,"\n")
		
	cat("Samples parameters\n")
	cat("\tNo. of Samples : \t",num_samples,"\n")
	cat("\tSamples Size: \t\t",sample_size,"\n")
	cat("\tMean : \t\t\t",mean(means),"\n")
	cat("\tCalculated std dev of sampling dist.: ",sd(means),"\n")
	cat("\tsigma/sqrt(sample size): ",pop_std/sqrt(sample_size),"\n")
	
	#plotting histogram
	h <- hist(means, breaks=10, col="white", main="Distribution of Sample means", xlab="Mean of Sample") 
	xdist <- seq(min(means),max(means),length=40) 
	ydist <- dnorm(xdist,mean=mean(means),sd=sd(means)) 
	ydist <- ydist*diff(h$mids[1:2])*length(means) 
	lines(xdist, ydist, col="blue", lwd=2)
	legend("topleft", c("Mean: ",mean(means)), bty="n") 

}
