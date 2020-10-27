function [SHAPELET_COMMAND_OUTPUT] = FastShapelets(data_file, varargin)

% FastShapelets Calls the FastShapelets exe code
% see ShapeletResearch/FastShapelets.cpp for more documentation
%
% Inputs:
%  - data_file: The relative path to the data 
%  - output_file: The relative path to write the output decision tree in
%  - varargin : additional keyword arguments, supplied like so
%  FastShapelets('filename', 'filename', 'cid_flag', 1, 'step_size', 2)
%
%  Keyword Arguments=default:
%  - max_shapelet_length=20: maximum length of shapelets generated
%  - min_shapelet_length=5: minimum length of shapelets generated
%  - step_size=1: step_size for window when generating shapelets
%  - distance_metric='euclidean': distance metric
%  - cid_flag=1: flag to use complexity invariant distance
%  - normalization_flag=1: flag to use normalization
%  - sax_k_amount=1: k for the number of sax letters generated
%  - R : what does R do????


%% Define the default arguments in a struct
options = struct(...
    'max_shapelet_length', 20, ...
    'min_shapelet_length', 5, ...
    'step_size', 1, ...
    'distance_metric', 'euclidean', ...
    'cid_flag', 1, ...
    'normalization_flag', 1, ...
    'sax_k_amount', 10, ...
    'R', 10, ...
    'output_file', 'tree.txt');

optionNames = fieldnames(options);

%% Require arguments in key-value pair form
if mod(length(varargin), 2) ~= 0
    error("Must have key-value pairs for inputs")
end

%% Match all keyword arguments as required
for pair = reshape(varargin, 2, [])
    inputName = lower(pair{1});
    
    if any(strcmp(inputName, optionNames))
        options.(inputName) = pair{2};
    else
        error('%s is not a valid parameter name', inputName)
    end
end

%% Infer the size & number of classes in the training set
training_data = load(data_file);
options.class_amount = size(unique(training_data(:, 1)), 1);
options.sample_amount = size(training_data, 1);

%% Compile the appropriate command line argument for running
shapelet_command = ['"./ShapeletResearch/Execs/FastShapelet" ' ...
    '"' data_file '" ' ...
    num2str(options.class_amount) ' ' ...
    num2str(options.sample_amount) ' ' ...
    num2str(options.max_shapelet_length) ' ' ...
    num2str(options.min_shapelet_length) ' ' ...
    num2str(options.step_size) ' ' ...
    num2str(options.R) ' ' ...
    options.distance_metric ' ' ...
    num2str(options.cid_flag) ' ' ...
    num2str(options.normalization_flag) ' ' ...
    num2str(options.sax_k_amount) ' ' ...
    options.output_file];

%% Execute FastShapelets command
disp(['Extracting shapelets for training file ' data_file '...'])
[status, SHAPELET_COMMAND_OUTPUT] = system(shapelet_command);
disp(['Done extracting shapelets for training file ' data_file])

if status == 1
    SHAPELET_COMMAND_OUTPUT
    error("Shapelet code failed, output above")
end 

end