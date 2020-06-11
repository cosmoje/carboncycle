clear all
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

% timesteps
x = [0:0.1:100];
figure;
hold on
grid on
xlabel('Average age (years)')
ylabel('Growth (m^3/ha/year)')

% On R2020a "optimoptions" seems to require installing Global Optimization Toolbox.
opts = optimoptions('lsqcurvefit');
opts.MaxFunctionEvaluations = 2000;
opts.MaxIterations = 2000;
lb = [];    % Tarvitaan jostain syyst‰ jos k‰ytt‰‰ opts.
ub = [];

% LOOCV
for i = 1:8
    
    if (i == 1)
        keskiiat_i = keskiiat(2:8);
        kasvut_i = kasvut(2:8);
    elseif (i == 8)
        keskiiat_i = keskiiat(1:7);
        kasvut_i = kasvut(1:7);
    else
        keskiiat_i = [keskiiat(1:i); keskiiat(i:8)];
        kasvut_i = [kasvut(1:i); kasvut(i:8)];
    end
    params_1 = lsqcurvefit(@(params, keskiiat) gompertz(params, keskiiat),[10; 0.05], keskiiat_i, kasvut_i, lb, ub, opts);

    p1 = plot(x, gompertz(params_1, x), 'r--');
    p1.Color(4) = 0.5;
end

% All data values used.
params_1 = lsqcurvefit(@(params, keskiiat) gompertz(params, keskiiat),[10; 0.05], keskiiat, kasvut, lb, ub, opts);
p2 = plot(x, gompertz(params_1, x), 'r', 'LineWidth', 1);
p3 = plot(keskiiat, kasvut, 'k.', 'MarkerSize', 6);
legend([p3 p1 p2], {'Data', 'Without individual data points', 'With all the data points'})

