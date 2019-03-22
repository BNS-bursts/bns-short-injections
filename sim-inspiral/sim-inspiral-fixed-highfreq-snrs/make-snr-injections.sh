#!/bin/bash

source /home/jclark/virtualenvs/pmrutils/bin/activate
source /home/jclark/opt/lscsoft/lalsuite-master/etc/lalsuiterc 

# #############################################################

# User Input
if [ $# != 3 ]; then
    echo "incorrect # of args"
    exit 1
fi

WAVEFORM=$1
MTOTAL=$2
NETSNR=$3
NSIGNALS=100
INJWINDOW=3600         # Distribute injections in this window
GPSTIME=1187008882.43 # Distribute around this time: [GPSTIME-0.5*INJWINDOW, GPSTIME + 0.5*INJWINDOW]

# #############################################################
# Derived / Hardcoded Input 

# Parse the waveform path to get the name of the simulation
wavename=`python -c "print '${WAVEFORM}'.split('/')[-1].replace('.h5','')"`
OUTNAME="HLV-${wavename}-netSNR_${NETSNR}.xml.gz"

# Static input
IFOS="H1 L1 V1"
PSDPATH="/home/jclark/Projects/bns-short-injections/data/psds"
H1ASD="${PSDPATH}/aLIGOZeroDetHighPower-ASD.txt"
L1ASD="${PSDPATH}/aLIGOZeroDetHighPower-ASD.txt"
V1ASD="${PSDPATH}/AdvVirgoDesign-ASD.txt"

# GPS start / end for series of injections
GPSSTART=$(python -c "print ${GPSTIME} - 0.5*${INJWINDOW}")
GPSEND=$(python -c "print ${GPSTIME} + 0.5*${INJWINDOW}")

# #############################################################
# Generate sim-inspiral table

prog="ligolw_pmrinj.py"

${prog} --seed 170817 \
    --gps-start-time ${GPSSTART} --gps-end-time ${GPSEND} \
    --signals-per-hour ${NSIGNALS} \
    --fixed-highfreq-snr ${NETSNR} \
    --time-distribution fixed  \
    --mtotal ${MTOTAL} --numrel-data ${WAVEFORM} \
    --ifos ${IFOS} --asd-files ${H1ASD} ${L1ASD} ${V1ASD} \
    --output ${OUTNAME} --verbose \
    --srate-pre 2048 --f-lower-pre 20 \
    --srate-post 8192 --f-lower-post 1024

