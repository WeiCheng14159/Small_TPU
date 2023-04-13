import tensorflow as tf
import tensorflow_model_optimization as tfmot
from quant_config.dense_q import DenseQuantizeConfig
from utils.quant_utils import quant_Dense_layer


def mynet(input_shape, num_classes,
          conv_config=[(1, (5, 5), (1, 1), 'same', 'relu'),
                       (1, (5, 5), (1, 1), 'same', 'relu')],
          fc_config=[(1, 'relu'),
                     (1, 'relu'),
                     (10, 'softmax')]):

    model = tf.keras.models.Sequential()

    # Add the input layer
    model.add(tf.keras.layers.Input(shape=input_shape))

    # Add the convolutional layers
    for i, (filters, kernel_size, strides, padding, activation) in enumerate(conv_config):
        model.add(tf.keras.layers.Conv2D(filters, kernel_size, strides=strides, padding=padding,
                                         activation=activation, name=f'conv{i+1}'))
        model.add(tf.keras.layers.MaxPooling2D(
            pool_size=(2, 2), strides=(2, 2), name=f'pool{i+1}'))

    # Add the fully connected layers
    model.add(tf.keras.layers.Flatten())
    for i, (units, activation) in enumerate(fc_config):
        model.add(tf.keras.layers.Dense(
            units, activation=activation, name=f'fc{i+1}'))

    # Add the output layer
    model.add(tf.keras.layers.Dense(
        num_classes, activation='softmax', name='output'))

    # Compile the model with categorical crossentropy loss and Adam optimizer
    model.compile(loss='categorical_crossentropy',
                  optimizer='adam',
                  metrics=['accuracy'])

    return model
