function [econ] = fn_get_economic_data(f_name, settings, type)
%Function responsible for loading economic data from input file.

switch(type)
    case('no_UQ')
        % Load data from file.
        econ     = load(f_name);

    otherwise
        disp("economic data type not yet implemented.")

end
