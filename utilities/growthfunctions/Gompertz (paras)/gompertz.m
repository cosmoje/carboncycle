function G = gompertz(params, keskiiat)
    % 2409 and 20.276 are form LUKE statistics (metsämaalla 2014-2018).
    % "Suomen metsiin mahtuisi puuta ainakin kolminkertaisesti
    % nykytilanteeseen verrattuna."
    % Updated 12.5.2020.
    G = (3*2409)/20.276 * params(1)*params(2) .* exp(-params(1) .* exp(-params(2)*keskiiat) - params(2)*keskiiat);
end

