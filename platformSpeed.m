function [platform_speed, figure_platform] = platformSpeed(config, mouse, falling_platform_frame, stopping_platform_frame, plot_bool)
% [platform_speed, figure_platform] = platformSpeed(config, mouse, falling_platform_frame, stopping_platform_frame, plot_bool)
% [platform_speed, figure_platform] = platformSpeed(config, mouse, 'false', 'false', 'false')
%
% This function determine the speed of the falling of the platform
% depending on the falling frame and stopping frame

switch nargin
    case 0
        config = defaultConfig();
        [all_table, labels, numbers, file_name, path_name]=importDlcFile();
        [mouse] = dlcSmooth(config ,file_name, path_name);
        falling_platform_frame = mouse.charact.falling_platform_frame;
        stopping_platform_frame = mouse.charact.stopping_platform_frame;
        plot_bool = 'false';
    case 1
        [all_table, labels, numbers, file_name, path_name]=importDlcFile();
        [mouse] = dlcSmooth(config ,file_name, path_name);
        falling_platform_frame = mouse.charact.falling_platform_frame;
        stopping_platform_frame = mouse.charact.stopping_platform_frame;
        plot_bool = 'false';
    case 2 
        falling_platform_frame = mouse.charact.falling_platform_frame;
        stopping_platform_frame = mouse.charact.stopping_platform_frame;
        plot_bool = 'false';
    case 3
        plot_bool = 'false';
    case 4
        plot_bool = 'false';
end

if strcmp(falling_platform_frame, 'true')
    falling_platform_frame = mouse.charact.falling_platform_frame;
elseif strcmp(falling_platform_frame, 'false') || isempty(falling_platform_frame)
    [falling_platform_frame, ~] = fallingPlatform(config, mouse);
end
if strcmp(stopping_platform_frame, 'true')
    stopping_platform_frame = mouse.charact.stopping_platform_frame;
elseif strcmp(stopping_platform_frame, 'false') || isempty(stopping_platform_frame)
    [~, stopping_platform_frame] = fallingPlatform(config, mouse);
end

delay = config.delay_platform;
dlc_model = config.dlc_model;
mirror_setup = config.mirror_setup;
frames = mouse.frames;
figure_platform = [];

% s is the slope of the trajectory of the platform
s = mean(abs(mouse.env.right_platform2.y.ds(falling_platform_frame+delay:min(falling_platform_frame+delay+50,stopping_platform_frame+delay)))); %reason of this min: sometimes the end of the prediction is really messy (we are sure to take after the platform has fallen)
% Initial height
y0 = mean(mouse.env.right_platform2.y.s(1:falling_platform_frame-1));

% Construction of the vectore that will be plotted to assess the speed of
% the platform
s_plot = zeros(frames,1);
frames_plot = (linspace(1,frames,frames))';

%Before the falling, slope = 0
for i = 1:falling_platform_frame
    s_plot(i) = y0;
end

% After the falling, the trajectory of the platform is linear with the
% slope beeing its derivative s
j = 1;
for i = falling_platform_frame:stopping_platform_frame
    s_plot(i) = -s*frames_plot(j)+y0;  
    j = j+1;
end

% Stop the plotting
for i = stopping_platform_frame:size(s_plot,1)
    s_plot(i) = NaN;  
    j = j+1;
end

if strcmp(plot_bool, 'true') || strcmp(plot_bool, 'short')
%     if not(strcmp(plot_bool, 'short'))
%         figure_platform = figure;
%         subplot(2,1,1)
%         if strcmp(dlc_model, 'Long_drop_full')
%             plot(mouse.env.right_platform1.y.ds);
%         else
%             plot(mouse.env.pm2.y.ds);
%         end
% 
%         hold on;
%         plot(mouse.env.right_platform2.y.ds);
%         plot(mouse.env.right_platform3.y.ds);
%         yline(-s,'-.','Color','k');
%         xline(falling_platform_frame,'-.','Color','k');
%         xline(stopping_platform_frame,'-.','Color','k');
%         legend('Vs Platform mirror 2', 'Vs Platform 2','Vs Platform 3', 'Speed');
%         if strcmp(dlc_model, 'Long_drop_full')
%             legend('Vs Platform 1', 'Vs Platform 2','Vs Platform 3', 'Speed');
%         else
%             legend('Vs Platform mirror 2', 'Vs Platform 2','Vs Platform 3', 'Speed');
%         end
% 
%         [leg_on_platform_frame] = legOnPlatform(config, mouse, 'plot_bool', 'false');
%         [leg_retraction_frame, ~, ~] = legRetraction(config, mouse, 'plot_bool', 'false');
% 
%         linePlot('leg_retraction_frame', leg_retraction_frame, 'leg_on_platform_frame', leg_on_platform_frame, 'display_type', 'on_plot', 'line_orientation', 'vertical');
% 
% 
%         subplot(2,1,2)
%         plot(mouse.env.stable_right_platform.y.s, '-o','MarkerIndices',1:10:frames, 'MarkerSize', 5)
% 
%         hold on;
% 
%         if strcmp(dlc_model, 'Long_drop_full')
%             plot(mouse.env.right_platform1.y.s,'-+','MarkerIndices',1:10:frames, 'MarkerSize', 5)
%         else
%             plot(mouse.env.pm2.y.s,'-+','MarkerIndices',1:10:frames, 'MarkerSize', 5)
%         end
% 
%         plot(mouse.env.right_platform2.y.s,'-v','MarkerIndices',1:10:frames, 'MarkerSize', 5)
%         plot(mouse.env.right_platform3.y.s,'-d','MarkerIndices',1:10:frames, 'MarkerSize', 5)
%         plot(s_plot,'-.','Color','k', 'LineWidth', 2);
% 
%         if strcmp(dlc_model, 'Long_drop_full')
%             legend('Stable','Platform 1','Platform 2','Platform 3', 'y = speed*frame + y0');
%         else
%             legend('Stable','Platform mirror 2','Platform 2','Platform 3', 'y = speed*frame + y0');
%         end
% 
%         sgtitle(mouse.name, 'Interpreter', 'None');
% 
%         %change window size
%         set(gcf, 'Position',  [512     2   668   953])
%     end
    figure_platform2 = figure;
    subplot(1,2,1)
    if strcmp(mirror_setup, 'true')
        plot(mouse.env.right_platform1.y.ds);
    else
        plot(mouse.env.pm2.y.ds);
    end
    hold on;
    plot(mouse.env.right_platform2.y.ds);
    plot(mouse.env.right_platform3.y.ds);
    if strcmp(dlc_model, 'Long_drop_full')
        legend('Vs Platform 1', 'Vs Platform 2','Vs Platform 3', 'Speed');
    else
        legend('Vs Platform mirror 2', 'Vs Platform 2','Vs Platform 3', 'Speed');
    end
    [leg_on_platform_frame] = legOnPlatform(config, mouse, 'plot_bool', 'false');
    [leg_retraction_frame, ~, ~] = legRetraction(config, mouse, 'plot_bool', 'false');
    xlabel('Time frames');
    ylabel('Y value [Pixels]');
    %linePlot('leg_retraction_frame', leg_retraction_frame, 'leg_on_platform_frame', leg_on_platform_frame, 'display_type', 'on_plot', 'line_orientation', 'vertical');
    linePlot('display_type', 'on_plot', 'line', falling_platform_frame+delay, 'line_orientation', 'vertical', 'Drop start', 'on');
    linePlot('display_type', 'on_plot', 'line', stopping_platform_frame+delay, 'line_orientation', 'vertical', 'Drop end', 'on');
    linePlot('display_type', 'on_plot', 'line', -s, 'line_orientation', 'horizontal', 'Mean of drop speed', 'on');
    set(gca,'FontSize',12);
    title('Platfrom dropping speed');
    
    subplot(1,2,2)
    plot(mouse.env.stable_right_platform.y.s, '-o','MarkerIndices',1:10:frames, 'MarkerSize', 5)
    hold on;
    if strcmp(dlc_model, 'Long_drop_full')
        plot(mouse.env.right_platform1.y.s,'-+','MarkerIndices',1:10:frames, 'MarkerSize', 5)
    else
        plot(mouse.env.pm2.y.s,'-+','MarkerIndices',1:10:frames, 'MarkerSize', 5)
    end
    plot(mouse.env.right_platform2.y.s,'-v','MarkerIndices',1:10:frames, 'MarkerSize', 5)
    plot(mouse.env.right_platform3.y.s,'-d','MarkerIndices',1:10:frames, 'MarkerSize', 5)
    plot(s_plot,'-.','Color','k', 'LineWidth', 2);
    if strcmp(dlc_model, 'Long_drop_full')
        legend('Stable','Platform 1','Platform 2','Platform 3', 'y = speed*frame + y0');
    else
        legend('Stable','Platform mirror 2','Platform 2','Platform 3', 'y = speed*frame + y0');
    end
    title('Vertical platform trajectory');
    xlabel('Time frames');
    ylabel('Y value [Pixels]');
    sgtitle(mouse.name, 'Interpreter', 'None');
    set(gca,'FontSize',12);
    %change window size
    set(gcf, 'Position',  [170         363        1453         545]);
    if not(strcmp(plot_bool, 'short'))
        figure;
        if strcmp(dlc_model, 'Long_drop_full')
            plot(mouse.env.right_platform1.y.dds);
        else
            plot(mouse.env.pm2.y.dds);
        end
        hold on;
        plot(mouse.env.right_platform2.y.dds);
        plot(mouse.env.right_platform3.y.dds);

        xline(falling_platform_frame,'-.','Color','k');
        xline(stopping_platform_frame,'-.','Color','k');

        if strcmp(dlc_model, 'Long_drop_full')
            legend('As Platform 1', 'As Platform 2','As Platform 3');
        else
            legend('As Platform mirror 2', 'As Platform 2','As Platform 3');
        end
        [leg_on_platform_frame] = legOnPlatform(config, mouse, 'plot_bool', 'false');
        [leg_retraction_frame, ~, ~] = legRetraction(config, mouse, 'plot_bool', 'false');

        linePlot('leg_retraction_frame', leg_retraction_frame, 'leg_on_platform_frame', leg_on_platform_frame, 'display_type', 'on_plot', 'line_orientation', 'vertical');
    end
    
end
platform_speed = s;
end

