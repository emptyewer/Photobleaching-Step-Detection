import sys
import os
import matplotlib.pyplot as plt

file_prefix = sys.argv[1]


def open_file(filename):
    array = []
    file_handle = open(filename, 'r')
    for line in file_handle.readlines():
        array.append(line.rstrip().split(','))
    return array

step_count_a = open_file(file_prefix+'_stepcount.txt')
trajectory_a = open_file(file_prefix+'_trajectory.txt')
step_details_a = open_file(file_prefix+'_stepdetails.txt')

trajectory_count = 1
step_details_index = 0
trajectory_x_values = range(1, len(trajectory_a[0]))
for i in range(len(step_count_a[0])):
    step = int(step_count_a[0][i])
    fit_x = []
    fit_y = []
    print ">>> Trajectory %d\n    Step Count: %d" % (trajectory_count, step)
    # print step_details_a[0][step_details_index:step_details_index+step*3]
    for i in range()
    step_details_index = step_details_index+step*3
    trajectory_count += 1