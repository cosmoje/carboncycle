function H = hossfeld(params, keskiiat)

    H = params(1)*params(2) .* keskiiat .^ (params(2)-1) ./ (params(1) + (keskiiat .^ params(2)) ./ 375) .^2;
end

