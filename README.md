
## Senior Design Files 

**wifi_testing.grc** <br>
GNURadio Companion File used to interface with the USRP2 device and collect samples into a file for later processing. GNURadio collects WiFi data from the USRP2 device as complex time samples, takes series of 1024-size FFTs of them, then writes their magnitudes to a file.

**WiFiCUPlots.m** <br>
MATLAB file used to process the data sent to the samples file generated by GNURadio, in order to produce a binary-blocking plot with respect to time.
This MATLAB file, when run, expects a set of raw data of samples. Each sample should be a 32-bit floating point number.

The function can be called in MATLAB as
```
WiFiCUPlots('example_samples.dat')
```

**WiFiCUPlots_in_python.py** <br>
An alternative way to process the data sent to the samples file generated by GNURadio, in order to produce a binary-blocking plot with respect to time. The raw data should be in the same format as above. Writing the program in Python will make it easier to re-write it as a custom GNURadio block in the future.