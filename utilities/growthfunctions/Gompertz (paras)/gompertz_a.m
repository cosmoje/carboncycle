function G = gompertz_a(params, keskiiat)

    G = params(3)*params(1)*params(2) .* exp(-params(1) .* exp(-params(2)*keskiiat) - params(2)*keskiiat);
end

