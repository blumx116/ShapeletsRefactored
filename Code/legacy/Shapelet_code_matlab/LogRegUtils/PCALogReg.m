function [original_train_accuracy, pca_train_accuracies, ...
    original_test_accuracy, pca_test_accuracies, pcaExplained] = PCALogReg(varargin)
rng(999);
addpath('Shapelet_code_matlab/utils');
addpath('Shapelet_code_matlab/LogRegUtils');

options = struct(...
    'FAST_SHAPELETS_DATAPATH', 'ShapeletResearch/Execs/', ...
    'DATASET_PATH', 'Shapelet_Datasets/UCR_Master/', ...
    'DATASET_NAME', 'Gun_Point', ...
    'TREE_FILE', 'Shapelet_Datasets/Trees/Gun_Point_limited_tree.txt', ...
    'NORMALIZATION_FLAG', 1, ...
    'PCA_FLAG', 1, ...
    'DATA_NORMALIZATION_FLAG', 0,...
    'SHAPELET_CENTERING_FLAG', 0, ...
    'FORCE_CENTERING', 0, ...
    'PEARSON_CORRELATION_FLAG', 0);

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

shapelet = SHAPELETS{i};

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

pca_train_accuracies = zeros(1, 5);
pca_test_accuracies = zeros(1, 5);

if size(train_x, 1) < size(train_x, 2)
    disp(["NUMBER OF TRAINING SAMPLES" size(train_x, 1)]);
    disp(["NUMBER OF VARIABLES" size(train_x, 2)]);
    error("Cannot run PCA if the number of dimensions is greater than the number of observations")
end

if options.SHAPELET_CENTERING_FLAG
    disp('Shapelet centering')
    train_x = bsxfun(@minus, train_x, shapelet);
    test_x = bsxfun(@minus, test_x, shapelet);
end

if options.PEARSON_CORRELATION_FLAG
    correlation_matrix = corr(train_x);
    dims = [];
    for i = 1:size(train_x, 2)
        use_this_feature = 1;
        for j = 1:size(dims)
            if correlation_matrix(i, j) > 5
                use_this_feature = 0;
            end
        end
        if use_this_feature
            disp('unnecessary feature detected!')
            dims = [dims i];
        end
    end
    train_x = train_x(:, dims);
    test_x = test_x(:, dims);
end

if options.DATA_NORMALIZATION_FLAG
    data_mean = mean(train_x);
    data_std = std(train_x);
    train_x = bsxfun(@minus, train_x, data_mean);
    train_x = bsxfun(@rdivide, train_x, data_std);
    
    test_x = bsxfun(@minus, test_x, data_mean);
    test_x = bsxfun(@rdivide, test_x, data_std);
end

%% base results (no PCA)
if options.FORCE_CENTERING
    train_x_projected = train_x.^2;
    test_x_projected = test_x.^2;
else
    train_x_projected = CircularProjection(train_x);
    test_x_projected = CircularProjection(test_x);
end

[pca_train_accuracies(1), pca_test_accuracies(1)] = pca_trial(...
    train_x_projected, train_y, ...
    test_x_projected, test_y);

%% now with PCA
[pca_mat, pcaExplained] = get_pca_mat(train_x, 5);
pcaExplained = pcaExplained(1:5)

for i = 2:5
    pca_coefs = pca_mat(1:i, :);
    train_x_projected = pca_project(train_x, pca_coefs);
    test_x_projected = pca_project(test_x, pca_coefs);
    
    if options.FORCE_CENTERING
        train_x_projected = train_x_projected.^2;
        test_x_projected = test_x_projected.^2;
    else
        train_x_projected = CircularProjection(train_x_projected);
        test_x_projected = CircularProjection(test_x_projected);
    end
    
    
    [pca_train_accuracies(i), pca_test_accuracies(i)] = pca_trial(...
        train_x_projected, train_y,...
        test_x_projected, test_y);
end

end

