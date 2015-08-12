import numpy as np
from sklearn.datasets import load_svmlight_file
from sklearn import svm
from collections import Counter

#loading the training and testing data
X_train, y_train = load_svmlight_file('Trainlabels.txt')
X_test, y_test = load_svmlight_file('Testlabels.txt',n_features=X_train.shape[1]) 


"""
pure_train_X, pure_train_y = load_svmlight_file('pure_cluster_pts.txt',n_features=X_train.shape[1])
X_test, y_test = load_svmlight_file('Testlabels.txt',n_features=X_train.shape[1]) 
"""


svm_rbf = svm.SVC(C=9.0) 	#default kernel is rbf c=1 and gamma =0

svm_rbf.fit(X_train,y_train)

predictions = svm_rbf.predict(X_test)

#pr = predictions.tolist()

#pr = [str(x) for x in pr] 

#y_test_str = [str(x) for x in y_test]

count = Counter(zip(y_test,predictions))

print count

"""inal_val = ['%s        %s\n' % (y_test_str[x], pr[x]) for x in range(len(pr))]

with open('predictionsSVM.txt','w') as p:
	p.write('ACTUAL  PREDICTED\n')
	p.writelines(final_val)
"""