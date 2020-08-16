function [leg_on_platform_frame, leg_on_platform_success, figure_leg_on_platform] = legOnPlatform(varargin)
%UNTITLED2 Summary of this function goes here
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

dlc_model = config.dlc_model;
mouse_type = 'random';
process_type = 's';
plot_bool = 'false';
p_value = config.p_value;
min_time_leg_on_platform=config.min_time_leg_on_platform;
min_time_reaction = config.min_time_reaction;
falling_platform_frame = 0;
criteria = 'right_mirror';
figure_leg_on_platform = [];
classified_speed = [];

for i = 3:2:nargin
   if strcmp(varargin{i}, 'mouse_type')
       mouse_type = varargin{i+1};
   elseif strcmp(varargin{i}, 'process_type')
       process_type = varargin{i+1};
   elseif strcmp(varargin{i}, 'falling_platform_frame')
       falling_platform_frame = varargin{i+1};
   elseif strcmp(varargin{i}, 'plot_bool')
       plot_bool = varargin{i+1};
   elseif strcmp(varargin{i}, 'criteria')
       criteria = varargin{i+1};
   elseif strcmp(varargin{i}, 'classified_speed')
       classified_speed = varargin{i+1};
   end
end

if strcmp(dlc_model, 'Long_drop_full')
    criteria = 'back';
else
    criteria = 'right_mirror';
end


if falling_platform_frame == 0
    falling_platform_frame = fallingPlatform(config, mouse);
end

if strcmp(falling_platform_frame, 'true')
    falling_platform_frame = fallingPlatform(config, mouse);
end
%the mice can't have a timing of reaction shorter than 60ms 
%=> the leg can't be on the platform again before 60ms 
if strcmp(criteria, 'right_mirror')
    speed_threshold = 2;
    height_threshold = 10;
    increase = 1;
elseif strcmp(criteria, 'back')
    height_threshold = 2;
    increase = 1;
else
    warning('Criteria not found, the right mirror is taken by default')
    criteria = 'right_mirror';
end

for i=1:length(process_type)        
    smooth_valueD = 10;    

    if not(strcmp(dlc_model, 'Long_drop_full'))
        mirror_diff_mtp = mouse.m2_right.mtp.y.(process_type)- mouse.env.spm1.y.(process_type);
        mirror_diff_toe = mouse.m2_right.toe.y.(process_type)- mouse.env.spm1.y.(process_type);    
    end
    
    back_diff_mtp = mouse.right.mtp.y.(process_type)- mouse.env.stable_right_platform.y.(process_type);
    back_diff_toe = mouse.right.toe.y.(process_type)- mouse.env.stable_right_platform.y.(process_type);

    if strcmp(criteria, 'right_mirror')
        criteria_mtp = mirror_diff_mtp;
        criteria_toe = mirror_diff_toe;
    elseif strcmp(criteria, 'back')
        criteria_mtp = back_diff_mtp;
        criteria_toe = back_diff_toe;
    end
    
    speed_criteria_mtp = smoothdata(diff(criteria_mtp), 'gaussian', smooth_valueD);
    speed_criteria_toe = smoothdata(diff(criteria_toe), 'gaussian', smooth_valueD);
    speed_criteria_mtp = speed_criteria_mtp(4:end); % derivative induce a delay of 1, smoothing give a speed of 0 later => delay for the minimization criteria
    speed_criteria_toe = speed_criteria_toe(4:end);
    
    acc_mtp = smoothdata(diff(speed_criteria_mtp), 'gaussian', smooth_valueD);
    acc_toe = smoothdata(diff(speed_criteria_mtp), 'gaussian', smooth_valueD);
    
    peak_acc_mtp = [];
    [~,temp_peak_acc_mtp] = min(acc_mtp);
    [~,peak_acc_toe] = min(acc_toe);
    
while isempty(peak_acc_mtp)
    [~,temp_peak_acc_mtp] = min(acc_mtp);
    if criteria_mtp(max([temp_peak_acc_mtp-min_time_reaction,1])) < 0 %acceleration must be neg, max to be sure not ot have neg index
        peak_acc_mtp = temp_peak_acc_mtp;
    else
        acc_mtp(temp_peak_acc_mtp) = 0;
        [~,temp_peak_acc_mtp] = min(acc_mtp);
    end
end
    % can't use this to find the zero because change too much
    %[~,first_zero] = min(abs(criteria_mtp_plot(peak_acc_mtp:peak_acc_mtp+25)))

    %check if there is a retraction
    %mean substraction ti0 be sure to begin with a negative value in case
    %the falling platform is a bit under the stable one
    if max(criteria_mtp(falling_platform_frame+4*min_time_leg_on_platform:mouse.frames)-mean(criteria_mtp(1:falling_platform_frame-5)))<-8
        leg_on_platform_frame = mouse.frames-3; % -3 because avoid bug when checking double derivative
        leg_on_platform_success = false
    else
        % in case the max of acceleration is after the leg is already above the
        % platform
        [first_zero,res,nit] = bisectionc(criteria_mtp, max([peak_acc_mtp-10,1]), peak_acc_mtp+10, 0.001, 100);

        start_check = max([peak_acc_mtp,first_zero+4])+3;
        start_check = max([start_check, falling_platform_frame+min_time_leg_on_platform]); % need a minimum of time reaction
        end_check = min([peak_acc_mtp+first_zero+50, mouse.frames-4]);

        value_mtp = 1000;
        index = mouse.frames;
        function2min = 1000;
        m = 1;

%         for j = start_check:1:end_check
%             h = abs(criteria_mtp(j))
%             v = 12*sqrt(abs(speed_criteria_mtp(j)))
%             frame_penality = log2(m)
%             temp_value(m) = h+v+frame_penality;  %function to minimise
%            if temp_value(m) < value_mtp
%                value_mtp = temp_value(m);
%                index_mtp = j;
%            end
%            m = m+1;
%         end
    
        for j = start_check:1:end_check
            height_penality(m) = abs(criteria_mtp(j));
            speed_penality(m) = 4*(abs(speed_criteria_mtp(j))+2)^1.8;
            frame_penality(m) = 5*log2(m+1)+(m+1)/4-1;
            function2min(m) = height_penality(m)+speed_penality(m)+frame_penality(m);  %function to minimise
            m = m+1;
        end
        function2min = smoothdata(function2min, 'gaussian', smooth_valueD);
        [~,min_func] = min(function2min);
        leg_on_platform_frame = min_func+start_check-3;
        if leg_on_platform_frame > mouse.frames-3
            leg_on_platform_frame = mouse.frames-3; %to be sure that every folowing computation will not be over the number of frames available (double derivative supress 2 values)
        end
        leg_on_platform_success = 'true';
        
    %     [~,first_zero] = min(abs(criteria_toe_plot(peak_acc_toe:peak_acc_toe+25)))
    % 
    %     for i = peak_acc_toe+first_zero+3:1:peak_acc_toe+first_zero+30
    %         h = abs(criteria_toe_plot(i))
    %         v = 30*abs(speed_criteria_toe_plot(i))
    %         temp_value = h+v+2*(i-peak_acc_toe)
    %         temp_index = i;
    %        if temp_value < value
    %            value_toe = temp_value;
    %            index_toe = temp_index;
    %        end
    %     end
    %     
    %     if value_toe<value_mtp
    %         leg_on_platform_frame = index_toe;
    %         leg_on_platform_success = 'true';
    %     else
    %         leg_on_platform_frame = index_mtp;
    %         leg_on_platform_success = 'true';
    %     end

        %leg_on_platform_frame = val1;
    end
    if strcmp(plot_bool, 'true') || strcmp(plot_bool, 'all') || strcmp(plot_bool, 'min_func')
        if not(strcmp(plot_bool, 'min_func'))
            if strcmp(dlc_model, 'Long_drop_full')

                nb_figures = 3; 
                figure_leg_on_platform.general = figure;
                subplot(nb_figures,1,1)
                plot(back_diff_mtp, 'DisplayName', 'MTP');
                hold on;
                plot(back_diff_toe, 'DisplayName', 'Toe');
                linePlot('leg_on_platform_frame', leg_on_platform_frame, 'falling_platform_frame', falling_platform_frame, 'display_type', 'on_plot');
                linePlot('line', peak_acc_mtp, 'line_orientation', 'vertical', 'display_type', 'on_plot', 'Peak', 'on');
                linePlot('line', 0, 'line_orientation', 'horizontal', 'off');
                xlabel('Time frames');
                ylabel('Y value [Pixels]');
                legend show;
                txt = ['Difference of MTP/toe y position and initial platform height, ', 'Back view'];
                title(txt, 'Interpreter', 'None');
                set(gca,'FontSize',12);

                subplot(nb_figures,1,2)
                plot(speed_criteria_mtp, 'DisplayName', 'MTP');
                hold on;
                plot(speed_criteria_toe, 'DisplayName', 'Toe');
                linePlot('leg_on_platform_frame', leg_on_platform_frame, 'falling_platform_frame', falling_platform_frame,  'off');
                linePlot('line', peak_acc_mtp, 'line_orientation', 'vertical', 'off');

                linePlot('line', 0, 'line_orientation', 'horizontal', 'off');
                xlabel('Time frames');
                ylabel('Y value [Pixels]');
                legend show;
                title('Speed');

                legend('Interpreter', 'None');
                sgtitle(mouse.name, 'Interpreter', 'None');
                set(gca,'FontSize',12);

                subplot(nb_figures,1,3)
                plot(diff(speed_criteria_mtp), 'DisplayName', 'MTP');
                hold on;
                plot(diff(speed_criteria_toe), 'DisplayName', 'Toe');
                linePlot('leg_on_platform_frame', leg_on_platform_frame, 'falling_platform_frame', falling_platform_frame,  'off');
                linePlot('line', peak_acc_mtp, 'line_orientation', 'vertical', 'off');
                linePlot('line', 0, 'line_orientation', 'horizontal', 'off');
                xlabel('Time frames');
                ylabel('Y value [Pixels]');
                legend show;
                title('Acceleration');
                set(gcf, 'Position', [1           1        1007         954]);
                set(gca,'FontSize',12);
            else
                nb_figures = 4; 
                figure_leg_on_platform.general = figure;
                subplot(nb_figures,1,1)
                plot(back_diff_mtp, 'DisplayName', 'MTP');
                hold on;
                plot(back_diff_toe, 'DisplayName', 'Toe');
                linePlot('leg_on_platform_frame', leg_on_platform_frame, 'falling_platform_frame', falling_platform_frame, 'display_type', 'on_plot');
                linePlot('line', peak_acc_mtp, 'line_orientation', 'vertical', 'display_type', 'on_plot', 'Peak', 'on');
                linePlot('line', 0, 'line_orientation', 'horizontal', 'off');
                xlabel('Time frames');
                ylabel('Y value [Pixels]');
                legend show;
                txt = ['Difference of MTP/toe y position and initial platform height, ', 'Back view'];
                title(txt, 'Interpreter', 'None');
                set(gca,'FontSize',12);

                subplot(nb_figures,1,2)
                plot(mirror_diff_mtp, 'DisplayName', 'MTP');
                hold on;
                plot(mirror_diff_toe, 'DisplayName', 'Toe');
                linePlot('leg_on_platform_frame', leg_on_platform_frame, 'falling_platform_frame', falling_platform_frame,  'off');
                linePlot('line', peak_acc_mtp, 'line_orientation', 'vertical', 'off');
                linePlot('line', 0, 'line_orientation', 'horizontal', 'off');
                xlabel('Time frames');
                ylabel('Y value [Pixels]');
                legend show;
                txt = ['Difference of MTP/toe y position and initial platform height, ', 'Mirror view'];
                title(txt, 'Interpreter', 'None');
                set(gca,'FontSize',12);

                subplot(nb_figures,1,3)
                plot(speed_criteria_mtp, 'DisplayName', 'MTP');
                hold on;
                plot(speed_criteria_toe, 'DisplayName', 'Toe');
                linePlot('leg_on_platform_frame', leg_on_platform_frame, 'falling_platform_frame', falling_platform_frame,  'off');
                linePlot('line', peak_acc_mtp, 'line_orientation', 'vertical', 'off');

                linePlot('line', 0, 'line_orientation', 'horizontal', 'off');
                xlabel('Time frames');
                ylabel('Y value [Pixels]');
                legend show;
                title('Speed');

                legend('Interpreter', 'None');
                sgtitle(mouse.name, 'Interpreter', 'None');
                set(gca,'FontSize',12);

                subplot(nb_figures,1,4)
                plot(diff(speed_criteria_mtp), 'DisplayName', 'MTP');
                hold on;
                plot(diff(speed_criteria_toe), 'DisplayName', 'Toe');
                linePlot('leg_on_platform_frame', leg_on_platform_frame, 'falling_platform_frame', falling_platform_frame,  'off');
                linePlot('line', peak_acc_mtp, 'line_orientation', 'vertical', 'off');
                linePlot('line', 0, 'line_orientation', 'horizontal', 'off');
                xlabel('Time frames');
                ylabel('Y value [Pixels]');
                legend show;
                title('Acceleration');
                set(gcf, 'Position', [1           1        1007         954]);
            set(gca,'FontSize',12);
            end
        end
        if strcmp(plot_bool, 'all') || strcmp(plot_bool, 'min_func')
            %to plot the minimizing function
            if strcmp(leg_on_platform_success, 'true')
                figure_leg_on_platform.min_function = figure;
                plot(function2min)
                hold on;
                plot(height_penality)
                plot(speed_penality)
                plot(frame_penality)
                legend('Sum', 'Height penality', 'Speed penality', 'Frame penality');
                linePlot('line', min_func, 'line_orientation', 'vertical', 'display_type', 'on_plot', 'Min', 'on');
                ylabel('Penality value [AU]');
                xlabel('Time frames from peak acceleration of MTP');
                set(gcf, 'Position', [1009  450   672 505]);
                legend('Interpreter', 'None');
                title('Function to minimize to define event of leg back on platform');
                sgtitle(mouse.name, 'Interpreter', 'None');
                set(gca, 'Position', [0.0774    0.0832    0.8735    0.8020]);
                set(gca,'FontSize',12);
            end 
            
             if not(strcmp(plot_bool, 'min_func'))
                if strcmp(dlc_model, 'Long_drop_full')
                    h1 = dlcAnatomyPlot(config, mouse, process_type, 'leg');
                    linePlot('leg_on_platform_frame', leg_on_platform_frame);
                    legend('Bottom midline', 'Right hip', 'Right knee', 'Right ankle', 'Right MTP', 'Right toe', 'Platform y');
                    xlabel('Time frames');
                    ylabel('Y value [Pixels]');
                    set(gca,'FontSize',12);
                    legend('Interpreter', 'None');
                    sgtitle(mouse.name, 'Interpreter', 'None');
                else
                    h1 = dlcAnatomyPlot(config, mouse, process_type, 'leg');
                    linePlot('leg_on_platform_frame', leg_on_platform_frame);
                    h=get(gca,'title');
                    titre=get(h,'string');% to get the title already set and add new part
                    tit1 = strcat(titre, ' - Back view');
                    ylim([-500 300]);
                    ax1 = gca; % get handle to axes of figure

                    h2 = dlcAnatomyPlot(config, mouse, process_type, 'leg_mirror');
                    linePlot('leg_on_platform_frame', leg_on_platform_frame);
                    h=get(gca,'title');
                    titre=get(h,'string');% to get the title already set and add new part
                    tit2 = strcat(titre, ' - Right mirror view');
                    ylim([-500 300]);
                    ax2 = gca; % get handle to axes of figure
                    
                    h3 = figure; %create new figure

                    s1 = subplot(1,2,1); %create and get handle to the subplot axes
                    title(tit1);
                    legend('Bottom midline', 'Right IC', 'Right hip', 'Right knee', 'Right ankle', 'Right MTP', 'Right toe', 'Platform y');
                    legend('Location','southeast')
                    xlabel('Time frames');
                    ylabel('Y value [Pixels]');
                    set(gca,'FontSize',12);

                    s2 = subplot(1,2,2);
                    title(tit2);
                    legend('Bottom midline', 'Right IC', 'Right hip', 'Right knee', 'Right ankle', 'Right MTP', 'Right toe', 'Platform y');
                    legend('Location','southeast')
                    xlabel('Time frames');
                    ylabel('Y value [Pixels]');
                    set(gca,'FontSize',12);
                    set(gca, 'Color', 'w');

                    fig1 = get(ax1,'children'); %get handle to all the children in the figure
                    fig2 = get(ax2,'children');

                    copyobj(fig1,s1); %copy children to new parent axes i.e. the subplot axes
                    copyobj(fig2,s2);
                    set(gca, 'Color', 'w');

                    legend('Interpreter', 'None');
                    sgtitle(mouse.name, 'Interpreter', 'None');
                    set(gcf, 'Position',  [170         363        1453         545])
                    set(gca, 'Color', 'w');

                end
             end
        end
    end
end
leg_on_platform_success = string(leg_on_platform_success);
end

