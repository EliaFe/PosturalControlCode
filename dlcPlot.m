function [] = dlcPlot(varargin)
%First entry is the config file, then mouse, process_type and enter joints

config = varargin{1};
mouse = varargin{2};
process_type = varargin{3};

for i = 4:1:nargin
    joint(i-3) = varargin{i};
end

figure;
nb_subplot = 2;
%[falling_platform_frame] = fallingPlatform(mouse);

%define name to display on the plot according to the type of processing
process_type_name = process_type;

for i = 1:length(process_type)
    if strcmp(process_type, 'r')
        process_type_name = 'Raw';
    elseif strcmp(process_type, 's')
        process_type_name = 'Smoothed';
    elseif strcmp(process_type, 'f')
        process_type_name = 'Filtered';
    elseif strcmp(process_type, 'fs')
        process_type_name = 'Filtered and smoothed';
    elseif strcmp(process_type, 'fm')
        process_type_name = 'Mean filtered';
    elseif strcmp(process_type, 'fms')
        process_type_name = 'Mean filtered and smoothed';
    elseif strcmp(process_type, 'd')
        process_type_name = 'Speed';
    elseif strcmp(process_type, 'ds')
        process_type_name = 'Smoothed speed';
    elseif strcmp(process_type, 'dd')
        process_type_name = 'Acceleration';
    elseif strcmp(process_type, 'dds')
        process_type_name = 'Smoothed acceleration';
    end
end

% Plotting the joints
subplot(nb_subplot,1,2)
for i = 1:1:nargin-3
    plot(joint(i).y.(string(process_type)));
    hold on;
end
xlabel('Time frames');
ylabel('Y Pixel value');

%legend('Bottom midline', 'Right hip', 'Right knee', 'Right ankle', 'Right MTP', 'Right toe', 'Platform y');
falling_platform_frame = fallingPlatform(config, mouse);
linePlot('falling_platform_frame', falling_platform_frame, 'display_type', 'on_plot');

[leg_on_platform_frame, leg_on_platform_success, ~] = legOnPlatform(config, mouse);
if strcmp(leg_on_platform_success, 'true')
    linePlot('leg_on_platform_frame', leg_on_platform_frame, 'display_type', 'on_plot');
end

[leg_retraction_frame, leg_retraction_success, ~] = legRetraction(config, mouse);
if strcmp(leg_retraction_success, 'true')
    linePlot('leg_retraction_frame', leg_retraction_frame, 'display_type', 'on_plot');
end

subplot(nb_subplot,1,1)
for i = 1:1:nargin-3
    plot(joint(i).x.(string(process_type)));
    hold on;
end
xlabel('Time frames');
ylabel('X Pixel value');
title(string(process_type_name));

falling_platform_frame = fallingPlatform(config, mouse);
linePlot('falling_platform_frame', falling_platform_frame);

[leg_on_platform_frame, leg_on_platform_success, ~] = legOnPlatform(config, mouse);
if strcmp(leg_on_platform_success, 'true')
    linePlot('leg_on_platform_frame', leg_on_platform_frame);
end

[leg_retraction_frame, leg_retraction_success, ~] = legRetraction(config, mouse);
if strcmp(leg_retraction_success, 'true')
    linePlot('leg_retraction_frame', leg_retraction_frame);
end

sgtitle(mouse.name, 'Interpreter','none');

end

