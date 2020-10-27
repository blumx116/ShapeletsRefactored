function [data_x, data_y] = xysplit(data)

data_x = data(:, 2:end);
data_y = data(:, 1);
end
