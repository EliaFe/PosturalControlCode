function [export_name, matlab_file, path] = saveDlcFile(import_name, export_name, path_name)
%[export_name, matlab_file, path] = saveDlcFile(import_name, export_name, path_name)
%[export_name, matlab_file, path] = saveDlcFile(import_name)
%
%Import and save the file 'import_name'.csv from DLC with the name
%'export_name' into a .mat format file
%
% INPUT: 
% "import_name": name of the file to import
% "export_name": name of the file to export, if none, it will be exported
%   with the 'import_name'.mat
% "path_name": path to the file if not in the same folder as matlab code
%
% OUTPUT: 
% "export_name"
% "matlab_file": matlab file composed of the complete table, labels (first 3 rows), values (from raw 3 till
%   the end of the file), ! First column is the time frame
% "path": path to the matlab file created
%
switch nargin
    case 0
        [all_table, labels, values, import_name, path] = importDlcFile();
        export_name = import_name;
        if length(import_name)>2
            if import_name(end-3:end)=='.csv'
                export_name = import_name(1:end-4);
            end
        end
        export_name = strcat(export_name,'.mat');
        save(string(export_name), 'all_table', 'labels', 'values');
        matlab_file = matfile(export_name);
    case 1
        export_name = import_name;
        path_name = [];
        if length(import_name)>2
            if import_name(end-3:end)=='.csv'
                export_name = import_name(1:end-4);
            end
        end
        [all_table, labels, values] = importDlcFile(import_name, path_name);
        export_name = strcat(export_name,'.mat');
        save(string(export_name), 'all_table', 'labels', 'values');
        matlab_file = matfile(export_name); 
end
% Don't work if placed here, don't know why (probably due to the switch

% export_name = strcat(export_name,'.mat');
% save(string(export_name), 'all_table', 'labels', 'values');
% matlab_file = matfile(export_name);
end

