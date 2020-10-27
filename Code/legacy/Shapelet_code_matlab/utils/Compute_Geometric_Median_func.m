function [GEOMETRIC_MEDIAN] = Compute_Geometric_Median_func(POINT_SET, NUM_ITERATIONS)
%CALCULATE_GEOMETRIC_MEDIAN_FUNC This function will calculate the geometric
%median for a point using Weiszfeld's algorithm.  

% Input Variables
% - POINT_SET: Matrix representing a set of points (rows are each point,
% columns are the dimensions)
% - NUM_ITERATIONS:  Number of iterations to run for.  
% 
% Output Variables
% - GEOMETRIC_MEDIAN:  Numerical approximation of the geometric median 
% of the points in POINT_SET
%
% Example function call:
% >> my_geo_median = Calculate_Geometric_Median_func(my_points, 20);

% Iteratively approximate the geometric median
% Rows are the individual points, columns are the dimensions
NUM_POINTS = size(POINT_SET,1);
NUM_DIMENSIONS = size(POINT_SET,2);

% Initialize vectors to hold the previously computed geo median
geo_median_prev = zeros(1,NUM_DIMENSIONS);

for i = 1:NUM_ITERATIONS
   % Clear current geo median from previous run
   geo_median_current = zeros(1,NUM_DIMENSIONS); 
    
   dist_sums = 0; % Track the distance sums
   
   % Compute update based on Weiszfeld's algorithm
   for j = 1:NUM_POINTS
       dist = norm(geo_median_prev - POINT_SET(j,:));
       geo_median_current = geo_median_current + POINT_SET(j,:)/dist;
       dist_sums = dist_sums + (1 / dist);
   end
   geo_median_current = geo_median_current / dist_sums;
   
   geo_median_prev = geo_median_current;
end

% Return the geometric median
GEOMETRIC_MEDIAN = geo_median_current;

end

