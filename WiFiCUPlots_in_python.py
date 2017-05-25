'''
WIFICU
Authors: Matt Blaschak, Greg Palmer, Sean Rajkowski
Description: This file outputs a graph in a readable format that shows when movement occured in front of the antenna based on when the amplitude went below the threshold.
'''

import numpy as np
import scipy.signal
import matplotlib.pyplot as plt

## Input the files as a string in the list
files = ["step_in_front_thru_wall1_43017.dat"]
samp_rate = 10*10**6
FFT_size = 1024

## FFT to Time conversion
FFT_to_time = FFT_size/samp_rate

## For every file inputted into array files
for file in files:

    ## Load the data into an array
    data = scipy.fromfile(open(file), dtype=scipy.float32)
    print('loaded in data')

    list_of_data = np.split(data, data.size//1024)
    print('transformed data into 2D list with dimentions x by 1024 (rows,columns) where 1024 is the number of fft points and x is time')

    array_of_data = np.asarray(list_of_data)
    print('transformed 2D list into array')

##    middle_third_freq_data = array_of_data[:,341:684]
##    print('took middle third frequency data')


    # Look at a single frequency
    single_freq_data = array_of_data[:,529]
    print('took the 530th frequency to analayze')
    
    array_of_single_freq = np.asarray(single_freq_data)
    print('transformed data from list to array')
    print('shape of array of is ', array_of_single_freq.shape)

##    average_across_rows = np.mean(array_of_middle_third, axis = 1, dtype=scipy.float32)
##    print('took the average across the rows')
##    print(average_across_rows.shape)
##    print('')

    ## Take the max filter
    max_across_rows = scipy.ndimage.filters.maximum_filter1d(array_of_single_freq,10000)
    print('took max filter')

    ## Decimate by 100
    decimate_max_across_rows = scipy.signal.decimate(max_across_rows,10)
    print(decimate_max_across_rows.shape)
    print('decimated the max filter')

    decimate_max_across_rows = scipy.signal.decimate(decimate_max_across_rows,10)
    print(decimate_max_across_rows.shape)
    print('decimated the max filter again')
 
    ## Take the median filter
    median_across_rows = scipy.ndimage.filters.median_filter(decimate_max_across_rows,500)
    print('took the median filter')
    print('')

    ## Interpolate
    interpolate_across_rows = scipy.signal.resample(median_across_rows, array_of_single_freq.size)
    print('interpolated the data')
    print(interpolate_across_rows.shape)
    
    ## Calculate the threshold and plot
    threshold = (max(max_across_rows)-min(max_across_rows))/2.5
    plt.plot(np.arange(len(interpolate_across_rows))*FFT_to_time,interpolate_across_rows)
    plt.plot(np.arange(len(max_across_rows))*FFT_to_time,max_across_rows)
    plt.plot((0,interpolate_across_rows.size*FFT_to_time),(threshold,threshold), 'k-')

    plt.axis([0,len(array_of_single_freq)*FFT_to_time,0,1])
   
    plt.legend(['after interpolation','after max filter','threshold'],loc='upper left')

    plt.show()

