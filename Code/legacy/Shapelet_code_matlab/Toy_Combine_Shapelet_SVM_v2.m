% Experimental toy script to get file structure environement
% up and running[MAV:27JUN2017]

%% Setup (add paths, parameter settings, etc.)
clearvars;
addpath('./utils'); % Add utils path

FAST_SHAPELETS_DATAPATH = '../My_Shapelet_Code/Execs/';
DATASET_PATH = '../Datasets/UCR_Master/';
%DATASET_PATH = '../Datasets/PMU_Data_Processed/';
DATASET_NAME = 'Gun_Point';

% Set shapelet parameters
MIN_SHAPELET_LENGTH = 5;
MAX_SHAPELET_LENGTH = 20;
STEP_SIZE = 1;
R = 10;
DISTANCE_METRIC = 'euclidean';
CID_FLAG = 0;
NORMALIZATION_FLAG = 1;
K = 10;
TREE_FILE = 'tree.txt';

%% Load datasets
TRAINING_DATA = load([DATASET_PATH DATASET_NAME '_TRAIN']);
TESTING_DATA = load([DATASET_PATH DATASET_NAME '_TEST']);


%% Use FastShapelets to find best shapelet with raw distance
SHAPELET_COMMAND_OUTPUT = FastShapelets_Wrapper_func(FAST_SHAPELETS_DATAPATH, ...
                          [DATASET_PATH DATASET_NAME '_TRAIN'], ...
                           MAX_SHAPELET_LENGTH, MIN_SHAPELET_LENGTH, ...
                           STEP_SIZE, R, DISTANCE_METRIC, CID_FLAG, ...
                           NORMALIZATION_FLAG, K, TREE_FILE);

%% Classify on the test dataset
CLASSIFY_COMMAND_OUTPUT = FastShapelets_Classify_Wrapper_func(FAST_SHAPELETS_DATAPATH, ... 
                          [DATASET_PATH DATASET_NAME '_TEST'], ...
                          MAX_SHAPELET_LENGTH, MIN_SHAPELET_LENGTH, ... 
                          STEP_SIZE, DISTANCE_METRIC, CID_FLAG, ...
                          NORMALIZATION_FLAG, TREE_FILE);                         
                            
%% Extract shapelet tree data from tree.txt file
[TREE_NODES, SHAPELET_IDS, SHAPELETS] = Extract_Shapelet_Tree_Info_func('tree.txt');

%% Plot training data (entire curves) 
% Setup for plotting...
classes = unique(TRAINING_DATA(:,1));
class_colors = lines(2*size(classes,1));

x = 1:size(TRAINING_DATA,2)-1;

figure;
hold on;
legend_array = [];
legend_strings = repmat('Class X', size(classes));
% Plot samples by class type (making displaying the legend easier)
for i = 1:size(classes,1)
    class_samples = TRAINING_DATA(TRAINING_DATA(:,1) == classes(i),:);
    h{i} = plot(x, class_samples(:,2:end), 'Color', class_colors(i,:));
    
    legend_array = [legend_array, h{i}(1)];
    legend_strings(i,7) = num2str(i);
end

legend(legend_array, legend_strings);
title([DATASET_NAME ' Dataset:  All Training Samples']);
hold off;



% Plot shapelets and originating sequences
shapelet_colors = lines(size(SHAPELETS,2));

figure;
hold on;
for i = 1:size(SHAPELETS,2)    
   current_shapelet = SHAPELETS{i};
   array_index = find(TREE_NODES.node_IDs == SHAPELET_IDS(i));
   offset = TREE_NODES.NonL_node_position(array_index);
   
   x = offset:offset+size(current_shapelet,2)-1;
   plot(x, current_shapelet, 'Color', shapelet_colors(i,:), 'DisplayName', ['Shapelet ' num2str(i)], 'LineWidth', 2)
   
   clear current_shapelet
end

title(['Shapelets found for ' DATASET_NAME ' dataset']);
legend('show')
hold off;


%% Extract shapelets from tree file, find distance and offset 
%[Shapelet_IDs, Shapelets] = Extract_Shapelet_From_Results_File_func('tree.txt');

for i = 1:size(SHAPELETS,2)
    SHAPELET_SIZES{i} = size(SHAPELETS{i},2);
    aligned_subsequences{i} = zeros(size(TRAINING_DATA,1), SHAPELET_SIZES{i}+1);
    
    for j = 1:size(TRAINING_DATA,1)
        aligned_subsequences{i}(j,1) = TRAINING_DATA(j,1);
    
        [seq_dist, seq_offset] = Compute_Shapelet_Distance_Normalized_func(TRAINING_DATA(j,2:end), SHAPELETS{i});
        shapelet_distances{i}(j) = seq_dist;
        aligned_subsequences{i}(j,2:SHAPELET_SIZES{i}+1) = TRAINING_DATA(j,seq_offset+1:seq_offset+SHAPELET_SIZES{i});
    end
end

% Plot each shapelet as a subsequence of the original curve
num_samples = size(aligned_subsequences{i});
for i = 1:size(SHAPELETS,2)
    num_samples = size(aligned_subsequences{i},1);
    SHAPELET_repmat = repmat(SHAPELETS{i},[num_samples 1]);
    pointwise_dist = SHAPELET_repmat - aligned_subsequences{i}(:,2:end);
    raw_dist{i} = sum(pointwise_dist,2);
    
    % Find the where the distance is 0.  This is the class the shapelet
    % came from.
    %shapelet_sample_num(i) = find(raw_dist{i} == 0);
    [~,shapelet_sample_num(i)] = min(raw_dist{i});
end

%% Plot aligned sequences
% Setup for plotting...
%classes = unique(aligned_subsequences(:,1));
%class_colors = jet(2*size(classes,1));

for i = 1:size(aligned_subsequences,2)
    x_steps = 2/(size(aligned_subsequences{i},2)-2);
    x = -0.5:x_steps:1.5; % x axis is the same for all...

    figure;
    for j = 1:size(aligned_subsequences{i},1)
        y = aligned_subsequences{i}(j,2:end);
        plot(x,y, 'Color', class_colors(aligned_subsequences{i}(j,1),:))

        hold on;
    end

    % Plot shapelet
    plot (x, SHAPELETS{i}, 'r', 'LineWidth', 3);
    title(['Shapelet ' num2str(i) ' for ' DATASET_NAME ' dataset']);
    hold off;
end

% Extract the accuracy for the shapelet decision tree on the test data
accuracies = Extract_Accuracy_func('tree.txt')







% Plot shapelet tree
%figure;
%treeplot(TREE_NODES.node_IDs_matlab_parent_style);
    




% % Look at the cumulative sum with the closest subsequences for each sample
% % and the shapelet
% cum_sum = aligned_subsequences(:,2:end);
% cum_sum = abs(cum_sum - Shapelets{1});
% cum_sum = cumsum(cum_sum,2);
% 
% % Plot cumulative sums
% figure;
% for i = 1:size(cum_sum,1)
%     y = cum_sum(i,:);
%     plot(x,y, 'Color', class_colors(aligned_subsequences(i,1),:))
%     
%     hold on;
% end
% 
% 
% 
% %% Save table to file (for SVM)
% dlmwrite('ALIGNED_SUBSEQUENCES', aligned_subsequences, 'delimiter', ' ');
% 
% %% Feed table into SVM to determine new classifier
% % Currently just feeding the following commmands into the terminal manually
% % (from the libsvm folder)
% 
% % ./svm-train ../../Shapelet_code_matlab/ALIGNED_SUBSEQUENCES
% % ./svm-predict ../../Shapelet_code_matlab/ALIGNED_SUBSEQUENCES ALIGNED_SUBSEQUENCES.model my_out
