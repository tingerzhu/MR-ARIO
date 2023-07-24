function [IO] = fn_get_IO_data(f_name)
%Function responsible for loading IO data from input file.

% Load data from file.
    IO_data     = load(f_name);
    IO          = IO_data.IO_table;

end
