function [max_gain_split_point, entropy_before, max_gain] = Find_Optimal_Split(ORDERED_ITEMS)
%FIND_OPTIMAL_SPLIT Finds the optimal split point for a set of ordered items based on entropy gain 

% ORDERED_ITEMS must be nx1 array...

% Calculate entropy before the split
entropy_before = Calculate_Entropy_func(ORDERED_ITEMS);

% Go through all possible split points to find the maximum information gain
% Here the split point identifies the last element of the first set
max_gain = 0;
max_gain_split_point = 1;

for split_point = 1:size(ORDERED_ITEMS,1)-1;
    entropy_set1 = Calculate_Entropy_func(ORDERED_ITEMS(1:split_point));
    entropy_set2 = Calculate_Entropy_func(ORDERED_ITEMS(split_point+1:end));

    % Calculated weighted entropies (by the size of each split set)
    weighted_entropy_set1 = entropy_set1 * size(ORDERED_ITEMS(1:split_point),1) / size(ORDERED_ITEMS,1);
    weighted_entropy_set2 = entropy_set2 * size(ORDERED_ITEMS(split_point+1:end),1) / size(ORDERED_ITEMS,1);

    % Calculate the gain in information (reduction in entropy) after the split
    gain = entropy_before - weighted_entropy_set1 - weighted_entropy_set2;
    
    % If this is the highest gain found so far, save it
    if (gain > max_gain)
        max_gain = gain;
        max_gain_split_point = split_point;
    end
end

end

