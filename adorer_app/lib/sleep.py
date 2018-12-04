import numpy as np
import matplotlib.pyplot as plt
#plt.plot(x[:-1], np.diff(y)/np.diff(x))
#plt.show()

derivatives = [[],[],[]]

def compute_derivative(x1,y1):
	return(np.diff(y1)/np.diff(x1))

def compute_distance(der):
	for i in range(0, 3):
		der[i] = compute_derivative(x,y)
	der_fin = np.sqrt(np.sum(np.square(der), axis=0))
	print(der_fin)
	return(der_fin)

def compute_peaks(fin):
	deep_sleep_score = 0
	rem_score = 0
	deep_sleep = np.max(fin)/3
	for i in range(0, np.size(fin)):
		if (fin[i] <= deep_sleep):
			deep_sleep_score+=1
		elif(fin[i] <= 2*deep_sleep):
			rem_score += 0.5
	return(deep_sleep_score + rem_score)

final = compute_distance(derivatives)
print(compute_peaks(final))
