import numpy as np


def float_to_fixed(array, min_val=-6.0, max_val=6.0, num_bits=8):
    # Calculate the range of values that can be represented in the fixed point format
    range_val = max_val - min_val

    # Calculate the scale factor to convert from floating point to fixed point
    scale_factor = (2**num_bits - 1) / range_val

    # Convert the floating point array to fixed point by scaling and rounding
    fixed_array = np.round((array - min_val) * scale_factor)

    # Clip values that are above the maximum or below the minimum to the maximum or minimum values, respectively
    fixed_array[fixed_array > 2**num_bits - 1] = 2**num_bits - 1
    fixed_array[fixed_array < 0] = 0

    # Return the fixed point array
    return fixed_array


# Define an example array of floating point numbers
float_array = np.array([0.1, 0.5, 1.2, -0.3, 3.0, 2.5])

# Define the minimum and maximum values and the number of bits in the fixed point format
min_val = -6.0
max_val = 6.0
num_bits = 8

# Convert the floating point array to fixed point using the function
fixed_array = float_to_fixed(float_array, min_val, max_val, num_bits)

# Print the input and output arrays
print(f"Input array: {float_array}")
print(f"Fixed point array: {fixed_array}")
