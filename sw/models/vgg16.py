import tensorflow as tf
import tensorflow_model_optimization as tfmot
from quant_config.dense_q import DenseQuantizeConfig
from utils.quant_utils import quant_Dense_layer

# Quantization shortcut
quantize_annotate_layer = tfmot.quantization.keras.quantize_annotate_layer
quantize_annotate_model = tfmot.quantization.keras.quantize_annotate_model
quantize_apply = tfmot.quantization.keras.quantize_apply
quantize_scope = tfmot.quantization.keras.quantize_scope
# Quantization config
q_config = DenseQuantizeConfig()
# Quantization helper function (only apply to dense layer)


def vgg16(input_shape, num_classes,
          conv_config=[(64, (3, 3), (1, 1), 'same', 'relu'),
                       (128, (3, 3), (1, 1), 'same', 'relu'),
                       (256, (3, 3), (1, 1), 'same', 'relu'),
                       (512, (3, 3), (1, 1), 'same', 'relu'),
                       (512, (3, 3), (1, 1), 'same', 'relu')],
          fc_config=[(4096, 'relu'),
                     (4096, 'relu'),
                     (1000, 'softmax')]):

    model = tf.keras.models.Sequential()

    # Add the input layer
    model.add(tf.keras.layers.Input(shape=input_shape))

    # Add the convolutional layers
    for i, (filters, kernel_size, strides, padding, activation) in enumerate(conv_config):
        model.add(tf.keras.layers.Conv2D(filters, kernel_size, strides=strides, padding=padding,
                                         activation=activation, name=f'block{i+1}_conv1'))
        model.add(tf.keras.layers.Conv2D(filters, kernel_size, strides=strides, padding=padding,
                                         activation=activation, name=f'block{i+1}_conv2'))
        model.add(tf.keras.layers.MaxPooling2D(pool_size=(
            2, 2), strides=(2, 2), name=f'block{i+1}_pool'))

    # Add the fully connected layers
    model.add(tf.keras.layers.Flatten())
    for i, (units, activation) in enumerate(fc_config):
        model.add(tf.keras.layers.Dense(
            units, activation=activation, name=f'fc{i+1}'))

    # Add the output layer
    model.add(tf.keras.layers.Dense(
        num_classes, activation='softmax', name='output'))

    # Compile the model
    model.compile(loss='categorical_crossentropy',
                  optimizer='adam',
                  metrics=['accuracy'])

    return model
