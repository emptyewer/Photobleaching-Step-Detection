#!/usr/bin/python
# -*- coding: utf-8 -*-

__author__ = 'Venkatramanan Krishnamani'
__copyright__ = 'Copyright 2014'
__version__ = '0.1'

#  The MIT License (MIT)
# =======================
#
# The source code in this file is copyrighted, but you are
# free to use and copy it as long as you don't change or
# remove any of the copyright notices.
#
# -----------------------------------------------------------------------------------
# Visualize steps detected and processed by the accompanying matlab script which uses
# heaviside function to detect the steps
#
# Copyright (C) 2014 by Venkatramanan Krishnamani <venky.krishna@me.com>
#
# Permission is hereby granted, free of charge, to any person obtaining a copy of this
# software and associated documentation files (the "Software"), to deal in the Software
# without restriction, including without limitation the rights to use, copy, modify,
# merge, publish, distribute, sublicense, and/or sell copies of the Software, and to
# permit persons to whom the Software is furnished to do so, subject to the following
# conditions:
#
# The above copyright notice and this permission notice shall be included in all copies
# or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED,
# INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR
# PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
# LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
# TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
# OTHER DEALINGS IN THE SOFTWARE.


import sys
import matplotlib.pyplot as plt
plt.ion()

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
trajectory_x_values = range(1, len(trajectory_a[0])+1)
for i in range(len(step_count_a[0])):
    step = int(step_count_a[0][i])
    if step > 0:
        print ">>> Trajectory %d\n    Step Count: %d" % (trajectory_count, step)
        step_details = step_details_a[0][step_details_index:step_details_index+step*3]
        [fit_x, fit_l, fit_y] = [step_details[i*step:i*step+step] for i in range(3)]
        fit_x = map(float, fit_x)
        fit_y = map(float, fit_y)
        fit_l = map(float, fit_l)
        temp_fit_x = [0]
        for xindex in range(len(fit_x)):
            temp_fit_x.append(fit_x[xindex])
            temp_fit_x.append(fit_x[xindex])
        temp_fit_x.append(trajectory_x_values[-1])
        fit_x = temp_fit_x
        for lindex in range(len(fit_l)):
            fit_y.insert(2*lindex+1, float(fit_y[lindex])+float(fit_l[lindex]))
        fit_y.insert(0, fit_y[0])
        fit_y.append(fit_y[-1])
        #Plotting
        fig = plt.figure()
        ax = fig.add_subplot(111)
        fig.suptitle(file_prefix + ' #AOI = ' + str(trajectory_count), fontweight='bold', fontsize=14)
        ax.plot(trajectory_x_values, map(float, trajectory_a[trajectory_count-1]), color='gray')
        ax.plot(fit_x, fit_y, 'ro-', linewidth=3, markersize=8)
        ax.set_xlabel('Step Count = %d' % step, fontsize=12)
        plt.show()
        _ = raw_input("Press [enter] to continue.")
        plt.close()
    step_details_index = step_details_index+step*3
    trajectory_count += 1