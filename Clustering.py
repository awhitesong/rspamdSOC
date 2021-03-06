# This will use DBSCAN clustering to detect strong points and clusters specific to spam and ham and write the produced composites and 
# clusters. Final cleaned points will be exported in libsvm format.

import numpy as np 
from sklearn.datasets import load_svmlight_file
from sklearn.cluster import DBSCAN
import pickle
import matplotlib.pyplot as plt 
from sklearn.datasets import dump_svmlight_file
from collections import Counter


X_train, y_train = load_svmlight_file("Trainlabels.txt")
X_test, y_test = load_svmlight_file("Testlabels.txt", n_features = X_train.shape[1])

#make clusters of training data using dbscan
dbscan = DBSCAN(eps=.5, min_samples = 3)
db = dbscan.fit(X_train)
set(db.labels_)


#this removes noise in reduced dimensions
rem_noise_pts = []
rem_noise = []
rem_noise_y = []
s_no = []

for i,cls in enumerate(db.labels_.tolist()):
    if cls!=-1:
        rem_noise = np.append(rem_noise,cls)
        rem_noise_pts = np.append(rem_noise_pts,X_red[i,:])
        rem_noise_y = np.append(rem_noise_y,y_train[i])
        s_no = np.append(s_no,i)


rem_noise_pts = rem_noise_pts.reshape(-1,2) 

fig = 	plt.figure()
fig.add_subplot(121)
plt.scatter(rem_noise_pts[:,0],rem_noise_pts[:,1],c=rem_noise)

fig.add_subplot(122)
plt.scatter(rem_noise_pts[:,0],rem_noise_pts[:,1],c=rem_noise_y,cmap=plt.cm.Paired)


plt.show()


#Count the ham and spam in each cluster
dict_count = {}

for i in set(rem_noise):
    dict_count[i] = [0,0]


for i,cl in enumerate(rem_noise):
    if rem_noise_y[i]==1: 
            dict_count[cl][0] += 1
    elif rem_noise_y[i]==0:
            dict_count[cl][1] += 1



#count number of actual ham and spam left after removing the noise
Counter(rem_noise_y)



#combine class and composition and save to a file
composition = np.array([])
for i,j in dict_count.items():
    composition = np.append(composition,i)
    composition = np.append(composition,j)


composition = composition.reshape(-1,3)

np.savetxt("Composition(min=3,eps=.5).txt",composition,fmt="%i")

#Getting all the symbols
symbols = np.loadtxt('allSymbolsNumbered.txt',usecols=(1,),dtype=np.str)

#writing composites to a file
for i in s_no:
    temp = []
    for j in X_train[i].nonzero()[1]:
            temp.append(symbols[j-1])
    with open('Clusters/%i.txt' % db.labels_[i] ,'a') as file:
            file.write(' '.join(temp) + '\n')

pure_cluster_sno = np.array([])

#this will remove the mixed clusters and put strong clusters acc. to cluster name in ham and spam files.
for i in s_no:
    if 0 in dict_count[db.labels_[i]]:
	    pure_cluster_sno = np.append(pure_cluster_sno,i)
	    temp = []
	    for j in X_train[i].nonzero()[1]:
	            temp.append(symbols[j-1])
	    if dict_count[db.labels_[i]].index(0) == 1:
	    	with open('Composites/ham/%i.txt' % db.labels_[i] ,'a') as file:
	    		file.write(' '.join(temp) + '\n')
	    else:
	    	with open('Composites/spam/%i.txt' % db.labels_[i] ,'a') as file:
	    		file.write(' '.join(temp) + '\n')

pure_cluster_sno = pure_cluster_sno.astype(int)
X_pure_cluster = X_train[pure_cluster_sno]
y_pure_cluster = y_train[pure_cluster_sno]

#making libsvm type file for pure cluster points to be used in OneClass SVM to decide whether to train message for bayes or not
dump_svmlight_file(X_pure_cluster,y_pure_cluster,"pure_cluster_pts.txt")
