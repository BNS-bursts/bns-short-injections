# sim-inspiral-fixed-snrs
## Script and file provenance

 * `bauswein_h5_list.txt`: list of Andi's most recent waveforms, as converted
    to NRHDF5. Created with:
```
find $PWD/waveforms/lvcnr-matter/BNS/bauswein/ -name *h5 > bauswein_h5_list.txt
```
 * `make-snr-injections.sh`: bash script to call PmrUtils script
    `ligolw_pmrinj` and generate 100 injections at fixed SNR for waveforms (i.e.,
    HDF5 file) provided as 1st input argument to the script.
 * `make-170817-injections.sh`:  makes 5 injections of the specified NRHDF5 file
   with 170817 localisation.


 * For the purposes of this initial exercise, we'll just use andi's most recent
   waveforms with `(m1, m2) - (1.37, 1.37)`
   * i.e., : `11 mtotal=$(python -c "print 2*1.37)`


### make-snr-injections.sh
Input:
 1. Full path to desired HDF5 file
 1. Total mass of system (typically 2*1.37=2.74)
 1. Desired network SNR

(Script should check number of nargs)

The "SNR" here is the total high-frequency SNR, evaluated from some f-low.  We
do not taper the waveform in the time-domain.

Also note we'll place injections in a time window with some trigger time +/- N
seconds.  We'll just use the 170817 trigger time ast the ceneter for this
(there's no reason the actual time should matter).

 * The highfreq SNR is evaluated using a low-frequency cutoff given by
   opts.f_lower_post (--f-lower-post): for consistency with previous studies,
   we'll use 1024 Hz here (the default value).
 * Orientation/polarisation/inclination: random and uniform on the sky / in a
   sphere.  This just requires the user to not specify anything special here.

#### Example
Example of running the fixed-SNR sim-inspiral generator:

```
$ export waveform="/home/jclark/Projects/BNS-injections/waveforms/lvcnr-matter/BNS/bauswein/wdl200av15ls220-137137/wdl200av15ls220-137137.h5"
$ export netsnr=10
$ export mtotal=2.74
$ ./make-snr-injections.sh ${waveform} ${netsnr} ${mtotal}
```

The `make-snr-injecsions.sh` has a hardcoded time window of 1 hour and an
instruction to generate 100 injections per hour.  Everything else should be
self-explanatory.

Note: you may need to convert the injection file to deal with (this)[https://git.ligo.org/lscsoft/bayeswave/merge_requests/60]:
```
ligolw_no_ilwdchar HLVblah.gz
```






