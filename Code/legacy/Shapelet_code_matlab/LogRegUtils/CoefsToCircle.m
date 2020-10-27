function x2 = CoefsToCircle(coefs, x1, pos)
%@param coefs: vector of length 5 representing Logistic Regression coefs
%@param x1: value of x to be plotted at 
%@param pos: boolean indicating if you want the positive or negative soln
%@returns: x2, the value of the circle at x1 as specified by coefs and pos

a = coefs(1);
b = coefs(2);
c = coefs(3);
d = coefs(4);
e = coefs(5);

middle = (d * (x1 ^ 2)) + (b * x1) + a - ((c^2) / (4 * e));
middle = (-1 / e) * middle;
root_part = ((-1) ^ (1 + pos)) * sqrt(middle);
x2 = root_part - (c / (2 * e));
end

