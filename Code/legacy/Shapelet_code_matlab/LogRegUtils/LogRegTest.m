function [original_train_accuracy, pca_accuracies_train, ...
    original_test_accuracy, pca_accuracies_test] = LogRegTest(varargin)
rng(999);
addpath('Shapelet_code_matlab/utils');
addpath('Shapelet_code_matlab/LogRegUtils');

options = struct(...
    'FAST_SHAPELETS_DATAPATH', 'ShapeletResearch/Execs/', ...
    'DATASET_PATH', 'Shapelet_Datasets/UCR_Master/', ...
    'DATASET_NAME', 'Gun_Point', ...
    'TREE_FILE', 'tree.txt', ...
    'PCA_FLAG', 1, ...
    'PCA_DIMS', 2, ...
    'LDA_FLAG', 0, ... 
    'NORMALIZATION_FLAG', 1);

optionNames = fieldnames(options);

%% Require arguments in key-value pair form
if mod(length(varargin), 2) ~= 0
    error("Must have key-value pairs for inputs")
end

%% Match all keyword arguments as required
for pair = reshape(varargin, 2, [])
    inputName = pair{1};
    
    if any(strcmp(inputName, optionNames))
        options.(inputName) = pair{2};
    else
        error('%s is not a valid parameter name', inputName)
    end
end
    
%% Load datasets

disp(['Loading training and testing datasets for ' ...
    options.DATASET_NAME '...'])

TRAINING_DATA = load([options.DATASET_PATH options.DATASET_NAME '_TRAIN']);
TESTING_DATA = load([options.DATASET_PATH options.DATASET_NAME '_TEST']);

disp('Done.')

%% Extract Shapelet from tree data
disp(['Extracting shapelets from tree file ' options.TREE_FILE '...'])
    
[TREE_NODES, SHAPELET_IDS, SHAPELETS] = ...
    Extract_Shapelet_Tree_Info_func(options.TREE_FILE);
disp('Done.')

%% Use only the first shapelet
ROOT_SHAPELET = SHAPELETS{1};

%% Classify TRAINING_DATA with existing shapelet

[root_shapelet_classification, left_class, right_class] = ...
    binary_classify_with_1_decision_node_func(...
        ROOT_SHAPELET, ...
        TREE_NODES.NonL_node_distance_threshold(1), ...
        TRAINING_DATA, ...
        TRAINING_DATA, ... %note: using training data
        options.NORMALIZATION_FLAG);
    
original_train_accuracy = sum(root_shapelet_classification == ...
    TRAINING_DATA(:,1)) / size(root_shapelet_classification, 1) * 100

[root_shapelet_classification, left_class, right_class] = ...
    binary_classify_with_1_decision_node_func(...
        ROOT_SHAPELET, ...
        TREE_NODES.NonL_node_distance_threshold(1), ...
        TRAINING_DATA, ...
        TESTING_DATA, ...
        options.NORMALIZATION_FLAG);
    
original_test_accuracy = sum(root_shapelet_classification == ...
    TESTING_DATA(:,1)) / size(root_shapelet_classification,1) * 100



%% Extract training and testing points for logistical regression

% First, create the points by extracting each training sample's 
% closest subsequence to the root shapelet
for i = 1:1%size(SHAPELETS,2) % Originally for the entire tree, just use the root shapelet
    SHAPELET_SIZES{i} = size(SHAPELETS{i},2);
    aligned_subsequences{i} = zeros(size(TRAINING_DATA,1), SHAPELET_SIZES{i}+1);
    
    for j = 1:size(TRAINING_DATA,1)
        % What is special about the first index? Does that one just denote
        % the class label?
        aligned_subsequences{i}(j,1) = TRAINING_DATA(j,1);
    
        [seq_dist, seq_offset] = Compute_Shapelet_Distance_Normalized_func(TRAINING_DATA(j,2:end), SHAPELETS{i});
        shapelet_distances{i}(j) = seq_dist;
        aligned_subsequences{i}(j,2:SHAPELET_SIZES{i}+1) = TRAINING_DATA(j,seq_offset+1:seq_offset+SHAPELET_SIZES{i});
    end
end

LOG_REG_TRAINING_POINTS = aligned_subsequences{1};

clear seq_dis seq_offset aligned_subsequences SHAPELET_SIZES

% Do the same for testing data
for i = 1:1%size(SHAPELETS,2) % Originally for the entire tree, just use the root shapelet
    SHAPELET_SIZES{i} = size(SHAPELETS{i},2);
    aligned_subsequences{i} = zeros(size(TESTING_DATA,1), SHAPELET_SIZES{i}+1);
    
    for j = 1:size(TESTING_DATA,1)
        aligned_subsequences{i}(j,1) = TESTING_DATA(j,1);
    
        [seq_dist, seq_offset] = Compute_Shapelet_Distance_Normalized_func(TESTING_DATA(j,2:end), SHAPELETS{i});
        shapelet_distances{i}(j) = seq_dist;
        aligned_subsequences{i}(j,2:SHAPELET_SIZES{i}+1) = TESTING_DATA(j,seq_offset+1:seq_offset+SHAPELET_SIZES{i});
    end
end

LOG_REG_TESTING_POINTS = aligned_subsequences{1};
clear seq_dis seq_offset aligned_subsequences SHAPELET_SIZES

%% Setup and train logistical regression classifier
disp('Training logistical regression classifier ...')

[train_x, train_y] = xysplit(LOG_REG_TRAINING_POINTS);
[test_x, test_y] = xysplit(LOG_REG_TESTING_POINTS);

classes = unique(train_y);
for i = 1:size(train_y, 1)
    train_y(i) = find(classes == train_y(i));
end

for i = 1:size(test_y, 1)
    test_y(i) = find(classes == test_y(i));
end

%plot(explained);

pca_mat = get_pca_mat(train_x, dims);




% project data x => [x x.^2]
train_x = CircularProjection(train_x);
coefs = mnrfit(train_x, train_y);

preds = zeros(size(train_x, 1), 1);
for i = 1:size(preds, 1)
    prediction = LogRegPredict(train_x(i, :), coefs);
    preds(i) = (prediction < 0) + 1;
end
log_reg_train_accuracy = 100 * sum(train_y == preds) / size(train_y, 1)

test_x = CircularProjection(test_x);


preds = zeros(size(test_x, 1), 1);
for i = 1:size(preds, 1)
    prediction =  LogRegPredict(test_x(i, :), coefs);
    preds(i) = (prediction < 0) + 1;
end
log_reg_test_accuracy = 100 * sum(test_y == preds) / size(test_y, 1)
end

