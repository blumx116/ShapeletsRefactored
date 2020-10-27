function [classification] = Classify_with_DT_func(SAMPLE_DATA, ...
    RELEVANT_INDEXES, SHAPELET_IDS, SHAPELET_ARRAY, DECISION_TREE, ...
    ACTIVE_NODE, current_classification, NORMALIZATION)
%CLASSIFY_WITH_DT This function will classify with a generic decision tree
% developed by [MAV].  
%   Output variables:
%   - classification:  The classification for the samples where
%   RELEVANT_INDEXES == 1;
%
%   Input variables:
%   - SAMPLE_DATA:  Time series data samples (first column is label, remaining
%   columns are time series data points
%   - RELEVANT_INDEXES:  Indexes that will be classified.  This will ignore
%   indexes in SAMPLES where RELEVANT_INDEXES == 0;
%   - SHAPELET_IDS:  Node ID for each shapelet in SHAPELET_ARRAY.
%   - SHAPELET_ARRAY:  Array of shapelets that goes with DECISION_TREE
%   - DECISION_TREE:  The decision tree we're using (note this is not
%   Matlab's decision tree data structure, since that data structure is
%   immutable).
%   - ACTIVE_NODE:  The decision node that is currently being used for
%   classification.
%   - current_classification:  Tracks the classification so far...
%   - NORMALIZATION:  If NORMALIZATION == 1, sequences will be
%   z-normalized.  Otherwise they will not.

% This is a recursive algorithm (not optimized for performance).  
% The base function call will look something like:
% Classify_with_DT_func(DATA, ones(size(DATA,1),1), SHAPELET_ARRAY, ...
% DECISION_TREE, 1, zeros(size(DATA,1),1)

% Check whether the node is a leaf node or a decision node
active_node_index = find(DECISION_TREE.node_IDs == ACTIVE_NODE);

if (DECISION_TREE.Leaf_node_classes(active_node_index) > 0)
   % Node is a leaf node.  Assign the class value to RELEVANT_INDEXES and
   % return the classification array.
   current_classification(RELEVANT_INDEXES) = DECISION_TREE.Leaf_node_classes(active_node_index);
   
   % Return current classification
   classification = current_classification;
    
else
    % Node is a decision node
    
    % Find the associated shapelet
    shapelet_index = find(SHAPELET_IDS == ACTIVE_NODE);
    % Compute the distances between the shapelet and samples we're classifying
    for i = 1:size(RELEVANT_INDEXES,2)
        if (NORMALIZATION == 1)
            [my_shapelet_distances(i), offset] = Compute_Shapelet_Distance_Normalized_func(SAMPLE_DATA(RELEVANT_INDEXES(i),2:end),...
                                                                       SHAPELET_ARRAY{shapelet_index});
        else
            [my_shapelet_distances(i), offset] = Compute_Shapelet_Distance_func(SAMPLE_DATA(RELEVANT_INDEXES(i),2:end),...
                                                                       SHAPELET_ARRAY{shapelet_index});
        end
    end

    % Determine partitions of samples based on distance threshold
    left_sample_indexes = find(my_shapelet_distances <= DECISION_TREE.NonL_node_distance_threshold(ACTIVE_NODE) == 1);
    left_sample_partition = RELEVANT_INDEXES(left_sample_indexes);
    
    right_sample_indexes = find(my_shapelet_distances > DECISION_TREE.NonL_node_distance_threshold(ACTIVE_NODE) == 1);
    right_sample_partition = RELEVANT_INDEXES(right_sample_indexes);
    
    % Do a recursive call on each partition to classify samples
    left_partition_classification = Classify_with_DT_func(SAMPLE_DATA, ...
        left_sample_partition, SHAPELET_IDS, SHAPELET_ARRAY, DECISION_TREE, ...
        ACTIVE_NODE*2, current_classification);
    
    right_partition_classification = Classify_with_DT_func(SAMPLE_DATA, ...
        right_sample_partition, SHAPELET_IDS, SHAPELET_ARRAY, DECISION_TREE, ...
        ACTIVE_NODE*2 + 1, current_classification);

    % Merge classifications together
    
    classification = left_partition_classification + right_partition_classification;

end

end

