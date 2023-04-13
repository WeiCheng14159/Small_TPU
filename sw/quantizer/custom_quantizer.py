import tensorflow as tf
import tensorflow_model_optimization as tfmot

Quantizer = tfmot.quantization.keras.quantizers.Quantizer


class CustomQuantizer(Quantizer):
    # Example quantizer which clips tensors in a fixed range.

    def build(self, tensor_shape, name, layer):
        """Construct the weights required by the quantizer.
        A quantizer may need to construct variables to hold the state for its
        algorithm. This function is invoked during the `build` stage of the layer
        that the quantizer is used for. Any variables constructed are under the
        scope of the `layer` and serialized as part of the layer.
        Args:
          tensor_shape: Shape of tensor which needs to be quantized.
          name: Name of tensor.
          layer: Keras layer which is quantizing the tensors. The layer is needed
            to construct the weights, and is also the owner of the weights.
        Returns: Dictionary of constructed weights. This dictionary will be
          passed to the quantizer's __call__ function as a `weights` dictionary.
        """
        range_var = layer.add_weight(
            name + '_range',
            initializer=tf.keras.initializers.Constant(6.0),
            trainable=False)

        return {
            'range_var': range_var,
        }

    def __call__(self, inputs, training, weights, **kwargs):
        """Apply quantization to the input tensor.
        This is the main function of the `Quantizer` which implements the core logic
        to quantize the tensor. It is invoked during the `call` stage of the layer,
        and allows modifying the tensors used in graph construction.
        Args:
          inputs: Input tensor to be quantized.
          training: Whether the graph is currently training.
          weights: Dictionary of weights the quantizer can use to quantize the
            tensor. This contains the weights created in the `build` function.
          **kwargs: Additional variables which may be passed to the quantizer.
        Returns: quantized tensor.
        """
        return tf.keras.backend.clip(
            inputs, 0.0, weights['range_var'])

    def get_config(self):
        """Returns the config used to serialize the `Quantizer`."""
        # Not needed. No __init__ parameters to serialize.
        return {}
