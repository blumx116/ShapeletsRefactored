function [SHAPELET_IDS, SHAPELETS] = Extract_Shapelet_From_Results_File_func(FILENAME)
%UNTITLED Extracts the shapelets from the tree results file from Fast
%Shapelet c code.  
%   Inputs
%   - FILENAME:  Filename (including path) of the Fast Shapelets tree file.
%   Outputs
%   - SHAPELET_IDS:  IDs of each of the shapelets (array)
%   - SHAPELETS:  Data points of each shapelet (saved as cell array due to
%   differing sizes).

% Example function call:
%  [SHAPELET_IDS, SHAPELETS] = Extract_Shapelet_From_Results_File_func('.\Results\TREE_PMU_TableIII_V.txt');

%clearvars;

% Open the file
%FILENAME = '.\Results\TREE_PMU_TableIII_V.txt';
fid = fopen(FILENAME);

num_shapelets = 0;

tline = fgetl(fid); % Get the 1st line of the file
while ischar(tline)
    % Look to see if the line contains the shapelet points (it will start
    % with with word 'Shapelet')
    if (size(tline,2) >= 8) % Has to be at least 8 characters to contain 'Shapelet', avoids out of bounds exception in if conditional below
        if (strcmp('Shapelet', tline(1:8)))
            % Shapelet found!
            num_shapelets = num_shapelets + 1;
            shapelet_tline{num_shapelets} = tline;
            %disp(['Found shapelet line:  ' tline])
        end
    end
    
    tline = fgetl(fid); % Get the next line of the file
end

fclose(fid); % Close file

% Now go through the shapelet text line and extract the shapelet data
% points
for i = 1:num_shapelets
    shapelet_tline{i}(1:8) = []; % Remove 'Shapelet' word

    SHAPELETS{i} = str2num(shapelet_tline{i});
    
    % Save shapelet ID and data points (ID is the 1st number)
    SHAPELET_IDS(i) = SHAPELETS{i}(1); 
    SHAPELETS{i} = SHAPELETS{i}(2:end); 
end






end

