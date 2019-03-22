#!/bin/bash

source /home/jclark/virtualenvs/pmrutils/bin/activate
source /home/jclark/opt/lscsoft/lalsuite-master/etc/lalsuiterc 

# --- Input

waveform=$1
mtotal=$(python -c "print 2*1.37")

ifos="H1 L1 V1"
psdpath="/home/jclark/Projects/BNS-injections/psds"
h1asd="${psdpath}/aLIGOZeroDetHighPower-ASD.txt"
l1asd="${psdpath}/aLIGOZeroDetHighPower-ASD.txt"
v1asd="${psdpath}/AdvVirgoDesign-ASD.txt"

# Source Location & Orientation
# ---------------------------
gpstime=1187008882.43
ra=3.44616
dec=-0.408084
iota=0
psi=0
distance=40 # Mpc
#Deff=51.8470059148 # reference param (unused)
# ---------------------------

# GPS start / end for series of injections
gpsstart=$(python -c "print ${gpstime} - 50")
gpsend=$(python -c "print ${gpstime} + 50")


# --- Injection Population

# Parse the waveform path to get the name of the simulation
wavename=`python -c "print '${waveform}'.split('/')[-1].replace('.h5','')"`
outname="HLV-${wavename}_170817.xml.gz"

prog="ligolw_pmrinj.py"

${prog} --seed 170817 \
    --gps-start-time ${gpsstart} --gps-end-time ${gpsend} \
    --signals-per-hour 100\
    --time-distribution fixed  \
    --fixed-distance ${distance} \
    --fixed-ra ${ra} --fixed-dec ${dec} \
    --fixed-inclination ${iota} --fixed-pol ${psi} \
    --mtotal ${mtotal} --numrel-data ${waveform} \
    --ifos ${ifos} --asd-files ${h1asd} ${l1asd} ${v1asd} \
    --output ${outname} --verbose \
    --srate-pre 2048 --srate-post 8192 --f-lower-pre 20 

