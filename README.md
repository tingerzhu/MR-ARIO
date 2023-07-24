# Multi-region ARIO analysis 
**Stanford Urban Resilience Initiative, 2023** <br>
**Original program by Stephane Hallegatte, 2014** <br>
MATLAB codebase for quantifying post-disaster economic recovery for multi-regional analysis. Based on the original ARIO model by Hallegatte, 2014 and single-region ARIO model by Stanford Urban Resilience Initiative, 2022. 

*License: GNU General Public License v3.0 (see LICENSE)*

## Updates
    07/23/2023: 
    - This program requires a set of pre-formatted inputs to run.

## Program overview
This repository contains the following:
* **mr_wrapper.m**: wrapper script governing analysis settings
* **fn_run_mr_ario.m**: wrapper function for multi-region ARIO program
* **functions**: functions for simulating economic recovery, and auxilaliary post-processing tools
* **inputs**: pre-processed (1) economic inputs, (2) damage/loss inputs, and (3) I-O inputs
    * params : input files for ARIO behavioral parameter distributions
* **output**: analysis output and main preprocessing program

## fn_run_mr_ario overview
The function fn_run_mr_ario is the main function governing the ARIO analysis, and is called by the program wrapper, sr_wrapper after analysis settings are defined.
* fn_load_default_ario_settings: loads hardcoded analysis parameters
* fn_initialize_mr_variables: initializes containers for all timesteps in the analysis. Sets initial, pre-disaster values where applicable.
* Main loop: for timestep $k = 1:n$:
    * fn_compute_demand: computes percentage of sector-level recovery, updates reconstruction demand rate and total final demand for the next time step
    * fn_compute_prod_lim_by_cap: computes production constrained by production capacity.
    * fn_compute_prod_lim_by_cap_sup: computes production constrained by production capacity and supplies available.
    * fn_get_output_econ_metrics: computes the actual satisfied demand and actual supply for the next time step.
    * fn_update_input_econ_metrics: update input economic metrics for the next time step.
    * fn_get_output_econ_performance: update output economic metrics for the next time step.

## Input files
* **mr_ario_building_damage.csv**: contains individual damage observations/simulations for each building (or building cluster) in the simulated inventory. Used directly by the program to construct sector-specific recovery curves, control the rate of reconstruction for each sector.
* **mr_ario_econ_data.mat**: economic data for each sector in the economy, including:
    * exports
    * final demand
    * imports
    * value added
    * local demand
    * fixed assets
    * total output
* **mr_ario_economic_sectors.csv**: list of sectors modeled in the economy (should include housing, if available). Each sector's ID, name, and non_stockable good status must be included.
* **mr_ario_IO_data.mat**: raw IO matrix (non-normalized) to be used directly in the analysis.
* **mr_ario_loss_data.mat**: variables that contain sector-level aggregate losses and reconstruction demand assignment.

## Output files
* **mr_ario_results.mat**: .mat file containing mr_output, a MATLAB struct containing the results of the analysis.

## Running an analysis
The steps to run a multi-region ARIO analysis are summarized below. 
1. Place (i) `mr_ario_building_damage.csv`, (ii) `mr_ario_econ_data.mat`, (iii) `mr_ario_economic_sectors.csv`,  (iv) `mr_ario_IO_data.mat`, and (v) `mr_ario_loss_data.mat` in the `inputs` directory. 
2. Run the `mr_ario_wrapper.m` script, which calls on the `run_mr_ario.m` function to initiate the ARIO analysis with user-defined settings.
3. Analysis will be saved in the `outputs` directory.
