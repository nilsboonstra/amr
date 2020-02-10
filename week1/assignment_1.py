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

def SonarDistance():
    '''Returns sonar distance'''
    return call_func('SensorSonar')[2][0]

def CurrentTick():
    '''Return the current tick of the simulation'''
    return call_func("CurrentTick")[2][0]

def ride_to_wall(timeout):
    '''
        Robot rides until distance to wall < 25.
        Return True if a wall is found, false if timed out.
    '''

    # start motor
    call_func('On', [3, 1])

    # check if distance > 25
    dist = SonarDistance()
    s_time = CurrentTick()
    c_time = CurrentTick()

    while dist > 25:
        dist = SonarDistance()
        c_time = CurrentTick()

        #timeout
        if c_time - s_time > timeout:
            return False

    # turn motor off if distance < 25
    call_func('Off', [3])
    return True

def turn_left():
    '''
        turns the robot 90 degrees to the left,
        and returns the sonar distance to the nearest object
    '''

    #reset gyro
    call_func('ResetGyroA')

    # turn left
    call_func('On', ints=[2, 1])
    call_func('On', ints=[1, -1])

    # keep turning to left for 90 degrees
    gyro = call_func('SensorGyroA')[1][0]
    while gyro > -90:
        gyro = call_func('SensorGyroA')[1][0]

    # turn off motors
    call_func('Off', [3])

    return SonarDistance()

def turn_right():
    '''
        turns the robot 90 degrees to the right,
        and returns the sonar distance to the nearest object
    '''

    #reset gyro
    call_func('ResetGyroA')

    # turn to right
    call_func('On', ints=[1, 1])
    call_func('On', ints=[2, -1])

    # keep turning to right for 90 degrees
    gyro = call_func('SensorGyroA')[1][0]
    while gyro < 90:
        gyro = call_func('SensorGyroA')[1][0]

    # turn off motors
    call_func('Off', [3])

    return SonarDistance()

def exercise_1():
    '''
        Exercise 1: drive the car through the maze without using sensors
    '''

    call_func('On', ints=[3, 10])
    timer(4.2)

    call_func('On', ints=[1, 10])
    call_func('On', ints=[2, 5])
    timer(1.22)

    call_func('On', ints=[3, 10])
    timer(4.0)

    call_func('On', ints=[2, 10])
    call_func('On', ints=[1, 5])
    timer(1.2)

    call_func('On', ints=[3, 10])
    timer(10)

    call_func('Off', ints=[3])

def exercise_2():
    '''
        Exercise 2: drive the car through the maze using sensors
    '''

    # Reset the gyro
    call_func('ResetGyroA')

    no_timeout = ride_to_wall(100)
    while no_timeout:
        # Ride to wall, and then turn
        no_timeout = ride_to_wall(100)
        dist = turn_left()

        # Find possible path
        while dist < 25:
            dist = turn_right()

if __name__ == "__main__":
    # Parse arguments
    parser = argparse.ArgumentParser()
    parser.add_argument('--exercise', type=int, default=1,
                        help='State what exercise needs to be run')
    ARGS = parser.parse_args()

    if clientID!=-1:
        print ('Connected to remote API server')
        if ARGS.exercise == 1:
            print("execute exercise 1")
            exercise_1()

        elif ARGS.exercise == 2:
            print("execute exercise 2")
            exercise_2()

        else:
            print("No exercise executed")

    else:
        print ('Failed connecting to remote API server')

    sim.simxFinish(-1)
