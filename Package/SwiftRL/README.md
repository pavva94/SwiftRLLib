# SwiftRL by Alessandro Pavesi

## Installing
There are few steps to install this Package:

- import package with xCode
- insert the package into the target preferences
- insert into the info.plist file
    - the two identifiers into the info.plist file to allow the background tasks
    - if needed the permission to read the data like location, ecc

## Usage
To create a simple RL problem using this Package.

Firstly we work on Swift to build the classes:
- Create at least a class that inherited from Action, include in the exec() function what that action have to do. (What you want, literally)
- Instanciate the Env class using a list ObservableData you want to observe, a list of your Actions and defining the action\_size. 
- Instanciate what Agent you want (DeepQNetwork or QNetwork) and pass to it the environment.

Then we need to build the Neural Network fitted for our problem:
- Firstly check the state size of the environment using the Env instance and calling getStateSize()
- Use the python script CreateModel.py to create the MLModel necessary to use the Package. Be sure of modify the parameter of the network, deciding the layers and its dimensions and most important set the correct input\_size and output\_size (env.getStateSize and env.getActionSize)

Then in xCode:
- Import the model created into the App folder
- Insert it into the Build Phase -> Compile Sources

A this point the project is ready, but we haven't interaction with the Agent or the Environment.

Here the fundamental part:
- the SarsaTuple to evaluate (that needs to add the reward) are stored by the Agent in database.json, to retrieve them call the loadDatabase("database.json")
- the SarsaTuple  completed with the reward needs to be passed to the agent to store them into the internal Replay Buffer, ready to train; to do this call the storeAndDelete function. (check the types of every argument)
- to train the network, if there's no need to personalize the training then i suggest to activate the backgroundTraining that works only with the phone plugged\-in and at defined interval, if you need something strange you can call directly the update().
- to use the Agent to predict an action use act() passing the state provided by the env.read()


