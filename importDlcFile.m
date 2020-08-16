function [all_table, labels, numbers, file_name, path_name] = importDlcFile(file_name, path_name)
%[all_table, labels, numbers, file_name, path_name] = importDlcFile(file_name, path_name)
%[all_table, labels, numbers, file_name, path_name] = importDlcFile(file_name)
%
% Import data from csv files and saves into .mat format
%
% INPUT: 
% "file_name": complete file name, .csv
% "path_name": if the file is not in same folder as the matlab code, the
%   path in needed
%
% OUTPUT: 
% "all_table": complete table (labels and values)
% "labels": labels (first 3 rows; DLC model used, label, coordinate)
% "numbers": values (from raw 3 till end of file)
% "file_name" and "path_name"
%
% ! First column is the time frame

switch nargin
    case 0
        %ask to pick the folder and take all .csv files to create a structure with 
        %each fields beeing a video ref => first element is the name
        [file_name, path_name] = uigetfile('*.csv');
    case 1
        path_name = cd;
        disp('importDlcFile function: Carefull, no path_name as been entered');
end

currentPath = cd;

cd(path_name);
fid = fopen(file_name);
myline = fgetl(fid);
i=1;
while ischar(myline)
    C(i,:) = strsplit(myline,',');
    % C now contains a cell array for each line
    myline = fgetl(fid);
    i  = i+1;
end
fclose(fid);
all_table = C;
labels = lower(C(1:3,:)); %everything in lower case
numbers = str2double(C(4:end, :));

cd (currentPath);
end