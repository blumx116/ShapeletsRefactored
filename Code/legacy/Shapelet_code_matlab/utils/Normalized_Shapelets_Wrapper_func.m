function [SHAPELET_COMMAND_OUTPUT, CLASSIFY_COMMAND_OUTPUT] = ...
    Normalized_Shapelets_Wrapper_func(FAST_SHAPELETS_DATAPATH, TRAINING_FILENAME,...
    TESTING_FILENAME, MAX_SHAPELET_LENGTH, MIN_SHAPELET_LENGTH, STEP_SIZE)
%FAST_SHAPELETS_WRAPPER_FUNC Calls the FastShapelet c code.
%   Inputs
%   - FAST_SHAPELETS_DATAPATH:  Directory containing the fast shapelets c
%   code
%   - TRAINING_FILENAME:  Filename (with path) of the training file (must
%   be a matrix)
%   - TESTING_FILENAME:  Filename (with path) of the testing file (must
%   also be a matrix)
%   - MAX_SHAPELET_LENGTH:  Maximum allowed length of discovered shapelets
%   - MIN_SHAPELET_LENGTH:  Minimum allowed length of discovered shapelets
%   - STEP_SIZE:  Step size between shapelet lengths
%
%   Outputs
%   - SHAPELET_DECISION_TREE:  Decision tree including the shapelets,
%   distances, and classification results
%   - SHAPELET_COMMAND_OUTPUT:  Output from running shapelet
%   discovery (FastShapelet.exe)
%   - CLASSIFY_COMMAND_OUTPUT:  Output from running shapelet classification

% Step 1:  Find shapelets and build shapelet decision tree
TRAINING_DATA = load(TRAINING_FILENAME);
NUM_TRAINING_ROWS= size(TRAINING_DATA,1);
NUM_TRAINING_CLASSES = size(unique(TRAINING_DATA(:,1)),1);

shapelet_command = ['"' FAST_SHAPELETS_DATAPATH ...
    './FastShapelet_Normalized" ' ...
    '"' TRAINING_FILENAME '" ' ...
    num2str(NUM_TRAINING_CLASSES) ' ' ...
    num2str(NUM_TRAINING_ROWS) ' ' ...
    num2str(MAX_SHAPELET_LENGTH) ' ' ...
    num2str(MIN_SHAPELET_LENGTH) ' ' ...
    num2str(STEP_SIZE)];

disp(['Extracting shapelets for training file ' TRAINING_FILENAME '...'])
[status, SHAPELET_COMMAND_OUTPUT] = system(shapelet_command);
disp(['Done extracting shapelets for training file ' TRAINING_FILENAME])

% Step 2:  Classify on test data
TESTING_DATA = load(TESTING_FILENAME);
NUM_TESTING_CLASSES = size(unique(TESTING_DATA(:,1)),1);
NUM_TESTING_ROWS= size(TESTING_DATA,1);

classify_command = ['"' FAST_SHAPELETS_DATAPATH ...
    './Classify_Normalized" ' ...
    '"' TESTING_FILENAME '" ' ...
    num2str(NUM_TESTING_CLASSES) ' ' ...
    num2str(NUM_TESTING_ROWS)];

disp(['Classifying for test file ' TESTING_FILENAME '...'])
[status, CLASSIFY_COMMAND_OUTPUT] = system(classify_command);
disp(['Done classifying for test file ' TESTING_FILENAME])

end

