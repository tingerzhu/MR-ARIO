function [mr] = fn_initialize_mr_variables(input, settings, sim)
%Function responsible for pre-allocate memory for major storage containers
% in the analysis, and handle assignment of pre-earthquake values where
% applicable. 
%
% Leverages information entered in the settings and input struct. 
% User can modify assumptions here, and add additional variables.
%
% Inputs:
%           input
%           mr
%           settings
%           sim 
% Output:
%           mr (containing initialized variables)
%

%% Step 1: Pre-allocate memory for storage containers 

    mr.imports                         = zeros(2, input.sectors.N);
    mr.exports                         = zeros(3, input.sectors.N);    
    mr.local_demand                    = zeros(2, input.sectors.N);
    mr.inter_purchases                 = zeros(2, input.sectors.N);
    mr.demand                          = zeros(2, input.sectors.N);
    mr.production                      = zeros(2, input.sectors.N);
    mr.demand_store                    = zeros(settings.Nstep_store+1, input.sectors.N);
    mr.production_store                = zeros(settings.Nstep_store+1, input.sectors.N);
    mr.production_cap                  = zeros(2, input.sectors.N);
    mr.production_cap_store            = zeros(settings.Nstep_store+1, input.sectors.N);
    mr.dom_production_cap              = zeros(2, input.sectors.N);
    mr.value_added                     = zeros(2, input.sectors.N);
    mr.value_added_store               = zeros(settings.Nstep_store+1, input.sectors.N);
    mr.scarcity_index                  = zeros(1, input.sectors.N);
    
    mr.dom_production                  = zeros(2, input.sectors.N);
    mr.dom_prod_lim_by_cap             = zeros(2, input.sectors.N);

    mr.orders                          = zeros(input.sectors.N, input.sectors.N, 2);
    mr.supply                          = zeros(input.sectors.N, input.sectors.N, 2);
    mr.stock                           = zeros(input.sectors.N, input.sectors.N, 2);
    mr.long_ST                         = zeros(input.sectors.N, input.sectors.N);

    mr.reconstr_demand_matrix          = zeros(input.sectors.N_wHousing, input.sectors.N, 2);
    mr.reconstr_demand_rate            = zeros(input.sectors.N_wHousing, input.sectors.N, 2);
    mr.reconstr_needs                  = zeros(1, input.sectors.N_wHousing);
    mr.reconstr_needs_store            = zeros(settings.Nstep_store+1, input.sectors.N_wHousing);
    mr.reconstr_inv                    = zeros(2, input.sectors.N_wHousing);
    mr.reconstr_demand_sat             = zeros(1,   input.sectors.N_wHousing);

    mr.budget                          = zeros(1, 2);
    mr.profit                          = zeros(2, input.sectors.N);
    mr.labor_comp                      = zeros(2, input.sectors.N);
    mr.macro_effect                    = 1;
    mr.total_labor                     = zeros(1, 2);
    mr.total_profit                    = zeros(1, 2);
    mr.price                           = ones(2, input.sectors.N);
    
    mr.destr                           = zeros(1, input.sectors.N);

%% Step 2: Assign pre-earthquake values 

    % Economic variables and containers
        mr.alpha_prod                            = ones(input.sectors.N, 1);
        mr.labor_comp(1,:)                       = input.econ.labor_comp_pre_eq   *  settings.exchange_rate;
        mr.assets                                = input.econ.FA_wHousing_pre_eq(1:input.sectors.N)  .* settings.exchange_rate;
        mr.imports(1, :)                         = input.econ.imports_pre_eq'       *  settings.exchange_rate;
        mr.imports(3, :) = mr.imports(1, :);
        mr.exports(1, :)                         = input.econ.exports_pre_eq'       *  settings.exchange_rate;    
        mr.local_demand(1, :)                    = input.econ.local_demand_pre_eq  *  settings.exchange_rate;
        mr.inter_sales(1, :)                     = sum(input.IO, 2);
        mr.inter_purchases(1, :)                 = sum(input.IO, 1);
        mr.production(1, :)                      = mr.exports(1, :)'   + mr.local_demand(1, :)'   + mr.inter_sales(1, :)';
        mr.IO_norm                               = input.IO./repmat(mr.production(1, :), input.sectors.N, 1);
        mr.demand(1, :)                          = mr.production(1, :);
        mr.dom_production(1, :)                  = mr.production(1, :) - mr.imports(1, :);
        mr.production_cap(1, :)                  = mr.production(1, :);
        mr.value_added(1, :)                     = mr.production(1, :) - mr.inter_purchases(1, :) - mr.imports(1, :);
        
        mr.demand_store(1, :)                    = mr.demand(1, :);
        mr.production_store(1, :)                = mr.production(1, :);
        mr.production_cap_store(1, :)            = mr.production_cap(1, :);
        mr.value_added_store(1, :)               = mr.value_added(1, :);

        % Orders, stocks
            for i = 1:input.sectors.N  
                for j = 1:input.sectors.N                          
                    mr.stock(i,j,1)   = input.IO(i,j) * input.params.n_stock(i, sim)*settings.dt;
                    mr.stock(i,j,2)   = mr.stock(i,j,1);
                    mr.long_ST(i,j) = mr.stock(i,j);
                    mr.orders(i,j,1)  = input.IO(i,j);
                    mr.orders(i,j,2)  = mr.orders(i,j,1);
                end
            end

        % Household budget modeling & macroeconomic effect
            mr.profit(1, :)                           = mr.production(1, :) - (mr.inter_purchases(1, :) + (settings.wage * mr.labor_comp(1, :)) + mr.imports(1, :));
            mr.total_labor(1)                         = sum(mr.labor_comp(1, :));
            mr.total_profit(1)                        = sum(mr.profit(1, :));
            mr.total_labor(2)                         = mr.total_labor(1);
            mr.total_profit(2)                        = mr.total_profit(1);

            % Profits from businesses outside the affected region
            % Assumption: Profits that leave the region are equal to Profits that enter the region
            mr.Pi                                     = (1 - settings.alpha) * sum(mr.profit(1, :));

            % Initial household consumption and investment 
            mr.DL_initial                             = settings.wage * sum(mr.labor_comp(1,:))+ settings.alpha * sum(mr.profit(1, :) ) + mr.Pi;

        % Losses and reconstruction demand
            mr.direct_losses_matrix                   = input.loss.losses_per_sector .* settings.ampl;
            mr.direct_losses_vector                   = sum(mr.direct_losses_matrix,2)   .* input.loss.frac_loss_prod';
            mr.destr_wHousing                         = mr.direct_losses_vector'         ./ input.econ.FA_wHousing_pre_eq;
            mr.destr(1,:)                             = mr.destr_wHousing(1:input.sectors.N);

            % Initialization of reconstruction demand 
                for i = 1:input.sectors.N_wHousing
                    for j = 1:input.sectors.N
                        mr.reconstr_demand_matrix(i,j,1) = mr.direct_losses_matrix(i,j);
                        mr.reconstr_demand_matrix(i,j,2) = mr.direct_losses_matrix(i,j);
                    end
                end                

            % Initialize reconstruction needs using sum of direct losses
                mr.reconstr_needs(1,:) = sum(mr.direct_losses_matrix,2)';
                mr.reconstr_needs_store(1,:) = mr.reconstr_needs(1,:);
            
disp("TEMP comment : The mr struct contains " + num2str(length(fieldnames(mr))) + " variables.")

end