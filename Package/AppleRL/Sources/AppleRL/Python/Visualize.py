import matplotlib.pyplot as plt
import json
import pandas as pd
import numpy as np


pathDatabase = 'database.json'
pathTxt = 'batteryValues.txt'
pathRandomTxt = 'batteryValuesRandomNew.txt'



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

def readTxt(pathTxt):
    text = []
    with open(pathTxt) as f:
        line = f.readline()
        while line:
            line = f.readline()
            print(line)
            text.append(line)

        f.close()

    # count = 0
    # for line in lines:
    #     count += 1
    #     print(f'line {count}: {line}')
    #     text.append(lines)
    print(len(text))
    return text


def txtProcessing(text):
    interestingLines = []
    for i in range(0, len(text)):
        if "[100.0]" in text[i] and i-1 >= 0:
            l = eval(text[i-1].replace("batteryValuesPer30Minutes: ", ""))
            print(l)
            interestingLines.append(len(l))
    return interestingLines


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
    # data = readDataset(path)
    # df = dataProcessing(data)
    # plotRewards(df['reward'])
    # plotActions(df['action'])
    data = readTxt(pathRandomTxt)
    df = txtProcessing(data)
    print(df)
    plotRewards(df, filename="LenghtBatteryLifeRandom")
    # plotActions(df['action'])


if __name__ == '__main__':
    main()
