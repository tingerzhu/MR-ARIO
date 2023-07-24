function [mr] = fn_compute_demand(input, mr, settings)
%Function to calculate new demand.
    
    % Export is assumed to be unchanged
    mr.exports(2,:) = input.econ.exports_pre_eq';
    
    % Local demand is modified by macro effect
    mr.local_demand(2,:) = mr.macro_effect * input.econ.local_demand_pre_eq';
    
    % Compute percentage recovery based on unmet reconstruction demand
    reconstr_demand =sum(mr.reconstr_demand_matrix(:,:,2),2);
    percent_recovered = 1 - (reconstr_demand ./ sum(mr.direct_losses_matrix,2));
    percent_recovered(isnan(percent_recovered)) = 1;
    idx_recovery = zeros(1,input.sectors.N_wHousing);
    
    % Locate the index of percentage % recovery on the provided empirical recovery curve
    for ind = 1:input.sectors.N_wHousing
        idx_recovery(ind) = find(input.recovery.smooth_recovery_curve(ind,:) >= percent_recovered(ind), 1, 'first');
    end
    
    raw_slope = input.recovery.smooth_slope_recovery_curve(:,idx_recovery);
    for ind = 1:input.sectors.N
        slopes(:,ind) = raw_slope(:,1).*mr.reconstr_demand_matrix(:,ind,2);
    end
    
    mr.reconstr_demand_rate(:,:,2) = slopes;
    
    % Compute aggregated order for each sector
    orders = sum(mr.orders(:,:,2),2)';
    
    % Compute total final demand 
    mr.demand(2,:) = max(settings.epsilon,mr.exports(2,:) + mr.local_demand(2,:) + sum(mr.reconstr_demand_rate(:,:,2)) + orders);

end

