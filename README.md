# Overview
This repository documents the simulation workflow I used in SLiM to model gene flow across a four-population tree. The model includes 11 key parameters, each with at least three values, resulting in a high-dimentional parameter space. 

To streamline the analysis, I identified five focused question blocks, organising a total of 162 evolutionary scenarions (unique parameter space). 

# Simulation Design
- Total simulations: 162 scenarios
- Replicates per scenario: 48
- Platform: HPC/Gadi
- Parallelisation strategy: Each simulation was run with 48 replicates, matching the 48 CPUs/cores available per node on Gadi. This setup maximised computational efficiency and ensured robust results.

# Folder Structure and Contents
Each question block contains the four subfolders: R/, slim/, /PBS, and done/. Below is a breakdown of the six key files used to run simulations in parallel on HPC/Gadi:

## R/
Contains input data for simulation replicates and parameter combinations:
- seeds.csv - A list of 48 unique random seeds, each corresponding to one replicate.
- combos.csv - Defines the parameter values varied in each question block and includes all combinations used in the simulations.

## slim/
Contains the SLiM simulation script:
- script.slim - The main SLiM script that runs the simulation, generates genomic data, and outputs results in VCF format.

## PBS/
Handles job scheduling and execution on Gadi:
- cmds.txt - A table with three columns: modelID, seed, and the path to runSimulationSR.sh. Each row represents a single simulation replicate.
- runSimulationSR.sh - A shell script reads parameter values from combos.csv and executes the SLiM simulation once.
- jobsub.sh - The job submission script used to launch simulations on Gadi via PBS.

## done/
Used for tracking simulation completion. This folder stores markers indicating whether each simulation has finished successfully. 

Note: Please ignore the folders old_block_5.1 and old_block_5.2. These have been updated and merged into block_5_42. 
