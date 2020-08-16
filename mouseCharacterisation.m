function [mouse, figures] = mouseCharacterisation(varargin)
%UNTITLED9 Summary of this function goes here
%   Detailed explanation goes here

switch nargin
    case 0
        config = defaultConfig();
        [all_table, labels, numbers, file_name, path_name]=importDlcFile();
        [mouse] = dlcSmooth(config, file_name, path_name);
    case 1
        [all_table, labels, numbers, file_name, path_name]=importDlcFile();
        [mouse] = dlcSmooth(config, file_name, path_name);
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
stage_figure = 'false';
free_fall_bool = 'false';
figures = [];

for i = 3:2:nargin
   if strcmp(varargin{i}, 'plot_bool')
       plot_bool = varargin{i+1};
   elseif strcmp(varargin{i}, 'stage_figure')
       stage_figure = varargin{i+1};
   elseif strcmp(varargin{i}, 'free_fall_bool')
       free_fall_bool = varargin{i+1};
   end
end

mouse.charact.mouse_name = mouse.name;

[mouse.charact.falling_platform_frame, mouse.charact.stopping_platform_frame] = fallingPlatform(config, mouse);
[mouse.charact.leg_retraction_frame, mouse.charact.leg_retraction_success, figures.figure_leg_retraction] = legRetraction(config, mouse, 'plot_bool', plot_bool, 'stage_figure', stage_figure);
[mouse.charact.platform_speed, figures.figure_platform] = platformSpeed(config, mouse, mouse.charact.falling_platform_frame, mouse.charact.stopping_platform_frame, plot_bool);
mouse.charact.classified_speed = platformSpeedClassifier(mouse.charact.platform_speed, free_fall_bool);
[mouse.charact.reaction_delay_frame, mouse.charact.reaction_delay_ms] = reactionDelay(config, mouse.charact.falling_platform_frame, mouse.charact.leg_retraction_frame);
[~, ~, ~, ~, mouse.charact.leg_extension] = legExtension(config, mouse, mouse.charact.falling_platform_frame, mouse.charact.leg_retraction_frame);
[mouse.charact.fall_at_retraction] = getFallAtRetraction(config, mouse, mouse.charact.falling_platform_frame, mouse.charact.leg_retraction_frame);
[mouse.charact.leg_on_platform_frame, mouse.charact.leg_on_platform_success, figures.figure_leg_on_platform] = legOnPlatform(config, mouse, 'plot_bool', plot_bool, 'stage_figure', stage_figure, 'criteria', 'right_mirror');
[leg_acc, leg_speed] = featuresAtRetraction(config, mouse);
mouse.charact.leg_acc_peak = leg_acc.peak;
mouse.charact.leg_acc_mean = leg_acc.mean;
mouse.charact.leg_speed_peak = leg_speed.peak;
mouse.charact.leg_speed_mean = leg_speed.mean;

[midline_displacement, pivot_midline, ~, figures.midline_mov] = midlineMov(config, mouse, 'plot_bool', plot_bool, 'stage_figure', stage_figure);
mouse.charact.midline_displacement_max_right = midline_displacement.max_right;
mouse.charact.midline_displacement_max_left = midline_displacement.max_left;
mouse.charact.pivot_midline_clock = pivot_midline.clock;
mouse.charact.pivot_midline_nclock = pivot_midline.nclock;

end

