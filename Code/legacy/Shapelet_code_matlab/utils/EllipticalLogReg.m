function [class] = EllipticalLogReg(theta, x)
%Computes elliptical logistic regression alligned with the axes
%Namely, it computes theta_1 + theta_2 * x_1 + theta_3*x_2 + ...
%+theta_{n+1}*x_n + theta_{n+2}*x_1^2 + theta_{n+3}*x_2^2 + ...
%+theta_{2n+1}*x_n^2
%
% Inputs : 
%  - 
x_projection = [1 x x.^2];
class = dot(theta, x_projection);
end