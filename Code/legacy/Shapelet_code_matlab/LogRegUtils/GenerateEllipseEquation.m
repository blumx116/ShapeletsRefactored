function coefs = GenerateEllipseEquation2D(center, radius)
assert(all(size(center) == size(radius)) && all(size(radius) == [1, 3]));

A = ((center(1) ^ 2) * (radius(2) ^ 2)) + ...
    ((center(2) ^ 2) * (radius(1) ^ 2)) - ...
    ((radius(1) ^ 2) * (radius(2) ^ 2));
B = -2 * center(1) * (width(2) ^ 2);
C = -2 * center(2) * (width(1) ^ 2);
D = width(2) ^ 2;
E = width(1) ^ 2;
eq = EllipseEquationFromCoefs2D([A B C D E]);
end