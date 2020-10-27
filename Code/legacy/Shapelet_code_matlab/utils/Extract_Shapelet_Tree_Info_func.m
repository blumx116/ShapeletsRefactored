function [TREE_NODES, SHAPELET_IDS, SHAPELETS] = Extract_Shapelet_Tree_Info_func(FILENAME)
%Extract_Shapelet_Tree_Info_func Extracts the shapelets from the tree results file from Fast
%Shapelet c code.  
%   Inputs
%   - FILENAME:  Filename (including path) of the Fast Shapelets tree file.
%   Outputs
%   - TREE_NODES:  A tree structure containing the decision nodes and leaf
%   nodes of the shapelet decision tree
%   - SHAPELET_IDS:  IDs of each of the shapelets (array)
%   - SHAPELETS:  Data points of each shapelet (saved as cell array due to
%   differing sizes).

% Example function call:
%  [TREE_NODES, SHAPELET_IDS, SHAPELETS] = Extract_Shapelet_From_Results_File_func('.\Results\TREE_PMU_TableIII_V.txt');

FILE_TEXT = fileread(FILENAME);
%% Extract shapelet tree from file text
NODE_EXPR = '[NonLeaf]{4} [^\n]*[\n]'; % Finds lines starting with 'NonL' or 'Leaf'
node_info = regexp(FILE_TEXT, NODE_EXPR, 'match');

num_nodes = size(node_info,2);
% Pre-allocate arrays for faster performance
TREE_NODES.node_IDs = zeros(1,num_nodes);
TREE_NODES.NonL_node_object_number = zeros(1,num_nodes);
TREE_NODES.NonL_node_position = zeros(1,num_nodes);
TREE_NODES.NonL_node_length = zeros(1,num_nodes);
TREE_NODES.NonL_node_distance_threshold = zeros(1,num_nodes);
TREE_NODES.NonL_node_training_split = cell(1,num_nodes);
TREE_NODES.Leaf_node_classes = zeros(1,num_nodes);
TREE_NODES.node_IDs_matlab_parent_style = zeros(1,num_nodes);

for i = 1:num_nodes
    if size(regexp(node_info{1,i},'NonL', 'match')) == 1 % Node is a non-leaf node
        NonLeaf_numbers = regexp(node_info{1,i}, '[.\d]+', 'match');
        
        TREE_NODES.node_IDs(i) = str2double(NonLeaf_numbers{1});
        TREE_NODES.NonL_node_object_number(i) = str2double(NonLeaf_numbers{2}) + 1; % Change from 0 starting index to 1 starting index
        TREE_NODES.NonL_node_position(i) = str2double(NonLeaf_numbers{3}) + 1; % Change from 0 starting index to 1 starting index
        TREE_NODES.NonL_node_length(i) = str2double(NonLeaf_numbers{4});
        TREE_NODES.NonL_node_distance_threshold(i) = str2double(NonLeaf_numbers{5});
        TREE_NODES.NonL_node_training_split{i} = regexp(node_info{1,i}, '==>[^\n]+[\n]', 'match');
        [TREE_NODES.left_partition{i}, TREE_NODES.right_partition{i}] = ...
            Extract_Shapelet_Partitions(TREE_NODES.NonL_node_training_split{i});
        
    else % Node is a leaf node....
        node_info{1,i}(1:4) = []; % Remove 'Leaf' from the string
        node_numbers = regexp(node_info{1,i}, '[\d]+', 'match');
        if size(node_numbers,2) ~= 2
            disp('Error, number of parameters extracted from leaf node was not 2')
        else
            % 1st number is node ID, 2nd number is node class
            TREE_NODES.node_IDs(i) = str2double(node_numbers{1});
            TREE_NODES.Leaf_node_classes(i) = str2double(node_numbers{2});
        end
    end
end

% Create matlab-style tree indexes (for use with decision trees,
% displaying, etc.)
for i = 1:num_nodes
   if (mod(TREE_NODES.node_IDs(i),2) == 0) % Even number, parent ID is node ID divided by 2
       parent_ID = TREE_NODES.node_IDs(i)/2;
       TREE_NODES.node_IDs_matlab_parent_style(i) = find(TREE_NODES.node_IDs == parent_ID);
   else % Odd number, parent ID is node ID minus 1, then divided by 2
       parent_ID = (TREE_NODES.node_IDs(i) - 1)/2;
       
       if (parent_ID == 0) % Root node
           TREE_NODES.node_IDs_matlab_parent_style(i) = parent_ID;
       else
           TREE_NODES.node_IDs_matlab_parent_style(i) = find(TREE_NODES.node_IDs == parent_ID);
       end
   end
end

%% Extract shapelet info from file text
SHAPELET_EXPR = 'Shapelet [^a-zA-Z\n]*[\n]'; % Finds lines starting with 'Shapelet'
shapelet_info = regexp(FILE_TEXT, SHAPELET_EXPR, 'match');

num_shapelets = size(shapelet_info,2);

% Pre-allocate arrays for faster performance
SHAPELET_IDS = zeros(1,num_shapelets);
SHAPELETS = cell(1,num_shapelets);

for i = 1:num_shapelets
    shapelet_info{1,i}(1:8) = []; % Remove 'Shapelet' word

    SHAPELETS{i} = str2num(shapelet_info{1,i});
    
    % Save shapelet ID and data points (ID is the 1st number)
    SHAPELET_IDS(i) = SHAPELETS{i}(1); 
    SHAPELETS{i} = SHAPELETS{i}(2:end); 
end