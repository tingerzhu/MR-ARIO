%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%   Japan-ARIO project: Multi-region economic data preprocessing script
%   Stanford Urban Resilience Initiative
%   Summer 2023
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%   This codes presents an example to extract the input information 
%   of two regions from a three-region IO table for the multi-
%   regional analysis.
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Clean up MATLAB workspace
clc; clear all; close all;

%% Load data
addpath('inputs')
sub_region = readtable('mr_ario_regions.csv');
sector = readtable('mr_ario_economic_sectors.csv');
raw_io = readtable('IO_table_data.csv');

%% Basic information
num_region = 3;        % number of regions in the inter-regional IO table
num_row = 46;           % number of rows in the sub-IO table for each region pair
num_col = 56;           % number of columns in the sub-IO table for each region pair
num_local_sector = 37;  % number of sectors in each sub-region
num_sub_region = 2;     % number of sub-regions for ARIO analysis

%% Seperation by region pairs
for i = 1:num_region
    for j = 1:num_region
        raw_io_sub{i}{j} = raw_io{((i-1)*num_row+3):(i*num_row+2),((j-1)*num_col+3):(j*num_col+2)};
    end
end

%% Rearrange of economic information
for i = 1:num_region
    for j = 1:num_region
        io.IO_table{i}{j} = raw_io_sub{i}{j}(1:num_local_sector,1:num_local_sector);
        io.value_added{i}{j} = raw_io_sub{i}{j}(39:44,1:num_local_sector);
        io.labor_comp{i}{j} = io.value_added{i}{j}(2,:);
        io.total_final_demand{i}{j} = raw_io_sub{i}{j}(1:num_local_sector,45);
        io.export{i}{j} = raw_io_sub{i}{j}(1:num_local_sector,49);
        io.export_only{i}{j} = raw_io_sub{i}{j}(1:num_local_sector,47);
        io.import{i}{j} = -raw_io_sub{i}{j}(1:num_local_sector,54)';
        io.import_only{i}{j} = raw_io_sub{i}{j}(1:num_local_sector,52);
        io.gross_output{i}{j} = raw_io_sub{i}{j}(1:num_local_sector,56);
        io.gross_input{i}{j} = raw_io_sub{i}{j}(46,1:num_local_sector);
        io.intermediate_input{i}{j} = raw_io_sub{i}{j}(38,1:num_local_sector);
    end
end
%% Matrix balancing (choose any suitable techniques)

%% Aggregated io table and local demand for each region
io.agg_io = {};
io.agg_tfd = {};
io.agg_va = {};
for i = 1:num_region
    io.agg_io{i} = io.IO_table{i}{i};
    io.agg_tfd{i} = io.total_final_demand{i}{i};
    io.agg_va{i} = io.value_added{i}{i};
    for j = 1:num_region
        if j ~= i
            io.agg_io{i} = io.agg_io{i} + io.IO_table{j}{i};
            io.agg_tfd{i} = io.agg_tfd{i} + io.total_final_demand{j}{i};
            io.agg_va{i} = io.agg_va{i} + io.value_added{j}{i};
        end
    end
end

%% Extract input of region 1 and region 2 for ARIO
%% Create IO table
IO_table = zeros(num_local_sector*2);
for i = 1:2
    for j = 1:2
        y = (i-1)*num_local_sector + 1;
        x = (j-1)*num_local_sector + 1;
        IO_table(y:(y+num_local_sector-1),x:(x+num_local_sector-1)) = io.IO_table{i}{j};
    end
end

for i  = 1:2
    for j = 1:num_region
        if j>2
            y = (i-1)*num_local_sector + 1;
            IO_table(y:(y+num_local_sector-1),y:(y+num_local_sector-1)) = ...
                IO_table(y:(y+num_local_sector-1),y:(y+num_local_sector-1)) + io.IO_table{j}{i};
        end
    end
end

save('inputs/mr_ario_IO_data.mat','IO_table');

%% Create economic and loss data
% initialize data
exports_pre_eq = zeros(num_local_sector*num_sub_region,1);
imports_pre_eq = zeros(1,num_local_sector*num_sub_region);
local_demand_pre_eq = zeros(num_local_sector*num_sub_region,1);
value_added_pre_eq = zeros(1,num_local_sector*num_sub_region);
labor_comp_pre_eq = zeros(1,num_local_sector*num_sub_region);
FA_wHousing_pre_eq = zeros(1,(num_local_sector+1)*num_sub_region);
losses_per_sector = zeros((num_local_sector+1)*num_sub_region);

inflow = {};
outflow = {};
for i = 1:2
    y = (i-1)*num_local_sector + 1;
    
    % exports and imports
    inflow{i} = zeros(num_local_sector,1);
    outflow{i} = zeros(num_local_sector,1);
    for j = 1:num_region
        if j>2
            inflow{i} = inflow{i} + sum(io.IO_table{j}{i},2) + io.total_final_demand{j}{i};
            outflow{i} = outflow{i} + sum(io.IO_table{i}{j},2) + io.total_final_demand{i}{j};
        end
    end
    exports_pre_eq(y:(y+num_local_sector-1)) = io.export_only{i}{i} + outflow{i};
    imports_pre_eq(y:(y+num_local_sector-1)) = -io.import_only{i}{i}' + inflow{i}';
    
    % labor
    labor_comp_pre_eq(y:(y+num_local_sector-1)) = io.labor_comp{i}{i};
    
    % local demand and value added
    for j = 1:2
        local_demand_pre_eq(y:(y+num_local_sector-1)) = ...
            local_demand_pre_eq(y:(y+num_local_sector-1)) + io.total_final_demand{i}{j};
        value_added_pre_eq(y:(y+num_local_sector-1)) = ...
            value_added_pre_eq(y:(y+num_local_sector-1)) + sum(io.value_added{j}{i},1);
    end
    for j = 1:num_region
        if j>2
            local_demand_pre_eq(y:(y+num_local_sector-1)) = local_demand_pre_eq(y:(y+num_local_sector-1))+io.total_final_demand{j}{i};
        end
    end
    
    % fixed asset
    damage_data_file = append('damage','_',sub_region.name{i},'.csv');
    damage_data = readtable(damage_data_file);
    FA_wHousing = damage_data.FA';
    FA_wHousing_pre_eq(y:(y+num_local_sector-1)) = FA_wHousing(2:num_local_sector+1);
    FA_wHousing_pre_eq(num_sub_region*num_local_sector+i) = FA_wHousing(1);
    
end

% loss
construction_dist = 0.75;
manufacturing_dist = 0.25;
loss_distribution = zeros(num_sub_region,num_local_sector);
for i = 1:2
    y = (i-1)*num_local_sector + 1;
    sector_class = sector.SectorClass(y:(y+num_local_sector-1));
    value_added = value_added_pre_eq(y:(y+num_local_sector-1));
    construction_idx = find(strcmp('Construction',sector_class));
    manufacturing_idx = find(strcmp('Manufacturing',sector_class));
    loss_distribution(i,construction_idx) = construction_dist;
    loss_distribution(i,manufacturing_idx) = manufacturing_dist/sum(value_added(manufacturing_idx))*value_added(manufacturing_idx);
    
    damage_data_file = append('damage','_',sub_region.name{i},'.csv');
    damage_data = readtable(damage_data_file);
    loss_wHousing = damage_data.Loss;
    losses_per_sector(y:(y+num_local_sector-1),y:(y+num_local_sector-1)) = loss_wHousing(2:num_local_sector+1)*loss_distribution(i,:);
    losses_per_sector(num_sub_region*num_local_sector+i-1,y:(y+num_local_sector-1)) = loss_wHousing(1)*loss_distribution(i,:);
end

% ratio K2Y
ratio_K2Y_pre_eq = FA_wHousing_pre_eq(1:num_local_sector*num_sub_region)./value_added_pre_eq;

% fraction loss productivity
frac_loss_prod = ones(1,(num_local_sector+1)*num_sub_region);


save('inputs/mr_ario_econ_data.mat','FA_wHousing_pre_eq','exports_pre_eq',...
    'imports_pre_eq','labor_comp_pre_eq','local_demand_pre_eq',...
    'value_added_pre_eq','ratio_K2Y_pre_eq');

save('inputs/mr_ario_loss_data.mat','losses_per_sector','frac_loss_prod','loss_distribution');