function [params] = sample_param_truncated_norm_mr(i,input, params, n_sim, default_alpha_max, default_inventory, ...
                                          default_psi, default_tau_alpha, default_tau_inventory)
% Function to sample parameters using default settings, truncated normal distribution 

      % Sampling settings
      dim = [input.sectors.N_per_region 1];
      assumed_cov = 0.25;
      x = (i-1)*input.sectors.N_per_region + 1;
      
      for UQ_sim = 1:n_sim
          
      % alpha_prod_max
            params.alpha_prod_max(x:(x+input.sectors.N_per_region-1),UQ_sim) = normrnd(default_alpha_max.mean, assumed_cov .* default_alpha_max.mean, dim);

            idx_resample = ~((params.alpha_prod_max(x:(x+input.sectors.N_per_region-1),UQ_sim) <= default_alpha_max.ub) & (params.alpha_prod_max(:,UQ_sim) >= default_alpha_max.lb));

            while(sum(double(idx_resample) > 0))
                % Resample for sectors out-of-bounds of truncation
                idx_resample = ~((params.alpha_prod_max(x:(x+input.sectors.N_per_region-1),UQ_sim) <= default_alpha_max.ub) & (params.alpha_prod_max(x:(x+input.sectors.N_per_region-1),UQ_sim) >= default_alpha_max.lb));
                idx_resample_dim = [sum(idx_resample) 1];
                params.alpha_prod_max(idx_resample,UQ_sim) = normrnd(default_alpha_max.mean(idx_resample), assumed_cov .* default_alpha_max.mean(idx_resample), idx_resample_dim);        
            end

      % Tau_Stock
            params.tau_stock(x:(x+input.sectors.N_per_region-1),UQ_sim) = normrnd(default_tau_inventory.mean, assumed_cov .* default_tau_inventory.mean, dim);

            idx_resample = ~((params.tau_stock(x:(x+input.sectors.N_per_region-1),UQ_sim) <= default_tau_inventory.ub) & (params.tau_stock(x:(x+input.sectors.N_per_region-1),UQ_sim) >= default_tau_inventory.lb));

            while(sum(double(idx_resample) > 0))
                % Resample for sectors out-of-bounds of truncation
                idx_resample = ~((params.tau_stock(x:(x+input.sectors.N_per_region-1),UQ_sim) <= default_tau_inventory.ub) & (params.tau_stock(x:(x+input.sectors.N_per_region-1),UQ_sim) >= default_tau_inventory.lb));
                idx_resample_dim = [sum(idx_resample) 1];
                params.tau_stock(idx_resample,UQ_sim) = normrnd(default_tau_inventory.mean(idx_resample), assumed_cov .* default_tau_inventory.mean(idx_resample), idx_resample_dim);        
            end

      % tau_alpha         
            params.tau_alpha(x:(x+input.sectors.N_per_region-1),UQ_sim) = normrnd(default_tau_alpha.mean, assumed_cov .* default_tau_alpha.mean, dim);

            idx_resample = ~((params.tau_alpha(x:(x+input.sectors.N_per_region-1),UQ_sim) <= default_tau_alpha.ub) & (params.tau_alpha(x:(x+input.sectors.N_per_region-1),UQ_sim) >= default_tau_alpha.lb));

            while(sum(double(idx_resample) > 0))
                % Resample for sectors out-of-bounds of truncation
                idx_resample = ~((params.tau_alpha(x:(x+input.sectors.N_per_region-1),UQ_sim) <= default_tau_alpha.ub) & (params.tau_alpha(x:(x+input.sectors.N_per_region-1),UQ_sim) >= default_tau_alpha.lb));
                idx_resample_dim = [sum(idx_resample) 1];
                params.tau_alpha(idx_resample,UQ_sim) = normrnd(default_tau_alpha.mean(idx_resample), assumed_cov .* default_tau_alpha.mean(idx_resample), idx_resample_dim);        
            end      
            
      % Psi         
            params.psi(x:(x+input.sectors.N_per_region-1),UQ_sim) = normrnd(default_psi.mean, assumed_cov .* default_psi.mean, dim);

            idx_resample = ~((params.psi(x:(x+input.sectors.N_per_region-1),UQ_sim) <= default_psi.ub) & (params.psi(x:(x+input.sectors.N_per_region-1),UQ_sim) >= default_psi.lb));

            while(sum(double(idx_resample) > 0))
                % Resample for sectors out-of-bounds of truncation
                idx_resample = ~((params.psi(x:(x+input.sectors.N_per_region-1),UQ_sim) <= default_psi.ub) & (params.psi(x:(x+input.sectors.N_per_region-1),UQ_sim) >= default_psi.lb));
                idx_resample_dim = [sum(idx_resample) 1];
                params.psi(idx_resample,UQ_sim) = normrnd(default_psi.mean(idx_resample), assumed_cov .* default_psi.mean(idx_resample), idx_resample_dim);        
            end      

            psi = params.psi(x:(x+input.sectors.N_per_region-1),UQ_sim)';

      % NStock         
            params.n_stock(x:(x+input.sectors.N_per_region-1),UQ_sim) = normrnd(default_inventory.mean, assumed_cov .* default_inventory.mean, dim);

            idx_resample = ~((params.n_stock(x:(x+input.sectors.N_per_region-1),UQ_sim) <= default_inventory.ub) & (params.n_stock(x:(x+input.sectors.N_per_region-1),UQ_sim) >= default_inventory.lb));

            while(sum(double(idx_resample) > 0))
                % Resample for sectors out-of-bounds of truncation
                idx_resample = ~((params.n_stock(x:(x+input.sectors.N_per_region-1),UQ_sim) <= default_inventory.ub) & (params.n_stock(x:(x+input.sectors.N_per_region-1),UQ_sim) >= default_inventory.lb));
                idx_resample_dim = [sum(idx_resample) 1];
                params.n_stock(idx_resample,UQ_sim) = normrnd(default_inventory.mean(idx_resample), assumed_cov .* default_inventory.mean(idx_resample), idx_resample_dim);        
            end      
      end
end

