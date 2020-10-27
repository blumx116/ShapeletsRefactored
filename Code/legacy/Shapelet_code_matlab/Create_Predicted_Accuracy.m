%% Setup (add paths, parameter settings, etc.)
clearvars;
addpath('./utils'); % Add utils path

DATASET_PATH = './Shapelet_Datasets/UCR_CV_DATA/';
FAST_SHAPELETS_DATAPATH = './ShapeletResearch/Execs/';

CV_FILE_FILTER = 'w*_TRAIN_CV1';
%CV2_FILE_FILTER = 'w*_TRAIN_CV2';

ALL_TRAINING_FILENAMES = getAllFiles(DATASET_PATH, CV_FILE_FILTER);

for i = 1:size(ALL_TRAINING_FILENAMES,2)
    [~,DATASET_NAMES{i},~] = fileparts(ALL_TRAINING_FILENAMES{i});
    DATASET_NAMES{i} = strrep(DATASET_NAMES{i}, '_TRAIN_CV1', '');
end

% The number of iterations we're going to run (since fastshapelets is
% non-deterministic)
num_iterations = 1; 


for i = 24:size(DATASET_NAMES,2)
    tic
    
    DATASET_NAME = DATASET_NAMES{i};
    
    DATA = load([DATASET_PATH DATASET_NAME '_TRAIN_CV1']);
    
    % Set min_shapelet_length, max_shapelet_length, and step_size
    MIN_SHAPELET_LENGTH = 1;
    MAX_SHAPELET_LENGTH = floor((size(DATA,2)-1)/2);
    STEP_SIZE = 1;

    
    for j = 1:num_iterations
        [SHAPELET_OUTPUT, CLASSIFY_OUTPUT] = ...
                         Normalized_Shapelets_Wrapper_func(FAST_SHAPELETS_DATAPATH, ...
                               [DATASET_PATH DATASET_NAME '_TRAIN_CV1'], ...
                               [DATASET_PATH DATASET_NAME '_TRAIN_CV2'], ...
                               MAX_SHAPELET_LENGTH, ...
                               MIN_SHAPELET_LENGTH, ...
                               STEP_SIZE);

        % Extract the accuracy for the shapelet decision tree on the test data
        current_accuracy = Extract_Accuracy_func('tree.txt');
        accuracies_CV1(j,i) = current_accuracy{1};

        % Copy the tree.txt file to the results folder
        copy_command = ['cp tree.txt CV_UCR_Results/TREE_' DATASET_NAME 'CV_1_iter_' num2str(j) '.txt'];
        status = system(copy_command);
        
        % Execute 2nd command, swapping CV1 and CV2 in train/test roles
        [SHAPELET_OUTPUT, CLASSIFY_OUTPUT] = ...
        Normalized_Shapelets_Wrapper_func(FAST_SHAPELETS_DATAPATH, ...
                               [DATASET_PATH DATASET_NAME '_TRAIN_CV2'], ...
                               [DATASET_PATH DATASET_NAME '_TRAIN_CV1'], ...
                               MAX_SHAPELET_LENGTH, ...
                               MIN_SHAPELET_LENGTH, ...
                               STEP_SIZE);

        % Extract the accuracy for the shapelet decision tree on the test data
        current_accuracy = Extract_Accuracy_func('tree.txt');
        accuracies_CV2(j,i) = current_accuracy{1};

        expected_accuracy(j,i) = (accuracies_CV1(j,i) + accuracies_CV2(j,i))/2;
        
        % Copy the tree.txt file to the results folder
        copy_command = ['cp tree.txt CV_UCR_Results/TREE_' DATASET_NAME 'CV_2_iter_' num2str(j) '.txt'];
        status = system(copy_command);
    end
    
    run_time(i) = toc;
    
    avg_expected_accuracy(i) = mean(expected_accuracy(:,i));
    
    % Save variables in environment
    save('results.mat', 'accuracies_CV1', 'accuracies_CV2', 'expected_accuracy', ...
        'DATASET_NAMES', 'run_time', 'avg_expected_accuracy');
    
    
end







