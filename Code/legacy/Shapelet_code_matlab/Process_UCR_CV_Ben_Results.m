clearvars;

% Path to results
UCR_RESULTS_PATH = '../Ben_UCR_Results/cv_output/';

%% Get a list of all folders in this folder.
files = dir(UCR_RESULTS_PATH);
dirFlags = [files.isdir];
subFolders = files(dirFlags);

%% Get rid of '.' and '..' folders
get_rid_of_folder = false(size(subFolders));
for k = 1:length(subFolders)
    if (subFolders(k).name == '.')
        get_rid_of_folder(k) = 1;
    end
end
subFolders(get_rid_of_folder) = [];

%% Print folder names to command window.
% for k = 1:length(subFolders)
% 	fprintf('Sub folder #%d = %s\n', k, subFolders(k).name);
% end

%% For each folder, go through files and extract the accuracies

% File component names
CV_file_component_names{1,1} = 'manhattan';
CV_file_component_names{1,2} = 'euclidean';
CV_file_component_names{1,3} = 'correlation';

CV_file_component_names{2,1} = 'normed';
CV_file_component_names{2,2} = 'unnormed';

CV_file_component_names{3,1} = 'CID';
CV_file_component_names{3,2} = 'NOCID';

CV_master_accuracy_table = zeros(12, length(subFolders));

for k = 1:length(subFolders)
    CV_master_accuracy_columns{k} = subFolders(k).name;
end

for i1 = 1:3
    for i2 = 1:2
        for i3 = 1:2
            index = 4*(i1-1) + 2*(i2-1) + (i3-1) + 1;
            CV_master_accuracy_rows{index,1} = [CV_file_component_names{1,i1} '_' ...
                       CV_file_component_names{2,i2} '_' CV_file_component_names{3,i3}];
        end
    end
end


for k = 1:length(subFolders)
    % Get files
    foldername = subFolders(k).name;
    disp(['Processing accuracy for all files for dataset ' foldername])

    files = dir([UCR_RESULTS_PATH foldername '/']);

    % Get rid of '.' and '..' folders
    get_rid_of_folder = false(size(files));
    for j = 1:length(files)
        if (files(j).name == '.')
            get_rid_of_folder(j) = 1;
        end
    end
    files(get_rid_of_folder) = [];
    
    
    
    % Specify type of file
    for i1 = 1:3
        for i2 = 1:2
            for i3 = 1:2
                FILE_NAME_REGEXP = [foldername '_' CV_file_component_names{1,i1} '_' ...
                       CV_file_component_names{2,i2} '_' CV_file_component_names{3,i3} '.*' ... 
                       '_acc.txt'];

                % Find all file indexes matching specified type
                match_indexes = [];
                for j = 1:length(files)
                    if (regexp(files(j).name, FILE_NAME_REGEXP))
                        match_indexes = [match_indexes; j];
                    end

                end
                
                % Extract accuracies for each file
                accuracies = zeros(size(match_indexes));
                for j = 1:size(match_indexes)
                    accuracy = Extract_Accuracy_func([UCR_RESULTS_PATH foldername '/' files(match_indexes(j)).name]);
                    accuracies(j) = accuracy{1}; % Assume only 1 accuracy in each file
                end
                
                avg_accuracy = mean(accuracies);
                
                % Calculate index into master table
                master_row_index = 4*(i1-1) + 2*(i2-1) + (i3-1) + 1;
                CV_master_accuracy_table(master_row_index, k) = avg_accuracy;
                
            end
        end
    end
    
end

% Remove rows 9 and 10 (nothing here, since normalization doesn't 
% matter for Pearson's correlation).

CV_master_accuracy_rows(9:10) = [];
CV_master_accuracy_table(9:10,:) = [];

invalid_entries = isnan(CV_master_accuracy_table);
CV_incomplete_datasets = any(invalid_entries,1);

save('Ben_UCR_CV_Results.mat', 'CV_master_accuracy_table', 'CV_file_component_names', ...
    'CV_master_accuracy_columns', 'CV_master_accuracy_rows', 'CV_incomplete_datasets');