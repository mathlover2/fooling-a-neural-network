#!/usr/bin/python3

from scapy.all import *
from sys import argv
from statistics import mean
from math import ceil

SAMPLE_RATE = 100
SAMPLE_INTERVAL_SIZE=1.0/SAMPLE_RATE

windows = []

packet_file = argv[1]
a = rdpcap(packet_file)
init_time = float(a[0].time)
end_time = float(a[-1].time)
curr_window_start_time = float(a[0].time)
curr_window_end_time = curr_window_start_time + SAMPLE_INTERVAL_SIZE
packet_index = 0
curr_window = []

while packet_index < len(a):
    if a[packet_index].time < curr_window_end_time:
        curr_window.append(a[packet_index])
        packet_index += 1
    else:
        windows.append(curr_window[:])
        curr_window = []
        windows.append([])
        jump = ceil((a[packet_index].time - curr_window_end_time)/SAMPLE_INTERVAL_SIZE)
        curr_window_start_time += jump*SAMPLE_INTERVAL_SIZE
        curr_window_end_time += jump*SAMPLE_INTERVAL_SIZE

for window in windows:
    if window:
        numPKT = len(window)
        numBytes = sum(len(p) for p in window)
        pktAtsec = SAMPLE_RATE*numPKT
        BitRate = 8*numBytes*SAMPLE_RATE
        interTime = mean([window[i+1].time - window[i].time
                          for i in range(numPKT-1)]) if numPKT > 1 else 0
        avgLenPkt = numBytes/numPKT
        print("{},{},{},{},{},{}".format(numPKT, numBytes, pktAtsec, BitRate,
                                         interTime, avgLenPkt) )
print("0,0,0,0,0,0")
