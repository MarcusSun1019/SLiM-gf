#!/bin/bash -l

cd $PBS_JOBFS
SECONDS=0

# Rename the first and second arguments passed to this single shot script for clarity
MODELINDEX=$1
SEED=$2
FILENAME=${MODELINDEX}_${SEED}
JOBNAME=block_1_28
FULLJOBNAME=$JOBNAME
TESTDIR=$HOME/CH2/$JOBNAME

if [ -f $TESTDIR/done/${FILENAME} ]; then
     echo "$FILENAME already done! Moving to next simulation."
     exit 0
fi

# Get the correct model index from the file: put into array
# From the table with all parameter combination: combo.csv
MODEL_FILE=$TESTDIR/R/combos.csv
MODEL_NUM=($(awk "NR==$MODELINDEX" $MODEL_FILE))

# Read in seeds from the list of seeds: seeds.csv
SEED_FILE=$TESTDIR/R/seeds.csv
SEED_NUM=($(awk "NR==$SEED" $SEED_FILE))

# Output a message indicating which model and seed are being run
# Run the model
echo "Running modelindex = $MODELINDEX, seed = $SEED...\n"
$HOME/software/slim-install/bin/slim -s ${SEED_NUM} -d modelindex=$MODELINDEX -d delta_t2=${MODEL_NUM[0]} -d delta_t3=${MODEL_NUM[1]} -d delta_t4=${MODEL_NUM[2]} -d m=${MODEL_NUM[3]} $TESTDIR/slim/script.slim

# Record the elapsed time and output a completion message
# Convert the seconds into hours, minutes, and seconds for readable outputs
DURATION=$SECONDS
echo "Run modelindex = $MODELINDEX, seed = $SEED finished!"
echo "$(($DURATION / 3600)) hours, $((($DURATION / 60) % 60)) minutes, and $(($DURATION % 60)) seconds elapsed."

# Create an empty file in the done directory with the model/seed name to indicate the specific simulation has been completed
touch $TESTDIR/done/${FILENAME}
