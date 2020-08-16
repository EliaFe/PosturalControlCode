 function [Index] = findLabel(labels, label1, label2, label3)
% [val3] = findLabel(labels, label1, label2, label3)
% [val3] = findLabel(labels, label1, label2)
%
% INTPUT: all input must be in lowercase
% "labels": array of label, ideally output of "importDlcFile"
% "labelx": wanted labels, label3 optional
%
% OUTPUT:
% "Index": the column number for which these labels corresponds
%
% Function to find the column number of the wanted label and coordinates (x,
% y or p) in an array of DLC output labels

switch nargin
    case {0,1,2}
        error('Not enough input arguments.');
    case 3
        %concat_label is the concatenated string of the inputs (without the
        %spaces)
        concat_label = strrep(strcat(label1, label2),' ','');
        concat_label2 = strrep(strcat(label2, label1),' ','');
        %full_label is the label to display in case of an error
        full_label = strcat(' "', label1, '" "', label2, '" ');
    case 4
        concat_label = strrep(strcat(label1, label2, label3),' ','');
        concat_label2 = strrep(strcat(label2, label1, label3),' ','');
        full_label = strcat(' "', label1, '" "', label2, '" "', label3, '" ');
end
%concat is the concatenated string of the labels given in the "labels"
%table
concat = strrep(strcat(labels(2,:), labels(3,:)),' ','');
%give the column index for which "concat_label" and "concat" correspond
%(while ignoring the lower or upper case)
Index = find(strcmpi(concat, concat_label));

if isempty(Index)
    Index = find(strcmpi(concat, concat_label2));
    if isempty(Index)
        msg = 'Sry, the label %s has not been found.';
        msg=sprintf(msg, full_label);
        error(msg);
    end
end

end

