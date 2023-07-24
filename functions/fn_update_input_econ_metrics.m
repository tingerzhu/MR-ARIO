function [mr] = fn_update_input_econ_metrics(sim, input, mr, settings)
%Function to calculate input economic metrics for timestep k+1.
    
    % Update reconstruction demand
    mr.reconstr_demand_matrix(:,:,1) = mr.reconstr_demand_matrix(:,:,2);
    mr.reconstr_demand_matrix(:,:,2) = max(0, mr.reconstr_demand_matrix(:,:,2) - ...
        mr.reconstr_demand_rate(:,:,2) .* mr.satisfied_ratio_wHousing(2,:)' .* settings.dt);
    mr.reconstr_inv(1,:) = mr.reconstr_inv(2,:);
    mr.reconstr_inv(2,:) = transpose(max(0, sum(mr.reconstr_demand_matrix(:,:,1),2)...
        - sum(mr.reconstr_demand_matrix(:,:,2),2)));
    mr.reconstr_needs(1,:) = mr.reconstr_needs(1,:)- mr.reconstr_inv(2,:);

    % Update stock
    mr.stock(:,:,2) = mr.stock(:,:,2) + settings.dt*...
        (mr.supply(:,:,2)-mr.IO_norm.* repmat(mr.production(2,:),input.sectors.N,1));
    mr.stock(:,:,2) = max(settings.epsilon,mr.stock(:,:,2));
    
    % Update order
    for i = 1:input.sectors.N
        for j = 1:input.sectors.N
            mr.orders(i,j,2) = max(settings.epsilon,mr.production(2,j)/mr.production(1,j)*input.IO(i,j)...
                + (mr.long_ST(i,j)-mr.stock(i,j,2))/input.params.tau_stock(i,sim));
        end
    end
    
    % Update overproduction capacity
    mr.scarcity_index(2,:) = 1 - mr.satisfied_ratio(2,:);
    for i = 1:input.sectors.N
        if mr.scarcity_index(2,i) > settings.epsilon
            mr.alpha_prod(i) = mr.alpha_prod(i) + ...
                (input.params.alpha_prod_max(i,sim)-mr.alpha_prod(i))* mr.scarcity_index(2,i)*settings.dt/input.params.tau_alpha(i,sim);
        else
            mr.alpha_prod(i) = mr.alpha_prod(i) + ...
                (1-mr.alpha_prod(i))*settings.dt/input.params.tau_alpha(i,sim);
        end    
    end
    
    
    % Update import
    mr.imports(2,:) = mr.imports(3, :);
    mr.imports(3,:) = mr.imports(1, :);
    
    % Update loss of productive capital
    for i=1:input.sectors.N
        mr.destr(i)=sum(mr.reconstr_demand_matrix(i,:,2))/mr.assets(i)*input.loss.frac_loss_prod(sim,i);
    end
    
    % Update macro effect
    mr.labor_comp(2,:) = mr.labor_comp(1,:).*mr.production(2,:)./mr.production(1,:);
    mr.total_labor(1) = mr.total_labor(2);
    mr.total_labor(2) = sum(mr.labor_comp(2,:));
    mr.inter_purchases(2,:) = sum(mr.IO_norm.* repmat(mr.production(2,:),input.sectors.N,1).* repmat(mr.price(2,:)',1,input.sectors.N));
    mr.profit(2,:) = mr.production(2,:) - (mr.inter_purchases(2,:) + mr.labor_comp(2,:)+ mr.imports(2,:))...
         - mr.reconstr_inv(1,1:input.sectors.N)*(1-settings.penetrationf);
    mr.total_profit(1) = mr.total_profit(2);
    mr.total_profit(2) = sum(mr.profit(2,:));
    mr.budget(2) = mr.budget(2)+ (settings.wage*mr.total_labor(2)-settings.wage*mr.total_labor(1)...
        + settings.alpha*(mr.total_profit(2) - mr.total_profit(1)));
    mr.macro_effect = (mr.DL_initial + 1/settings.tauR * mr.budget(2))/mr.DL_initial;
    
    
end