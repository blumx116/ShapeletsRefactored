function [tree_edges, tree_node_vals] = Create_Shapelet_Decision_Tree_func(DATA_MAT, L)
%CREATE_SHAPELET_DECISION_TREE_FUNC This function will create a decision
%tree for a PMU data matrix (frequency or voltage)

% This script will create a decision tree (using shapelets and distances)
% for classification

% tree_edges outlines the layout of the tree (can be viewed with the
% 'treeplot' function
% tree_node_vals outlines the values at each node.  A leaf node contains a
% class label.  An intermediate decision node contains the shapelet, distance
% threshold, class_label, starting_entropy, and gain.  (on the shapelet and
% distance threshold are needed...)


% Create initial decision tree variables
% Find the number of classes and store them at the root node
tree_node_vals{1} = unique(DATA_MAT(:,1))';
num_classes = size(tree_node_vals{1},2);
num_nodes = num_classes * 2 - 1;
num_decision_nodes = num_classes - 1;
tree_edges = [0]; % start with just the root node
num_classes_at_leaf_node = [num_classes];

for i = 1:num_decision_nodes
    disp(['Creating decision node ' num2str(i)])
    % Let's expand the first leaf node we find with multiple classes
    node_to_expand_index = find(num_classes_at_leaf_node > 1, 1);
    
    % Now we need to update the tree
    % First expand the node to 2 leaf nodes
    tree_edges = [tree_edges node_to_expand_index node_to_expand_index];
    
    % Extract the current number of classes we're splitting, and set the
    % value to 0 at the node we just expanded
    current_num_classes = num_classes_at_leaf_node(node_to_expand_index);
    num_classes_at_leaf_node(node_to_expand_index) = 0;
    
    % Now determine the number of classes at each new leaf node
    % Use a random number for now... till I get the rest set up
    current_class_list = tree_node_vals{node_to_expand_index};

    % Now we find the shapelet that partitions the training samples best.  
    class_label_rows = ismember(DATA_MAT(:,1), current_class_list);
    subset_DATA_MAT = DATA_MAT(class_label_rows,:);
    disp('Calculating best shapelet')
    [shapelet, distance, class_label, starting_entropy, gain] = Find_Best_Heuristic_Shapelet_func(subset_DATA_MAT, L);
    disp('Best Shapelet found')
    
    % Calculate the distance between each training sample and the shapelet
    for j = 1:size(subset_DATA_MAT,1)
       partition_distance(j) = Compute_Shapelet_Distance_func(subset_DATA_MAT(j,2:end), shapelet);
    end
    
    partition = zeros(size(subset_DATA_MAT,1),1);
    for j = 1:size(subset_DATA_MAT,1)
       if (partition_distance(j) <= distance)
           partition(j) = 1;
       else
           partition(j) = 2;
       end     
    end
    
    % Add the classes to each partition as necessary
    classes_first_partition = [];
    classes_second_partition = [];
    for j = 1:size(current_class_list,2)
        class_rows = find(subset_DATA_MAT(:,1) == current_class_list(j));
        
        instances_first_partition(j) = sum(partition(class_rows,1) == 1);
        instances_second_partition(j) = sum(partition(class_rows,1) == 2);
        
        if (instances_first_partition(j) >= instances_second_partition(j))
            % Add to the first partition
            classes_first_partition = [classes_first_partition, current_class_list(j)];
        else
            % Add to the second partition
            classes_second_partition = [classes_second_partition, current_class_list(j)];
        end
    end

    % If one partition is empty, move the highest class over to it
    if (size(classes_first_partition,2) == 0)
        % Add largest class present in it
         [temp, largest_for_first_partition_loc] = max(instances_first_partition);
         classes_first_partition = classes_second_partition(largest_for_first_partition_loc);
         classes_second_partition(largest_for_first_partition_loc) = [];
         
    else
        if (size(classes_second_partition,2) == 0)
            % Add largest class present in it
            [temp, largest_for_second_partition_loc] = max(instances_second_partition);
            classes_second_partition = classes_first_partition(largest_for_second_partition_loc);
            classes_first_partition(largest_for_second_partition_loc) = [];
        end
    end
    
    
    num_classes_first_partition = size(classes_first_partition,2);
    num_classes_second_partition = size(classes_second_partition,2);
    num_classes_at_leaf_node = [num_classes_at_leaf_node num_classes_first_partition num_classes_second_partition];
    
    tree_node_vals{node_to_expand_index} = {shapelet, distance, class_label, starting_entropy, gain};
    current_expansion = size(tree_node_vals,2);
    tree_node_vals{current_expansion + 1} = classes_first_partition;
    tree_node_vals{current_expansion + 2} = classes_second_partition;
    
    % Save everything for this iteration
%     params{i}.tree_node_vals = tree_node_vals;
%     params{i}.num_classes = num_classes;
%     params{i}.num_nodes = num_nodes ;
%     params{i}.num_decision_nodes = num_decision_nodes;
%     params{i}.tree_edges = tree_edges;
%     params{i}.num_classes_at_leaf_node = num_classes_at_leaf_node;
%     params{i}.node_to_expand_index = node_to_expand_index;
%     params{i}.current_class_list = current_class_list;
% %    params{i}.largest_for_first_partition_loc = largest_for_first_partition_loc;
%     params{i}.classes_first_partition = classes_first_partition;
% %    params{i}.largest_for_second_partition_loc = largest_for_second_partition_loc;
%     params{i}.classes_second_partition = classes_second_partition;
    
end
end

