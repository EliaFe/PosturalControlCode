function [leg_retraction_frame, leg_retraction_success, figure_leg_retraction] = legRetraction(varargin)
%[leg_retraction_frame] = legRetraction(config, mouse, 'mouse_type', 'random', 'process_type', 's', 'fall_platform_frame', 0, plot_bool, 'false', 'p_value', 0.3)

switch nargin
    case 0
        config = defaultConfig();
        [all_table, labels, numbers, file_name, path_name]=importDlcFile();
        [mouse] = dlcSmooth(config, file_name, path_name, 'leg');
    case 1
        [all_table, labels, numbers, file_name, path_name]=importDlcFile();
        [mouse] = dlcSmooth(config, file_name, path_name, 'leg');
    otherwise
        if isa(varargin{1}, 'struct')
            config = varargin{1};
        else
            error('First entry must be the config structure.');
        end
        if isa(varargin{2}, 'struct')
            mouse = varargin{2};
        else
            error('Second entry must be the structure describing the mouse, see function dlcSmooth.');
        end
end

mouse_type = 'random';
process_type = 's';
plot_bool = 'false';
p_value = config.p_value;
min_time_reaction = config.min_time_reaction;
falling_platform_frame = 0;
stage_figure = 'false';
figure_leg_retraction = [];
leg_retraction_success = [];
leg_retraction_frame = [];
criteria = 'right_mirror';
dlc_model = config.dlc_model;

for i = 3:2:nargin
   if strcmp(varargin{i}, 'mouse_type')
       mouse_type = varargin{i+1};
   elseif strcmp(varargin{i}, 'process_type')
       process_type = varargin{i+1};
   elseif strcmp(varargin{i}, 'falling_platform_frame')
       falling_platform_frame = varargin{i+1};
   elseif strcmp(varargin{i}, 'plot_bool')
       plot_bool = varargin{i+1};
   elseif strcmp(varargin{i}, 'stage_figure')
       stage_figure = varargin{i+1};
   elseif strcmp(varargin{i}, 'criteria')
       criteria = varargin{i+1};
   end
end

if falling_platform_frame == 0
    falling_platform_frame = fallingPlatform(config, mouse);
end

if strcmp(falling_platform_frame, 'true')
    falling_platform_frame = fallingPlatform(config, mouse);
end

if strcmp(plot_bool, 'false')
    figure_leg_retraction = [];
end

if strcmp(dlc_model, 'Long_drop_full')
    criteria = 'back';
else
    criteria = 'right_mirror';
end

if strcmp(criteria, 'right_mirror')
    acc_leg = mouse.leg.right_mirror.y.dd;
elseif strcmp(criteria, 'back')
    acc_leg = mouse.leg.back.y.dd;
else
    disp('Criteria not found, right_mirror taken in account')
end

if strcmp(mouse_type, 'WT') || strcmp(mouse_type, 'random')
    nb = length(acc_leg);
    x = linspace(1,nb,nb);
    % Find the max of acceleration
    [acc_value,temp_leg_retraction_frame] = findpeaks(acc_leg,x,'SortStr','descend');
    for k = 1:length(acc_value)
        % max of acceleration must be after a timing of reaction defined in
        % the config file
        if temp_leg_retraction_frame(k) < falling_platform_frame + min_time_reaction
            acc_value(k) = 0;
            temp_leg_retraction_frame(k) = 0;
        end
        % acceleration must be higher than 1
        if acc_value(k) < 1
            acc_value(k) = 0;
            temp_leg_retraction_frame(k) = 0;
        end
    end
    % Take the first value that correspond to these criterias
    [~,~,temp_leg_retraction_frame] = find(temp_leg_retraction_frame,1);
    
    if isempty(temp_leg_retraction_frame)
        leg_retraction_frame = mouse.frames-config.min_time_reaction;
        leg_retraction_success = "false";
    else
        leg_retraction_frame = temp_leg_retraction_frame(1)+1;
        leg_retraction_success = "true";
    end
    
elseif strcmp(mouse_type, 'PV')

elseif strcmp(mouse_type, 'FT')
    joint = 'mtp';

    joint_timing = mouse.right.(joint).y.dds;
    [~, leg_retraction_frameU] = maxk(joint_timing, 10);

    shift = 5;
    for j =1:10
        max_joint(j) = leg_retraction_frameU(1);
        for i = leg_retraction_frameU-shift:leg_retraction_frameU+shift
            if i <1
                joint_timing(1) = 0;
            else
                joint_timing(i) = 0;
            end
            [~, leg_retraction_frameU] = max(joint_timing);
        end
    end

    for j=1:10
        if max_joint(j)+4 > size(mouse.right.(joint).y.(process_type))
            max_joint(j)=0;
        elseif not(mouse.right.(joint).y.(process_type)(max_joint(j)+4)-mouse.right.(joint).y.(process_type)(max_joint(j)) > 15)
            max_joint(j) = 0;
        end
        if not(max_joint(j) == 0) && max_joint(j) > falling_platform_frame + 30
            max_joint(j) = 0;
        end
    end

    if max_joint(1) == 0
        leg_retraction_frame = max_joint(2);
        if max_joint(2) == 0
            leg_retraction_frame = max_joint(3);
            if max_joint(3) == 0
                leg_retraction_frame = max_joint(4);
            end
        end
    else
        leg_retraction_frame = max_joint(1);
    end

    for i =1:10
        if not(max_joint(i)==0)
            if mouse.right.(joint).y.dd(leg_retraction_frame) < mouse.right.(joint).y.dd(max_joint(i)) 
                leg_retraction_frame = max_joint(i);
            end
        end
    end
    leg_retraction_frame = leg_retraction_frame+1;
else
    error('Unknown mouse type entered')
end

if strcmp(plot_bool, 'true')
   process_type_temp = {'s', 'ds', 'dds'};
   figure_leg_retraction.figure_leg_only = dlcAnatomyPlot(config, mouse, process_type_temp, 'leg_retr_mirror');    
   set(gcf, 'Position',  [-10           1        1612         954])
%    figures.figure_leg = dlcAnatomyPlot(config, mouse, process_type_temp, 'leg');
%    set(gcf, 'Position', [   463     1   668   830]);
end

if strcmp(stage_figure, 'true')
   process_type_temp = "s";
   %figures.figure_leg = dlcAnatomyPlot(config, mouse, process_type_temp, 'leg', leg_retraction_frame);
   figure_leg_retraction.figure_stage = dlcAnatomyPlot(config, mouse, process_type_temp, 'leg_only_right_mirror');    
   set(gcf, 'Position', [   463     1   668   484]);
end

end

