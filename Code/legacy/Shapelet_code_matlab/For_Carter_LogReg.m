% Script for Carter to plug logistical regression into for initial results
% Currently only designed for binary classification with a single shapelet
% [MAV:27JUN2017]

%% Setup (add paths, parameter settings, etc.)
clearvars;
rng(777);
addpath('Shapelet_code_matlab/utils'); % Add utils path
addpath('Shapelet_code_matlab/LogRegUtils'); % add helper functions to path

FAST_SHAPELETS_DATAPATH = 'ShapeletResearch/Execs/';
DATASET_PATH = 'Shapelet_Datasets/UCR_Master/';
DATASET_NAME = 'Gun_Point';

%% Load datasets
disp(['Loading training and testing datasets for ' DATASET_NAME '...'])
TRAINING_DATA = load([DATASET_PATH DATASET_NAME '_TRAIN']);
TESTING_DATA = load([DATASET_PATH DATASET_NAME '_TEST']);
PCA_FLAG = 1;
disp('Done.')

%% Use Fast Shapelets to create shapelet tree (commented out for now)
% Set shapelet parameters
% MIN_SHAPELET_LENGTH = 5;
% MAX_SHAPELET_LENGTH = 20;
% STEP_SIZE = 1;
% R = 10;
% DISTANCE_METRIC = 'euclidean';
% CID_FLAG = 0;
% NORMALIZATION_FLAG = 1;
% K = 10;
TREE_FILE = 'tree.txt';


% Use FastShapelets to create shapelet tree
% SHAPELET_COMMAND_OUTPUT = FastShapelets_Wrapper_func(FAST_SHAPELETS_DATAPATH, ...
%                           [DATASET_PATH DATASET_NAME '_TRAIN'], ...
%                            MAX_SHAPELET_LENGTH, MIN_SHAPELET_LENGTH, ...
%                            STEP_SIZE, R, DISTANCE_METRIC, CID_FLAG, ...
%                            NORMALIZATION_FLAG, K, TREE_FILE);
                            
%% Extract shapelet tree data from tree.txt file
disp(['Extracting shapelets from tree file ' TREE_FILE '...'])
[TREE_NODES, SHAPELET_IDS, SHAPELETS] = Extract_Shapelet_Tree_Info_func(TREE_FILE);
disp('Done.')

%% Use only the first shapelet
ROOT_SHAPELET = SHAPELETS{1};
num_dimensions = size(ROOT_SHAPELET, 2);
%% Classify TRAINING_DATA with existing shapelet
NORMALIZATION = 1;
[root_shapelet_classification, left_class, right_class] = binary_classify_with_1_decision_node_func(...
                                               ROOT_SHAPELET, TREE_NODES.NonL_node_distance_threshold(1), ... 
                                               TRAINING_DATA, TESTING_DATA, NORMALIZATION);

root_shapelet_accuracy = sum(root_shapelet_classification == TESTING_DATA(:,1)) / size(root_shapelet_classification,1) * 100

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

%plot(explained);
if PCA_FLAG
    [train_indices, valid_indices, ~] = dividerand(size(LOG_REG_TRAINING_POINTS, 1), 0.5, 0.5, 0.0);
    [train_x_cross, train_y_cross] = xysplit(LOG_REG_TRAINING_POINTS(train_indices, :));
    [valid_x, valid_y] = xysplit(LOG_REG_TRAINING_POINTS(valid_indices, :));
    
    pca_mat = get_pca_mat(train_x_cross, num_dimensions);
    
    best_number = 1;
    best_accuracy = 0;
    for i = 1:floor(num_dimensions / 3)
        pca_coefs = pca_mat(1:i, :);
        
        train_x_projected = pca_project(train_x_cross, pca_coefs);
        train_x_projected = CircularProjection(train_x_projected);
        
        valid_x_projected = pca_project(valid_x, pca_coefs);
        valid_x_projected = CircularProjection(valid_x_projected);
        
        mnr_coefs = mnrfit(train_x_projected, train_y_cross);
        
        preds = zeros(size(valid_y, 1), 1);
        for j = 1:size(preds, 1)
            prediction = LogRegPredict(valid_x_projected(j, :), mnr_coefs);
            preds(j) = (prediction < 0) + 1;
        end
        
        accuracy = 100 * sum(valid_y == preds) / size(valid_y, 1);
        
        if accuracy > best_accuracy
            best_accuracy = accuracy
            best_number = i
        end
    end
    
    train_x = pca_project(train_x, pca_mat(1:best_number, :));
    test_x = pca_project(test_x, pca_mat(1:best_number, :));
end
    
    
train_x = CircularProjection(train_x);
coefs = mnrfit(train_x, train_y);

test_x = CircularProjection(test_x);
preds = zeros(size(test_x, 1), 1);

for i = 1:size(preds, 1)
    prediction =  LogRegPredict(test_x(i, :), coefs);
    preds(i) = (prediction < 0) + 1;
end

logistic_regression_accuracy = 100 * sum(test_y == preds) / size(test_y, 1)

% Use LOG_REG_TESTING_POINTS to test accuracy
% Change in accuracy = log_reg_accuracy - root_shapelet_accuracy 

%% Extra code to analyze at the type of classifier created (ellipsoid, some type of parabola, etc...)


%% Extra code to plot points, optimized decision function, misclassified points, etc.


