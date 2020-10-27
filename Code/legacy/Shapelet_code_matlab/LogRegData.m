addpath('Shapelet_code_matlab/LogRegUtils');

TREES_PATH = 'Shapelet_Datasets/Trees/';
DATASET_PATH = 'Shapelet_Datasets/UCR_Master/';
OUTPUT_FILE = 'output.csv';

fid = fopen(OUTPUT_FILE, 'w');
fprintf(fid, "Name,,Base Accuracy (Train),LR Accuracy (Train),Base Accuracy (Test),LR Accuracy (Test)\n");
tree_files = dir([TREES_PATH '*.txt']);

dataset_files = dir(DATASET_PATH);

for tree_index = 1:size(tree_files)
    tree_file = tree_files(tree_index).name
    dataset_name = tree_file(1:strfind(tree_file, '_')-1);
    
    train_file = [pwd '/' DATASET_PATH dataset_name '_TRAIN'];
    test_file = [pwd '/' DATASET_PATH dataset_name '_TEST'];
    
    DATASET_PATH
    dataset_name
    [TREES_PATH tree_file]
    
    if exist(train_file, 'file') && exist(test_file, 'file')
        try
            [bAccuracyTrain, lrAccuracyTrain, bAccuracyTest, lrAccuracyTest] ... 
                = LogRegTest(...
                'DATASET_PATH', DATASET_PATH, ...
                'DATASET_NAME', dataset_name, ...
                'TREE_FILE', [TREES_PATH tree_file], ...
                'PCA_FLAG', 0);

            fprintf(fid, '%s,%d,%d,%d,%d\n', ...
                tree_file, ...
                bAccuracyTrain, ...
                lrAccuracyTrain, ...
                bAccuracyTest, ...
                lrAccuracyTest);
        catch ME
            fprintf(fid, '%s, => ERROR');
        end
    else
        fprintf(fid, '%s, => associated data files could not be found\n');
    end
end
    
fclose(fid);