import numpy as np
import matplotlib.pyplot as plt

# Create some mock data
f=open("times","r")
dat=f.readlines()
lines=len(dat)
data1=np.empty(lines)
data2=np.empty(lines)
t=np.empty(lines)

i=0
for d in dat:
	d=d.split()
	data1[i]=float(d[1])
	t[i]=float(d[0])
	i=i+1
f=open("fitness","r")
dat=f.readlines()
i=0
for d in dat:
	d=d.split()
	print(d)
	data2[i]=float(d[1])
	i=i+1

fig, ax1 = plt.subplots()

color = 'tab:red'
ax1.set_xlabel('Generation')
ax1.set_ylabel('Time (Seconds)', color=color)
ax1.plot(t, data1, color=color)
ax1.tick_params(axis='y', labelcolor=color)
ax1.set_title('Generation Time and Fitness')

ax2 = ax1.twinx()  # instantiate a second axes that shares the same x-axis
color = 'tab:blue'
ax2.set_ylabel('Fitness', color=color)  # we already handled the x-label with ax1
ax2.plot(t, data2, color=color)
ax2.tick_params(axis='y', labelcolor=color)

fig.tight_layout()  # otherwise the right y-label is slightly clipped
plt.show()