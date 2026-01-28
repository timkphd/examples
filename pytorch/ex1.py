import torch
from time import time as clock
import sys

# Set up device (CPU or GPU if available)
#device = "cuda" if torch.cuda.is_available() else "cpu" print(f"Using device: {device}")

if torch.backends.mps.is_available():
	device = torch.device("mps")
	print("MPS device found. Using MPS.")
else:
	device = torch.device("cpu")
	print("MPS not available. Using CPU.")

if len(sys.argv) > 1:
	device=sys.argv[1]
	print("device set to ",device)

# Create a synthetic dataset for y = 2x - 1 (linear relationship)
torch.manual_seed(0)  # for reproducibility
X = torch.linspace(-1, 1, steps=100).unsqueeze(1).to(device)  # 100x1 tensor of inputs
y = 2 * X - 1  + 0.2 * torch.randn_like(X)  # true relationship with some noise# Define a simple linear model f(x) = wx + b using nn.Linear
for a,b in zip(X,y):
	print(a,b)
model = torch.nn.Linear(1, 1).to(device)  # 1 input feature, 1 output# Define a loss function and optimizer
criterion = torch.nn.MSELoss()  # mean squared error loss
optimizer = torch.optim.SGD(model.parameters(), lr=0.1)

t1=clock()
# Training loop
try:
	for epoch in range(5001):
			model.train()                 # set model to training mode (good practice)
			y_pred = model(X)             # forward pass: compute predicted y
			loss = criterion(y_pred, y)   # compute loss between prediction and true y
			optimizer.zero_grad()         # zero out gradients from previous step
			loss.backward()               # backpropagate to compute new gradients
			optimizer.step()              # update model parameters
			if epoch % 100 == 0:          # Print progress every 100 epochs
				print(f"Epoch {epoch:>3}: Loss = {loss.item():.4f}")
except Exception as e:
			print(f"An error occurred during training: {e}")

t2=clock()
# After training, let's see the learned parameters
w = model.weight.item()
b = model.bias.item()
t3=clock()
print(f"Learned parameters - Weight: {w:.2f}, Bias: {b:.2f}")

print(device,t2-t1,t3-t3,t3-t1)