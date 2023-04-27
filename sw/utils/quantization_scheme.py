import numpy as np


class QuantizationScheme:
    def __init__(self, total_bits=16, int_bits=8):
        self.total_bits = total_bits
        self.int_bits = int_bits
        self.frac_bits = (total_bits - int_bits)
        # Quantization param
        self.q_unit = 1/(2.**self.frac_bits)
        self.q_min = -(2.**(self.int_bits - 1))
        self.q_max = 2.**(self.int_bits-1) - self.q_unit

    def convert(self, array):  # Quantization scheme uses 2's compliment
        # Remove the value that is smaller than q_unit
        fixed_arr = array - np.fmod(array, self.q_unit)

        # Clip values that are greater than max or less than min
        fixed_arr[fixed_arr < self.q_min] = self.q_min
        fixed_arr[fixed_arr > self.q_max] = self.q_max

        return fixed_arr


# Define the minimum and maximum values and the number of bits in the fixed point format
num_bits, num_int = 16, 8

q_sch = QuantizationScheme(num_bits, num_int)

# Define an example array of floating point numbers
float_array = np.array([0.0, 0.5, 1.2, -0.3, 3.0, 2.5])

# Convert the floating point array to fixed point using the function
fixed_arr = q_sch.convert(float_array)

# Print the input and output arrays
print(f"Input array: {float_array}")
print(f"Fixed point array: {fixed_arr}")
