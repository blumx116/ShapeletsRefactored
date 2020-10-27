clearvars;

% Data location
DATASET_PATH = './Shapelet_Datasets/UCR_Master/';

% Location of destination file (folder must already be created...)
CV_DESTINATION_FOLDER = 'Shapelet_Datasets/CV_DATA/';

% Get names of all training files (with datapath included)
FILE_FILTER = 'w*_TRAIN';
ALL_TRAINING_FILENAMES = getAllFiles(DATASET_PATH, FILE_FILTER);

% Loop through filenames found
for i = 1:size(ALL_TRAINING_FILENAMES,2)
    [~,DATASET_NAME,~] = fileparts(ALL_TRAINING_FILENAMES{i});
    
    disp(['Creating cross-validated sets for dataset ' DATASET_NAME])
    
    % Load data, generate cross-validation sets
    DATA = load([DATASET_PATH DATASET_NAME]);
    
    Cross_validation_sets = Generate_Cross_Validation_Sets_2_func([DATA]);    
    CV_DATA_1 = DATA(Cross_validation_sets{1},:);
    CV_DATA_2 = DATA(Cross_validation_sets{2},:);

    % Write to new files
    dlmwrite([CV_DESTINATION_FOLDER DATASET_NAME '_CV1'], ...
        CV_DATA_1, 'delimiter', ' ');
    dlmwrite([CV_DESTINATION_FOLDER DATASET_NAME '_CV2'], ...
        CV_DATA_2, 'delimiter', ' ');
end