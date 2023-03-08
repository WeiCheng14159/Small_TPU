import tensorflow as tf
import tensorflow_model_optimization as tfmot
from quant_config.dense_q import DenseQuantizeConfig
from utils.quant_utils import quant_Dense_layer


def lenet5(input_shape, num_classes,
           conv_config=[(6, (5, 5), (1, 1), 'valid', 'tanh'),
                        (16, (5, 5), (1, 1), 'valid', 'tanh')],
           fc_config=[(120, 'tanh'),
                      (84, 'tanh'),
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


# Quantization shortcut
quantize_annotate_layer = tfmot.quantization.keras.quantize_annotate_layer
quantize_annotate_model = tfmot.quantization.keras.quantize_annotate_model
quantize_apply = tfmot.quantization.keras.quantize_apply
quantize_scope = tfmot.quantization.keras.quantize_scope


def lenet5_qnn(input_shape, num_classes):

    model = lenet5(input_shape=input_shape, num_classes=num_classes)

    # Use `tf.keras.models.clone_model` to apply `quant_Dense_layer`
    # to the layers of the model.
    annotated_model = tf.keras.models.clone_model(
        model, clone_function=quant_Dense_layer)

    # `quantize_apply` requires mentioning `DenseQuantizeConfig` with `quantize_scope`
    with quantize_scope({'DenseQuantizeConfig': DenseQuantizeConfig}):
        q_model = quantize_apply(annotated_model)

    # `quantize_apply` requires a recompile.
    q_model.compile(loss='categorical_crossentropy',
                    optimizer='adam',
                    metrics=['accuracy'])

    return q_model
