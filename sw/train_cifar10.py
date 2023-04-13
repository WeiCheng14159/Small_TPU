from models.mynet_qnn import mynet_qnn_v1
from models.mynet import mynet
from models.vgg16_qnn import vgg16_qnn_v1
from models.vgg16 import vgg16
from models.lenet5_qnn import lenet5_qnn_v1
from models.lenet5 import lenet5
from tensorflow.keras import datasets, layers, models
import tensorflow as tf
import os

# Set the GPU index you want to use (0-based)
os.environ['CUDA_VISIBLE_DEVICES'] = '0,1'


# Define the input shape of the network
input_shape = (32, 32, 3)
# Define the number of classes
num_classes = 10

model = vgg16(input_shape=input_shape, num_classes=num_classes)

# Load the CIFAR-10 dataset
(train_images, train_labels), (test_images,
                               test_labels) = datasets.cifar10.load_data()

# Normalize pixel values to be between 0 and 1
train_images, test_images = train_images / 255.0, test_images / 255.0

# Convert the labels to one-hot encoding
train_labels = tf.keras.utils.to_categorical(train_labels, num_classes)
test_labels = tf.keras.utils.to_categorical(test_labels, num_classes)

# TensorBoard
log_dir = "logs/fit"
tb_callback = tf.keras.callbacks.TensorBoard(log_dir=log_dir, histogram_freq=1)

# Train the model
model.fit(train_images, train_labels, epochs=30,
          validation_data=(test_images, test_labels), callbacks=[tb_callback])

model.save_weights('qnn.h5')
