function C_R = CR_a(params, keskiiat)

    C_R = params(3)*params(1)*params(2) .* exp(-params(1) .* keskiiat) .* (1-exp(-params(1) .* keskiiat)) .^ (params(2)-1); 
end

