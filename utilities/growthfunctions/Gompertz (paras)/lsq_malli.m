clear all
close all
format long

ikaluokat_koot = [2208,2143,2730,3785,2476,1544,918,2072;
    2826,2535,3088,3635,2401,1446,934,2095;
    3102,2912,3335,3372,2432,1445,849,1990;
    3102,3524,3314,3289,2468,1381,863,1836;
    3268,3733,3299,3297,2543,1444,759,1732;
    3415,3833,3615,3199,2304,1151,609,1673;
    3252,3680,4140,3311,2372,1173,626,1456;
    3117,3661,4282,3513,2304,1181,579,1384];

% age classes
ages = [10.5, 30.5, 50.5, 70.5, 90.5, 110.5, 130.5, 150.5];

keskiiat = [73.81841575
            70.33016878
            67.78764727
            65.94420286
            64.58916563
            62.01371281
            61.66841579
            61.49345687];
        
kasvut = [2.9 2.9 3.4 3.8 4.2 4.9 5.1 5.2]';

opts = optimoptions('lsqcurvefit');
lb = [0;0];    % Tarvitaan jostain syyst‰ jos k‰ytt‰‰ opts.
ub = [Inf;1];
opts.MaxFunctionEvaluations = 20000;
opts.MaxIterations = 20000;

% Ekassa a on annettu, tokassa malli etsii sen. Eka parempi.
init = [10; 0.05];
[params,resnorm,residual,~,~]= lsqcurvefit(@(params, keskiiat) gompertz(params, keskiiat), init, keskiiat, kasvut, lb, ub, opts);
%params_a = lsqcurvefit(@(params, keskiiat)  gompertz_a(params, keskiiat),[b; c; 375], keskiiat, kasvut, lb, ub, opts);

opts.MaxFunctionEvaluations = 20000*5;
opts.MaxIterations = 20000*5;
init_pop = [45; 0.7];
[params_population,resnorm_pop,residual_pop,~,~] = ...
    lsqcurvefit(@(params, ikaluokat_koot) gompertz_population(params, ikaluokat_koot), ...
    init_pop, ikaluokat_koot, kasvut, lb, ub, opts);

% print fitted parameters
params
resnorm
params_population
resnorm_pop

% Plot both fitted functions
subplot(2,1,1);
hold on
grid on
plot(keskiiat, kasvut, '.')
x = [0:0.1:100];
% plot using wrong function just to be able to compare parameters' effect
plot(x, gompertz(params_population, x), 'r')
% plot also function predictions for age structure
plot(keskiiat, gompertz_population(params_population, ikaluokat_koot), 'rx')
title('Age structure taken into account')
xlabel('Age')
ylabel('m^3/ha/year')

subplot(2,1,2);
hold on
grid on
plot(keskiiat, kasvut, '.')
x = [0:0.1:100];
plot(x, gompertz(params, x), 'r')
title('a = 3*2500/20 = 375 (m^3/ha)')
xlabel('Age')
ylabel('m^3/ha/year')


