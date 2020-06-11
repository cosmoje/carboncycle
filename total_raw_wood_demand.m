function [raw_total, harvest_total] = total_raw_wood_demand(demand, ...
    parameters_filename)
% Function for calculating total raw wood demand.
%
% The function takes into account losses from solid wood production going
% into pulp as raw wood (chips).
%
% NB: this function is probably in some subfolder, e.g. "Utilities". Add it
% to your path like this: addpath(strcat(pwd, "\Utilities"))

% Read product parameters from file
warning("off")
product_parameters = readtable(parameters_filename);
warning("on")

% solid wood
sw_demand = demand .* (product_parameters.RAW_WOOD_IN_PRODUCT > 0);
raw_sw = product_parameters.PRODUCTION_COST_RAW_WOOD' * sw_demand;

% chips to pulp production
chips_sw = product_parameters.TO_PULP' * sw_demand;

% pulp
pulp_demand = product_parameters.PULP_USED_IN_PRODUCT' * demand;
raw_pulp_gross = 3.2229 * pulp_demand;

% Net pulp raw material demand
raw_pulp_net = raw_pulp_gross - chips_sw;

% total raw wood demand
raw_total = raw_sw + raw_pulp_net;

% total harvesting
harvest_total = raw_total * (70.3 + 9.8)/70.3;  % raw_total * c_harvesting

end
