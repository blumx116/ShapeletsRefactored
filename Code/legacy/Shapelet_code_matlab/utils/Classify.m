function [CLASSIFY_COMMAND_OUTPUT] = Classify(data_file, varargin)

%% Define the default arguments in a struct
options = struct(...
    'distance_metric', 'euclidean', ...
    'cid_flag', 1, ...
    'normalization_flag', 1, ...
    'tree_file', 'tree.txt', ...
    'time_file', 'time.txt');

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
classify_command = ['"../ShapeletResearch/Execs/Classify" ' ...
    '"' data_file '" ' ...
    num2str(options.class_amount) ' '...
    num2str(options.sample_amount) ' ' ...
    options.distance_metric ' ' ...
    num2str(options.cid_flag) ' ' ...
    num2str(options.normalization_flag) ' ' ...
    options.tree_file ' ' ...
    options.time_file];

%% Ececute Classify command
disp(['classifying testing file ' data_file '...'])
[status, CLASSIFY_COMMAND_OUTPUT] = system(classify_command);
disp(['Done classifying testing file ' data_file])


if status == 1
    CLASSIFY_COMMAND_OUTPUT
    error("Shapelet code failed, output above")
end 

end