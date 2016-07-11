##  Anomaly Detection in Time Evolving Networks

Implementation of Signature Similarity algorithm for time evolving graph comparison.

Data set: [Stanford Large Network Dataset Collection.](http://snap.stanford.edu/data/)

### Description

Implement only the algorithm described in Section 5.5 using Signature Similarity. Because of the way the similarity is calculated, anomalous graphs are identified by two consecutive anomalous time points in the output. For example, similarity score 1 is between graphs 1 and 2 and similarity score two is between graphs 2 and 3. If both similarity score 1 and similarity score 2 are found to be anomalous, the anomalous graph is then graph 2, since it is the one in common. Use the lower bound from the individual moving range threshold, and anything below it is an anomaly.

Based on paper: http://ilpubs.stanford.edu:8090/836/2/webgraph_similarity.pdf

### Results

Following visualization of Similarity values of 2 consecutive graphs shows those graphs as anomany which have value beyond the threshold value.

![anomalies.png]({{site.baseurl}}/anomaly-detection/anomalies.png)

