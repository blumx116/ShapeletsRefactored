function [shapelet, distance, class_label, starting_entropy, gain] = Find_Best_Heuristic_Shapelet_func(DATA_MAT, L)
%FIND_BEST_HEURISTIC_SHAPELET_FUNC This function will return the shapelet
%that best partitions the data (when measured by reduction in entropy)

% Input variables
% DATA_MAT:  This is assumed to be an nx61 data matrix, where is the number of
% samples, the first column is the label, and the remaining 60 colums are
% the PMU time series

% L:  This is the number of points to include on either side of the anchor
% point (typically L=4).

% Extract the heuristic anchor point shapelet for each sample
for i = 1:size(DATA_MAT,1)
    y = DATA_MAT(i,2:61);    
    [DShapelet{i}, extreme_anchor_point(i,1), start_index_shapelet(i,1), end_index_shapelet(i,1)] = Extract_DShapelet_func(y,L);    
end

% Calculate distances for each shapelet from each training sample
for current_shapelet = 1:size(DShapelet,2)
    for current_time_series = 1:size(DATA_MAT,1)
        shapelet_distances(current_shapelet, current_time_series) = ...
            Compute_Shapelet_Distance_func(DATA_MAT(current_time_series, 2:61), ...
            DShapelet{current_shapelet});
    end
end

% Find the gain (reduction in entropy) for each shapelet
for current_shapelet = 1:size(DShapelet,2)
    labels = DATA_MAT(:,1);
    [sorted_distances, sorting_indexes] = sort(shapelet_distances(current_shapelet,:));
    sorted_labels = labels(sorting_indexes);

    [optimal_split(current_shapelet), original_entropy(current_shapelet), entropy_gain(current_shapelet)] = Find_Optimal_Split(sorted_labels);

    % Calculate distance threshold for optimal split
    distance_threshold(current_shapelet) = (sorted_distances(optimal_split(current_shapelet)) + sorted_distances(optimal_split(current_shapelet)+1))/2;
end

% Let's find the best shapelet based on it's gain (reduction in
% entropy)
[best_gain,best_shapelet_index] = max(entropy_gain);

shapelet = DShapelet{best_shapelet_index};
distance = distance_threshold(best_shapelet_index);
class_label = DATA_MAT(best_shapelet_index,1);
starting_entropy = original_entropy(best_shapelet_index);
gain = entropy_gain(best_shapelet_index);


end

