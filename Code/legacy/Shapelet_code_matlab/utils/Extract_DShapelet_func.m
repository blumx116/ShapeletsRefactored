function [DShapelet, anchor_loc, start_index, end_index] = Extract_DShapelet_func(BASE_TIME_SERIES, L)
%EXTRACT_DSHAPELET_FUNC 
% Extracts the DShapelet from the time series using the extreme
% anchor point (maximum or minimum, whichever comes first), and a symetric
% window of length L

% Input variables
% - BASE_TIME_SERIES:  Time series we're finding the shapelet in
% - L:  Length of DShapelet before and after anchor point

% Output variables
% - DShapelet:  The shapelet found
% - anchor_loc:  The index of the extreme anchor point
% - start_index:  The start index of the shapelet
% - end_index:  The end index of the shapelet

% Identify anchor point (heuristic)
% Anchor point is defined as the global maximum or minimum, 
% whichever occurs first temporally
[maximum, max_loc] = max(BASE_TIME_SERIES);
[minimum, min_loc] = min(BASE_TIME_SERIES);

if (min_loc < max_loc)
    anchor_val = minimum;
    anchor_loc = min_loc;
else
    anchor_val = maximum;
    anchor_loc = max_loc;
end

% Do bound checking to make sure we stay within the given sequence for the
% L value given

before_length = L;
if (anchor_loc - before_length < 1)
    start_index = 1;
else
    start_index = anchor_loc - L;
end

after_length = L;
if (anchor_loc + after_length > size(BASE_TIME_SERIES,2))
    end_index = size(BASE_TIME_SERIES,2);
else
    end_index = anchor_loc + L;
end


DShapelet = BASE_TIME_SERIES(start_index:end_index);


end

