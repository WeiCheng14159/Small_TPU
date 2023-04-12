import os
# Set the GPU index you want to use (0-based)
os.environ['CUDA_VISIBLE_DEVICES'] = '0,1'

import tensorflow as tf
from tensorflow.keras import datasets

from models.lenet5 import lenet5, lenet5_qnn
from models.vgg16 import vgg16, vgg16_qnn

# Define the input shape of the network
input_shape = (28, 28, 1)
# Define the number of classes
num_classes = 10

model = lenet5_qnn(input_shape=input_shape, num_classes=num_classes)

# Load the MNIST dataset and preprocess the data
(x_train, y_train), (x_test, y_test) = datasets.mnist.load_data()

# Reshape the data to match the input shape of the model
x_train = x_train.reshape(-1, 28, 28, 1)
x_test = x_test.reshape(-1, 28, 28, 1)

# Convert the labels to one-hot encoded vectors
y_train = tf.keras.utils.to_categorical(y_train, num_classes)
y_test = tf.keras.utils.to_categorical(y_test, num_classes)

# TensorBoard
log_dir = "logs/fit"
tb_callback = tf.keras.callbacks.TensorBoard(log_dir=log_dir, histogram_freq=1)

# Train the model on the training data
model.fit(x_train, y_train, batch_size=128, epochs=30,
          validation_data=(x_test, y_test),
          callbacks=[tb_callback])
