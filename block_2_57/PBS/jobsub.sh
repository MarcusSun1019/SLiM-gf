#!/bin/bash -l
#PBS -P ht96
#PBS -q normal
#PBS -l walltime=10:00:00
#PBS -l ncpus=2736
#PBS -l mem=10830GB
#PBS -l jobfs=22800GB
#PBS -l storage=scratch/ht96+gdata/ht96

ECHO=/bin/echo
JOBNAME=block_2_57
#
# These variables are assumed to be set:
#     NJOBS is the total number of jobs in a sequence of jobs (defaults to 1)
#     NJOB is the number of the current job in the sequence (defaults to 0)
# We don't need to set NJOB unless we are restarting from midway through the sequence

if [ X$NJOBS == X ]; then
   $ECHO "NJOBS (total number of jobs in sequence) is not set - defaulting to 1"
   export NJOBS=1
fi

if [ X$NJOB == X ]; then
   $ECHO "NJOB (current job number in sequence) is not set - defaulting to 0"
   export NJOB=1
   # Since this is the first iteration, create our folders
   $ECHO "Creating outputs folders..."
   cd $PBS_O_WORKDIR

   # Make output folders
   mkdir -p /scratch/ht96/ys7485/CH2/$JOBNAME
   mkdir -p /g/data/ht96/ys7485/CH2/$JOBNAME
   mkdir -p $HOME/CH2/$JOBNAME/done
fi

#
# Quick termination of job sequence - look for a specific file
#
if [ -f STOP_SEQUENCE ] ; then
    $ECHO "Terminate sequence at job number $NJOB"
    exit 0
fi

$ECHO "Starting job $NJOB of $NJOBS"

# Pre-job file manipulation goes here ...
#
# INSERT CODE
cd $PBS_O_WORKDIR
SAVE_DIR=/g/data/ht96/ys7485/CH2/$JOBNAME

# ========================================================================
# .... USER INSERTION OF EXECUTABLE LINE HERE
# ========================================================================
# Make sure we're at the right place so we can find the bash script to run

$ECHO "Running nci-parallele..."

# Use 1 core per SLiM run
module load nci-parallel/1.0.0a
export ncores_per_task=1
export ncores_per_numanode=12

# Calculate the range of parameter combinations we are exploring this job in the sequence

CMDS_PATH=$HOME/CH2/$JOBNAME/PBS/cmds.txt
CUR_TOT=$(cat $CMDS_PATH | wc -l)
CUR_MIN=$((($NJOB-1)*$PBS_NCPUS+1))
CUR_MAX=$(($NJOB*$PBS_NCPUS))

if [ $CUR_MAX -gt $CUR_TOT ]; then
    CUR_MAX=$CUR_TOT
fi

sed -n -e "${CUR_MIN},${CUR_MAX}p" $CMDS_PATH > ./JOB_PATH.txt

mpirun -np $((PBS_NCPUS/ncores_per_task)) --map-by ppr:$((ncores_per_numanode/ncores_per_task)):NUMA:PE=${ncores_per_task} nci-parallel --input-file ./JOB_PATH.txt --timeout 36000

# ========================================================================
## .... Nick's original code but I am not using this
# $ECHO "All jobs finished, combining output..."

##  Combine outputs
# cd /scratch/ht96/<username>/$JOBNAME/

# cat ./slim_output* >> $SAVEDIR/slim_muts.csv
# cat ./slim_time* >> $SAVEDIR/slim_time.csv

## Delete loose files in scratch with seed and model indices
# find -regex ".*[0-9]*_*[0-9].csv+" -delete
# ========================================================================

#
# Check the exit status
#
errstat=$?
if [ $errstat -ne 0 ]; then
   # A brief nap so PBS kills us in normal termination
   # If execution line above exceeded some limit we want PBS
   # to kill us hard
   sleep 5
   $ECHO "Job number $NJOB returned an error status $errstat - stopping job sequence."
   exit $errstat
fi

#
# Are we in an incomplete job sequence - more jobs to run ?
#
if [ $NJOB -lt $(($NJOBS - 1)) ]; then
# Now increment counter and submit the next job
#
   NJOB=$(($NJOB+1))
   $ECHO "Submitting job number $NJOB in sequence of $NJOBS jobs"
   cd $PBS_O_WORKDIR
   qsub -v NJOBS=$NJOBS,NJOB=$NJOB ./$JOBNAME.sh
else
   $ECHO "Finished last job in sequence of $NJOBS jobs"
fi
