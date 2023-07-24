function [mr] = fn_get_output_econ_performance(input, mr)
%Function to calculate output economic performance for timestep k.
    
    % Calculate value added
    mr.value_added(2,:) = mr.production(2,:) - mr.imports(2,:)...
        - sum(mr.IO_norm.* repmat(mr.production(2,:),input.sectors.N,1),1);
    
    
end