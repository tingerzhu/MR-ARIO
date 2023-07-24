function [settings] = fn_load_default_ario_settings(input, settings)
% function responsible for loading hardcoded analysis parameters.

    % Set threshold used to estimate what is full recovery (in adaptation process)
        settings.epsilon = 1.e-6;
    
    % Set size of the direct losses (default = 1.00)
        settings.ampl = 1.00;

    % Set macro effect / economic settings
        % set timescale of debt reimbursement (years)
          settings.tauR = 2;

        % set household insurance penetration rate
           settings.penetration    = 1.0;

        % set business insurance penetration rate
           settings.penetrationf   = 1.0 ;

        % set alpha = fraction of capital that is owned locally - ad hoc assumption
        % (used to know how decrease in business profit affects household income.)
            settings.alpha         = 0.5;

        % set wage and exchange rate
            settings.wage          = 1.0;
            settings.exchange_rate = 1.0;



end
