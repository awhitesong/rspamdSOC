#This will use optimized SVM for predicting ham or spam class on the basis of symbols.

import numpy as np
from sklearn.datasets import load_svmlight_file
from sklearn import svm
from collections import Counter

#loading the training and testing data
X_train, y_train = load_svmlight_file('Trainlabels.txt')
X_test, y_test = load_svmlight_file('Testlabels.txt',n_features=X_train.shape[1]) 

#default kernel is rbf c=1 and gamma =0

svm_rbf = svm.SVC(C=9.0)

svm_rbf.fit(X_train,y_train)

predictions = svm_rbf.predict(X_test)

count = Counter(zip(y_test,predictions))

print count
