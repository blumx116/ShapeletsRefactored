% Experimental toy script to get file structure environement
% up and running[MAV:27JUN2017]

%% Setup (add paths, parameter settings, etc.)
clearvars;
addpath('./utils'); % Add utils path

FAST_SHAPELETS_DATAPATH = './ShapeletResearch/Execs/';
DATASET_PATH = './Shapelet_Datasets/UCR_Master/';
%DATASET_NAME = 'SonyAIBORobotSurface';
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
classes = unique(aligned_subsequences{1}(:,1));
%class_colors = jet(2*size(classes,1));

for i = 1:size(aligned_subsequences,2)
    x_steps = 2/(size(aligned_subsequences{i},2)-2);
    x = -0.5:x_steps:1.5; % x axis is the same for all...

    figure;
    for j = 1:size(aligned_subsequences{i},1)
        y = aligned_subsequences{i}(j,2:end);
        sample_class = find(classes == aligned_subsequences{i}(j,1));
        plot(x,y, 'Color', class_colors(sample_class,:))

        hold on;
    end

    % Plot shapelet
    plot (x, SHAPELETS{i}, 'r', 'LineWidth', 3);
    title(['Shapelet ' num2str(i) ' for ' DATASET_NAME ' dataset']);
    hold off;
end

% Extract the accuracy for the shapelet decision tree on the test data
accuracies = Extract_Accuracy_func('tree.txt')


%% Classify TRAINING_DATA with existing shapelet
NORMALIZATION = 1;
[original_shapelet_training_classification, left_class, right_class] = binary_classify_with_1_decision_node_func(...
                                               SHAPELETS{1}, TREE_NODES.NonL_node_distance_threshold(1), ... 
                                               TRAINING_DATA, TRAINING_DATA, NORMALIZATION);
                  
partition_left = find(original_shapelet_training_classification == left_class);
partition_left_classes = TRAINING_DATA(partition_left,1);

partition_right = find(original_shapelet_training_classification == right_class);

partition_left_correct = partition_left;
partition_left_correct(find(partition_left_classes ~= left_class)) = [];

%% Build the GeoMedian Virtual Shapelet with the correclty classified samples close to the shapelet
partition_left_correct_aligned_subsequences = aligned_subsequences{1}(partition_left_correct, 2:end);
GeoMedian_Shapelet = Compute_Geometric_Median_func(partition_left_correct_aligned_subsequences, 20);

%% Plot selected aligned subsequences with Shapelet and Virtual Shapelet
clear my_virtual_shapelet_distances legend_strings original_shapelet_distances

figure;
hold on;

my_colors = get(gca,'colororder');

x = 1:size(partition_left_correct_aligned_subsequences,2);
for i = 1:size(partition_left_correct_aligned_subsequences,1)
    y = partition_left_correct_aligned_subsequences(i,:);
    h{1} = plot(x, y, 'Color', my_colors(1,:));
end

legend_array = h{1};
legend_strings(1,:) = ('Aligned Training Samples');

% Plot original shapelet
h{2} = plot(x, SHAPELETS{1}, 'Color', my_colors(2,:), 'LineWidth', 1);
legend_array = [legend_array, h{2}];
legend_strings(2,:) = ('Original Shapelet Found ');
    
% Plot virtual shapelet
h{3} = plot(x, GeoMedian_Shapelet, 'Color', my_colors(3,:), 'LineWidth', 1);
legend_array = [legend_array, h{3}];
legend_strings(3,:) = ('Virtual Shapelet Found  ');

legend(legend_array, legend_strings);
hold off

%% Find virtual shapelet cutoff distance
for i = 1:size(TRAINING_DATA,1)
    [my_virtual_shapelet_distances(i), vs_offset(i)] = Compute_Shapelet_Distance_Normalized_func(TRAINING_DATA(i,2:end),...
                                                                   GeoMedian_Shapelet);
end

my_virtual_shapelet_distances = my_virtual_shapelet_distances';
[my_virtual_shapelet_distances, sorting_index] = sort(my_virtual_shapelet_distances);

my_virtual_shapelet_distances(:,2) = TRAINING_DATA(sorting_index,1);

% Find optimal split point
[VS_optimal_split, starting_entropy, VS_GAIN] = Find_Optimal_Split(my_virtual_shapelet_distances(:,2));

VS_shapelet_distance_threshold = (my_virtual_shapelet_distances(VS_optimal_split, 1) + ...
                                      my_virtual_shapelet_distances(VS_optimal_split + 1, 1)) / 2;

%% Find gain for each (for expected accuracy)
for i = 1:size(TRAINING_DATA,1)
    [original_shapelet_distances(i), offset(i)] = Compute_Shapelet_Distance_Normalized_func(TRAINING_DATA(i,2:end),...
                                                                   SHAPELETS{1});
end

original_shapelet_location = find(original_shapelet_distances == 0);

original_shapelet_distances = original_shapelet_distances';
[original_shapelet_distances, sorting_index] = sort(original_shapelet_distances);

original_shapelet_distances(:,2) = TRAINING_DATA(sorting_index,1);
[OS_optimal_split, starting_entropy, OS_GAIN] = Find_Optimal_Split(original_shapelet_distances(:,2));
                                  
%% Classify TEST_DATA with original shapelet
[OS_testing_classification] = binary_classify_with_1_decision_node_func(...
                                               SHAPELETS{1}, TREE_NODES.NonL_node_distance_threshold(1), ... 
                                               TRAINING_DATA, TESTING_DATA, NORMALIZATION);

OS_correct_classifications = OS_testing_classification == TESTING_DATA(:,1);
OS_accuracy = sum(OS_correct_classifications)/size(OS_correct_classifications,1);


%% Classify TEST_DATA with virtual shapelet
[VS_testing_classification] = binary_classify_with_1_decision_node_func(...
                                               GeoMedian_Shapelet, VS_shapelet_distance_threshold, ...
                                               TRAINING_DATA, TESTING_DATA, NORMALIZATION);
                                           

VS_correct_classifications = VS_testing_classification == TESTING_DATA(:,1);
VS_accuracy = sum(VS_correct_classifications)/size(VS_correct_classifications,1);

%% Classify TEST_DATA with physical shapelet, virtual shapelet pair
% First we use the physical shapelet to find the closest subsequences
TEST_aligned_subsequences = zeros(size(TESTING_DATA,1), SHAPELET_SIZES{1}+1);

for j = 1:size(TESTING_DATA,1)
    TEST_aligned_subsequences(j,1) = TESTING_DATA(j,1);

    [seq_dist, seq_offset] = Compute_Shapelet_Distance_Normalized_func(TESTING_DATA(j,2:end), SHAPELETS{1});
    
    TEST_aligned_subsequences(j,2:SHAPELET_SIZES{1}+1) = TESTING_DATA(j,seq_offset+1:seq_offset+SHAPELET_SIZES{1});
    
    % Use the virtual shapelet to find the distance
    TEST_shapelet_distances(j) = Compute_Shapelet_Distance_Normalized_func(TEST_aligned_subsequences(j,2:end), GeoMedian_Shapelet);
    
end

VS_OS_PAIR_LEFT = find(TEST_shapelet_distances <= VS_shapelet_distance_threshold == 1)';
VS_OS_PAIR_RIGHT = find(TEST_shapelet_distances > VS_shapelet_distance_threshold == 1)';

VS_OS_PAIR_CLASSIFICATION = zeros(size(TESTING_DATA,1),1);

VS_OS_PAIR_CLASSIFICATION(VS_OS_PAIR_LEFT) = left_class;
VS_OS_PAIR_CLASSIFICATION(VS_OS_PAIR_RIGHT) = right_class;

VS_OS_PAIR_correct_classifications = VS_OS_PAIR_CLASSIFICATION == TESTING_DATA(:,1);
VS_OS_PAIR_accuracy = sum(VS_OS_PAIR_correct_classifications)/size(VS_OS_PAIR_correct_classifications,1);

%% Look at a PCA analysis of the aligned subsequences
PCA_input = [aligned_subsequences{1}(:,2:end); GeoMedian_Shapelet];
[my_pca, score, latent, tsquared, explained] = pca(PCA_input');

my_2d_plot_points = my_pca(:,1:2);
pca_percent_rep = sum(explained(1:2))/100;


% Separate left class shapelet points first
left_class_training_indexes = TRAINING_DATA(:,1) == left_class;
left_class_points = my_2d_plot_points(left_class_training_indexes,:);

% Then separate right class shapelet points
right_class_training_indexes = TRAINING_DATA(:,1) == right_class;
right_class_points = my_2d_plot_points(right_class_training_indexes,:);

% Plot points with original shapelet, original shapelet, and distance
figure;
hold on;

scatter(left_class_points(:,1), left_class_points(:,2), [], 'r');
scatter(right_class_points(:,1), right_class_points(:,2), [], 'b');
scatter(my_2d_plot_points(original_shapelet_location,1), my_2d_plot_points(original_shapelet_location,2), ...
                        [], 'filled', 'd');
                    
radius = TREE_NODES.NonL_node_distance_threshold(1)/2 * pca_percent_rep;
rectangle_position = [my_2d_plot_points(original_shapelet_location,1) - radius/2, ...
    my_2d_plot_points(original_shapelet_location,2) - radius/2, ...
    radius, radius];
rectangle('Position', rectangle_position, 'Curvature', [1 1]);
axis equal;

title('Original (physical) shapelet vs virtual shapelet')

% Plot virtual shapelet point
scatter(my_2d_plot_points(end,1), my_2d_plot_points(end,2), ...
                          [], 'filled', 'd');

% Plot virtual shapelet distance radius    
radius = VS_shapelet_distance_threshold/2 * pca_percent_rep;
rectangle_position = [my_2d_plot_points(end,1) - radius/2, ...
    my_2d_plot_points(end,2) - radius/2, ...
    radius, radius];
rectangle('Position', rectangle_position, 'Curvature', [1 1], 'EdgeColor', 'r');
