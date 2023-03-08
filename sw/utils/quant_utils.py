import tensorflow as tf
import tensorflow_model_optimization as tfmot

from quant_config.dense_q import DenseQuantizeConfig, NoQuantizeConfig

q_config = DenseQuantizeConfig()

# Quantize Dense layer


def quant_Dense_layer(layer):
    if isinstance(layer, tf.keras.layers.Dense):
        return tfmot.quantization.keras.quantize_annotate_layer(layer, q_config)
    return layer

# Quantize Conv2D layer


def quant_Conv2D_layer(layer):
    if isinstance(layer, tf.keras.layers.Conv2D):
        return tfmot.quantization.keras.quantize_annotate_layer(layer, q_config)
    return layer
