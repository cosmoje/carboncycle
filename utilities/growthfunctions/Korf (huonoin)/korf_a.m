function G = korf_a(params, keskiiat)

    G = params(3)*params(1)*params(2) .* keskiiat .^ (-params(2)-1) .* exp(-params(1) .* keskiiat .^ (-params(2)));
end

