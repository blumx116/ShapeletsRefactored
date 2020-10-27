function [entropy] = Calculate_Entropy_func(list)
%CALCULATE_ENTROPY_FUNC Calculates the entropy of a set of objects, as defined in (Ye, Keogh '09)

% Identify the number of classes present

unique_classes = unique(list);

entropy = 0;

% Add the entropy for each class
for current_class = 1:size(unique_classes,1)
     matches = list == unique_classes(current_class);
     proportion_current_class = sum(matches)/size(list,1);
     class_entropy = - proportion_current_class * log(proportion_current_class);
     entropy = entropy + class_entropy;
end


end

