#!/usr/bin/env python
# coding: utf-8

# In[ ]:


import torch
import torch.nn as nn
import numpy as np
import sys
from time import time as clock


# In[ ]:


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
#device = torch.device("cpu")
print("final device ",device)


# In[ ]:


#
torch.manual_seed(0)  # for reproducibility
wingboxes=79
angles=37


# In[ ]:


invert=True
dtype = np.float32
file_path = 'data/rcsout.bin'
numpy_array = np.fromfile(file_path, dtype=dtype)
#numpy_array = numpy_array.reshape(numpy_array.shape[0]//angles,angles)
numpy_array = numpy_array.reshape(angles,numpy_array.shape[0]//angles)
numpy_array=numpy_array.T

if invert:
    print("finding a function to map rcs to wing")
else:
    print("finding a function that maps wing to rcs")

if invert :
    k = torch.from_numpy(numpy_array).to(device)
else:
    y = torch.from_numpy(numpy_array).to(device)

file_path = 'data/cells.bin'
numpy_array = np.fromfile(file_path, dtype=dtype)
#numpy_array = numpy_array.reshape(numpy_array.shape[0]//wingboxes,wingboxes)
numpy_array = numpy_array.reshape(wingboxes,numpy_array.shape[0]//wingboxes)
numpy_array=numpy_array.T

if invert :
    y = torch.from_numpy(numpy_array).to(device)
else:
    k = torch.from_numpy(numpy_array).to(device)

#use random data...
#y= torch.randn(y.size()[0], y.size()[1]).to(device)
#k= torch.randn(k.size()[0], k.size()[1]).to(device)

nf=k.size()[-1]
nout=y.size()[-1]
model = torch.nn.Linear(nf,nout,bias=True).to(device)  # input feature, output
print("inputs: ",k.size(),"\noutputs",y.size(),"\nmodel",y.size(),model)


# In[ ]:


print(y[0,:].size(),y[0,:])


# In[ ]:


print(k[0,:].size(),k[0,:])


# In[ ]:


fart=model(k[0,:])
print(fart.size(),fart)


# In[ ]:


# Define a loss function and optimizer
criterion = torch.nn.MSELoss()  # mean squared error loss
optimizer = torch.optim.SGD(model.parameters(), lr=0.0005)
t1=clock()
# Training loop
try:
	for epoch in range(100000):
			model.train()                 # set model to training mode (good practice)
			y_pred = model(k)             # forward pass: compute predicted y
			loss = criterion(y_pred, y)   # compute loss between prediction and true y
			optimizer.zero_grad()         # zero out gradients from previous step
			loss.backward()               # backpropagate to compute new gradients
			optimizer.step()              # update model parameters
			if epoch % 1000 == 0:          # Print progress every 100 epochs
				print(f"Epoch {epoch:8d}: Loss = {loss.item():.8f}")
except Exception as e:
			print(f"An error occurred during training: {e}")
t2=clock()
# After training, let's see the learned parameters
w = model.weight
b = model.bias
t3=clock()
print(f"time for {str(device):s} {(t3-t1):6.2f} seconds")


# In[ ]:


w = model.weight
b = model.bias
print("weight matrix size ",w.size(),"\nbias size",b.size())


# In[ ]:


w


# In[ ]:


b


# In[ ]:


tinput=k[0,:]
z=k[0,:] @ w.t()


# In[ ]:


print("input size",tinput.size()," output size",z.size())


# In[ ]:


print("input\n",tinput)


# In[ ]:


print("y\n",y[0,:])


# In[ ]:


print("z\n",z)


# In[ ]:


print("z-y\n",z-y[0,:])


# In[ ]:




