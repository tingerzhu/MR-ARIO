function [mr] = fn_compute_prod_lim_by_cap(mr, input)
%Function to calculate new production capacity.
    
    % Compute production capacity ratio (compared to pre-event production) due to damage
    mr.product_cap_ratio = 1 - mr.destr(1,:);
    
    % Compute production capacity considering overproduction adaptation
    mr.dom_production_cap(2,:) = max(0, mr.alpha_prod(:,1)'.*mr.dom_production(1,:).*mr.product_cap_ratio);
    mr.production_cap(2,:) = mr.dom_production_cap(2,:) + mr.imports(3,:);
    
    % Compute production limited by capacity by taking the minimum of
    % production capacity and demand
    mr.prod_lim_by_cap(2,:) = min(mr.production_cap(2,:), mr.demand(2,:));
    for i = 1:input.sectors.N
        if mr.demand(2,i) > mr.production_cap(2,i)
            mr.dom_prod_lim_by_cap(2,i) = mr.prod_lim_by_cap(2,i) - mr.imports(3,i);
        else
            mr.dom_prod_lim_by_cap(2,i) = mr.prod_lim_by_cap(2,i)/mr.production_cap(2,i)*mr.dom_production_cap(2,i);
            mr.imports(3,i) = mr.prod_lim_by_cap(2,i)/mr.production_cap(2,i)*mr.imports(3,i);
        end
    end
end