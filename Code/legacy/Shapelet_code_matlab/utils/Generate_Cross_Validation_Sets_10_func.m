function [data_subset_rows] = Generate_Cross_Validation_Sets_func(DATA_MAT)
%UNTITLED Divides the data rows into subsets for cross-valiation training
% Divide data into 10 subsets for cross-validation
% Given 1 subset, the other 90% will be used for training, and the 10% will
% be used for testing, so we need to make sure there is a representative
% sample of each class in both sets....

% Input variables
% - DATA_MAT:  The matrix containing the data.  The first column is assumed
% to be the label, and the remaining columns are assumed to be the time
% series data.  

% Output variables
% - data_subset_rows:  Row indexes for the 10 different subsets, containing
% a proportional subset of each class.  

% Identify the unique class labels
classes = unique(DATA_MAT(:,1));
num_classes = size(classes,1);

% Build 10 subsets
for i = 1:10
    data_subset_rows{i} = [];
end

for i = 1:num_classes    
    class_rows{i} = find(DATA_MAT(:,1) == classes(i));
    ten_percent_size(i) = size(class_rows{i},1) * 0.1;
end


for j = 1:num_classes
    start_index = 1;
    for i = 1:10
        end_index = floor(ten_percent_size(j) * i);
        data_subset_rows{i} = [data_subset_rows{i}; class_rows{j}(start_index:end_index)];
        start_index = end_index + 1;
    end
end

end

