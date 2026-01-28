#!/usr/bin/env python
# coding: utf-8

# In[ ]:


import torch
import torch.nn as nn
import sys
from time import time as clock
#from numpy import sin,pi
#import numpy as np

print("python bin ",sys.executable," is ",sys.version)
if torch.cuda.is_available():
    device = "cuda"
    print("cuda device found. Using cuda.")
elif torch.backends.mps.is_available():
	device = torch.device("mps")
	print("MPS device found. Using MPS.")
else:
	device = torch.device("cpu")
	print("MPS/cuda not available. Using CPU.")

if( not 'ipykernel' in sys.modules ) :
    # not running in a notebook check for device on command line
    if len(sys.argv) > 1:
        device=sys.argv[1]
        print("device set to ",device)
#newstart
dim=2
mysize=1000
k= torch.randn(mysize, dim).to(device)

nf=k.size()[-1]
z=1.0

for n in range(0,nf) :
    k[:,n]=torch.linspace(-z, z, steps=mysize).to(device)
for m in range(0,k[:,1].size()[0]) :
    k[m,1]=k[m,1]**2

torch.manual_seed(0)  # for reproducibility
#This was the original 1d example
y = 2 * k -1 + 0.01 * torch.randn_like(k)
#model = torch.nn.Linear(1, 1).to(device)  # 1 input feature, 1 output

#Here we reset  K/Y to give use two independent dependencies
#Thus our outputs should be about 2,0,-1 and 0,4,-5; the coefficients
#of these two equations with 0 indicating no cross dependency.
y[:,0]= 2 * k[:,0] -1 + 0.01 * torch.randn_like(k[:,0])
y[:,1]= 4 * k[:,1] -5 + 0.01 * torch.randn_like(k[:,1])
model = torch.nn.Linear(2, 2).to(device)  # 2 input feature, 2 output

# Define a loss function and optimizer
criterion = torch.nn.MSELoss()  # mean squared error loss
optimizer = torch.optim.SGD(model.parameters(), lr=0.1)

t1=clock()
# Training loop
try:
	for epoch in range(2001):
			model.train()                 # set model to training mode (good practice)
			y_pred = model(k)             # forward pass: compute predicted y
			loss = criterion(y_pred, y)   # compute loss between prediction and true y
			optimizer.zero_grad()         # zero out gradients from previous step
			loss.backward()               # backpropagate to compute new gradients
			optimizer.step()              # update model parameters
			if epoch % 100 == 0:          # Print progress every 100 epochs
				print(f"Epoch {epoch:8d}: Loss = {loss.item():.8f}")
except Exception as e:
			print(f"An error occurred during training: {e}")

t2=clock()
# After training, let's see the learned parameters
w = model.weight
b = model.bias
t3=clock()
print(f"\nLearned parameters - Weight: {w}, \nBias: {b}")
print()
print(f"device:{str(device):s}    time:{(t3-t1):.4f}")


# In[ ]:


yout=k @ w.t()+b
ferror=sum(((yout-y)**2)**0.5)/yout.size()[0]
print("Difference:", ferror)


# In[ ]:




