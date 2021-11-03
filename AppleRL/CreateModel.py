import keras
import tensorflow as tf
import coremltools as ct

def convert_model_to_mlmodel(model):
    # Pass in `tf.keras.Model` to the Unified Conversion API
    mlmodel = ct.convert(model, respect_trainable=True)
    mlmodel.save("MLModel")
    
    coreml_model_path = "MLModel.mlmodel"

    spec = ct.utils.load_spec(coreml_model_path)
    builder = ct.models.neural_network.NeuralNetworkBuilder(spec=spec)
    builder.inspect_layers()
    
    neuralnetwork_spec = builder.spec

    neuralnetwork_spec.description.metadata.author = 'Alessandro Pavesi'
    neuralnetwork_spec.description.metadata.license = 'MIT'
    neuralnetwork_spec.description.metadata.shortDescription = (
            'Personalized Keras DQN Model')
    
    model_spec = builder.spec
    builder.make_updatable(['sequential/dense_1/Tensordot/MatMul', 'sequential/input_dense/Tensordot/MatMul', 'sequential/output_dense'])
    builder.set_categorical_cross_entropy_loss(name='lossLayer', input='output')

    from coremltools.models.neural_network import Adam
    builder.set_sgd_optimizer(Adam(lr=0.01, batch=32))
    builder.set_epochs(10)

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
    @param: input_shape      = tuple with shape of input (e.g. (None, 32, 32))
    """

    q_net = keras.models.Sequential()

    q_net.add(keras.layers.Dense(unit_per_layer[0], input_shape=input_shape, activation='relu', name="input_dense"))

    for i in range(1, len(layers)-1):
        l = layers[i].lower()
        upl = unit_per_layer[i]
        if l ==  "dense":
                q_net.add(keras.layers.Dense(upl, activation='relu', name="dense_"+str(i)))
        else:
            print("Only Dense layer please")

    q_net.add(keras.layers.Dense(unit_per_layer[-1], activation='linear', name="output_dense"))
    q_net.compile(optimizer=tf.optimizers.SGD(learning_rate=0.001), loss='mse')
    q_net.summary()
    return q_net

def create_ppo(layers, unit_per_layer, input_shape):
    pass

def create_ac(layers, unit_per_layer, input_shape):
    pass



def create_model(type, layers, unit_per_layer, input_shape):
    print("Type selected: " + type)
    if type == "DQN":
            mlmodel = create_dqn(layers, unit_per_layer, input_shape)
    elif type == "PPO":
            mlmodel =  create_ppo(layers, unit_per_layer, input_shape)
    elif type == "A2C":
            mlmodel =  create_ac(layers, unit_per_layer, input_shape)
    else:
            print("Wrong Type. Admitted: DQN, PPO, A2C")
            return
    
    convert_model_to_mlmodel(mlmodel)
    print("Model Created")



if __name__ == "__main__":
    print("Create NN")
    create_model("DQN", ["dense", "dense", "dense"], [64, 32, 2], (None, 1))
