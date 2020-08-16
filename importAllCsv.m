function [mice] = importAllCsv(path)
%[mices] = importAllCsv(path)
%Import all files whose name finish with "filtered.csv" in a folder,
%specified by the path, 

%Take all files whose name finish with "filtered.csv" in a folder,
%specified by the path
files = dir(fullfile(path, '*filtered.csv'));

% Create a structure variable "mice" for each file
for i =1:length(files)
     [mice(i)] = dlcSmooth(files(i).name, path);
end

end

