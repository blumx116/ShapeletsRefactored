function [CLASSIFICATION, LEFT_CLASS, RIGHT_CLASS] = binary_classify_with_1_decision_node_func(ROOT_NODE_SHAPELET, DISTANCE_THRESHOLD, ...
                                                        TRAINING_DATA, TESTING_DATA, NORMALIZATION)
% binary_classify_with_1_decision_node_func
%   Classifies with just the root node of the decision tree
%   Is only designed for binary classification problems (i.e. there are 
%   only 2 classes).
%
%   Input variables:
%   - ROOT_NODE_SHAPELET:  Shapelet for the root node of the tree.
%   - DISTANCE_THRESHOLD:  Distance threshold for the shapelet
%   - TRAINING_DATA:  Training data that was used to build the tree (this
%   is only going to be used to determine the class levels of the root tree
%   decision node).
%   - TESTING_DATA:  The data that's going to be classified (can be the
%   same as TRAINING_DATA).
%   - NORMALIZATION:  If NORMALIZATION == 1, then the time series will be
%   z-normalized prior to distance computations.
%
%   Output variables:
%   - CLASSIFICATION:  Classifcation of TESTING_DATA
%   - LEFT_CLASS:  Class label of time series within the distance threshold
%   of the root node shapelet.
%   - RIGHT_CLASS:  Class label of the time series over the distance
%   threshold of the root node shapelet.



%% Establish root node, extract shapelet and distance threshold
%ROOT_NODE = 1;

%ROOT_NODE_SHAPELET = SHAPELETS{ROOT_NODE};
%DISTANCE_THRESHOLD = DECISION_TREE.NonL_node_distance_threshold(ROOT_NODE);

%% Use TRAINING_DATA to determine which class is closest to the shapelet
% Compute the distances between the shapelet and samples we're classifying
for i = 1:size(TRAINING_DATA,1)
    if (NORMALIZATION == 1)
        [original_shapelet_distances(i), offset] = Compute_Shapelet_Distance_Normalized_func(TRAINING_DATA(i,2:end),...
                                                                   ROOT_NODE_SHAPELET);
    else
        [original_shapelet_distances(i), offset] = Compute_Shapelet_Distance_func(TRAINING_DATA(i,2:end),...
                                                                   ROOT_NODE_SHAPELET);
    end
end

% Determine partitions of samples based on distance threshold
left_sample_indexes = find(original_shapelet_distances <= DISTANCE_THRESHOLD == 1)';
left_sample_classes = TRAINING_DATA(left_sample_indexes,1);

right_sample_indexes = find(original_shapelet_distances > DISTANCE_THRESHOLD == 1)';
right_sample_classes = TRAINING_DATA(right_sample_indexes,1);
    
% We're only working with 2 classes, labeled 1 and 2
class_labels = unique(TRAINING_DATA(:,1));
% Find class that's classified left
num_instances_class1 = size(find(left_sample_classes == class_labels(1)),1);
num_instances_class2 = size(find(left_sample_classes == class_labels(2)),1);
if (num_instances_class1 > num_instances_class2)
   % Class 1 goes to the left
   LEFT_CLASS = class_labels(1);
   RIGHT_CLASS = class_labels(2);
else
    % Class 2 goes to the left
    LEFT_CLASS = class_labels(2);
    RIGHT_CLASS = class_labels(1);
end

clear original_shapelet_distances left_sample_indexes left_sample_classes ...
    right_sample_indexes right_sample_classes

%% Now that we have the class labels for each side, classify the data
for i = 1:size(TESTING_DATA,1)
    if (NORMALIZATION == 1)
        [original_shapelet_distances(i), offset] = Compute_Shapelet_Distance_Normalized_func(TESTING_DATA(i,2:end),...
                                                                   ROOT_NODE_SHAPELET);
    else
        [original_shapelet_distances(i), offset] = Compute_Shapelet_Distance_func(TESTING_DATA(i,2:end),...
                                                                   ROOT_NODE_SHAPELET);
    end
end

% Determine partitions of samples based on distance threshold
left_sample_indexes = find(original_shapelet_distances <= DISTANCE_THRESHOLD == 1)';
right_sample_indexes = find(original_shapelet_distances > DISTANCE_THRESHOLD == 1)';

CLASSIFICATION = zeros(size(TESTING_DATA,1),1);

CLASSIFICATION(left_sample_indexes) = LEFT_CLASS;
CLASSIFICATION(right_sample_indexes) = RIGHT_CLASS;
end

