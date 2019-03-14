# Simple demo of reading each analog input from the ADS1x15 and printing it to
# the screen.
# Author: Tony DiCola
# License: Public Domain
import time
import sys

# Import the ADS1x15 module.
import Adafruit_ADS1x15

import RPi.GPIO as GPIO
GPIO.setmode(GPIO.BCM)
LED = 5
GPIO.setwarnings(False)
import numpy as np
from os import system, remove
import matplotlib.pyplot as plt
# Create an ADS1115 ADC (16-bit) instance.
adc = Adafruit_ADS1x15.ADS1115()
GAIN = 1
#print 'Initializing...'

#print('Reading ADS1x15 values, press Ctrl-C to quit...')
# Print nice channel column headers.
#print('| {0:>6} | {1:>6} | {2:>6} | {3:>6} |'.format(*range(4)))
#print('-' * 37)
# Main loop.
ledState = False
GPIO.setup(LED,GPIO.OUT)
iteration = 100
duration = 5        #keep min 2
rawval = [[0 for x in range(iteration)] for y in range(4)]
#values = [[0 for x in range((duration-1)*iteration)] for y in range(4)]
values = [0]*4
d = 0

initialize = 1


#while d<duration:
#file = open("datafile.txt","w+")

while 1:
    # Read all the ADC channel values in a list.

#    values = [0]*4



    for j in range(iteration):
        for i in range(4):
            # Read the specified ADC channel using the previously set gain value.
            rawval[i][j] = adc.read_adc(i, gain=GAIN)

            if j == iteration-1: 
                initialize = 0

            n = (d-1)*iteration+j
            if initialize != 1:
                values[i] = sum(rawval[i])/iteration
        if initialize != 1 and n>=0:
            #print n,':',values[0],values[1],values[2],values[3]
            print '0:',values[0]
            #sys.stdout.write('0:'+str(values[0])+'\n')
            #file.write(str(n))
            #file.write("\t")
            #file.write(str(values[0]))
            #file.write(",")
            #file.write(str(values[0][n]))
            #file.write(",")
            #file.write(str(values[0][n]))
            #file.write(",")
            #file.write(str(values[0][n]))
            #file.write("\n")
            #file.close()
            #file = open("datafile.txt","w+")

            #time.sleep(0.5)

        ledState = not ledState
        GPIO.output(LED, ledState)

    #print '0:',values[0]
    d = d+1
    #print d


    #time.sleep(0.05)


#file.close()
    #system('gnuplot liveplot.gnu')
#xs = range((duration-1)*iteration)
#y0s = values[0]
#y1s = values[1]
#y2s = values[2]
#y3s = values[3]
#
## Explicitly create our figure and subplots
#fig = plt.figure()
#ax0 = fig.add_subplot(2, 2, 1)
#ax1 = fig.add_subplot(2, 2, 2)
#ax2 = fig.add_subplot(2, 2, 3)
#ax3 = fig.add_subplot(2, 2, 4)
#
## Draw our signals on the different subplots
#ax0.plot(xs, y0s)
#ax1.plot(xs, y1s)
#ax2.plot(xs, y2s)
#ax3.plot(xs, y3s)
#
## Adding labels to subplots is a little different
#ax0.set_title('A0')
#ax0.set_xlabel('Time')
#ax0.set_ylabel('Value')
#ax0.set_ylim([0,40000])
#ax1.set_title('A1')
#ax1.set_xlabel('Time')
#ax1.set_ylabel('Value')
#ax1.set_ylim([0,40000])
#ax2.set_title('A2')
#ax2.set_xlabel('Time')
#ax2.set_ylabel('Value')
#ax2.set_ylim([0,40000])
#ax3.set_title('A3')
#ax3.set_xlabel('Time')
#ax3.set_ylabel('Value')
#ax3.set_ylim([0,40000])
#
## We can use the subplots_adjust function to change the space between subplots
##plt.subplots_adjust(hspace=0.6)
#
## Draw all the plots!
#plt.show()

