function [original_train_accuracy, pca_train_accuracies, ...
    original_test_accuracy, pca_test_accuracies, pcaExplained] = ...
    PCALogRegGraph(varargin)
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
    'DATA_NORMALIZATION_FLAG', 1,...
    'SHAPELET_CENTERING_FLAG', 0, ...
    'FORCE_CENTERING', 0, ...
    'PEARSON_CORRELATION_FLAG', 0, ...
    'SHOW', 'TRAIN');

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
DISTANCE_THRESHHOLD = TREE_NODES.NonL_node_distance_threshold(1);

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


pca_mat = get_pca_mat(train_x, 2);
train_x_projected2 = pca_project(train_x, pca_mat);
test_x_projected2 = pca_project(test_x, pca_mat);


coefs = mnrfit(CircularProjection(train_x_projected2, 0), train_y);

switch options.SHOW
    case 'TRAIN'
        dataset_x = train_x_projected2;
        dataset_y = train_y;
    case 'TEST'
        dataset_x = test_x_projected2;
        dataset_y = test_y;
    otherwise
        error("INVALID SHOW VALUE");
end

dataset_x_insample = dataset_x(dataset_y == 1, :);
dataset_x_outsample = dataset_x(dataset_y ~= 1, :);

scatter(dataset_x_insample(:, 1), dataset_x_insample(:, 2), 5, [0, 0, 1]);
hold on
scatter(dataset_x_outsample(:, 1), dataset_x_outsample(:, 2), 5, [1 0 0]);

a = coefs(1);
b = coefs(2);
c = coefs(3);
d = coefs(4);
e = coefs(5);
f = coefs(6);

fn = @(x, y) a + (b * x) + (c * y) + (d * (x .^ 2)) + (e * x .* y) + (f * (y .^ 2));
fimplicit(fn);

width = [0.45, 0.9];
center = [0.6, -0.3];

circ_fn = @(x,y) (x.^ 2) + (y.^2) - (DISTANCE_THRESHHOLD^2);

fimplicit(circ_fn);

switch options.SHOW
    case 'TRAIN'
        orig_accuracy = original_train_accuracy;
        
        
    case 'TEST'
        orig_accuracy = original_test_accuracy;
end

final_accuracy = test_accuracy(CircularProjection(dataset_x, 0), dataset_y, coefs);
title([options.SHOW '   ' 'Circle Accuracy : ' num2str(orig_accuracy) ...
    '   ' 'Quadratic Accuracy : ' num2str(final_accuracy)]);
%A = ((center(1) ^ 2) * (width(2) ^ 2)) + ((center(2) ^ 2) * (width(1) ^ 2)) - ((width(1) ^ 2) * (width(2) ^ 2));
%B = -2 * center(1) * (width(2) ^ 2);
%C = -2 * center(2) * (width(1) ^ 2);
%D = width(2) ^ 2;
%E = width(1) ^ 2;

%F = @(X, Y) A + (B * X) + (C * Y) + (D * (X .^ 2)) + (E * (Y .^ 2));

%fimplicit(F);

hold off
end

