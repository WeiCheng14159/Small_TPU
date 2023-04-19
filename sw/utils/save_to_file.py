import numpy as np


def save_weights(w, filename):
    data = w.flatten()
    write_float32(data, filename)


def save_inputs(inp, filename):
    data = inp.flatten()
    write_float32(data, filename)


def save_outputs(outp, filename):
    data = outp.flatten()
    write_float32(data, filename)


def write_float32(data, filename):
    if not isinstance(data, np.ndarray):
        raise ("This is not an numpy ndarray")
    if len(data.shape) != 1:
        raise ("numpy ndarray is not flattened")
    with open(filename, 'w') as f:
        for i in range(data.shape[0]):
            f.write('{:.8f}\n'.format(data[i]))
    f.close()
