function [mat, explained] = get_pca_mat(data, dims)
[X, ~, ~, ~, explained, ~] = pca(data);
mat = X(1:dims, :);
end
