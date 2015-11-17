#!/usr/bin/python
from sklearn.ensemble import RandomForestRegressor
from sklearn.ensemble import AdaBoostRegressor
from sklearn.ensemble import BaggingRegressor
from sklearn.ensemble import GradientBoostingRegressor
from sklearn import cross_validation
import numpy as np
import matplotlib.pyplot as plt
import math as math

import csv_io
def main():
   #read in the training file
   header, csv = csv_io.read_csv("transactions.csv")
   header = np.array(header[2:])
   weight = np.array([x[0] for x in csv])
   target = [x[1] for x in csv]
   days_ago = [x[2] for x in csv]
   #balance = [x[9] for x in csv]
   train = [x[2:] for x in csv]


   print('fitting the model')

   rf = RandomForestRegressor(oob_score=True, n_estimators=100, max_features="auto")
   #rf = RandomForestRegressor(n_estimators=100)
   scores = cross_validation.cross_val_score(rf, train, target, cv=3)
   print scores
   print("Accuracy: %0.2f (+/- %0.2f)" % (scores.mean(), scores.std() * 2))

   #rf = AdaBoostRegressor()
   #scores = cross_validation.cross_val_score(rf, train, target, cv=3)
   #print("Accuracy: %0.2f (+/- %0.2f)" % (scores.mean(), scores.std() * 2))

   #rf = GradientBoostingRegressor()
   #scores = cross_validation.cross_val_score(rf, train, target, cv=3)
   #print("Accuracy: %0.2f (+/- %0.2f)" % (scores.mean(), scores.std() * 2))

   #rf = BaggingRegressor()
   #scores = cross_validation.cross_val_score(rf, train, target, cv=3)
   #print("Accuracy: %0.2f (+/- %0.2f)" % (scores.mean(), scores.std() * 2))
   #return

   #rf.fit(train, target, weight)
   rf.fit(train, target)
   print "oob_score: %f" % rf.oob_score_ 

   #print target
   #print list(rf.oob_prediction_)

   order = np.argsort(rf.feature_importances_)[::-1]
   print order[0:19]
   print header[order[0:19]]
   print rf.feature_importances_[order[0:19]]
   print np.sum(rf.feature_importances_[order[0:19]])
   print np.sum(rf.feature_importances_)

   return
   print np.array(np.array(range(len(train))),rf.feature_importances_)
   print list(np.sort(rf.feature_importances_))
   #x = np.array([target, list(rf.oob_prediction_)]).T
   #print x
   print rf.oob_score_ 

   #plt.plot(days_ago, balance, 'g-')
   #plt.show()

   plt.plot(days_ago, target, 'g-', days_ago, list(rf.oob_prediction_), 'r-')
   plt.show()

   #plt.plot(target, list(rf.oob_prediction_), 'r.')
   #plt.show()

if __name__=="__main__":
    main()
