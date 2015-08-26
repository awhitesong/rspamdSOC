# This will take the composites in libsvm format and assign them weights using the parameters in SVM with linear kernel.
# The final weights will be written to a file.

from sklearn.datasets import load_svmlight_file
from sklearn import svm

X_composites, y_composites = load_svmlight_file("libsvmComposites.txt")

linear_svm = svm.SVC(kernel='linear',C=100.0)


linear_svm.fit(X_composites, y_composites)
print linear_svm.coef_

for i,j in enumerate(linear_svm.coef_.A[0]):
    with open('weights.txt', 'a' ) as p:
        p.write(str(i+1)+' '+str(j)+'\n')


