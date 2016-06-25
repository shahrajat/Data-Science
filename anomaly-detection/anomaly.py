from igraph import *
import pandas as pd
import sys
from os import listdir
from os.path import isfile, join
import hashlib
import matplotlib.pyplot as plt

#Returns the path of all the files for the folder given in CL arguments
#File list is sorted based on number prefixed in filename
def get_file_list():
	if(len(sys.argv) != 2):
		print "Incorrect parameters"
		return
	folder = sys.argv[1]
	files = [f for f in listdir(folder) if isfile(join(folder, f))]
	files =  sorted(files, key=lambda f: (int(f.partition('_')[0])))
	return map(lambda f: folder+f, files)
	
#Returns the directed graph represented by the input file
def file_to_graph(f):
	edgelist = pd.read_csv(f, sep=' ', header = None)
	n = edgelist[0][0]	#Number of vertices
	m = edgelist[1][0]	#Number of edges
	edgelist = edgelist[1:]
	edgeTuples = [tuple(x) for x in edgelist.values]
	graph = Graph(directed=True)		#Directed Igraph object to be returned
	graph.add_vertices(n)
	graph.add_edges(edgeTuples)
	return graph

#Returns weighted features from input Graph
def graph_to_featureset(g):
	#Vertex quality (or weight) = it's pagerank value
	page_rank = g.pagerank()
	vertex_feature_set = [ (str(ti),wi) for ti,wi in enumerate(page_rank)]
	
	#Weight of each edge (u, v) = quality(v)/out_degree
	edge_feature_set = []
	for edge in g.get_edgelist():
		(u, v) = edge
		ti = str(u)+' '+str(v)
		wi = page_rank[u]/g.outdegree(u)
		edge_feature_set.append((ti, wi))
		
	#Overall feature set for the input graph
	feature_set = vertex_feature_set + edge_feature_set
	return feature_set

#Returns simHash for the graph using feature_set as input 
def sim_hash(feature_set):
	b = 128
	#B-bits vector to be returned, b=128 in this case and md5 128 bit hashing is used 
	h = [0]*b
	
	for ti, wi in feature_set:
		#Digest for toxen ti
		hex_dig = hashlib.md5( ti.encode('utf-8') ).hexdigest() 
		#convert to binary digest
		binary_dig = bin(int(hex_dig, 16) )[2:].zfill(b)
		#summing up +wi for each 1 in hash, -wi for each 0
		for i in range(b):
			h[i] += wi if binary_dig[i] == '1' else -wi
			
	#set ith entry to 1 if entry is positive, 0 otherwise
	for i in range(b):
		h[i] = 1 if h[i] > 0 else 0
	return h

#Returns a list simHash for all the files	
def get_simhash_list(files):
	simhash_list = []
	i = 1
	for f in files: 
		g = file_to_graph(f)
		feature_set = graph_to_featureset(g)
		simhash_list.append(sim_hash(feature_set))
		i += 1
	return simhash_list

#returns similarity between two simHash vectors. similarity is (1 - hamming_dist/b)
def get_similarity(x, y):
    b = len(x)

    #Hamming Distance is count of disaggrement 
    hamming_dist = 0
    for i in range(b):
        if x[i] != y[i]: 
        	hamming_dist += 1 
    return(1 - float(hamming_dist)/b)

#get median, moving average, lower, and upper threshold for anomalous points similarity
def get_threshold(similarities):
    m = median(similarities)
    n = len(similarities) 
    if n < 2: return(m)
    
    #Moving Average calculation
    mr_sum = 0
    for i in range(1,n):
        mr_sum += abs(similarities[i] - similarities[i-1]) #mr(i) = |x(i+1) - x(i)|
    mr = float(mr_sum)/(n-1)

    #Return a dictionary with lower threshold and median value
    return({"median": m, "mr": mr, "lower": m - 3*mr})

#Plot results with visualtization for anamalous points
def plot_result(sim_list, threshold, filename):
	plt.plot(range(0, len(sim_list)), sim_list, 'ro', color = '0.8')
	plt.axis([0, len(sim_list), min(sim_list)-0.02, max(sim_list)+0.02]) 
	plt.title('Graph Similarity Plot' )
	plt.xlabel('Graph Index')
	plt.ylabel('Similarity')
	plt.grid(True)   
    #Draw horizontal line for lower threshold.
	line1, = plt.plot([0, len(sim_list)], [threshold["lower"], threshold["lower"]], 'r--', lw=1, alpha=0.75)
	plt.legend([line1], ['Threshold (Median - 3*MR)'])
	plt.savefig(filename)

#returns anamalous points based on the threshold
def get_anomalous_points(sim_list, threshold):
    anomalous_point = []
    #Ignoring last point 
    for index, similarity in enumerate(sim_list[:-1]):
        next_similarity = sim_list[index+1]
        if ( (similarity < threshold["lower"] and next_similarity < threshold["lower"]) ):
            #Finding the disance of anamolous point from median in order to perform sorting
            distance_from_median = abs( similarity - threshold["median"] )
            anomalous_point.append( (index+1, distance_from_median) )
    return(anomalous_point)

#Writes output to a txt file
def write_output(anomalous_points, out_put_file):
   
    number_of_anomalies = len(anomalous_points)
    out_file = open(out_put_file , 'w+') 
    out_file.write(str(number_of_anomalies))

    #Reverse Sorting anomalous points based on distance from median
    anomalous_points.sort(key= lambda item: item[1], reverse=True)

    for i in range(number_of_anomalies):
        out_file.write( '\n' + str( anomalous_points[i][0] ) )

    out_file.close()
#-------------------------------------------------------------------------------------------------
#Flow of main program

#Get all files
files = get_file_list()[:10]

#Get singature digest of all graphs 
signature_list = get_simhash_list(files)

#Total days for which graphs are present
num_days = len(files)
sim_list = []
for i, j in zip(signature_list, signature_list[1:]):
	similarity = get_similarity(i, j)
	sim_list.append(similarity) 

#Calculate the threshold
threshold = get_threshold(sim_list)

#File name of output file
output_file = "out_newer"

#Plot the results
plot_result(sim_list, threshold, output_file+".png")

#Calculate Anamolous Points using similarities and threshold
anomalous_point = get_anomalous_points(sim_list, threshold)

write_output(anomalous_point, output_file)
