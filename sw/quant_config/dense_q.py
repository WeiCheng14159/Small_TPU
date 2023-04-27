import tensorflow_model_optimization as tfmot

### Custom quantizers ###
from quantizer.fixed_point_quantizer import FixedPointQuantizer
from quantizer.custom_quantizer import CustomQuantizer

### List of built-in quantizers ###
# Quantize tensor based on range the last batch of values.
LastValueQuantizer = tfmot.quantization.keras.quantizers.LastValueQuantizer
# Quantize tensor based on a moving average of values across batches.
MovingAverageQuantizer = tfmot.quantization.keras.quantizers.MovingAverageQuantizer
# Quantize tensor based on min/max of tensor values with the fixed range.
FixedQuantizer = tfmot.quantization.keras.quantizers.FixedQuantizer
# Quantize tensor based on min/max of tensor values across all batches.
AllValuesQuantizer = tfmot.quantization.keras.quantizers.AllValuesQuantizer


class DenseQuantizeConfig(tfmot.quantization.keras.QuantizeConfig):
 # Configure how to quantize weights.
    def get_weights_and_quantizers(self, layer):
        """Return weights to be quantized along with their quantizers.
        This function tells the quantize code which weights within a layer
        should be quantized, and how. The weights are the TF variables in a layer
        and the quantizers are `Quantizer` instances.
        This method is invoked by the quantization code when quantizing a layer.
        Example for a `Dense` layer:
        ```python
        def get_weights_and_quantizers(self, layer):
        return [(layer.kernel, LastValueQuantizer())]
        ```
        Args:
        layer: layer being quantized.
        Returns:
        List of 2-tuples. Each tuple is a weight tensor and an associated
        quantizer.
        """

        return [(layer.kernel, FixedQuantizer(num_bits=16, init_min=-6.0, init_max=6.0, narrow_range=True))]
        # return [(layer.kernel, FixedPointQuantizer(num_bits=8, init_min=-6.0, init_max=6.0, narrow_range=False))]
        # return [(layer.kernel, AllValuesQuantizer(num_bits=8, per_axis=False, symmetric=True,narrow_range=False))]
        # return [(layer.kernel, LastValueQuantizer(num_bits=8, symmetric=True, narrow_range=False, per_axis=False))]

    # Configure how to quantize activations.
    def get_activations_and_quantizers(self, layer):
        """Return activations to be quantized along with their quantizers.
        This function tells the quantize code which activations within a layer
        should be quantized, and how. The activations are the activation
        attributes in a layer, and the quantizers are `Quantizer` instances.
        This method is invoked by the quantization code when quantizing a layer.
        Example for a `Dense` layer:
        ```python
        def get_activations_and_quantizers(self, layer):
        return [(layer.activation, MovingAverageQuantizer())]
        ```
        Args:
        layer: layer being quantized.
        Returns:
        List of 2-tuples. Each tuple is a keras activation and an associated
        quantizer.
        """

        return [(layer.activation, MovingAverageQuantizer(num_bits=8, symmetric=True, narrow_range=True, per_axis=False))]

    def set_quantize_weights(self, layer, quantize_weights):
        """Replace the weights in the layer with quantized weights.
        This method is invoked by the quantization code to replace the weights
        within a layer with quantized weights. It is responsible for ensuring that
        the weights within a layer are properly replaced.
        Example for a `Dense` layer:
        ```python
        def set_quantize_weights(self, layer, quantize_weights):
        layer.kernel = quantize_weights[0]
        ```
        Args:
        layer: layer being quantized.
        quantize_weights: List of quantized weight tensors.
        Returns:
        None
        """
        layer.kernel = quantize_weights[0]

    def set_quantize_activations(self, layer, quantize_activations):
        """Replace the activations in the layer with quantized activations.
        This method is invoked by the quantization code to replace the activations
        within a layer with quantized activations. It is responsible for ensuring
        that the activations within a layer are properly replaced.
        Example for a `Dense` layer:
        ```python
        def set_quantize_activations(self, layer, quantize_activations):
        layer.activation = quantize_activations[0]
        ```
        Args:
        layer: layer being quantized.
        quantize_activations: List of quantized activations to replace the
            original activations in the layer.
        Returns:
        None
        """
        layer.activation = quantize_activations[0]

    # Configure how to quantize outputs (may be equivalent to activations).
    def get_output_quantizers(self, layer):
        """Returns the quantizer used to quantize the outputs from a layer.
        For certain layers, we may want to quantize the outputs tensors returned
        by the layer's `call` function. This allows us to quantize those output
        tensors.
        This function should return a list of quantizers. In most cases, a layer
        outputs only a single tensor so it should only have one quantizer. Return
        an empty list for if no quantization operation is desired on the results
        of the layer.
        Args:
        layer: layer being quantized.
        Returns:
        List of `Quantizer`s to be used to quantize the resulting tensors from
        a layer.
        """
        return []

    def get_config(self):
        """Returns the config used to serialize `QuantizeConfig`."""
        return {}


class NoQuantizeConfig(tfmot.quantization.keras.QuantizeConfig):
    """QuantizeConfig which does not quantize any part of the layer."""

    def get_weights_and_quantizers(self, layer):
        return []

    def get_activations_and_quantizers(self, layer):
        return []

    def set_quantize_weights(self, layer, quantize_weights):
        pass

    def set_quantize_activations(self, layer, quantize_activations):
        pass

    def get_output_quantizers(self, layer):
        return []

    def get_config(self):
        return {}
