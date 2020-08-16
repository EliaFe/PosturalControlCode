function [falling_platform_frame, stopping_platform_frame] = fallingPlatform(config, mouse, threshold, a_threshold)
% [falling_platform_frame, stopping_platform_frame] = fallingPlatform(config, mouse, threshold, a_threshold)
% [falling_platform_frame, stopping_platform_frame] = fallingPlatform(config, mouse, -0.4, -0.2)
% Fonction to detect falling platform frame event.
%
% INPUT:
% "config" : structure describing the basic info of data we are handling
% "mouse": strcuture defining the mouse
% "threshold" : speed threshold criteria
% "a_threshold" : acceleration threshold criteria
%
% OUTPUT:
% "falling_frame": frame for which the criteria is met, ideally means when
%   the platform is falling.....
% "stopping_platform_frame" : frame at which the platform stop falling
%
% Condition given is the first time when both y speed value for measure for
% platform label 1 and 2 are below the "threshold". If the speed doesn not
% mean the criteria, there is a second condition for the acceleration.

switch nargin
    case 0
        config = defaultConfig(); % Set the default config values
        [all_table, labels, numbers, file_name, path_name]=importDlcFile(); % choose one file
        [mouse] = dlcSmooth(config ,file_name, path_name);
        threshold = -0.4; 
        a_threshold = -0.2;
    case 1
        [all_table, labels, numbers, file_name, path_name]=importDlcFile();
        [mouse] = dlcSmooth(config ,file_name, path_name);
        threshold = -0.4; 
        a_threshold = -0.2;
    case 2
         threshold = -0.4;
         a_threshold = -0.2;
    case 3
        a_threshold = -0.2;
end

delay = config.delay_platform;
dlc_model = config.dlc_model;
mirro_setup = config.mirror_setup;

% Find columns number for which the derivative of the y axis is lower than
% threshold
if strcmp(mirro_setup, 'false')
    d1 = find(mouse.env.right_platform1.y.d<threshold);
elseif strcmp(mirro_setup, 'true')
    d1 = find(mouse.env.pm2.y.d<threshold);
end
d2 = find(mouse.env.right_platform2.y.d<threshold);
d3 = find(mouse.env.right_platform3.y.d<threshold);

% Put the last value of the platform meeting the criteria above => end of
% the fall of the platform
df1 = flip(d1);
df2 = flip(d2);
df3 = flip(d3);

% Take first common frame meeting criteria (here either falling of platform
% = first value of dx or stop of the falling = last value of dx)
[val1, ~] = intersect(d1,d2);
[val2, ~] = intersect(d2,d3);
[val, ~] = intersect(val1,val2);

[end1, ~] = intersect(df1,df2);
[end2, ~] = intersect(df2,df3);
[valf, ~] = intersect(end1,end2);

% If no value found, acceleration critera is used
if (isempty(val))
    a2 = find(mouse.env.right_platform2.y.dd<a_threshold);
    a3 = find(mouse.env.right_platform3.y.dd<a_threshold);
    [val_a, ~] = intersect(a2,a3);
end

% To be sure to have an end of falling of the platform, this criteria is
% important for computing the speed of the platform but often not that
% important...
if (isempty(valf))
    [value, valf_a] = max(mouse.env.right_platform1.y.d);
end

% Falling platform frame event definition: we take the first value of val
% minus a delay (due to the derivative, usually set in the config file at 0
% or 1)
if not(isempty(val))
    falling_platform_frame = val(1,1)-delay;
elseif isempty(val) && not(isempty(val_a))
    disp('Falling platform: acceleration criteria took in account');
    falling_platform_frame = val_a(1,1)-delay;
else  
    error('No value found for falling platform.');
    falling_platform_frame = [];
end

% Same for the end of the falling
if not(isempty(valf))
    stopping_platform_frame = valf(end,1)-delay;
elseif isempty(valf) && not(isempty(valf_a))
    disp('End of falling platform: acceleration criteria took in account');
    falling_platform_frame = valf_a(end,1)-delay;
else  
    error('No value found for end of the fall of the platform.');
    falling_platform_frame = [];
end 
end

