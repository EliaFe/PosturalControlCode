function [midline_displacement] = pivot(varargin)
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
initial
midline_displacement



end

