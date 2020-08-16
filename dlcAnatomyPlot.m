function [figure_anat] = dlcAnatomyPlot(config, mouse, process_type, anatomy, falling_platform_frame, leg_on_platform_frame, leg_retraction_frame)
%[] = dlcAnatomyPlot(config, mouse, process_type, anatomy, leg_retraction_frame)
% dlcAnatomyPlot(config, mouse, process_type, 'leg', leg_retraction_frame)
% process_type must be in this format ex: {'s', 'ds', 'dds'}
figure_anat = figure;
switch nargin
    case 0
        config = defaultConfig();
        [all_table, labels, numbers, file_name, path_name]=importDlcFile();
        anatomy = 'leg';
        [mouse] = dlcSmooth(config, file_name, path_name, anatomy);
        process_type = {'r', 's', 'fs', 'fms'};
        [falling_platform_frame] = fallingPlatform(config, mouse);
        [leg_retraction_frame] = legRetraction(config, mouse);
        [leg_on_platform_frame, leg_on_platform_success] = legOnPlatform(config, mouse, 'falling_platform_frame', falling_platform_frame);
    case 1
        [all_table, labels, numbers, file_name, path_name]=importDlcFile();
        anatomy = 'leg';
        [mouse] = dlcSmooth(config, file_name, path_name, anatomy);
        process_type = {'r', 's', 'fs', 'fms'};
        anatomy = 'leg';
        [falling_platform_frame] = fallingPlatform(config, mouse);
        [leg_retraction_frame] = legRetraction(config, mouse);
        [leg_on_platform_frame, leg_on_platform_success] = legOnPlatform(config, mouse, 'falling_platform_frame', falling_platform_frame);
    case 2
        process_type = {'r', 's', 'ms', 'fms'};
        anatomy = 'leg';
        [falling_platform_frame] = fallingPlatform(config, mouse);
        [leg_retraction_frame] = legRetraction(config, mouse);
        [leg_on_platform_frame, leg_on_platform_success] = legOnPlatform(config, mouse, 'falling_platform_frame', falling_platform_frame);
    case 3 
        anatomy = 'leg';
        [falling_platform_frame] = fallingPlatform(config, mouse);
        [leg_retraction_frame] = legRetraction(config, mouse);
        [leg_on_platform_frame, leg_on_platform_success] = legOnPlatform(config, mouse, 'falling_platform_frame', falling_platform_frame);
    case 4
        [falling_platform_frame] = fallingPlatform(config, mouse);
        [leg_retraction_frame] = legRetraction(config, mouse);
        [leg_on_platform_frame, leg_on_platform_success] = legOnPlatform(config, mouse, 'falling_platform_frame', falling_platform_frame);
    case 5
        [leg_retraction_frame] = legRetraction(config, mouse);
        [leg_on_platform_frame, leg_on_platform_success] = legOnPlatform(config, mouse, 'falling_platform_frame', falling_platform_frame);
    case 6
        [leg_retraction_frame] = legRetraction(config, mouse);
end
frames = mouse.frames;
nb_subplot = size(process_type,2);
dlc_model = config.dlc_model;

%define name to display on the plot according to the type of processing
process_type_name = process_type;

for i = 1:length(process_type)
    %this conditon and the one for "process_type_name_checked" below are
    %mandatory if we want to handle only one process type
    if length(process_type) == 1
        process_type_check = process_type;
        ylegend_name_checked = process_type;
    else
        process_type_check = process_type(i);
        ylegend_name_checked = process_type(i);
    end
    if strcmp(process_type_check, 'r')
        process_type_name_checked = cellstr('Raw');
        ylegend_name_checked = cellstr('Y value [Pixels]');
    elseif strcmp(process_type_check, 's')
        process_type_name_checked = cellstr('Smoothed');
        ylegend_name_checked = cellstr('Y value [Pixels]');
    elseif strcmp(process_type_check, 'f')
        process_type_name_checked = cellstr('Filtered');
        ylegend_name_checked = cellstr('Y value [Pixels]');
    elseif strcmp(process_type_check, 'fs')
        process_type_name_checked = cellstr('Filtered and smoothed');
        ylegend_name_checked = cellstr('Y value [Pixels]');
    elseif strcmp(process_type_check, 'fm')
        process_type_name_checked = cellstr('Mean filtered');
        ylegend_name_checked = cellstr('Y value [Pixels]');
    elseif strcmp(process_type_check, 'fms')
        process_type_name_checked = cellstr('Mean filtered and smoothed');
        ylegend_name_checked = cellstr('Y value [Pixels]');
    elseif strcmp(process_type(i), 'd')
        process_type_name_checked = cellstr('Speed');
        ylegend_name_checked = cellstr('Y value [Pixels/frames]');
    elseif strcmp(process_type_check, 'ds')
        process_type_name_checked = cellstr('Smoothed speed');
        ylegend_name_checked = cellstr('Y value [Pixels/frames]');
    elseif strcmp(process_type_check, 'dd')
        process_type_name_checked = cellstr('Acceleration');
        ylegend_name_checked = cellstr('Y value [Pixels/frames^2]');
    elseif strcmp(process_type_check, 'dds')
        process_type_name_checked = cellstr('Smoothed acceleration');
        ylegend_name_checked = cellstr('Y value [Pixels/frames^2]');
    elseif strcmp(process_type_check, 'm')
        process_type_name_checked = cellstr('Spline interpolation');
        ylegend_name_checked = cellstr('Y value [Pixels]');
    elseif strcmp(process_type_check, 'ms')
        process_type_name_checked = cellstr('Smoothed Spline interpolation');
        ylegend_name_checked = cellstr('Y value [Pixels]');
    end
    if length(process_type) == 1
        process_type_name = process_type_name_checked;
        ylegend_name = ylegend_name_checked;
    else
        process_type_name(i) = process_type_name_checked;
        ylegend_name(i) = ylegend_name_checked;
    end
end

frames = mouse.frames;

% Plotting the joints
if strcmp(anatomy, 'leg')
    joints = string(fieldnames(mouse.right));
    for i = 1:size(process_type,2)
        subplot(nb_subplot,1,i)
        plot(mouse.midline.end.y.(string(process_type(1,i)))-mouse.env.stable_right_platform.y.(string(process_type(1,i))));
        hold on;
        for j = 1:length(joints)
            plot(mouse.right.(joints(j)).y.(string(process_type(1,i)))-mouse.env.stable_right_platform.y.(string(process_type(1,i))));
        end
        plot(mouse.env.right_platform2.y.(string(process_type(1,i)))-mouse.env.stable_right_platform.y.(string(process_type(1,i))), '-*','MarkerIndices',1:5:frames, 'MarkerSize', 3);
        linePlot('line', 0, 'line_orientation', 'horizontal', 'off');
        hold off;
        xlabel('Time frames');
        ylabel(string(ylegend_name(i)));
        title(string(process_type_name(i)));
        if not(strcmp(falling_platform_frame, 'false') && strcmp(leg_retraction_frame, 'false') && strcmp(leg_on_platform_frame, 'false'))
            linePlot('falling_platform_frame', falling_platform_frame, 'leg_retraction_frame', leg_retraction_frame, 'leg_on_platform_frame', leg_on_platform_frame, 'display_type', 'box');
            [reaction_delay_frame, reaction_delay_ms] = reactionDelay(config, falling_platform_frame, leg_retraction_frame);   
            annotation(figure_anat,'textbox',...
            [0.0384251497006007 0.926547743966422 0.162173652694611 0.0493179433368333],...
            'String',{'Time reaction:', ['  ' num2str(reaction_delay_frame) ' [Frames]'], ['  ' num2str(reaction_delay_ms) ' [ms]']},...
            'LineWidth',1,...
            'FitBoxToText','on');
        end
        if strcmp(dlc_model, 'Long_drop_full') || strcmp(dlc_model, 'Long_drop_full_short') || strcmp(dlc_model, 'Full_platform_videos')
            legend('Bottom midline', 'Right hip', 'Right knee', 'Right ankle', 'Right MTP', 'Right toe', 'Platform y');
        else
            legend('Bottom midline', 'Right IC', 'Right hip', 'Right knee', 'Right ankle', 'Right MTP', 'Right toe', 'Platform y');
        end
        set(gca, 'FontSize', 12)
    end
    set(gcf, 'Position',  [512     2   668   953])

elseif strcmp(anatomy, 'leg_retr')
    joints = string(fieldnames(mouse.right));
%     ymin = [-500 -60 -10];
%     ymax = [300 60 15];
    for i = 1:size(process_type,2)
        subplot(nb_subplot,2,2*i-1)
        plot(mouse.midline.end.y.(string(process_type(1,i)))-mouse.env.stable_right_platform.y.(string(process_type(1,i))));
        hold on;
        for j = 1:length(joints)
            plot(mouse.right.(joints(j)).y.(string(process_type(1,i)))-mouse.env.stable_right_platform.y.(string(process_type(1,i))));
        end
        plot(mouse.env.right_platform2.y.(string(process_type(1,i)))-mouse.env.stable_right_platform.y.(string(process_type(1,i))), '-*','MarkerIndices',1:5:frames, 'MarkerSize', 3);
        linePlot('line', 0, 'line_orientation', 'horizontal', 'off');
        hold off;
        ylabel(string(ylegend_name(i)));
        title(string(process_type_name(i)));
        if not(strcmp(falling_platform_frame, 'false') && strcmp(leg_retraction_frame, 'false') && strcmp(leg_on_platform_frame, 'false'))
            linePlot('falling_platform_frame', falling_platform_frame, 'leg_retraction_frame', leg_retraction_frame, 'leg_on_platform_frame', leg_on_platform_frame, 'display_type', 'box');
            [reaction_delay_frame, reaction_delay_ms] = reactionDelay(config, falling_platform_frame, leg_retraction_frame);   
        end
        if strcmp(dlc_model, 'Long_drop_full') || strcmp(dlc_model, 'Long_drop_full_short') || strcmp(dlc_model, 'Full_platform_videos')
            legend('Bottom midline', 'Right hip', 'Right knee', 'Right ankle', 'Right MTP', 'Right toe', 'Platform y');
        else
            legend('Bottom midline', 'Right IC', 'Right hip', 'Right knee', 'Right ankle', 'Right MTP', 'Right toe', 'Platform y');
        end
%         ylim([ymin(i) ymax(i)]);
        xticks(0:20:frames+20)
        xticklabels(0:20:frames+20)
        set(gca, 'FontSize', 14)
    end
        xlabel('Time frames');

    for i = 1:size(process_type,2)
        subplot(nb_subplot,2,2*i)
        xlabel('Time frames');
        ylabel(string(ylegend_name(i)));
        initial_leg = mean(mouse.leg.right_mirror.y.(string(process_type(1,i)))(1:falling_platform_frame-5));
        initial_platform = mean(mouse.env.pm2.y.(string(process_type(1,i)))(1:falling_platform_frame-5));
        plot(mouse.leg.right_mirror.y.(string(process_type(1,i)))-initial_leg);
        hold on;
        plot(mouse.env.pm2.y.(string(process_type(1,i)))-initial_platform, '-*','MarkerIndices',1:10:frames, 'MarkerSize', 3);
        title(string(process_type_name(i)));
        legend('Leg','Platform y');
        linePlot('falling_platform_frame', falling_platform_frame, 'leg_retraction_frame', leg_retraction_frame, 'leg_on_platform_frame', leg_on_platform_frame, 'display_type', 'box');
        [reaction_delay_frame, reaction_delay_ms] = reactionDelay(config, falling_platform_frame, leg_retraction_frame);   
        annotation(figure_anat,'textbox',...
        [0.0384251497006007 0.926547743966422 0.162173652694611 0.0493179433368333],...
        'String',{'Time reaction:', ['  ' num2str(reaction_delay_frame) ' [Frames]'], ['  ' num2str(reaction_delay_ms) ' [ms]']},...
        'LineWidth',1,...
        'FitBoxToText','on',...
        'FontSize', 14);
        xticks(0:20:frames+20)
        xticklabels(0:20:frames+20)
%         ylim([ymin(i) ymax(i)]);
        set(gca, 'FontSize', 14)
    end
    xlabel('Time frames');
    set(gcf, 'Position',  [-10           1        1612         954])
    
elseif strcmp(anatomy, 'leg_retr_mirror')
    joints = string(fieldnames(mouse.m2_right));
%     ymin = [-500 -60 -10];
%     ymax = [300 60 15];
    for i = 1:size(process_type,2)
        subplot(nb_subplot,2,2*i-1)
        plot(mouse.m2_midline.end.y.(string(process_type(1,i)))-mouse.env.spm1.y.(string(process_type(1,i))));
        hold on;
        for j = 1:length(joints)
            plot(mouse.m2_right.(joints(j)).y.(string(process_type(1,i)))-mouse.env.spm1.y.(string(process_type(1,i))));
        end
        plot(mouse.env.pm2.y.(string(process_type(1,i)))-mouse.env.spm1.y.(string(process_type(1,i))), '-*','MarkerIndices',1:5:frames, 'MarkerSize', 3);
        linePlot('line', 0, 'line_orientation', 'horizontal', 'off');
        hold off;
        ylabel(string(ylegend_name(i)));
        title(string(process_type_name(i)));
        if not(strcmp(falling_platform_frame, 'false') && strcmp(leg_retraction_frame, 'false') && strcmp(leg_on_platform_frame, 'false'))
            linePlot('falling_platform_frame', falling_platform_frame, 'leg_retraction_frame', leg_retraction_frame, 'leg_on_platform_frame', leg_on_platform_frame, 'display_type', 'box');
            [reaction_delay_frame, reaction_delay_ms] = reactionDelay(config, falling_platform_frame, leg_retraction_frame);   
        end
        if strcmp(dlc_model, 'Long_drop_full') || strcmp(dlc_model, 'Long_drop_full_short') || strcmp(dlc_model, 'Full_platform_videos')
            legend('Bottom midline', 'Right hip', 'Right knee', 'Right ankle', 'Right MTP', 'Right toe', 'Platform y');
        else
            legend('M2 Bottom midline', 'M2 Right IC', 'M2 Right hip', 'M2 Right knee', 'M2 Right ankle', 'M2 Right MTP', 'M2 Right toe', 'M2 Platform y');
        end
%         ylim([ymin(i) ymax(i)]);
        xticks(0:20:frames+20)
        xticklabels(0:20:frames+20)
        set(gca, 'FontSize', 14)
    end
        xlabel('Time frames');

    for i = 1:size(process_type,2)
        subplot(nb_subplot,2,2*i)
        xlabel('Time frames');
        ylabel(string(ylegend_name(i)));
        initial_leg = mean(mouse.leg.right_mirror.y.(string(process_type(1,i)))(1:falling_platform_frame-5));
        initial_platform = mean(mouse.env.pm2.y.(string(process_type(1,i)))(1:falling_platform_frame-5));
        plot(mouse.leg.right_mirror.y.(string(process_type(1,i)))-initial_leg);
        hold on;
        plot(mouse.env.pm2.y.(string(process_type(1,i)))-initial_platform, '-*','MarkerIndices',1:10:frames, 'MarkerSize', 3);
        title(string(process_type_name(i)));
        legend('Leg','Platform y');
        linePlot('falling_platform_frame', falling_platform_frame, 'leg_retraction_frame', leg_retraction_frame, 'leg_on_platform_frame', leg_on_platform_frame, 'display_type', 'box');
        [reaction_delay_frame, reaction_delay_ms] = reactionDelay(config, falling_platform_frame, leg_retraction_frame);   
        annotation(figure_anat,'textbox',...
        [0.0384251497006007 0.926547743966422 0.162173652694611 0.0493179433368333],...
        'String',{'Time reaction:', ['  ' num2str(reaction_delay_frame) ' [Frames]'], ['  ' num2str(reaction_delay_ms) ' [ms]']},...
        'LineWidth',1,...
        'FitBoxToText','on',...
        'FontSize', 14);
        xticks(0:20:frames+20)
        xticklabels(0:20:frames+20)
%         ylim([ymin(i) ymax(i)]);
        set(gca, 'FontSize', 14)
    end
    xlabel('Time frames');
    set(gcf, 'Position',  [-10           1        1612         954])
    sgtitle('Mirror view');
elseif strcmp(anatomy, 'leg_mirror')
    joints = string(fieldnames(mouse.m2_right));
    for i = 1:size(process_type,2)
        subplot(nb_subplot,1,i)
        plot(mouse.m2_midline.end.y.(string(process_type(1,i)))-mouse.env.spm1.y.(string(process_type(1,i))));
        hold on;
        for j = 1:length(joints)-1
            plot(mouse.m2_right.(joints(j)).y.(string(process_type(1,i)))-mouse.env.spm1.y.(string(process_type(1,i))));
        end
        plot(mouse.env.right_platform2.y.(string(process_type(1,i)))-mouse.env.spm1.y.(string(process_type(1,i))), '-*','MarkerIndices',1:5:frames, 'MarkerSize', 3);
        linePlot('line', 0, 'line_orientation', 'horizontal', 'off');
        hold off;
        xlabel('Time frames');
        ylabel(string(ylegend_name(i)));
        title(string(process_type_name(i)));
        linePlot('falling_platform_frame', falling_platform_frame, 'leg_retraction_frame', leg_retraction_frame, 'leg_on_platform_frame', leg_on_platform_frame, 'display_type', 'box');
        legend('Bottom midline', 'Right IC', 'Right hip', 'Right knee', 'Right ankle', 'Right MTP', 'Right toe', 'Platform y');
    end
    [reaction_delay_frame, reaction_delay_ms] = reactionDelay(config, falling_platform_frame, leg_retraction_frame);   
    annotation(figure_anat,'textbox',...
    [0.0384251497006007 0.926547743966422 0.162173652694611 0.0493179433368333],...
    'String',{'Time reaction:', ['  ' num2str(reaction_delay_frame) ' [Frames]'], ['  ' num2str(reaction_delay_ms) ' [ms]']},...
    'LineWidth',1,...
    'FitBoxToText','on');
    set(gcf, 'Position',  [512     2   668   953])    

elseif strcmp(anatomy, 'leg_only_right_mirror')
    for i = 1:size(process_type,2)
        subplot(nb_subplot,1,i)
        xlabel('Time frames');
        ylabel(string(ylegend_name(i)));
        initial_leg = mean(mouse.leg.right_mirror.y.(string(process_type(1,i)))(1:falling_platform_frame-5));
        initial_platform = mean(mouse.env.pm2.y.(string(process_type(1,i)))(1:falling_platform_frame-5));
        plot(mouse.leg.right_mirror.y.(string(process_type(1,i)))-initial_leg);
        hold on;
        plot(mouse.env.pm2.y.(string(process_type(1,i)))-initial_platform, '-*','MarkerIndices',1:10:frames, 'MarkerSize', 3);
        title(string(process_type_name(i)));
        linePlot('falling_platform_frame', falling_platform_frame, 'leg_retraction_frame', leg_retraction_frame, 'leg_on_platform_frame', leg_on_platform_frame, 'display_type', 'on_plot');
        legend('Leg','Platform y');
        [reaction_delay_frame, reaction_delay_ms] = reactionDelay(config, falling_platform_frame, leg_retraction_frame);   
        annotation(figure_anat,'textbox',...
        [0.0384251497006007 0.926547743966422 0.162173652694611 0.0493179433368333],...
        'String',{'Time reaction:', ['  ' num2str(reaction_delay_frame) ' [Frames]'], ['  ' num2str(reaction_delay_ms) ' [ms]']},...
        'LineWidth',1,...
        'FitBoxToText','on');
        set(gcf, 'Position',  [254     2   995   953])
        xticks(0:5:frames)
        xticklabels(0:5:frames)
        set(gca, 'Color', 'w');

    end

elseif strcmp(anatomy, 'leg_only_back')
    for i = 1:size(process_type,2)
        subplot(nb_subplot,1,i)
        xlabel('Time frames');
        ylabel(string(ylegend_name(i)));
        initial_leg = mean(mouse.leg.back.y.(string(process_type(1,i)))(1:falling_platform_frame-5));
        initial_platform = mean(mouse.env.right_platform2.y.(string(process_type(1,i)))(1:falling_platform_frame-5));
        plot(mouse.leg.back.y.(string(process_type(1,i)))-initial_leg);
        hold on;
        plot(mouse.env.right_platform2.y.(string(process_type(1,i)))-initial_platform, '-*','MarkerIndices',1:10:frames, 'MarkerSize', 3);
        title(string(process_type_name(i)));
        linePlot('falling_platform_frame', falling_platform_frame, 'leg_retraction_frame', leg_retraction_frame, 'leg_on_platform_frame', leg_on_platform_frame, 'display_type', 'on_plot');
        legend('Leg','Platform y');
        [reaction_delay_frame, reaction_delay_ms] = reactionDelay(config, falling_platform_frame, leg_retraction_frame);   
        annotation(figure_anat,'textbox',...
        [0.0384251497006007 0.926547743966422 0.162173652694611 0.0493179433368333],...
        'String',{'Time reaction:', ['  ' num2str(reaction_delay_frame) ' [Frames]'], ['  ' num2str(reaction_delay_ms) ' [ms]']},...
        'LineWidth',1,...
        'FitBoxToText','on');
        set(gcf, 'Position',  [512     2   668   953])
        set(gca, 'Color', 'w');

    end

elseif strcmp(anatomy, 'midline')
    joints = string(fieldnames(mouse.midline));
    for i = 1:size(process_type,2)
        subplot(nb_subplot,1,i)
        for j = 1:length(joints)
            plot(mouse.midline.(joints(j)).x.(string(process_type(1,i))));
            hold on;
        end
        hold off;
        xlabel('Time frames');
        ylabel('X Pixel value');
        title(string(process_type_name(i)));
        linePlot('falling_platform_frame', falling_platform_frame, 'leg_retraction_frame', leg_retraction_frame, 'leg_on_platform_frame', leg_on_platform_frame);
        legend('Up midline', 'Mid midline', 'End midline');
    end
    [reaction_delay_frame, reaction_delay_ms] = reactionDelay(config, falling_platform_frame, leg_retraction_frame);   
    annotation(figure_anat,'textbox',...
    [0.0384251497006007 0.926547743966422 0.162173652694611 0.0493179433368333],...
    'String',{'Time reaction:', ['  ' num2str(reaction_delay_frame) ' [Frames]'], ['  ' num2str(reaction_delay_ms) ' [ms]']},...
    'LineWidth',1,...
    'FitBoxToText','on');
    set(gcf, 'Position',  [512     2   668   953])    

elseif strcmp(anatomy, 'm_midline')
    side = ["m1_midline", "m2_midline"];
    joints = string(fieldnames(mouse.m1_midline));
    coord = ["x", "y"];
    n = 1;
    for m = 1:length(side)
        for k = 1:length(coord)
            for i = 1:size(process_type,2)
                subplot(4,nb_subplot,n)
                n = n+1;
                hold on;
                for j = 1:length(joints)
                    plot(mouse.(side(m)).(joints(j)).(coord(k)).(string(process_type(1,i))));
                    hold on;
                end
                hold off;
                xlabel('Time frames');
                if k == 1
                    ylabel('X Pixel value');
                elseif k==2
                    ylabel('Y Pixel value');
                end
                title(string(process_type_name(i)));
                linePlot('falling_platform_frame', falling_platform_frame, 'leg_retraction_frame', leg_retraction_frame, 'leg_on_platform_frame', leg_on_platform_frame);
                legend('Nose', 'Head', 'Neck', 'Up midline', 'Mid midline', 'End midline', 'Location', 'eastoutside');
            end
        end
    % Create textbox
    annotation(figure_anat,'textbox',...
    [0.053989352035231 0.711018629916419 0.0217250324254215 0.0242456896551724],...
    'String',{'M1'},...
    'LineWidth',1);

    % Create textbox
    annotation(figure_anat,'textbox',...
    [0.053989352035231 0.289682423019867 0.0217250324254215 0.0242456896551724],...
    'String',{'M2'},...
    'LineWidth',1);
    end   
    [reaction_delay_frame, reaction_delay_ms] = reactionDelay(config, falling_platform_frame, leg_retraction_frame);   
    annotation(figure_anat,'textbox',...
    [0.0384251497006007 0.926547743966422 0.162173652694611 0.0493179433368333],...
    'String',{'Time reaction:', ['  ' num2str(reaction_delay_frame) ' [Frames]'], ['  ' num2str(reaction_delay_ms) ' [ms]']},...
    'LineWidth',1,...
    'FitBoxToText','on');
    set(gcf, 'Position',  [68     2   1542   953])

elseif strcmp(anatomy, 'head')
    side = ["m1_midline", "m2_midline"];
    joints = string(fieldnames(mouse.m1_midline));
    coord = ["x", "y"];
    n = 1;
    for m = 1:length(side)
        for k = 1:length(coord)
            for i = 1:size(process_type,2)
                subplot(4,nb_subplot,n)
                n = n+1;
                hold on;
                for j = 1:length(joints)-3
                    plot(mouse.(side(m)).(joints(j)).(coord(k)).(string(process_type(1,i))));
                    hold on;
                end
                hold off;
                xlabel('Time frames');
                if k == 1
                    ylabel('X Pixel value');
                elseif k==2
                    ylabel('Y Pixel value');
                end
                title(string(process_type_name(i)));
                linePlot('falling_platform_frame', falling_platform_frame, 'leg_retraction_frame', leg_retraction_frame, 'leg_on_platform_frame', leg_on_platform_frame);
                legend('Nose', 'Head', 'Neck', 'Location', 'eastoutside');
            end
        end
    % Create textbox
    annotation(figure_anat,'textbox',...
    [0.053989352035231 0.711018629916419 0.0217250324254215 0.0242456896551724],...
    'String',{'M1'},...
    'LineWidth',1);

    % Create textbox
    annotation(figure_anat,'textbox',...
    [0.053989352035231 0.289682423019867 0.0217250324254215 0.0242456896551724],...
    'String',{'M2'},...
    'LineWidth',1);
    end   
    [reaction_delay_frame, reaction_delay_ms] = reactionDelay(config, falling_platform_frame, leg_retraction_frame);   
    annotation(figure_anat,'textbox',...
    [0.0384251497006007 0.926547743966422 0.162173652694611 0.0493179433368333],...
    'String',{'Time reaction:', ['  ' num2str(reaction_delay_frame) ' [Frames]'], ['  ' num2str(reaction_delay_ms) ' [ms]']},...
    'LineWidth',1,...
    'FitBoxToText','on');
    set(gcf, 'Position',  [68     2   1542   953])
else
    error('Anatomy not found');
end
set(gca, 'Color', 'w');

sgtitle(mouse.name, 'Interpreter','none');
end