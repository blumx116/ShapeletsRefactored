function [ACCURACIES] = Extract_Accuracy_func(FILENAME)
% EXTRACT_ACCURACY_FUNC Extracts the accuracy from a tree.txt file produced
% by Classify.exe from FastShapelets code
%   Inputs
%   - FILENAME:  Filename (including path) of the Fast Shapelets tree file.
%   Outputs
%   - ACCURACY:  The accuracy from the classification.

FILE_TEXT = fileread(FILENAME);

ACCURACY_EXPR = 'accuracy= [\d.]* ';
ACCURACY_TEXT = regexp(FILE_TEXT, ACCURACY_EXPR, 'match');

ACCURACY_STRING = regexp(ACCURACY_TEXT, '[\d.]+', 'match');
for i = 1:size(ACCURACY_STRING,2)
    % Extract all accuracies in the tree.txt file (there may be multiple if
    % multiple classify commands were run).
    ACCURACIES{i} = str2double(ACCURACY_STRING{i});
end

end

