import sys
import numpy as np
import matplotlib.pyplot as plt

# Get the filename from the command line argument
if len(sys.argv) < 2:
    print('Usage: python visualize_mnist.py file_contains_fp.txt')
    sys.exit()
filename = sys.argv[1]

# Read in the list of 784 floating point numbers from the file
with open(filename, 'r') as f:
    numbers = [float(x) for x in f.read().split()]

# Convert the list to a numpy array
array = np.array(numbers)

# Reshape the array to a 28x28 matrix
array = np.reshape(array, (28, 28))

# Draw the black and white image using matplotlib
plt.imshow(array, cmap='binary')
# Show the plot
plt.savefig("mnist.png")
