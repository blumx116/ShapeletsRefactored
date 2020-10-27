function [data_subset_rows] = Generate_Cross_Validation_Sets_func(DATA_MAT)
%UNTITLED Divides the data rows into subsets for cross-valiation training
% Divide data into 2 subsets for predicted accuracy using cross-validation

% Input variables
% - DATA_MAT:  The matrix containing the data.  The first column is assumed
% to be the label, and the remaining columns are assumed to be the time
% series data.  

% Output variables
% - data_subset_rows:  Row indexes for the 2 different subsets, containing
% a proportional subset of each class.  

% Identify the unique class labels
classes = unique(DATA_MAT(:,1));
num_classes = size(classes,1);

% Build 2 subsets
for i = 1:2
    data_subset_rows{i} = [];
end

for i = 1:num_classes    
    class_rows{i} = find(DATA_MAT(:,1) == classes(i));
    half_size(i) = size(class_rows{i},1) * 0.5;
end


for j = 1:num_classes
    start_index = 1;
    for i = 1:2
        end_index = floor(half_size(j) * i);
        data_subset_rows{i} = [data_subset_rows{i}; class_rows{j}(start_index:end_index)];
        start_index = end_index + 1;
    end
end

% % Sort for clearer reading...
% for i = 1:2
%    data_subset_rows{i} = sort(data_subset_rows{i}); 
% end

end

