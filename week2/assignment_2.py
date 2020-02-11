################################################################################
#
# Student Names: Henk, Lodewijk, Nils
#
#
# Student Numbers: 11676892, 11054115, 11784415
#
#
# Group number: 17
#
#
###############################################################################

try:
    import sim
except:
    print ('--------------------------------------------------------------')
    print ('"sim.py" could not be imported. This means very probably that')
    print ('either "sim.py" or the remoteApi library could not be found.')
    print ('Make sure both are in the same folder as this file,')
    print ('or appropriately adjust the file "sim.py"')
    print ('--------------------------------------------------------------')
    print ('')

sim.simxFinish(-1) # just in case, close all opened connections
clientID=sim.simxStart('127.0.0.1',19999,True,True,5000,5) # Connect to CoppeliaSim

import time
import argparse

def call_func(name, ints=[], floats=[], strings=[]):
    '''
        Call a function from the robot.
        The functions can be found in the "functiones" file in the scene file
    '''

    return sim.simxCallScriptFunction(clientID, 'Funciones',
                                      sim.sim_scripttype_childscript,
                                      name, ints, floats, strings,
                                      bytearray('1', 'utf-8'),
                                      sim.simx_opmode_blocking)

def timer(wait_time):
    """
        Timer that uses simulation time.
        Input can be flaots or ints
    """
    _, _, start_time, _, _ = call_func("CurrentTick")
    start_time = start_time[0]
    while True:
        _,_, current_time, _, _ = call_func("CurrentTick")

        if (current_time[0] - start_time) > wait_time:
            break


def main():
    '''
        Exercise 3: drive the car through the maze without stopping
    '''

    ### YOUR CODE FOR EXERCISE 3 HERE

    return


if __name__ == "__main__":
    # Parse arguments
    parser = argparse.ArgumentParser()
    parser.add_argument('--exercise', type=int, default=1,
                        help='State what exercise needs to be run')
    ARGS = parser.parse_args()

    if clientID!=-1:
        print ('Connected to remote API server')
        print("execute main")
        main()

    else:
        print ('Failed connecting to remote API server')

    sim.simxFinish(-1)
