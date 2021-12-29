import matplotlib.pyplot as plt
import json
import pandas as pd
import numpy as np


path = 'database.json'



'''
Data example:
{
    "reward":-12,
    "id":0,
    "state":[89,8,30,0.90000000000000002],
    "nextState":[77,9,0,1],
    "action":0
}
'''

def readDataset(path):
    # Opening JSON file
    f = open(path)

    # returns JSON object as
    # a dictionary
    data = json.load(f)

    # Iterating through the json
    # list
    for d in data:
        reward = d['reward']
        state = d['state']
        nextState = d['nextState']
        action = d['action']
        #print(d)

    # Closing file
    f.close()

    return data

def dataProcessing(data):
    df = pd.DataFrame(data, columns=['reward', 'id', 'state', 'nextState', 'action'])
    print(df.head())
    return df

def plotRewards(data, filename="GraphRewards"):
    plt.figure()
    plt.plot(data)
    plt.xlabel('Episodes')
    plt.ylabel('Rewards')
    plt.xticks(np.arange(len(data)))
    plt.title('Episode Rewards')
    plt.grid(True)
    plt.savefig(filename + ".png")
    plt.close()

def plotActions(data, filename="GraphActions"):
    plt.figure()
    plt.plot(data)
    plt.xlabel('Episodes')
    plt.ylabel('Actions')
    plt.xticks(np.arange(len(data)))
    plt.title('Episodes Action')
    plt.grid(True)
    plt.savefig(filename + ".png")
    plt.close()

def main():
    data = readDataset(path)
    df = dataProcessing(data)
    plotRewards(df['reward'])
    plotActions(df['action'])


if __name__ == '__main__':
    main()
