function [mr] = fn_compute_prod_lim_by_cap_sup(sim, input, mr, settings)
%Function to calculate production limited by supplies.
    
    % Compute target inventories
    stock_required = repmat(mr.prod_lim_by_cap(2,:),input.sectors.N,1).*...
        mr.IO_norm.*repmat(input.params.n_stock(:,sim)*settings.dt,1,input.sectors.N);
    
    if input.sub_ratio == 1
        % Compute production ratio (compared to pre-event production) by stock
        stock_by_sector = zeros(input.sectors.N_per_region, input.sectors.N_per_region*input.sectors.region_N);
        stock_required_adj = repmat(input.params.psi(:,sim),1,input.sectors.N).*stock_required;
        stock_required_by_sector = zeros(input.sectors.N_per_region, input.sectors.N_per_region*input.sectors.region_N);

        for i = 1:input.sectors.region_N
            stock_by_sector = stock_by_sector + mr.stock(((i-1)*input.sectors.N_per_region+1):(i*input.sectors.N_per_region),:,2);
            stock_required_by_sector = stock_required_by_sector + stock_required_adj(((i-1)*input.sectors.N_per_region+1):(i*input.sectors.N_per_region),:);
        end

        product_ratio_by_sector = stock_by_sector ./ stock_required_by_sector;

        % Compute the production constraints on sector i by sector j and
        % resultant actual production limited by both capacity and supplies
        dom_product_constraint = repmat(transpose(mr.dom_prod_lim_by_cap(2,:)),1,input.sectors.N_per_region); % how much industry i can produce constrained on j
        for i = 1:input.sectors.N
           for j = 1:input.sectors.N_per_region
               if stock_by_sector(j,i)< stock_required_by_sector(j,i)
                   dom_product_constraint(i,j) = dom_product_constraint(i,j) * min(1,product_ratio_by_sector(j,i));
               end
           end
           mr.dom_production(2,i) = min(dom_product_constraint(i,:));
           if mr.dom_production(2,i)<mr.dom_prod_lim_by_cap(2,i)
               mr.imports(3,i) = min(mr.imports(3,i)+mr.dom_prod_lim_by_cap(2,i)-mr.dom_production(2,i),mr.imports(1,i));
           end
           mr.production(2,i) = mr.dom_production(2,i) + mr.imports(3,i);
        end
        
    else
        % Compute production ratio (compared to pre-event production) by stock
        product_ratio = mr.stock(:,:,2)./(repmat(input.params.psi(:,sim),1,input.sectors.N).*stock_required);

        % Compute the production constraints on sector i by sector j and
        % resultant actual production limited by both capacity and supplies
        dom_product_constraint = repmat(transpose(mr.dom_prod_lim_by_cap(2,:)),1,input.sectors.N); % how much industry i can produce constrained on j
        for i = 1:input.sectors.N
           for j = 1:input.sectors.N
               if mr.stock(j,i,2)< input.params.psi(j,sim)*stock_required(j,i)
                   dom_product_constraint(i,j) = dom_product_constraint(i,j) * min(1,product_ratio(j,i));
               end
           end
           mr.dom_production(2,i) = min(dom_product_constraint(i,:));
           if mr.dom_production(2,i)<mr.dom_prod_lim_by_cap(2,i)
               mr.imports(3,i) = min(mr.imports(3,i)+mr.dom_prod_lim_by_cap(2,i)-mr.dom_production(2,i),mr.imports(1,i));
           end
           mr.production(2,i) = mr.dom_production(2,i) + mr.imports(3,i);
        end
    end
    
    
end