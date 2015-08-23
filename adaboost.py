from sklearn.ensemble import AdaBoostClassifier
from sklearn.tree import DecisionTreeClassifier
from collections import Counter

X_train, y_train = load_svmlight_file('Trainlabels.txt')
X_test, y_test = load_svmlight_file('Testlabels.txt',n_features=X_train.shape[1]) 


bdt = AdaBoostClassifier(DecisionTreeClassifier(),
                         n_estimators=200,
                         algorithm="SAMME")

bdt.fit(X_train, y_train)

y_ada = bdt.predict(X_test)

ada_results_compare = Counter(zip(y_test,y_ada))

print ada_results_compare