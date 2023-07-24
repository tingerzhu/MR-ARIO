function [mr] = fn_get_output_econ_metrics(input, mr)
%Function to calculate output economic metrics for timestep k.
    
    % Calculate actual satisfied demand
    mr.local_demand_sat(2,:) = mr.local_demand(2,:).*mr.satisfied_ratio(2,:);
    
    % Calculate actual supply
    mr.supply(:,:,2) = mr.orders(:,:,2).* transpose(repmat(mr.satisfied_ratio(2,:),input.sectors.N,1));
    
end