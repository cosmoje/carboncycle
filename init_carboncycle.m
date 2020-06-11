function [simulation_output] = init_carboncycle(t_simulation, demand_0, ...
    use_demand_predictions, k_sustainable_harvesting, k_final_felling, ...
    forest_volume_0, forest_area, forest_age_0, ...    
    update_workspace)
% Initialization and execution script for carbon cycle simulation.


%% Simulation parameters
%%%%%%%%%%%%%%%%%%%%%%%%
model_name = 'carboncycle';

% Initialize simulation input object that sets all variables and options
simInp = Simulink.SimulationInput(model_name);  

% Simulation time
simInp = simInp.setModelParameter('StopTime', num2str(t_simulation));


%% Product types
%%%%%%%%%%%%%%%%
warning('off')
product_parameters = readtable('product_parameters.csv'); 
warning('on')

% Replace NaN with 0
for i_col = 1:size(product_parameters,2)
    % Only replace non-cell (i.e. non-strings)
    if ~iscell(product_parameters{:,i_col})
        product_parameters{:,i_col}(isnan(product_parameters{:,i_col})) = 0;
    end
end

forest_recycling_rates = product_parameters(:,["PRODUCT_NAME", ...
    "MATERIAL_RECOVERY", "ENERGY_RECOVERY", "INCINERATION_RATES"]); 
sub_recycling_rates = product_parameters(:,["SUB_NAME", ...
    "SUB_MATERIAL_RECOVERY", "SUB_ENERGY_RECOVERY", ...
    "SUB_INCINERATION_RATES"]);

% Check for zeroes (i.e. anything smaller than 0.001), default to
% incineration rate 1.
forest_recycling_rates{sum(forest_recycling_rates{:,2:end} < 0.001,2) == 3, ...
    "INCINERATION_RATES"} = 1;
sub_recycling_rates{sum(sub_recycling_rates{:,2:end} < 0.001,2) == 3, ...
    "SUB_INCINERATION_RATES"} = 1;   

% Validity checks of parameters set by user
if ~all(abs(sum(forest_recycling_rates{:,2:end},2) - 1) < 0.001)
    error(['Recycling rates for forest products not defined ', ...
        'correctly: recycling rates for each product ', ...
        'should sum to one but do not.'])
elseif ~all(abs(sum(sub_recycling_rates{:,2:end},2) - 1) < 0.001)
    error(['Recycling rates for substitute products not defined ', ...
        'correctly: recycling rates for each product ', ...
        'should sum to one but do not.'])
end

                   
%% DEMAND
%%%%%%%%%
% N.B: The prediction functions are fitted using the current years, so t =
% 0 corresponds to 2019 (last year with known real production data).

timestamps = 0:t_simulation;

% Simulink requires the timestamps in the first column and dimension, thus
% we need to transpose to a [N time steps] x [N products] matrix.
demand = [timestamps; repmat(demand_0, 1, length(timestamps))]';

if use_demand_predictions == 1    
    product_names = product_parameters.PRODUCT_NAME;
    for i_product = 1:size(product_parameters,1)
        % Extract name as string to allow logical comparison directly with
        % product names vector.
        product_name = string(product_names{i_product});
        switch product_name
            case "sawn_wood"
                production_2019 = 11330000;  % m^3                
                % Demand prediction: linear. Intercept = demand_0.
                demand(:,i_product + 1) = ...
                    demand_0(i_product) / production_2019 * ...  % scale
                    58122.12544 * timestamps + ...  % linear growth
                    demand_0(i_product);  % intercept
            case "plywood"
                production_2019 = 1090000;  % m^3
                % Demand prediction: linear. Intercept = demand_0.
                demand(:,i_product + 1) = ...
                    demand_0(i_product) / production_2019 * ...  % scale
                    14159.47179 * timestamps + ...  % linear growth
                    demand_0(i_product);  % intercept
            case "packaging_paper"
                production_2019 = 4800000;  % tonnes
                % Demand prediction: linear. Intercept = demand_0.
                demand(:,i_product + 1) = ...
                    demand_0(i_product) / production_2019 * ...  % scale
                    100800 * timestamps + ...  % linear growth
                    demand_0(i_product);  % intercept
            case "graphic_paper"
                production_2019 = 4538000;  % tonnes
                % This function's prediction for 2019, for shifting the
                % curve vertically to fit the user-defined initial demand.
                prediction_2019 = 9.2686e+259 * 2019.^(-76.6235818);
                % Demand prediction: power function ax^b + c, b < 0,
                % asymptotically going to 0. Intercept c is the initial
                % demand. First timestamp should be 2020, thus t =
                % timesteps + 2020.
                demand(:,i_product + 1) = ...
                    demand_0(i_product) / production_2019 * ...  % scale
                    (9.2686e+259 * (2019 + timestamps).^(-76.6235818) - prediction_2019) ... % decreasing
                     + demand_0(i_product);  % vertical shift
            case "tissue_paper"
                production_2019 = 162000;  % tonnes
                % This function's prediction for 2019, for shifting the
                % curve vertically to fit the user-defined initial demand.
                prediction_2019 = 1.98e+41 * 2019.^(-10.9158334);
                % Demand prediction: power function ax^b + c, b < 0,
                % asymptotically going to 0. Intercept c is the initial
                % demand. First timestamp should be 2019, thus t =
                % timesteps + 2019.
                demand(:,i_product + 1) = ...
                    demand_0(i_product) / production_2019 * ...  % scale
                    (1.98e+41 * (2019 + timestamps).^(-10.9158334) - prediction_2019) ... % decreasing
                    + demand_0(i_product);  % vertical shift
            otherwise
                % constant demand
        end
        
        demand(demand < 0) = 0;
    end
end

% Add demands to Simulink model
simInp.ExternalInput = demand;


%% FOREST
%%%%%%%%%
simInp = simInp.setVariable('forest_volume_0', forest_volume_0);

% Initial wood/forest stock (to compensate the lack of recycled products
% in the beginnign).
initial_stock = total_raw_wood_demand(demand_0, 'product_parameters.csv')/5;
simInp = simInp.setVariable('initial_stock', initial_stock);

simInp = simInp.setVariable('forest_age_0', forest_age_0);

% Share of sequestered carbon that is released back into atmosphere through
% autotrophic respiration; NPP = (1 - k_autotrophic_respiration) * GPP.
k_autotrophic_respiration = 0.5;
simInp = simInp.setVariable('k_autotrophic_respiration', ...
    k_autotrophic_respiration);

% Share of NPP that is released back into atmosphere through heterotrophic
% respiration; NEP = (1 - k_heterotrophic_respiration) * NPP.
k_heterotrophic_respiration = 0.5;
simInp = simInp.setVariable('k_heterotrophic_respiration', ...
    k_heterotrophic_respiration);

convert_co2_to_forestvolume = 1/1;  % 1 m3 of wood (~~forest) per 1 tCO2
simInp = simInp.setVariable('convert_co2_to_forestvolume', ...
    convert_co2_to_forestvolume);

% Shares of NEP that are lost due to natural or anthropogenic disturbances
% (e.g. forest fires or harvesting);
% NBP = NEP - k_forest_loss * forest_volume - [harvesting volume].
k_natural_loss = 5.6 / 2465.1; % "Luonnonpoistuma", share of volume (m3/m3)
simInp = simInp.setVariable('k_natural_loss', k_natural_loss);

% Harvesting factor: how many cubic meters of forest is harvested to make a
% cubic meter of raw wood? The total amount of forest harvested is found by
% multiplying the required amount of raw wood by this factor.
% Calculated as: ("Hakkuukertyma" + "Metsahukkapuu") / "Hakkuukertyma"
c_harvesting = (70.3 + 9.8)/70.3;
simInp = simInp.setVariable('c_harvesting', c_harvesting);

% Sustainable harvesting limit: what percentage of the forest stock can be
% harvested sustainably, i.e. allowing sustainable growth and maintaining
% the forest stock.
% Factor calculated as:
% [sustainable limit of total stemwood cutting] / [forest_volume]
simInp = simInp.setVariable('k_sustainable_harvesting', ...
    k_sustainable_harvesting);

        %% GROWING
        %%%%%%%%%
        % "Suomen metsiin mahtuisi puuta ainakin kolminkertaisesti
        % nykytilanteeseen verrattuna." - Arvometsä blog
        max_forest = 3*forest_volume_0;
        simInp = simInp.setVariable('max_forest', max_forest);
        
        simInp = simInp.setVariable('forest_area', forest_area);

        simInp = simInp.setVariable('k_final_felling', k_final_felling);


%% FOREST_PRODUCTION
%%%%%%%%%%
% Production costs, in terms of total raw wood per unit of product if
% produced directly from raw wood (e.g. not from pulp). Transposed to allow
% matrix multiplication.
c_production_raw_wood = product_parameters.PRODUCTION_COST_RAW_WOOD';
simInp = simInp.setVariable('c_production_raw_wood', c_production_raw_wood);

% Units of raw wood used in the final product, after all types of losses.
c_production_raw_wood_used = product_parameters.RAW_WOOD_IN_PRODUCT';
simInp = simInp.setVariable('c_production_raw_wood_used', ...
    c_production_raw_wood_used);
% Units of product from units of raw wood. To be used instead of division
% with the above variable, since some reciprocals will be infinite.
c_production_raw_wood_used_reciprocal = ...
    zeros(size(c_production_raw_wood_used));
c_production_raw_wood_used_reciprocal(c_production_raw_wood_used ~= 0) = ...
    1 ./ c_production_raw_wood_used(c_production_raw_wood_used ~= 0);
simInp = simInp.setVariable('c_production_raw_wood_used_reciprocal', ...
    c_production_raw_wood_used_reciprocal);

c_production_pulp_used = product_parameters.PULP_USED_IN_PRODUCT';
simInp = simInp.setVariable('c_production_pulp_used', ...
    c_production_pulp_used);
% Units of product from units of pulp. To be used instead of division with
% the above variable, since some reciprocals will be infinite.
c_production_pulp_used_reciprocal = ...
    zeros(size(c_production_pulp_used));
c_production_pulp_used_reciprocal(c_production_pulp_used ~= 0) = ...
    1 ./ c_production_pulp_used(c_production_pulp_used ~= 0);
simInp = simInp.setVariable('c_production_pulp_used_reciprocal', ...
    c_production_pulp_used_reciprocal);

% Byproducts: raw wood to pulp production.
c_production_to_pulp = product_parameters.TO_PULP';
simInp = simInp.setVariable('c_production_to_pulp', ...
    c_production_to_pulp);

c_production_losses_used_for_energy = ...
    product_parameters.LOSSES_USED_FOR_FUEL';
simInp = simInp.setVariable('c_production_losses_used_for_energy', ...
    c_production_losses_used_for_energy);

% Byproducts: biofuel production raw material.
c_production_losses_used_for_biofuel = ...
    product_parameters.LOSSES_USED_FOR_BIOFUEL';
simInp = simInp.setVariable('c_production_losses_used_for_biofuel', ...
    c_production_losses_used_for_biofuel);

c_production_biofuel_cost_tall_oil = 1/1; % unit: tonnes/tonnes
simInp = simInp.setVariable('c_production_biofuel_cost_tall_oil', ...
    c_production_biofuel_cost_tall_oil);

c_production_biofuel_cost_co2 = 0.740; % unit: tonnes CO2e/tonnes biofuel
simInp = simInp.setVariable('c_production_biofuel_cost_co2', ...
    c_production_biofuel_cost_co2);

c_production_pulp_raw_wood_demand = 3.2229; % unit: m^3/tonne
simInp = simInp.setVariable('c_production_pulp_raw_wood_demand', ...
    c_production_pulp_raw_wood_demand);

% Production costs, in terms of (exogenous) CO2 units released per unit of
% product. Transposed to allow matrix multiplication.
c_production_co2_forest = product_parameters.MANUFACTURE_COST_CO2';
simInp = simInp.setVariable('c_production_co2_forest', c_production_co2_forest);


%% SUBSTITUTE_PRODUCTION
%%%%%%%%%%
% Production costs, in terms of (exogenous) CO2 units released per unit of
% substitute product produced. Transposed to allow matrix multiplication.
c_production_co2_substitute = ...
    product_parameters.SUB_MANUFACTURE_COST_CO2_FROM_VIRGIN';
simInp = simInp.setVariable('c_production_co2_substitute', c_production_co2_substitute);


%% FOREST_RECYCLING
%%%%%%%%%%%%
k_energy_recovery_forest = forest_recycling_rates{:,"ENERGY_RECOVERY"};
simInp = simInp.setVariable('k_energy_recovery_forest', k_energy_recovery_forest);

k_incineration_forest = forest_recycling_rates{:,"INCINERATION_RATES"};
simInp = simInp.setVariable('k_incineration_forest', k_incineration_forest);

k_material_recovery_forest = forest_recycling_rates{:,"MATERIAL_RECOVERY"};
simInp = simInp.setVariable('k_material_recovery_forest', k_material_recovery_forest);
           
% Reycling costs, in terms of CO2 units released per unit of (forest)
% product that is recycled.
c_recycling_co2_forest = product_parameters.RECYCLING_COST_CO2';
simInp = simInp.setVariable('c_recycling_co2_forest', c_recycling_co2_forest);
    

%% SUBSTITUTE_RECYCLING
%%%%%%%%%%%%
k_energy_recovery_substitute = sub_recycling_rates{:,"SUB_ENERGY_RECOVERY"};
simInp = simInp.setVariable('k_energy_recovery_substitute', k_energy_recovery_substitute);

k_incineration_substitute = sub_recycling_rates{:,"SUB_INCINERATION_RATES"};
simInp = simInp.setVariable('k_incineration_substitute', k_incineration_substitute);

k_material_recovery_substitute = sub_recycling_rates{:,"SUB_MATERIAL_RECOVERY"};
simInp = simInp.setVariable('k_material_recovery_substitute', k_material_recovery_substitute);
           
% Reycling costs, in terms of CO2 units released per unit of substitute
% product.
c_recycling_co2_substitute = product_parameters.SUB_RECYCLING_COST_CO2';
simInp = simInp.setVariable('c_recycling_co2_substitute', c_recycling_co2_substitute);


%% FOREST_WASTE
%%%%%%%%
% All transposed to allow matrix multiplication directly.

c_forest_burning_energy_released = product_parameters.ENERGY_RELEASED';
simInp = simInp.setVariable('c_forest_burning_energy_released', ...
    c_forest_burning_energy_released);

c_forest_burning_co2_released = product_parameters.CO2_RELEASED';
simInp = simInp.setVariable('c_forest_burning_co2_released', ...
    c_forest_burning_co2_released);

c_forest_burning_losses_co2_released = ...
    product_parameters.LOSSES_USED_FOR_FUEL_CO2';
simInp = simInp.setVariable('c_forest_burning_losses_co2_released', ...
    c_forest_burning_losses_co2_released);

c_forest_burning_losses_energy_released = ...
    product_parameters.LOSSES_USED_FOR_FUEL_ENERGY';
simInp = simInp.setVariable('c_forest_burning_losses_energy_released', ...
    c_forest_burning_losses_energy_released);

c_forest_burning_biofuel_co2_released = 1.85; % tonnes / tonne
simInp = simInp.setVariable('c_forest_burning_biofuel_co2_released', ...
    c_forest_burning_biofuel_co2_released);

c_forest_burning_biofuel_energy_released = 4519.72; % kWh / tonne
simInp = simInp.setVariable('c_forest_burning_biofuel_energy_released', ...
    c_forest_burning_biofuel_energy_released);

% Share of wood based CO2 stored in products (waste) that is released to
% atmosphere through waste handling (burning).
k_waste_co2_release_forest = 1;  % Assuming complete combustion of fuel
simInp = simInp.setVariable('k_waste_co2_release_forest', k_waste_co2_release_forest);


%% SUBSTITUTE_WASTE
%%%%%%%%
% All transposed to allow matrix multiplication directly.

c_substitute_burning_energy_released = product_parameters.SUB_ENERGY_RELEASED';
simInp = simInp.setVariable('c_substitute_burning_energy_released', ...
    c_substitute_burning_energy_released);

c_substitute_burning_co2_released = product_parameters.SUB_CO2_RELEASED';
simInp = simInp.setVariable('c_substitute_burning_co2_released', ...
    c_substitute_burning_co2_released);

% Share of CO2 stored in products (waste) that is released to atmosphere
% through waste handling (burning).
k_waste_co2_release_substitute = 1;  % Assuming complete combustion of fuel
simInp = simInp.setVariable('k_waste_co2_release_substitute', k_waste_co2_release_substitute);


%% Configuring the model workspace variables
% If we either want to manually update_workspace or the dimension of the
% model inport for the demand does not match the number of products in the
% product_parameters table then update the whole model workspace and all
% its variables manually. This also requires deleting auxiliary files
% created by earlier Rapid Accelerator Mode compilations/runs to work. This
% cannot (and should not need to) be done with a compiled application.

if ~isdeployed
    
    if ~exist('update_workspace', 'var')
        update_workspace = 0;
    end
    
    % Load Simulink system to access workspace and parameters.
    load_system(model_name);
    
    dimension_do_not_match = ...
        get_param([model_name, '/Demand'], 'PortDimensions') ~= ...
            num2str(size(product_parameters,1));
        
    if update_workspace || dimension_do_not_match
        % Delete Simulink cache file if it exists to allow rebuilding of
        % Rapid Accelerator target (deleted below)
        if exist([model_name, '.slxc'], 'file') == 2
            delete([model_name, '.slxc']);
        end

        % 7: matchin directory exists
        if exist(['slprj/raccel/', model_name], 'dir') == 7
            rmdir(['slprj/raccel/', model_name], 's');
        end

        model_workspace = get_param(model_name, 'modelworkspace');

        % List all model workspace variables.
        variables = whos(model_workspace);

        for i_variable = 1:length(variables)
            % assign local variable value eval(variable.name) to the
            % variable with the same name in the model workspace
            assignin(model_workspace, variables(i_variable).name, ...
                eval(variables(i_variable).name));
        end

        n_products = size(demand,2) - 1;
        set_param([model_name, '/Demand'], 'PortDimensions', ...
            num2str(n_products));

        save_system;
    end
end


%% Running the simulation

% Needed to compile, e.g. sets Rapid Accelerator Mode.
simInp = simulink.compiler.configureForDeployment(simInp);

simulation_output = sim(simInp);


end