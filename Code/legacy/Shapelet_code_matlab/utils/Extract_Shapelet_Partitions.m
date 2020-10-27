function [left_partition, right_partition] = Extract_Shapelet_Partitions(STRING_PARTITION)
%EXTRACT_SHAPELET_PARTITIONS This will take the string section of the
%tree.txt file that has partitions for a given shapelet and extract them
%from the string.
%   Input Arguments
%   - STRING_PARTITION:  The string that has the partition (should look
%   something like "==>   6   0   1   0   4  /   0   6   5   6   2 ?"
%
%   Output Arguments
%   - left_partition:  The partition that results from samples within the
%   specified distance of the shapelet.
%   - right_partition: The partition that results from samples farther than
%   the specific distance from the shapelet.

% Split partitions
partitions = split(STRING_PARTITION, '/');

% If the number of partitions is not 2, the string was not parsed correctly.
% Throw error and stop the function
if (size(partitions,1) ~=2)
   disp('Array is the wrong size') 
end

% Strip everything except digits and white space for the 2 partitions
my_regex = '[\d\s]*';

left_partition_string = regexp(partitions{1}, my_regex, 'match');
right_partition_string = regexp(partitions{2}, my_regex, 'match');

% Convert to numbers
left_partition = str2double(split(left_partition_string));
right_partition = str2double(split(right_partition_string));

% Remove 'NaN' entries (caused by empty strings)
left_partition(isnan(left_partition)) = [];
right_partition(isnan(right_partition)) = [];

end

