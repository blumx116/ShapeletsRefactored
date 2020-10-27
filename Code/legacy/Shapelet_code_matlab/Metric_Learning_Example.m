clearvars;
addpath('./dca');
addpath('./utils'); % Add utils path

FAST_SHAPELETS_DATAPATH = './ShapletResearch/Execs/';
DATASET_PATH = './Shapelet_Datasets/UCR_Master/';
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
    shapelet_sample_num(i) = find(raw_dist{i} == 0);
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





%% Prep for distance metric learning
normalized_subsequences = aligned_subsequences{1};
for i = 1:size(normalized_subsequences,1)
   my_mean = mean(normalized_subsequences(i,2:end)); 
   my_std = std(normalized_subsequences(i,2:end));
   normalized_subsequences(i,2:end) = (normalized_subsequences(i,2:end) - my_mean) / my_std;
end

my_shapelet = SHAPELETS{1};
my_mean = mean(my_shapelet);
my_std = std(my_shapelet);
my_shapelet = (my_shapelet - my_mean) / my_std;

% % Offset the shapelet and normalized subsequences so that there are no
% % negative values
% min1 = min(min(normalized_subsequences(:,2:end))); % Find the min of the aligned subsequences
% min2 = min(my_shapelet);                              % Find the minimum of the shapelet
% offset = min([min1 min2]);                         % Take whichever is smaller as the offset
% 
% % Add the offset to all values so they are nonnegative
% normlized_subsequences = normalized_subsequences + offset;
% my_shapelet = my_shapelet + offset;

%DATA = aligned_subsequences{1}(:,2:end)';
DATA = normalized_subsequences(:,2:end)';
CHUNKS = aligned_subsequences{1}(:,1);
NEG_LINKS = [0 1; 1 0];

[B, DCA, NEW_DATA] = DCA_func(DATA, CHUNKS, NEG_LINKS);

%% Use the Mahalanobis distance to find the distance between the shapelet and aligned subsequences
for i = 1:size(normalized_subsequences,1)
    raw_dist = normalized_subsequences(i,2:end) - my_shapelet;
    DCA_dist(i,1) = raw_dist * B * raw_dist';
end

DCA_dist(:,2) = aligned_subsequences{1}(:,1);
[~,sort_index] = sort(DCA_dist(:,1));
DCA_dist_sorted = DCA_dist(sort_index,:);


for i = 1:size(normalized_subsequences,1)
    raw_dist = normalized_subsequences(i,2:end) - my_shapelet;
    Eucl_dist(i,1) = raw_dist * raw_dist';
end

Eucl_dist(:,2) = aligned_subsequences{1}(:,1);
[~,sort_index] = sort(Eucl_dist(:,1));
Eucl_dist_sorted = Eucl_dist(sort_index,:);

%% Try to plot points in space...
% Plot points in original space


[my_pca, score, latent, tsquared, explained] = pca(normalized_subsequences(:,2:end));

top_2_dimensions = my_pca(:,1:2);
top_3_dimensions = my_pca(:,1:3);
pca_percent_rep_2D = sum(explained(1:2))/100
pca_percent_rep_3D = sum(explained(1:3))/100

my_2d_plot_points = normalized_subsequences(:,2:end) * top_2_dimensions;

class_1_indexes = find(normalized_subsequences(:,1) == 1);
class_2_indexes = find(normalized_subsequences(:,1) == 2);

class_1_point_matrix = my_2d_plot_points(class_1_indexes,:);
class_2_point_matrix = my_2d_plot_points(class_2_indexes,:);



figure;
hold on;

scatter(class_1_point_matrix(:,1), class_1_point_matrix(:,2), [], 'r');
scatter(class_2_point_matrix(:,1), class_2_point_matrix(:,2), [], 'b');


% Plot points in transformed space
A = sqrtm(B);
A = real(A); % Get rid of complex numbers... so we can plot....

new_points = A*normalized_subsequences(:,2:end)';
new_points = new_points';

[my_pca, score, latent, tsquared, explained] = pca(new_points);

top_2_dimensions = my_pca(:,1:2);
my_2d_plot_points = new_points * top_2_dimensions;
pca_percent_rep = sum(explained(1:2))/100

class_1_point_matrix = my_2d_plot_points(class_1_indexes,:);
class_2_point_matrix = my_2d_plot_points(class_2_indexes,:);

figure;
hold on;

scatter(class_1_point_matrix(:,1), class_1_point_matrix(:,2), [], 'r');
scatter(class_2_point_matrix(:,1), class_2_point_matrix(:,2), [], 'b');



%[A, converged] = iter_projection_new2(X, S, D, A, w, t, maxiter)  