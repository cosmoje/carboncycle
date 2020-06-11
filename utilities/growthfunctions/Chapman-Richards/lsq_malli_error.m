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

opts = optimoptions('lsqcurvefit');
lb = [];    % Tarvitaan jostain syyst‰ jos k‰ytt‰‰ opts.
ub = [];
opts.MaxFunctionEvaluations = 20000;    % T‰ss‰ ei riitt‰nyt 2000
opts.MaxIterations = 20000;


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
    params_1 = lsqcurvefit(@(params, keskiiat) CR(params, keskiiat),[0.05; 10], keskiiat_i, kasvut_i, lb, ub, opts);

    x = [0:0.1:100];
    
    if (i == 1)
        figure;
    end
    hold on
    grid on
    plot(keskiiat_i, kasvut_i, '.')
    plot(x, CR(params_1, x), 'r')
    xlabel('Age')
    ylabel('m^3/ha/year')
    title('Chapman-Richards')
end

