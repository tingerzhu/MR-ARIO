function [sectors] = fn_get_sectors_mr(f_name)
%Function responsible for loading sector data from input file.

% Load data from file.
    sector_data          = readtable(f_name);
    sectors.id           = sector_data.SectorID;
    sectors.name         = sector_data.Sector;
    sectors.mask         = [sectors.id > 0];
    sectors.N            = sum(sectors.mask);
    sectors.N_wHousing   = length(sectors.name);
    sectors.non_stock    = sector_data.non_stock;
    sectors.name_per_pref = unique(sector_data.SectorCat,'stable');
    sectors.region_name  = unique(sector_data.Region,'stable');
    sectors.region_ID    = sector_data.RegionID;
    sectors.region_N     = sectors.N_wHousing - sectors.N;
    sectors.N_per_region = sectors.N / sectors.region_N;
    sectors.class        = sector_data.SectorClass;

end
