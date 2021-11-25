#import tensorflow as tf
#
#graph = tf.Graph()
#with graph.as_default():
#  x = tf.placeholder(tf.float32, shape=[None, 20], name="input")
#  W = tf.Variable(tf.truncated_normal([20, 10], stddev=0.1))
#  b = tf.Variable(tf.ones([10]))
#  y = tf.matmul(x, W) + b
#  output_names = [y.op.name]
#
#
#import tempfile
#import os
#from tensorflow.python.tools.freeze_graph import freeze_graph
#
#model_dir = "./"  #tempfile.mkdtemp()
#graph_def_file = os.path.join(model_dir, 'tf_graph.pb')
#checkpoint_file = os.path.join(model_dir, 'tf_model.ckpt')
#frozen_graph_file = os.path.join(model_dir, 'tf_frozen.pb')
#
#with tf.Session(graph=graph) as sess:
#  # initialize variables
#  sess.run(tf.global_variables_initializer())
#  # save graph definition somewhere
#  tf.train.write_graph(sess.graph, model_dir, graph_def_file, as_text=False)
#  # save the weights
#  saver = tf.train.Saver()
#  saver.save(sess, checkpoint_file)
#
#  # take the graph definition and weights
#  # and freeze into a single .pb frozen graph file
#  freeze_graph(input_graph=graph_def_file,
#               input_saver="",
#               input_binary=True,
#               input_checkpoint=checkpoint_file,
#               output_node_names=",".join(output_names),
#               restore_op_name="save/restore_all",
#               filename_tensor_name="save/Const:0",
#               output_graph=frozen_graph_file,
#               clear_devices=True,
#               initializer_nodes="")
#
#print("TensorFlow frozen graph saved at {}".format(frozen_graph_file))
#
import coremltools as ct
#
#
#
#mlmodel = ct.converters.keras.convert(frozen_graph_file)
#mlmodel.save(frozen_graph_file.replace("pb","mlmodel"))
#print("DOCANEI")
#
def convert_model_to_mlmodel(model):
    # Pass in `tf.keras.Model` to the Unified Conversion API
    #mlmodel = ct.keras_converter.convert(model)
    #mlmodel.save("MLModel")

    coreml_model_path = "tf_fronzen.mlmodel"

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
    builder.set_adam_optimizer(Adam(lr=0.01, batch=32))
    builder.set_epochs(10)


from keras.models import Sequential
from keras.layers import Dense, Flatten, Conv2D

model = Sequential()
model.add(Dense(64, activation='relu', input_shape=(2, 2, 1)))
model.add(Dense(128, activation='relu'))
model.add(Dense(128, activation='relu'))
model.add(Dense(10, activation='softmax'))

from coremltools.converters import keras as keras_converter
class_labels = ['0', '1', '2', '3', '4', '5', '6', '7', '8', '9']
mlmodel = keras_converter.convert(model, input_names=['data'],
                                  output_names=['digitProbabilities'],
                                  #class_labels=class_labels,
                                  predicted_feature_name='digit')

mlmodel.save('tf_fronzen.mlmodel')
convert_model_to_mlmodel(mlmodel)
