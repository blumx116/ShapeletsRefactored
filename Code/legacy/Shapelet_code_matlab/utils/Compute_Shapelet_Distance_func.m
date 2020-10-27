function [ distance, distance_location_offset ] = Compute_Shapelet_Distance_func(BASE_TIME_SERIES, SHAPELET)
%COMPUTE_SHAPELET_DISTANCE This function computes the difference between a shapelet
%and a times series.  
%   Parameters:
%       Input:
%       - BASE_TIME_SERIES:  The base time series (longer in length than
%       the shapelet)
%       - SHAPELET:  The shapelet (shorter time series)
%       Output:
%       - distance:  The distance between the two (the minimum distance
%       between all points using any possible index offset)
%       - location_offset:  The offset of the best fit distance

time_series_length = size(BASE_TIME_SERIES,2);
shapelet_length = size(SHAPELET,2);

same_length_subtimeseries = zeros(time_series_length - shapelet_length + 1, shapelet_length);
start_index = 1;
end_index = start_index + shapelet_length - 1;
while (end_index <= time_series_length)
    same_length_subtimeseries(start_index,:) = BASE_TIME_SERIES(1, start_index:end_index);
    
    % Update indexes for next iteration
    start_index = start_index + 1;
    end_index = start_index + shapelet_length - 1;
end

shapelet_repmat = repmat(SHAPELET, time_series_length - shapelet_length + 1, 1);
%shapelet_distances = sum(abs(same_length_subtimeseries - shapelet_repmat),2);
shapelet_distances = sqrt(sum((abs(same_length_subtimeseries - shapelet_repmat)).^2,2));

[distance, distance_location_offset] = min(shapelet_distances);
%distance_location_offset = distance_location_offset - 1; % Modify the offset so it's a true offset instead of an index (index starts at 1 instead of 0...)
end

