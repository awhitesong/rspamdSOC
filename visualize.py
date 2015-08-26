# This uses TSNE to reduce the feature space and plots the initial distribution of corpus messages based on symbols 
# visualizing them in 2d space. 

import numpy as np
from sklearn.datasets import load_svmlight_file
from sklearn.manifold import TSNE
import matplotlib.pyplot as plt

fig=plt.figure()

#loading the training and testing data
X_train, y_train = load_svmlight_file('Trainlabels.txt')
X_test, y_test = load_svmlight_file('Testlabels.txt',n_features=X_train.shape[1]) 


#X_red is the 2 dimensional reduced form of original data. Used simple TSNE algo.
model = TSNE(n_components=2)
X_red = model.fit_transform(X_train)

#Visualizing using Scatter
fig.add_subplot('221')
plt.scatter(X_red[:,0],X_red[:,1],c=y_train,cmap=plt.cm.Paired)


#Extracting Separate Ham and spam data
X_red_ham=[]
X_red_spam=[]
for i in range(y_train.shape[0]):
	if y_train[i]==1:
		X_red_ham.append(X_red[i,:].tolist())
	elif y_train[i]==0:
		X_red_spam.append(X_red[i,:].tolist())

X_red_ham = np.array(X_red_ham)
X_red_spam = np.array(X_red_spam)

fig.add_subplot('222')
plt.scatter(X_red_ham[:,0],X_red_ham[:,1],c='brown',marker='o')

fig.add_subplot('223')
plt.scatter(X_red_spam[:,0],X_red_spam[:,1],c='cyan',marker='o')

plt.show()
