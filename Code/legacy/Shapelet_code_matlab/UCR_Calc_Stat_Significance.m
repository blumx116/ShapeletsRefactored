clearvars;
load('Ben_UCR_Results.mat');

%% Perform statistical significance test on normed vs. unnormed
% Normed index
normed_index = [2 1 2];
unnormed_index = [2 2 2];

normed_accuracies = all_accuracies{normed_index(1)}{normed_index(2)}{normed_index(3)};
unnormed_accuracies = all_accuracies{unnormed_index(1)}{unnormed_index(2)}{unnormed_index(3)};

% Loop through all the datasets
for i = 1:size(master_accuracy_columns,2)
    normed_accuracies_for_this_dataset = normed_accuracies{i};
    unnormed_accuracies_for_this_dataset = unnormed_accuracies{i};
    
    % Do a statistical significance test for each dataset
    x = normed_accuracies_for_this_dataset;
    y = unnormed_accuracies_for_this_dataset;
    [h(1,i), p(i)] = ttest(x, y);
    
    if (h(1,i) == 1)
        h(2,i) = mean(normed_accuracies_for_this_dataset) - mean(unnormed_accuracies_for_this_dataset);
    else %h(i) == 0
        h(2,i) = 0;
    end
end

h = h';
p = p';

% Change h(61) to a 0 (all of the values are the same, so it ends up a NaN
% for some reson)
h(61,1) = 0;

for i = 1:size(h,1)

end


