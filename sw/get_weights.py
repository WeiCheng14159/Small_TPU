import tensorflow as tf
import sys
import numpy as np

# Models
from models.mynet_qnn import mynet_qnn_v1
from models.mynet import mynet
from models.vgg16_qnn import vgg16_qnn_v1
from models.vgg16 import vgg16
from models.lenet5_qnn import lenet5_qnn_v1
from models.lenet5 import lenet5

# Utilities
from visualize.visualize_dist import plot_distribution
from utils.save_to_file import save_weights, save_inputs, save_outputs

if len(sys.argv) < 2:
    print("Usage: python get_wrights.py <loaded_model_name>")
    sys.exit(1)

# Get the model name from command line argument
model_name = sys.argv[1]

# Define the input shape of the network
input_shape = (28, 28, 1)
# Define the number of classes
num_classes = 10

model = mynet_qnn_v1(input_shape=input_shape, num_classes=num_classes)
model.load_weights(model_name)
model.summary()

# Specify the names of the layers whose weights you want to print
specific_layers = ['quant_fc1', 'quant_fc2', 'quant_fc3']

# Get the trained weight tensors for all fully connected layers
weight_tensors = []

# Iterate through the layers and print the weights
for layer in model.layers:
    if layer.name in specific_layers:
        # Get the weight tensor
        weight_tensor = layer.get_weights()[0]
        weight_tensors.append(weight_tensor)

# Create a random input tensor for testing
input_x = np.random.rand(1, 28, 28, 1)

# Evaluate the model and get the output tensors
outputs = model.predict(input_x)

# Store input tensor


# Print the iweight, and output tensors for all fully connected layers
for i, weight_tensor in enumerate(weight_tensors):
    print(f"Layer {i} weights shape: {weight_tensor.shape}")
    plot_distribution(weight_tensor, str(specific_layers[i]+".png"))
    print(weight_tensor)
