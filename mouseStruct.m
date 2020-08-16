function [mouse] = mouseStruct(config, mouse, labels, values, part_struct, part_csv, joint_struct, joint_csv, coord_struct, coord_csv, smooth_value)
% Function to construct the structure associated with the mouse
%=> the different anatomy/env parts and their processing types

if nargin < 11
    smooth_value = config.smooth_value;
end

for i = 1:length(part_struct)
    for j = 1:length(joint_struct)
        for k = 1:length(coord_struct)
            if strcmp(coord_csv(k), 'y')
                mouse.(part_struct(i)).(joint_struct(j)).(coord_struct(k)).r = -values(:, findLabel(labels, part_csv(i), joint_csv(j), coord_csv(k)));
            else
                mouse.(part_struct(i)).(joint_struct(j)).(coord_struct(k)).r = values(:, findLabel(labels, part_csv(i), joint_csv(j), coord_csv(k)));
            end
        end
        if strcmp(part_struct, 'env')
            mouse.(part_struct(i)).(joint_struct(j)) = processFunction(config, mouse.(part_struct(i)).(joint_struct(j)), smooth_value, 'env');
        else
            mouse.(part_struct(i)).(joint_struct(j)) = processFunction(config, mouse.(part_struct(i)).(joint_struct(j)), smooth_value);
        end
    end
end

end

