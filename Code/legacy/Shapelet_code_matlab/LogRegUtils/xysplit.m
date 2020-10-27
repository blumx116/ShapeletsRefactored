function [x_data, y_data] = xysplit(data)
% Assumes first line of each observation is class.
% Splits data in to vector showing class and 
x_data = data(:, 2:end);
y_data = data(:, 1);
end