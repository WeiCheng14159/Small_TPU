# hex file explanation

## BaseKernel9.hex
- Each word is 9 bits, one word per row.
- Contains base kernel data
## FilterKernel9.hex
- Each word is 9 bits, one word per row.
- Contains filter kernel data
## Input8.hex
- Each word is 8 bits, one word per row.
- Contains input image data, 8 bit per pixel
## Output8.hex
- Each word is 8 bits, one word per row.
- Contains output image data, 8 bit per pixel
## param.hex
- Each word is 32 bits, one word per row.
- Contains layer configuration data.
- Row 1: Input image dimension (assume square)
- Row 2: Number of input channel
- Row 3: Number of kernels (also equals to the number of output channel)
- Row 4: Kernel dimension 