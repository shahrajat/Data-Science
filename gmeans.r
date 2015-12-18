# Based on Learning the K in K-Means : http://papers.nips.cc/paper/2526-learning-the-k-in-k-means.pdf 
# G-Means(Gaussian Means) Algorithm Implementation
# Rajat Shah

library(fpc)
library(nortest)
library(cluster)
library(graphics)

#builds new model with the steps suggested in paper for each center
getKm = function(xi, c){
  pca = prcomp(xi)
  lambda = pca$sdev[1]^2  #lambda corresponding to PC
  s = pca$rotation[,1]    #s is the eigen vector
  m = s*sqrt(2*lambda/pi)
  km = kmeans(xi,rbind(c+m,c-m))  #use c+-m as the new centers
  return (km)
}

#Computes the optimal K and returns the set of centers for K clusters
gmeans = function(data, centers, alpha){
  if(dim(centers)[1]==1){       #k=1 , directly call kmeans
    km = kmeans(data, 1)
  }
  else{
    km = kmeans(data, centers)
  }
  returnCenters = c()
  numClusters = nrow(km$centers)
  for(i in 1:numClusters){
    xi = data[km$cluster == i,]     #Subset of X corresponding to cluster "i"
    ci = km$centers[i,]
    newKm = getKm(xi,ci)
    #initializing new "children" centers of c
    c1 = newKm$centers[1,]
    c2 = newKm$centers[2,]
    v = c1-c2
    xdash = as.matrix(xi)%*%v/(norm(as.matrix(v))^2)  #calculate X' by projecting X on V
    xdash = scale(xdash)    #scale to get mean=0 and var = 1
    ad = ad.test(xdash)       #test value
    if(ad$p.value <= alpha){  #reject NULL hyposthesis, use new centers
      returnCenters = rbind(returnCenters, newKm$centers[1,],newKm$centers[2,])
    }
    else{
      returnCenters = rbind(returnCenters, ci)
    }
  }
  return (returnCenters)
}

#calls G-Means repeatedly and returns the centers
main = function(data, alpha){
  k = 1
  initialCenter = kmeans(data,k)$centers           #initial set of centers
  centersList = initialCenter
  temp = c()
  repeat {
    temp = gmeans(data, centersList, alpha)
    if(length(centersList) == length(temp)){   #no new centers created in this iteration
      break
    }
    centersList = temp
  }
  optimalK = dim(centersList)[1]
  cat ("Optimal number of clusters: ",optimalK)
  #create the model for the optimal centers found
  model = kmeans(data, centersList)
  #plot the data, use PCA for >2 dimensions
  clusplot(data, model$cluster, lines = 4, cex = 0.4, xlab = "Dimension 1", ylab = "Dimension 2", col.p = "dark blue" )
}

#MAKE CHANGES HERE

#Modify the CSV File
data = read.csv("hw5-3d-data.csv", head=T)

#set alpha as required
alpha = 0.0001

main(data, alpha)
