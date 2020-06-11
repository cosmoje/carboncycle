# Introduction

This is a Systems Dynamics simulation used to model forests as carbon sources and sinks. The main metric measured is the net change in atmospheric CO2 over time. The model includes a dynamically growing forest; manufacturing, recycling, energy recovery, and waste handling (and these processes' costs in CO2) of forest-based and non-renewable substitute products; and models substitutions effects using non-renewable substitute products.

This project is one of the five project topics in the Aalto University course MS-E2177 - Seminar on Case Studies in Operations Research. The original authors of this project and simulation are Cosmo Jenytin ([cosmoje](https://github.com/cosmoje)), Sonja Kokkonen ([sonjakokkonen](https://github.com/sonjakokkonen)), Roni Sihvonen ([ronisihvonen](https://github.com/ronisihvonen)), and Joanna Simms ([joannasimms](https://github.com/joannasimms)), four master students who study operations research under the Department of Mathematics and Systems Analysis. The four-month course started in January 2020 and lasted until the end of May.

## System dynamics modelling of forests as carbon sources and sinks

The objective of this project is to use system dynamics to model the carbon cycle in forestry. More specifically, the idea is to model the entire Finnish forest industry and biological Finnish forests. This is done by developing an interactive tool to help us understand what kind of effects different parameters and products have on the net impact of carbon emissions.

The objective is primarily educational – to improve conceptual understanding and support the sustainable aims of experts. The target audience is an expert or a private forest owner. The interactivity and visuality of the model support the educational aspect of this project.


## Project deliverables

The main product is an interactive application designed with the MATLAB App Designer. The launcher is called “name.mlapp” and it can be run under MATLAB or as a standalone executable.

The actual system dynamics model consists of a Simulink file `carboncycle.slx` and a MATLAB file `init_carboncycle.m`. The products and their parameters are defined in a csv-file called `product_parameters.csv`.

In addition to the model-related files, the repository includes a final report, “name”. This is an overall report of the entire course and it includes introduction to the topic, a literature review, description of the model, results, discussion, and conclusions as well as appendices and a self-assessment section.


# Using the model


## Installation

Matlab Runtime to run the executables.


## Running the simulations

To run the simulations using GUI in MATLAB, open the GUI_carboncycle.mlapp file, press "Run" to open the actual application. Then set the parameters etc. and press "Run the simulation". For the most realistic results, use the default parameter values.

If you have a standalone executable application (see section **Compiling the model into standalone application**), open the `.exe` file and proceed as mentioned above.


# Modifying the model


## Modifying the GUI

New features can be added to the GUI in the "Design View", and their functions can be modified in the "Code View". Please see the .mlapp file for examples.
For example, if a new product is added to the model, its initial demand is set from the GUI (see how other initial demands have been implemented in the .mlapp file).

## Adding or updating products
The simulation uses product parameter values and recycling rates set by the user in the csv file `product_parameters.csv` in the `data` folder.

Each product type is defined by the different life cycle parameter values corresponding to that product type. Each product and its corresponding substitute product's life cycle parameter values are on one row of the table below.

The demand functions (i.e. predictions) are the only product-specific aspects that are defined in the function `init_carboncycle.m`. If the product name does not match a pre-defined demand function's product name, constant demands are used. The demand functions require initial demands to be set when running the function, i.e. by the user in the GUI (which requires adding both code and probably a new GUI box for setting the initial demand).

To add the new products simply assign a value to all categories which are defined below. New products can be added by creating an extra row to the product_parameters.csv file. If a new row is added to the csv file the code will simply iterate over the new product, meaning no changes to the code are required for the product lifecycle.

|Column Name			|Explaination									|
|------------------------------ |-------------------------------------------------------------------------------|
|PRODUCT NAME			| name of the product.								|
|PRODUCT UNIT			| unit of product used throughout the simulation (e.g. tonnes, cubic meters, etc).	|
|PRODUCT AMOUNT			| the number of finished products that amount to the unit in the system. Eg 50 Plywood boards are equivalent to 1m2 of plywood. |
|UNITS PRODUCT AMOUNT		| final product name.		|
|PRODUCTION COST RAW WOOD	| units of raw wood required per unit of product.  |
|UNITS PRODUCTION COST RAW WOOD | m3 ie volume of wood.		|
|RAW WOOD IN PRODUCT		| units of (solid) raw wood used in production.		|	
|RAW WOOD IN PRODUCT UNITS	| volume per unit of product.	|
|TO PULP			| units of raw wood going to pulp production as a byproduct of the production. |
|UNITS TO PULP			| the amount of chips going to pulp. All chips are assumed to go to pulp.	|
|PULP USED IN PRODUCT		| units of pulp used in production.		|
|PULP USED IN PRODUCT UNIT	| tonne of pulp per tonne of paper. It is assumed that paper is 100% pulp in this column. |
|LOSSES USED FOR FUEL		| amount of byproduct that is used for energy recovery/directly as fuel.	|
|UNITS LOSSES USED FOR FUEL	| tonnes of by-product per unit of product produced. Bark is the only byproduct considered and assumed to be 10% of the volume.	|
|LOSSES USED FOR FUEL ENERGY	| amount of energy released per unit of byproduct used for energy recovery/directly as fuel. All energy values are generated with 38% efficiency as this is the average [efficiency of coal power stations](https://www.powermag.com/who-has-the-worlds-most-efficient-coal-power-plant-fleet/). |
|LOSSES USED FOR FUEL ENERGY UNITS| energy per tonne of byproduct per unit of product. |
|LOSSES USED FOR BIOFUEL	| byproduct that is used for biofuel production.	|
|LOSSES USED FOR BIOFUEL UNITS	| amount of byproduct that is used for biofuel production. Tall oil is considered rather than black liquor. Tall oil is also considered to have a 1:1 ratio with the biofuel produced. |
|MANUFACTURE COST CO2		| units of exogenous CO2 released per unit of product produced. |
|UNITS MANUFACTURE COST CO2	| tonne of CO2 eq per product unit.	|
|RECYCLING COST CO2		| units of exogenous CO2 released per unit of product recycled. |
|UNITS RECYCLING COST CO2	| tonne of CO2 eq per product unit. 	|
|MATERIAL RECOVERY		| share of recycled units that are recycled back into the same product.	|
|ENERGY RECOVERY		| share of recycled units that are recycled into energy recovery (burned for energy production). |
|INCINERATION RATES		| share of recycled units that are burned without energy recovery (i.e. just burned, no energy production).	|
|CO2 RELEASED			| CO2 (in tonnes) released from burning one unit of the product (in energy recovery or incineration).		|
|ENERGY RELEASED		| kWh of energy produced by burning one unit of the product (in energy recovery or incineration).		|
|SUB NAME			| name of the corresponding substitute product. |
|SUB UNIT			| unit of the corresponding substitute product.	|
|SUB MANUFACTURE COST CO2 FROM VIRGIN | CO2 released when producing one unit of the substitute product from virgin raw materials		|

SUB PRODUCT AMOUNT, SUB UNITS PRODUCED AMOUNT, SUB CO2 RELEASED, SUB ENERGY RELEASED, SUB ENERGY RELEASED UNIT, SUB RECYCLING COST CO2, UNITS SUB RECYCLING COST CO2, SUB MATERIAL RECOVERY, SUB ENERGY RECOVERY, SUB INCINERATION RATES: as for primary products above.

Recycling rates need to sum to one; if a product has no recycling rates, the incineration rate defaults to 1.


## References for Values Used

The data used for the product_parameters.csv is referenced in the report for this model. However, here is a list of the sources for numbers directly used in the code.

|Parameters						|Source		|
|-------------						|------------- |
| Units of CO2 released per unit of biofuel produced 	| Report Lanscape Table |
| Units of raw wood needed to produce one unit of pulp	| Derived from LUKE values|
| Units of CO2 released per burned unit of biofuel	|Report (Source: Phyllis2 European Database, [Biodiesel #3273](https://phyllis.nl/Browse/Standard/ECN-Phyllis#biodiesel)	|
| Units of energy released per burned unit of biofuel 	| Report (Source: Phyllis2 European Database, [Biodiesel #3273)](https://phyllis.nl/Browse/Standard/ECN-Phyllis#biodiesel)	|
| Initial volume of the forest stock			| From LUKE statistics. Volume mets�mailla 2014-2018.	|
| Initial wood/forest stock				| From LUKE statistics. Total roundwood drain in 2019.	|
| Initial average age of the forest stock		| Calculated using the age intervals from LUKE statistics.	|
| Share of sequestered carbon that is released back into the atmosphere through autotrophic respiration | Kirschbaum, M. U. F., et al. "Definitions of some ecological terms commonly used in carbon accounting." Net Ecosystem Exchange Workshop. 2001.	|
| Share of NPP that is released back into the atmosphere through heterotrophic respiration		    | Kirschbaum, M. U. F., et al. "Definitions of some ecological terms commonly used in carbon accounting." Net Ecosystem Exchange. Workshop. 2001.	|
| Conversion rate from tonnes of CO2 (tCO2) to cubic meters (m3) of forest/wood			    | [metsawood](https://www.metsawood.com/global/news-media/articles/Pages/carbon-storage.aspx)	|
| Shares of NEP that are last due to natural or anthropogenic disturbances			    | Suomen puuvirrat 2016	|
| Harvesting factor: how many cubic meters of forest is harvested to make a cubic meter of raw wood? The total amount of forest harvested is found by multiplying the required amount of raw wood by this factor. | Suomen puuvirrat 2016		|
| Sustainable harvesting limit: what percentage of the forest stock can be harvested sustainably, i.e. allowing sustainable growth and maintaining the forest stock. 						  | Luke statistics database [sustainable limit](http://statdb.luke.fi/PXWeb/pxweb/en/LUKE/LUKE__04%20Metsa__06%20Metsavarat/3.01_Suurin_kestava_hakkuukertymaarvio.px/?rxid=f8ed5f38-9607-4c55-91c9-791d660b234e), Suomen puuvirrat 2016 (forest stock). Based on figures for 2015--2024 and 2016, respectively. |

Values for CO2 released and energy released have been provided assuming complete combustion of the fuel and with the 38% average power [efficientcy of coal power stations](https://www.powermag.com/who-has-the-worlds-most-efficient-coal-power-plant-fleet/).

Initial demands for each product are based on real data on forestry products produced in Finland in 2019 (LUKE), and scaled to match annual Finnish harvesting.


## Adding or updating variables

To make sure your new features/variables etc. work, it is recommended to delete the "slprj" folder in MATLAB every time you have modified the model. This is due to the command "simInp = simulink.compiler.configureForDeployment(simInp);" at the end of the init_carboncycle.m file.
  - This command is needed for the Simulink Compiler to work (to make creating standalone executable possible). For some reason, tuning the model variables doesn't seem to work without this command, so the command has to be there even when the model is used in MATLAB only.


### New variables

If you add new model variables or change their dimensions, they need to be added/changed to the `.slx` file. This guarantees that the variables are well defined in a standalone executable.

  - Manually, variables can be added in the `.slx` file by pressing "Model Workspace" in the "MODELING" tab's "DESIGN" section. Press "Add MATLAB Variable", name it and give it an appropriate initial value.
  - Adding variables with more dimensions or updating the dimensions can be done more easily with the `init_carboncycle.m` function by setting the argument "update_workspace" to 1. Before doing this, the name of the variable has to be in the Model Workspace (added e.g. as described above), and the variable has to be defined in the `init_carboncycle.m` function as described in section **Modifying existing variables using the GUI**.

The demand is given as an external input (see the `init_carboncycle.m` function) and it doesn't have to be in the Model Workspace. The model didn't work when the demand was defined as a variable.


### Modifying existing variables using the GUI

The model variables should also be defined in the `init_carboncycle.m` function or given as an input for that function, and then "sent" to the `.slx` file with command `simInp = simInp.setVariable('variable', value)`. This allows you to tune the variables from the GUI and define variables that depend on other variables.

Variables given by user are extracted from the GUI in the `.mlapp` file (please se the file for examples) and then given as an input for the `init_carboncycle.m` function.


## Outputs from Simulink

All simulation outputs (if you want to plot something using the GUI etc.) are extracted from the `.slx` file using Simulink's "Outports". The "Port number" of the outport is needed when referring to the output from `.mlapp` file. Please see examples in the .mlapp file.

Outports are used (instead of e.g. "To Workspace" blocks) because standalone executables for some reason do not seem to work with other blocks. When extracting these outputs from the `.mlapp` file, the values should be inside squeeze()-function, because sometimes Simulink outputs the values with dimension 1 x 1 x n (n is the length of the output vector). Plotting does not work with these extra dimensions, and squeeze()-function gets rid of those.


## Removing compiled and temporary files to allow recompilation

To make sure your new features/variables etc. work, it is recommended to delete the "slprj" folder in MATLAB every time you have modified the model. This is due to the command "simInp = simulink.compiler.configureForDeployment(simInp);" at the end of the `init_carboncycle.m` file.
  - This command is needed for the Simulink Compiler to work (to make creating standalone executable possible). For some reason, tuning the model variables doesn't seem to work without this command, so the command has to be there even when the model is used in MATLAB only.


# Compiling the model into standalone application

To run standalone executable applications, you need to download MATLAB Runtime (version R2020a), suitable compiler (e.g. MinGW works, see https://www.mathworks.com/support/requirements/supported-compilers.html) and the Simulink Compiler add-on.

Before compiling, make sure the model and the GUI work in MATLAB. In addition, it is recommended that the "slprj" folder is deleted before compiling (similarly as when the model is updated, see section **Removing copiled and temporary files to allow recompilation**). Then, use the command "mcc -m name_of_the_mlapp_file.mlapp" in the MATLAB Command Window to compile the app.

Now enter "deploytool" command and select "Application Compiler". In the "Main File" section, add the file to be deployed, name_of_the_mlapp_file.mlapp. In the "Packaging Options" section on the toolstrip, select "Runtime included in package" and enter "deployed_installer" in the text box. Click "Package" in the "Package" section of the toolstrip. Once the package is ready, use the "deployed_installer" in the "for_redistribution" folder to install the proper runtime environment for running the deployed application.


# Assumptions of the model

As the extent of this project and our resources are limited, some assumptions and simplifications have been made. These have been set after doing research and analysis of plenty of data sources and discussing what are the most relevant components and details to include in the model.

The model represents Finland and Finnish forestry. No exported or imported materials are included. Aggregate numbers are used such that all Finnish forests are considered as a single homogeneous (apart from age) forest – no differences in tree species, locations or densities are included. However, forest growth is assumed to be a function of average age of the forest. The average age of the forest can only decrease by final felling.

When substitutions are made, we assume that the demand is first met by the forest products within the harvesting limit. The rest of the demand is fulfilled by the substitute products, which are assumed to come from an infinite source. In other words, there is no limit to the number of products that can be produced from a substitute material.

However, if a product does not have a substitute, and the demand is not fulfilled with the forest products, an equal share of each product is left unproduced. This means that some of the products with no substitute are not produced at all as either forest or substitute products.

The model does not consider any dynamics of economy. Producing has been transformed by a factor into demand. This is a reasonable assumption for the more temporary products. For plywood and sawn wood, we assume that the products being produced match the older products that go to waste handling. For example, the amount of new plywood put into a building will match the old plywood that is being replaced.

The recycling shares are mean averages of Finnish recycling data from 2018 [Tilastokeskus]. The recycling options include material recovery, energy use and incineration of waste. The model includes no landfill; the landfill waste is assumed to be a part of incineration. Material recovery implies that each product becomes the same kind of product in the recycling process. Hence, no “downgrading” of materials is included. No consumer recycling error is considered and the recycling efficiency is assumed to stay at the current rate, that is, no predictions about improved technologies or recycling efficiencies have been made.

There are no initial stocks for recycled products in the model. To avoid overly large harvesting in the beginning, we are using initial wood stock which is used for production before harvesting forests. This way there are recycled products when harvesting is begun. For substitute products, the lack of recycled products might cause odd fluctuation e.g. in the CO2 emissions in the beginning of the simulation before the simulations stabilizes.
