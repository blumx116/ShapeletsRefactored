function projectedData = CircularProjection(data, varargin)
% Converts the data from linear form to circular by mapping x => [x x.^2]
% @param data - an n x k matrix to be projected
% @returns projectedData - an n x (2k) matrix after the mapping
align_axis = 1;
for i=1:size(varargin)
    x = varargin{i};
    align_axis = x(1);
end
align_axis

original_feature_count = size(data, 2);
num_observations = size(data, 1);



if align_axis
    projectedData = zeros(num_observations, 2 * original_feature_count);
    for i = 1:size(data, 1)
        x = data(i, :);
        projectedData(i, :) = [x x.^2];
    end
else 
    new_feature_count = original_feature_count + ...
        (original_feature_count * (original_feature_count + 1) / 2);
    projectedData = zeros(num_observations, new_feature_count);
    for i = 1:size(data, 1)
        x = data(i, :);
        num_mixed_terms = (original_feature_count * (original_feature_count + 1) / 2);
        mixed_terms = zeros(1, num_mixed_terms);
        current_index = 1;
        for j=1:original_feature_count
            for k=j:original_feature_count
                mixed_terms(current_index) = x(j) * x(k);
                current_index = current_index + 1;
            end
        end
        projectedData(i, :) = [x mixed_terms];
    end
end
end