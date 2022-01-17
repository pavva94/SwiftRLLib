import coremltools as ct
from keras.models import Sequential
from keras.layers import Dense, Flatten, Conv2D
from coremltools.converters import keras as keras_converter
from coremltools.models.neural_network import datatypes

def convert_model_to_mlmodel(model, updatable_layers, output_shape):
  
    coreml_model_path = "AppleRLModel.mlmodel"

    spec = ct.utils.load_spec(coreml_model_path)
    builder = ct.models.neural_network.NeuralNetworkBuilder(spec=spec)
    builder.inspect_layers()
    
    neuralnetwork_spec = builder.spec

    neuralnetwork_spec.description.metadata.author = 'Alessandro Pavesi'
    neuralnetwork_spec.description.metadata.license = 'MIT'
    neuralnetwork_spec.description.metadata.shortDescription = (
            'Personalized Keras DQN Model')
    
    builder.make_updatable(updatable_layers)
    builder.set_mean_squared_error_loss(name='lossLayer', input_feature=('actions', datatypes.Array(output_shape, )))

    from coremltools.models.neural_network import AdamParams
    adam_params = AdamParams(lr=0.001, batch=8, beta1=0.9, beta2=0.999, eps=1e-8)
    adam_params.set_batch(8, [1, 2, 8, 16])
    builder.set_adam_optimizer(adam_params)
    builder.set_epochs(10, [1, 10, 50])
    builder.set_shuffle(False)
    print(builder.spec.description.trainingInput)
    
    ct.utils.save_spec(builder.spec, coreml_model_path)
    
    print("Updatable Model Created:")
    builder.inspect_layers()
    builder.inspect_optimizer()
    builder.inspect_loss_layers()
    builder.inspect_updatable_layers()
#
#    Set random weights and bias
#    model = coremltools.models.MLModel("HandsTuri.mlmodel")
#    model.short_description = ""
#    spec = model._spec
#    layer = spec.neuralNetworkClassifier.layers[-2]
#
#    W_old = np.array(layer.innerProduct.weights.floatValue)
#    B_old = np.array(layer.innerProduct.bias.floatValue)
#
#    fan_in = layer.innerProduct.inputChannels
#    bound = np.sqrt(6.0 / fan_in)
#    W_new = np.random.uniform(-bound, bound, W_old.shape)
#
#    bound = 1 / np.sqrt(fan_in)
#    B_new = np.random.uniform(-bound, bound, B_old.shape)
#
#    layer.innerProduct.weights.ClearField("floatValue")
#    layer.innerProduct.weights.floatValue.extend(W_new)
#
#    layer.innerProduct.bias.ClearField("floatValue")
#    layer.innerProduct.bias.floatValue.extend(B_new)
#
#    coremltools.utils.save_spec(spec, "HandsEmpty.mlmodel")

#    # or save the keras model in SavedModel directory format and then convert
#    tf_keras_model.save('tf_keras_model')
#    mlmodel = ct.convert('tf_keras_model')
#
#    # or load the model from a SavedModel and then convert
#    tf_keras_model = tf.keras.models.load_model('tf_keras_model')
#    mlmodel = ct.convert(tf_keras_model)
#
#    # or save the keras model in HDF5 format and then convert
#    tf_keras_model.save('tf_keras_model.h5')
#    mlmodel = ct.convert('tf_keras_model.h5')



def create_dqn(layers, unit_per_layer, input_shape):
    """
    @param: layer            = list of string with names of layer (e.g. ["dense", "dropout", "dense", "dense"])
    @param: unit_per_layer   = list of int meaning the units for each layer (e.g. [64, 0, 32, 2])
    @param: input_shape      = tuple with shape of input (e.g. (32, 32, 1))
    """
    updatable_layers = []
    q_net = Sequential()
    print(len(layers))

    for i in range(0, len(layers)-1):
        l = layers[i].lower()
        upl = unit_per_layer[i]
                
        if i == 0:
            if l == "dense":
                layer_name = "dense_" + str(i)
                q_net.add(Dense(unit_per_layer[0], input_shape=input_shape, activation='relu'))
                updatable_layers.append(layer_name)
            if l == "conv2d":
                layer_name = "conv2d_" + str(i)
                q_net.add(Conv2D(upl[0], upl[1], activation='relu', dilation_rate=2, name=layer_name, input_shape=input_shape))
                updatable_layers.append(layer_name)
            continue
        
        if l == "dense":
            layer_name = "dense_" + str(i)
            q_net.add(Dense(upl, activation='relu', name=layer_name))
            updatable_layers.append(layer_name)
        if l == "flatten":
            layer_name = "flatten_" + str(i)
            q_net.add(Flatten(name=layer_name))
#            updatable_layers.append(layer_name)
        elif l == "conv2d":
            layer_name = "conv2d_" + str(i)
            q_net.add(Conv2D(upl[0], upl[1], activation='relu', dilation_rate=2, name=layer_name))
            updatable_layers.append(layer_name)
        else:
            print("Only Dense layer please")
    
    layer_name = "dense_" + str(len(layers)-1)
    
    q_net.add(Dense(unit_per_layer[-1], activation='linear', name=layer_name))
    updatable_layers.append(layer_name)
    mlmodel = keras_converter.convert(q_net, input_names=['data'],
                                      output_names=['actions'],
                                      #class_labels=class_labels,
                                      predicted_feature_name='action')

    mlmodel.save('AppleRLModel.mlmodel')
    return q_net, updatable_layers


def create_model(type, layers, unit_per_layer, input_shape):
    print("Type selected: " + type)
    if type == "DQN":
        mlmodel, updatable_layers = create_dqn(layers, unit_per_layer, input_shape)
    else:
        print("Wrong Type. Admitted: DQN")
        return
    
    convert_model_to_mlmodel(mlmodel, updatable_layers, unit_per_layer[-1])
    print("Model Created")



if __name__ == "__main__":
    print("Create NN")
    create_model("DQN", ["conv2d", "conv2d","conv2d", "flatten", "dense", "dense"], [(2, 3), (2, 3), (2, 3), 0, 16, 2], (512, 512, 1))
    print("End")
