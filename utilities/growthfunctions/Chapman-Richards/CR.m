function C_R = CR(params, keskiiat)

    C_R = 375*params(1)*params(2) .* exp(-params(1) .* keskiiat) .* (1-exp(-params(1) .* keskiiat)) .^ (params(2)-1); 
end

