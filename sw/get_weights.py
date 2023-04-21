import tensorflow as tf
import sys
import numpy as np

# Models
from models.model_zoo import model_zoo

# Utilities
from visualize.visualize_dist import plot_distribution
from utils.save_to_file import save_weights, save_inputs, save_outputs

if len(sys.argv) < 2:
    print("Usage: python get_wrights.py <loaded_model_name.h5>")
    sys.exit(1)

# Get the model name from command line argument
model_filename = str(sys.argv[1])
model_name = model_filename.replace(".h5", "")

# Define the input shape of the network
input_shape = (28, 28, 1)
# Define the number of classes
num_classes = 10

if model_name not in model_zoo():
    print(
        f"Model '{model_name}' not found. Please choose from {list(model_zoo().keys())}.")
    sys.exit(1)

model = model_zoo()[model_name](
    input_shape=input_shape, num_classes=num_classes)
model.load_weights(model_filename)
model.summary()

# Specify the names of the layers whose weights you want to print
specific_layers = ['quant_fc1', 'quant_fc2', 'quant_fc3']

# Create a random input tensor for testing
input_x = np.random.rand(1, 28, 28, 1)

# Save inputs (of format: NHWC) as text file
save_inputs(input_x, "input.txt")

# Get the trained weight tensors
weight_tensors = []

# Iterate through layers of interests and store weight tensors
for layer in model.layers:
    if layer.name in specific_layers:
        weight_tensor = layer.get_weights()[0]
        weight_tensors.append(weight_tensor)

# Get the trained bias tensors
bias_tensors = []

# Iterate through layers of interests and store bias tensors
for layer in model.layers:
    if layer.name in specific_layers:
        bias_tensor = layer.get_weights()[1]
        bias_tensors.append(bias_tensor)

# Get the output tensors of each layer
output_tensors = []

# Iterate through the layers of interests and build an intermediate models. Then, store the output of that layer
for layer_name in specific_layers:
    temp_model = tf.keras.Model(inputs=model.input,
                                outputs=model.get_layer(layer_name).output)
    output_tensors.append(temp_model.predict(input_x))

# Print the weight tensors for targeted layers
for i, _ in enumerate(weight_tensors):
    # Get weight tensors
    tensor_w = weight_tensors[i]
    layer_name = specific_layers[i]

    # w
    print(f"Layer {i} weights shape: {tensor_w.shape}")
    # Save weights as text file
    save_weights(tensor_w, layer_name+"_w.txt")
    # Plot weight distributions and save as an image
    # plot_distribution(tensor_w, str(layer_name+"_w.png"))

# Print the output tensors for targeted layers
for i, _ in enumerate(output_tensors):
    # Get output tensors
    tensor_out = output_tensors[i]
    layer_name = specific_layers[i]

    # output
    print(f"Layer {i} output shape: {tensor_out.shape}")
    # Save outputs as text file
    save_weights(tensor_out, layer_name+"_out.txt")
    # Plot weight distributions and save as an image
    # plot_distribution(tensor_out, str(layer_name+"_out.png"))

# Print the bias tensors for targeted layers
for i, _ in enumerate(bias_tensors):
    # Get bias tensors
    tensor_bias = bias_tensors[i]
    layer_name = specific_layers[i]

    # output
    print(f"Layer {i} bias shape: {tensor_bias.shape}")
    # Save outputs as text file
    save_weights(tensor_bias, layer_name+"_bias.txt")
    # Plot weight distributions and save as an image
    # plot_distribution(tensor_out, str(layer_name+"_bias.png"))
