function [loss] = fn_get_loss_data(f_name, settings, type)
%Function responsible for loading loss data from input file.

switch(type)
    case('no_UQ')
        % Load data from file.
        loss     = load(f_name);

    otherwise
        disp("loss data type not yet implemented.")

end
