function [mr] = run_mr_ario(input, settings)
% 
%   Multi-region ARIO function
%   Stanford Urban Resilience Initiative
%   Summer 2023
%
% Inputs:
%           input (sectors, IO, econ, loss, recovery, params)
%           settings (n_sim, st, NStep)
% Output:
%           mr_output


    for sim = 1:settings.n_sim
        %% Load_default_ARIO_model_settings 
            % Load default analysis settings
            [settings]     = fn_load_default_ario_settings(input, settings);

        %% Initialize storage containers 
            [mr]           = fn_initialize_mr_variables(input, settings, sim);

        %% Main loop
            for k = 1:settings.Nstep
                %% Stage 1: get_production
                % Purpose of this stage: leverage (i) demand, (ii)production capacity, and
                % (iii) supply constraints to generate actual production for each time
                % step

                % Compute demand 
                [mr] = fn_compute_demand(input, mr, settings);

                % Impose constraint 1: production capacity 
                [mr] = fn_compute_prod_lim_by_cap(mr, input);

                % Impose constraint 2: supply 
                [mr] = fn_compute_prod_lim_by_cap_sup(sim, input, mr, settings);

                %% Stage 2: calculate result economic metrics and update for next time step
                % Purpose of this stage: leverage satisfied ratio (production/demand) 
                % to compute (i) output economic metrics for timestep k,
                % (ii) input economic metrics for timestep k+1, and (iii)
                % output economic performance for timestep k

                mr.satisfied_ratio(2,:) = mr.production(2,:) ./ mr.demand(2,:);
                mr.satisfied_ratio_wHousing(2,:) = [mr.satisfied_ratio(2,:) mr.satisfied_ratio(2,input.construction_idx)];

                % Calculate the output economic metrics for timestep k 
                [mr] = fn_get_output_econ_metrics(input, mr);

                % Update the input economic metrics for timestep k+1
                [mr] = fn_update_input_econ_metrics(sim, input, mr, settings);
                
                % Calculate the output economic performance for timestep k 
                [mr] = fn_get_output_econ_performance(input, mr);

                %% Stage 3: Save variables of interest
                    if (mod(k,settings.dt_store/settings.dt)<1)
                        store_k = store_k + 1;
                        mr.demand_store(store_k, :)                    = mr.demand(2, :);
                        mr.production_store(store_k, :)                = mr.production(2, :);
                        mr.production_cap_store(store_k, :)            = mr.production_cap(2, :);
                        mr.value_added_store(store_k, :)               = mr.value_added(2, :);
                        mr.reconstr_needs_store(store_k, :)            = mr.reconstr_needs(1,:);
                    end
            end
    end
end