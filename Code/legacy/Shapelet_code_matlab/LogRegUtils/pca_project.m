function projected_data = pca_project(data, coefs)
projected_data = (coefs * data')';
end