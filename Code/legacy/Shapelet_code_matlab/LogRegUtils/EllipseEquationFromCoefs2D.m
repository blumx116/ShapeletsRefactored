function eq = EllipseEquationFromCoefs2D(coefs)
eq = @(X, Y) coefs(1) + (coefs(2) * X) + (coefs(3) * Y) + ... 
    (coefs(4) * (X .^ 2)) + (coefs(5) * (Y .^ 2));
end

