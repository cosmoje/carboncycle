function H = hossfeld_a(params, keskiiat)

    H = params(1)*params(2) .* keskiiat .^ (params(2)-1) ./ (params(1) + (keskiiat .^ params(2)) ./ params(3)) .^2;
end

