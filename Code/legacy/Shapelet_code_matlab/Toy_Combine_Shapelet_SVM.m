% Beginning script to combine SVM classification with the best FastShapelet
% found through raw distance. [MAV:23MAY2017]


%% Load some data, add utils path for util functions

clearvars;

DATASET_PATH = './Shapelet_Datasets/UCR_Master/Gun_Point_';
FAST_SHAPELETS_DATAPATH = './ShapeletResearch/Execs/';




%% Use FastShapelets to find best shapelet with raw distance
% Set min_shapelet_length, max_shapelet_length, and step_size
MIN_SHAPELET_LENGTH = 5;
MAX_SHAPELET_LENGTH = 20;
STEP_SIZE = 1;

[SHAPELET_OUTPUT, CLASSIFY_OUTPUT] = ...
    Normalized_Shapelets_Wrapper_func(FAST_SHAPELETS_DATAPATH, ...
                                [DATASET_PATH 'TRAIN'], ...
                                [DATASET_PATH 'TEST'], ...
                                MAX_SHAPELET_LENGTH, ...
                                MIN_SHAPELET_LENGTH, ...
                                STEP_SIZE);

%% Extract shapelets from tree file, find distance and offset 
[Shapelet_IDs, Shapelets] = Extract_Shapelet_From_Results_File_func('tree.txt');


%% Create table with subsequences and labels (just for the 1st shapelet for now)
Gun_Point_TRAIN = load([DATASET_PATH 'TRAIN']);


SHAPELET_SIZE = size(Shapelets{1},2);
aligned_subsequences = zeros(size(Gun_Point_TRAIN,1), SHAPELET_SIZE+1);

for i = 1:size(Gun_Point_TRAIN,1)
    aligned_subsequences(i,1) = Gun_Point_TRAIN(i,1);
    
    [seq_dist, seq_offset] = Compute_Shapelet_Distance_func(Gun_Point_TRAIN, Shapelets{1});
    aligned_subsequences(i,2:SHAPELET_SIZE+1) = Gun_Point_TRAIN(i,seq_offset+1:seq_offset+SHAPELET_SIZE);
end

%% Plot aligned sequences
% Setup for plotting...
classes = unique(aligned_subsequences(:,1));
class_colors = jet(2*size(classes,1));

x_steps = 2/(size(aligned_subsequences,2)-2);
x = -0.5:x_steps:1.5; % x axis is the same for all...

% Plot samples
figure;
for i = 1:size(aligned_subsequences,1)
    y = aligned_subsequences(i,2:end);
    plot(x,y, 'Color', class_colors(aligned_subsequences(i,1),:))
    
%     % Plot closest shapelet
%     c_s_i = closest_shapelet(i,1); %Closest shapelet index
%     plot(x(start_index_shapelets_training(c_s_i,1):end_index_shapelets_training(c_s_i,1)), training_shapelets{c_s_i},'g')
    hold on;
end

% Plot shapelet
plot (x, Shapelets{1}, 'r', 'LineWidth', 3);
hold off;

% Look at the cumulative sum with the closest subsequences for each sample
% and the shapelet

cum_sum = aligned_subsequences(:,2:end);
cum_sum = abs(cum_sum - Shapelets{1});
cum_sum = cumsum(cum_sum,2);

% Plot cumulative sums
figure;
for i = 1:size(cum_sum,1)
    y = cum_sum(i,:);
    plot(x,y, 'Color', class_colors(aligned_subsequences(i,1),:))
    
    hold on;
end



%% Save table to file (for SVM)
dlmwrite('ALIGNED_SUBSEQUENCES', aligned_subsequences, 'delimiter', ' ');

%% Feed table into SVM to determine new classifier
% Currently just feeding the following commmands into the terminal manually
% (from the libsvm folder)

% ./svm-train ../../Shapelet_code_matlab/ALIGNED_SUBSEQUENCES
% ./svm-predict ../../Shapelet_code_matlab/ALIGNED_SUBSEQUENCES ALIGNED_SUBSEQUENCES.model my_out
