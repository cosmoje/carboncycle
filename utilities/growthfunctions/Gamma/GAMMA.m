function Gm = GAMMA(params, keskiiat)
    v = 6;
    l = 2;
    Gm = params(1) * (l ^ v)/gamma(2) .* (keskiiat ./ params(2)) .^ (v-1) .* exp(-l .* (keskiiat ./ params(2)));
end

