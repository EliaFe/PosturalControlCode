function [leg_acc, leg_speed] = featuresAtRetraction(varargin)
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here

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

plot_bool = 'false';
p_value = config.p_value;
falling_platform_frame = 0;
leg_retraction_frame = 0;
leg_on_platform_frame = 0;
figure_leg_acc = [];

for i = 3:2:nargin
   if strcmp(varargin{i}, 'falling_platform_frame')
       falling_platform_frame = varargin{i+1};
   elseif strcmp(varargin{i}, 'leg_retraction_frame')
       leg_retraction_frame = varargin{i+1};
   elseif strcmp(varargin{i}, 'leg_on_platform_frame')
       leg_on_platform_frame = varargin{i+1};
   elseif strcmp(varargin{i}, 'plot_bool')
       plot_bool = varargin{i+1};
   end
end


if falling_platform_frame == 0
    falling_platform_frame = fallingPlatform(config, mouse);
end

if strcmp(falling_platform_frame, 'true')
    falling_platform_frame = fallingPlatform(config, mouse);
end

if leg_retraction_frame == 0
    [leg_retraction_frame, leg_retraction_success,~] = legRetraction(config, mouse, 'falling_platform_frame', falling_platform_frame);
end

if strcmp(leg_retraction_frame, 'true')
    [leg_retraction_frame, leg_retraction_success,~] = legRetraction(config, mouse, 'falling_platform_frame', falling_platform_frame);
end

if leg_on_platform_frame == 0
    [leg_on_platform_frame, leg_on_platform_success, ~] = legOnPlatform(config, mouse, 'falling_platform_frame', falling_platform_frame);
end

if strcmp(leg_on_platform_frame, 'true')
    [leg_on_platform_frame, leg_on_platform_success, ~] = legOnPlatform(config, mouse, 'falling_platform_frame', falling_platform_frame);
end

if strcmp(leg_retraction_success, 'true')
    leg_on_platform_frame
    mouse.frames
    leg_acc.peak  = max(mouse.leg.right_mirror.y.dds(falling_platform_frame:leg_on_platform_frame));
    leg_speed.peak  = max(mouse.leg.right_mirror.y.ds(falling_platform_frame:leg_on_platform_frame));
    
    % Mean of only positive accelerations values
    idx_positive_acc = mouse.leg.right_mirror.y.dds(leg_retraction_frame:leg_on_platform_frame) > 0;
    value_acc = mouse.leg.right_mirror.y.dds(leg_retraction_frame:leg_on_platform_frame);
    value_positive_acc = idx_positive_acc.*value_acc;
    only_positive_acc = [];
    
    for j = 1:length(value_positive_acc)
        if not(value_positive_acc(j) == 0)
            only_positive_acc = [only_positive_acc, value_positive_acc(j)];
        end
    end
    
    % Mean of only positive speed values
    idx_positive_speed = mouse.leg.right_mirror.y.ds(leg_retraction_frame:leg_on_platform_frame) > 0;
    value_speed = mouse.leg.right_mirror.y.ds(leg_retraction_frame:leg_on_platform_frame);
    value_positive_speed = idx_positive_speed.*value_speed;
    only_positive_speed = [];
    
    for j = 1:length(value_positive_speed)
        if not(value_positive_speed(j) == 0)
            only_positive_speed = [only_positive_speed, value_positive_speed(j)];
        end
    end
    
    leg_acc.mean  = mean(only_positive_acc);
    leg_speed.mean  = mean(only_positive_speed);
else
    disp('No leg retraction');
    peak_leg_acc  = 0;
    peak_leg_speed  = 0;
    mean_leg_acc  = 0;
    mean_leg_speed  = 0;
end

[~, mean_midline_movement] = midlineMov(config, mouse);


end