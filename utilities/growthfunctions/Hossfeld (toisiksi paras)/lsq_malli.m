clear all
close all
format long

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
lb = [];    % Tarvitaan jostain syyst‰ jos k‰ytt‰‰ opts.
ub = [];
opts.MaxFunctionEvaluations = 20000;
opts.MaxIterations = 20000;

b = 6000;
c = 4;
params = lsqcurvefit(@(params, keskiiat)  hossfeld(params, keskiiat),[b; c], keskiiat, kasvut, lb, ub, opts);
params_a = lsqcurvefit(@(params, keskiiat)  hossfeld_a(params, keskiiat),[b; c; 375], keskiiat, kasvut, lb, ub, opts);

x = [0:0.1:100];


subplot(2,1,1);
hold on
grid on
plot(keskiiat, kasvut, '.')
plot(x, hossfeld(params, x), 'r')
title('a = 3*2500/20 = 375 (m^3/ha)')
xlabel('Age')
ylabel('m^3/ha/year')

subplot(2,1,2);
hold on
grid on
plot(keskiiat, kasvut, '.')
plot(x, hossfeld_a(params_a, x), 'r')
title('3 parameters')
xlabel('Age')
ylabel('m^3/ha/year')
