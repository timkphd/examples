#!/usr/bin/env python
# coding: utf-8



# This code is based on the implementation of Mohammad Pezeshki available at
# https://github.com/mohammadpz/pytorch_forward_forward and licensed under the MIT License.
# Modifications/Improvements to the original code have been made by Vivek V Patel.

import torch
import torch.nn as nn
from torchvision.datasets import MNIST
from torchvision.transforms import Compose, ToTensor, Normalize, Lambda
from torch.utils.data import DataLoader
from torch.optim import Adam
import time
import sys

def overlay_y_on_x(x, y, classes=10):
    x_ = x.clone()
    x_[:, :classes] *= 0.0
    x_[range(x.shape[0]), y] = x.max()
    return x_


class Net(torch.nn.Module):
    def __init__(self, dims):

        super().__init__()
        self.layers = []
        for d in range(len(dims) - 1):
            self.layers = self.layers + [Layer(dims[d], dims[d + 1]).to(device)]

    def predict(self, x):
        goodness_per_label = []
        for label in range(10):
            h = overlay_y_on_x(x, label)
            goodness = []
            for layer in self.layers:
                h = layer(h)
                goodness = goodness + [h.pow(2).mean(1)]
            goodness_per_label += [sum(goodness).unsqueeze(1)]
        goodness_per_label = torch.cat(goodness_per_label, 1)
        return goodness_per_label.argmax(1)

class Layer(nn.Linear):
    def __init__(self, in_features, out_features, bias=True, device=None, dtype=None):
        super().__init__(in_features, out_features, bias, device, dtype)
        self.relu = torch.nn.ReLU()
        self.opt = Adam(self.parameters(), lr=args.lr)
        self.threshold = args.threshold
        self.num_epochs = args.epochs

    def forward(self, x):
        x_direction = x / (x.norm(2, 1, keepdim=True) + 1e-4)
        return self.relu(torch.mm(x_direction, self.weight.T) + self.bias.unsqueeze(0))

if __name__ == "__main__":
	ptname=sys.argv[1]
	print("reloading saved model",ptname)
	model=torch.load(ptname,weights_only=False)
	transform = Compose(
		[
			ToTensor(),
			Normalize((0.1307,), (0.3081,)),
			Lambda(lambda x: torch.flatten(x)),
		]
		)

	device = torch.accelerator.current_accelerator()
	test_dataset=MNIST("./data/", train=False, download=True, transform=transform)
	for it in range(0,10):        
		image,lable=test_dataset[it]
	#help(net.eval)
		with torch.no_grad():
			bonk=image.unsqueeze(0)
			dbonk=bonk.to(device)
			output=model.predict(dbonk)
			print(it,lable,int(output[0]),lable==int(output[0]))
