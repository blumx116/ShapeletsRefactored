function [CLASSIFY_COMMAND_OUTPUT] = FastShapelets_Classify_Wrapper_func(...
                          FAST_SHAPELETS_DATAPATH, ... 
                          TEST_FILENAME, ...
                          MAX_SHAPELET_LENGTH, MIN_SHAPELET_LENGTH, ... 
                          STEP_SIZE, DISTANCE_METRIC, CID_FLAG, ...
                          NORMALIZATION_FLAG, TREE_FILE)

                      
% FASTSHAPELETS_CLASSIFY_WRAPPER_FUNC Calls the Classify.exe C++ code.
%   Inputs:  
%   - FAST_SHAPELETS_DATAPATH:  Directory containing the fast shapelets c
%   code
%   - TEST_FILENAME:  Filename (with path) of the test file (must
%   be a matrix)
%
%   - Remaining inputs match the arguments for the C++ code
%   (Documented in the readme.md file)
%
%   Outputs
%   - CLASSIFY_COMMAND_OUTPUT:  Command line output from running shapelet
%   discovery (FastShapelet.exe)





% Step 2:  Classify on test data
TEST_DATA = load(TEST_FILENAME);
NUM_TESTING_CLASSES = size(unique(TEST_DATA(:,1)),1);
NUM_TESTING_ROWS= size(TEST_DATA,1);

classify_command = ['"' FAST_SHAPELETS_DATAPATH ...
    './Classify" ' ...
    '"' TEST_FILENAME '" ' ...
    num2str(NUM_TESTING_CLASSES) ' ' ...
    num2str(NUM_TESTING_ROWS)];

disp(['Classifying for test file ' TEST_FILENAME '...'])
[status, CLASSIFY_COMMAND_OUTPUT] = system(classify_command);
disp(['Done classifying for test file ' TEST_FILENAME])





end

