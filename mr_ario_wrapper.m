%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%   Japan-ARIO project: Multi-region wrapper script
%   Stanford Urban Resilience Initiative
%   Summer 2023
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Clean up MATLAB workspace
clc; clear all; close all;

%% Main analysis settings

    settings.n_sim   = 1;
    settings.dt      = 1/365;
    settings.dt_store = 1/365;
    settings.Nstep   = round(10/settings.dt);
    settings.Nstep_store = round(10/settings.dt_store);
    settings.epsilon = 1.e-6;
    settings.t       = 0:settings.dt:settings.Nstep*settings.dt;
    settings.t_store = 0:settings.dt_store:settings.Nstep_store*settings.dt_store;

%% Enter path settings

    f_name.IO      = "mr_ario_IO_data.mat";
    f_name.econ    = "mr_ario_econ_data.mat";
    f_name.loss    = "mr_ario_loss_data.mat";
    f_name.dmg     = "mr_ario_building_damage.csv";
    f_name.sectors = "mr_ario_economic_sectors.csv";

addpath inputs
addpath functions

%% Load analysis input parameters/data
    
    % get_sectors
        input.sectors  = fn_get_sectors_mr(f_name.sectors);
        input.construction_idx = 21:input.sectors.N_per_region:input.sectors.N; % manually identified the index for construction sector
        
    % get_IO_data
        input.IO       = fn_get_IO_data(f_name.IO);
    
    % get_economic_data
        input.econ     = fn_get_economic_data(f_name.econ, settings, 'no_UQ');
    
    % get_loss_data
        input.loss     = fn_get_loss_data(f_name.loss, settings, 'no_UQ');
        
    
    % get_t95_data or get_emp_recovery_curves
        % constant slope to t_95
        input.recovery = fn_get_emp_recovery_curves_mr(f_name.dmg, input, settings, 'no_UQ');
    
    % get_behavorial_parameters
        input.params   = fn_get_behavorial_parameters_mr(input, settings, 'mean');
    
    
%% Run single_region_ARIO function
    mr_output = run_mr_ario(input, settings);
    save('outputs/mr_ario_results.mat','input','settings','mr_output', '-v7.3');
