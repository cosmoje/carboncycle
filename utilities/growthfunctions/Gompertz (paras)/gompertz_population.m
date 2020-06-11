function G = gompertz_population(params, volumes_by_age)
    a = 375;  % hard coded maximum volume of Finnish forest stock
    b = params(1);  % growth parameter
    c = params(2);  % growth rate
    
    % age classes
    ages = [10.5, 30.5, 50.5, 70.5, 90.5, 110.5, 130.5, 150.5]';
    
    % maximum volume for each age class, scaled from maxmimum total volume
    % according to age class volume share of total volume
    a_pop = a * volumes_by_age ./ sum(volumes_by_age, 2);
    
    % Calculate derivative of Gompertz as total differential i.e. sum of
    % population Gompertz functions. Matrix multiplication takes care of
    % summing "per row"
    G = a_pop * b * c * exp( -b * exp( -c * ages ) - c * ages);
end
