# Overview
This repository documents the simulation workflow I used in SLiM to model gene flow across a four-population tree. The model includes 11 key parameters, each with at least three values, resulting in a high-dimentional parameter space. 

To streamline the analysis, I identified five focused question blocks, organising a total of 162 evolutionary scenarions (unique parameter space). 

# Simulation Design
- Total simulations: 162 scenarios
- Replicates per scenario: 48
- Platform: HPC/Gadi
- Parallelisation strategy: Each simulation was run with 48 replicates, matching the 48 CPUs/cores available per node on Gadi. This setup maximised computational efficiency and ensured robust results.

# Folder Structure
Each question block contains the following subfolders:
- PBS/
- R/
- slim/
- done/ (This folder is used to track whether each simulation has completed successfully.)

These folders collectively include six essential files that enable parallel execution of simulations.

Note: Please disregard the folders old_block_5.1 and old_block_5.2. These have been updated and merged into block_5_42. 
