function [midline_displacement, pivot_midline, mean_midline, figure_midline, central_mid_position, pivot_plot] = midlineMov(varargin)
%UNTITLED4 Summary of this function goes here
%   Detailed explanation goes here
switch nargin
    case 0
        config = defaultConfig();
        [all_table, labels, numbers, file_name, path_name]=importDlcFile();
        [mouse] = dlcSmooth(config, file_name, path_name, 'head');
    case 1
        [all_table, labels, numbers, file_name, path_name]=importDlcFile();
        [mouse] = dlcSmooth(config, file_name, path_name, 'head');
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
stage_figure = 'false';
figure_midline = [];
markers = 'none';

for i = 3:2:nargin
   if strcmp(varargin{i}, 'mouse_type')
       mouse_type = varargin{i+1};
   elseif strcmp(varargin{i}, 'process_type')
       process_type = varargin{i+1};
   elseif strcmp(varargin{i}, 'plot_bool')
       plot_bool = varargin{i+1};
   elseif strcmp(varargin{i}, 'stage_figure')
       stage_figure = varargin{i+1};
   elseif strcmp(varargin{i}, 'markers')
       markers = varargin{i+1};
   end
end

end_check = 30;

falling_platform_frame = mouse.charact.falling_platform_frame;
leg_retraction_frame = mouse.charact.leg_retraction_frame;
leg_on_platform_frame = mouse.charact.leg_on_platform_frame;

start_norm = max(1, falling_platform_frame-5); %make sure we dont begin before the first frame

%initial_up_midline_position = mean(mouse.midline.up.x.(process_type)(1:falling_platform_frame-5));
x_platform = mean(mouse.env.right_platform3.x.(process_type)(:));
x_platform2 = mean(mouse.env.right_platform2.x.(process_type)(1:start_norm));
x_platform1 = mean(mouse.env.c3.x.(process_type)(1:start_norm));
initial_mid_midline_position = mean(mouse.midline.mid.x.(process_type)(max(1,falling_platform_frame-15):(max(1, falling_platform_frame-3))));

up_midline = mouse.midline.up.x.(process_type) - x_platform;
mid_midline = mouse.midline.mid.x.(process_type) - x_platform;
end_midline = mouse.midline.end.x.(process_type) - x_platform;
left_knee = mouse.left.knee.x.(process_type) - x_platform;
right_knee = mouse.right.knee.x.(process_type) - x_platform;
left_ankle = mouse.left.ankle.x.(process_type) - x_platform;
right_ankle = mouse.right.ankle.x.(process_type) - x_platform;

left_hip = mouse.left.hip.x.(process_type) - x_platform;
right_hip = mouse.right.hip.x.(process_type) - x_platform;
left_ic = mouse.left.ic.x.(process_type) - x_platform;
right_ic = mouse.right.ic.x.(process_type) - x_platform;

left_hipy = mouse.left.hip.y.(process_type);
right_hipy = mouse.right.hip.y.(process_type);
left_icy = mouse.left.ic.y.(process_type);
right_icy = mouse.right.ic.y.(process_type);
degree = 2;

mean_midline = ponderatedMean(config, mouse, 's', 2, 'x', mouse.midline.up, mouse.midline.mid, mouse.midline.end);
mean_midline = smoothdata(mean_midline, 'gaussian', 10) - x_platform;
plot_frames = linspace(1, mouse.frames, mouse.frames); 

central_mid_position = mouse.midline.mid.x.(process_type) - initial_mid_midline_position;

midline_displacement.max_right = max(mean_midline(falling_platform_frame:min(leg_retraction_frame + end_check, mouse.frames)));
midline_displacement.max_left = min(mean_midline(falling_platform_frame:min(leg_retraction_frame + end_check, mouse.frames)));

pivot_plot = mouse.midline.up.x.(process_type) - mouse.midline.end.x.(process_type);

central_pivot = pivot_plot - mean(pivot_plot(max(1,falling_platform_frame-10)));
pivot_midline.clock = max(central_pivot(falling_platform_frame:min(leg_retraction_frame + end_check, mouse.frames)));
pivot_midline.nclock = min(central_pivot(falling_platform_frame:min(leg_retraction_frame + end_check, mouse.frames)));

if strcmp(plot_bool, 'true')
%     figure_midline.general = figure;
%     hold on;
%    
%     nb_plot = 1;
%     nb_plot2 = 3;
% 
%     subplot(nb_plot, nb_plot2, 1)
%     plot(mean_midline, plot_frames, 'LineWidth', 1.5, 'DisplayName', 'Ponderated mean midline');
%     hold on;
%     plot(up_midline, plot_frames, 'DisplayName', 'Up midline');
%     plot(mid_midline, plot_frames, 'DisplayName', 'Mid midline');
%     plot(end_midline, plot_frames, 'DisplayName', 'End midline');
%     set(gca,'Ydir','reverse')
%     linePlot('falling_platform_frame', falling_platform_frame, 'leg_retraction_frame', leg_retraction_frame, 'leg_on_platform_frame', leg_on_platform_frame, 'line_orientation', 'horizontal');
%     linePlot('line', 0, 'line_orientation', 'vertical');
%     linePlot('line', x_platform2-x_platform, 'line_orientation', 'vertical');
% 
%     ylabel('Time frames');
%     xlabel('X value [pixels]');
%     axis auto;                        % not strictly necessary
%     limits = max( abs(gca().XLim) )*1.1;  % take the larger of the two "nice" endpoints
%     xlim( [-limits, limits] );  
%     title('Midline displacement');
%     legend('Location', 'northoutside');
% 
%     subplot(nb_plot, nb_plot2, 2)
%     plot(mean_midline, plot_frames, 'LineWidth', 1.5, 'DisplayName', 'Ponderated mean midline');
%     hold on;
%     set(gca,'Ydir','reverse')
%     linePlot('falling_platform_frame', falling_platform_frame, 'leg_retraction_frame', leg_retraction_frame, 'leg_on_platform_frame', leg_on_platform_frame, 'line_orientation', 'horizontal');
%     linePlot('line', 0, 'line_orientation', 'vertical');
%     ylabel('Time frames');
%     xlabel('X value [pixels]');
%     axis auto;                        % not strictly necessary
%     limits = max( abs(gca().XLim) )*1.1;  % take the larger of the two "nice" endpoints
%     xlim( [-limits, limits] );  
%     title('Midline ponderated mean displacement');
%     legend('Location', 'northoutside');
% 
%     %set(gcf, 'Position', [   560     1   560   954]);
%     set(gcf, 'Position', [ 1013     1     668 954]);

%     subplot(nb_plot, nb_plot2, 3)
%     plot(mean_midline, plot_frames, 'LineWidth', 1.5, 'DisplayName', 'Ponderated mean midline');
%     hold on;
%     plot(left_knee, plot_frames, 'DisplayName', 'Left knee');
%     plot(right_knee, plot_frames, 'DisplayName', 'Right knee');
%     plot(left_ankle, plot_frames, 'DisplayName', 'Left ankle');
%     plot(right_ankle, plot_frames, 'DisplayName', 'Right ankle');
%     set(gca,'Ydir','reverse')
%     linePlot('falling_platform_frame', falling_platform_frame, 'leg_retraction_frame', leg_retraction_frame, 'leg_on_platform_frame', leg_on_platform_frame, 'line_orientation', 'horizontal');
%     linePlot('line', 0, 'line_orientation', 'vertical');
%     ylabel('Time frames');
%     xlabel('X value [pixels]');
%     axis auto;                        % not strictly necessary
%     limits = max( abs(gca().XLim) )*1.1;  % take the larger of the two "nice" endpoints
%     xlim( [-limits, limits] );  
%     title('Midline displacement');
%     legend('Location', 'northoutside');
%     sgtitle(mouse.name, 'Interpreter', 'None');

%  subplot(nb_plot, nb_plot2, 3)
%     plot(mean_midline, plot_frames, 'LineWidth', 1.5, 'DisplayName', 'Ponderated mean midline');
%     hold on;
%     plot(left_ic, plot_frames, 'DisplayName', 'Left ic');
%     plot(right_ic, plot_frames, 'DisplayName', 'Right ic');
%     plot(left_hip, plot_frames, 'DisplayName', 'Left hip');
%     plot(right_hip, plot_frames, 'DisplayName', 'Right hip');
%     set(gca,'Ydir','reverse')
%     linePlot('falling_platform_frame', falling_platform_frame, 'leg_retraction_frame', leg_retraction_frame, 'leg_on_platform_frame', leg_on_platform_frame, 'line_orientation', 'horizontal');
%     linePlot('line', 0, 'line_orientation', 'vertical');
%     ylabel('Time frames');
%     xlabel('X value [pixels]');
%     axis auto;                        % not strictly necessary
%     limits = max( abs(gca().XLim) )*1.1;  % take the larger of the two "nice" endpoints
%     xlim( [-limits, limits] );  
%     title('Midline displacement');
%     legend('Location', 'northoutside');
%     sgtitle(mouse.name, 'Interpreter', 'None');

% figure;
%     %plot(mean_midline, plot_frames, 'LineWidth', 1.5, 'DisplayName', 'Ponderated mean midline');
%     hold on;
%     plot(left_icy-right_icy, 'DisplayName', 'ic');
%     %plot(right_icy, plot_frames, 'DisplayName', 'Right ic');
%     plot(left_hipy-right_hipy, 'DisplayName', 'hip');
%     %plot(right_hipy, plot_frames, 'DisplayName', 'Right hip');
%     %set(gca,'Ydir','reverse')
%     linePlot('falling_platform_frame', falling_platform_frame, 'leg_retraction_frame', leg_retraction_frame, 'leg_on_platform_frame', leg_on_platform_frame, 'line_orientation', 'vertical');
%     linePlot('line', 0, 'line_orientation', 'horizontal');
%     xlabel('Time frames');
%     ylabel('Y value [pixels]');
%     axis auto;                        % not strictly necessary
%     %limits = max( abs(gca().XLim) )*1.1;  % take the larger of the two "nice" endpoints
%     %xlim( [-limits, limits] );  
%     title('Midline displacement');
%     legend('Location', 'northoutside');
%     sgtitle(mouse.name, 'Interpreter', 'None');
%     set(gca,'FontSize',15);
% end
end
if strcmp(plot_bool, 'midline_mov') || strcmp(plot_bool, 'true')
    figure;
    subplot(2,1,1)
    plot(central_mid_position, 'DisplayName', 'Mid midline position')
    linePlot('falling_platform_frame', falling_platform_frame, 'leg_retraction_frame', leg_retraction_frame, 'leg_on_platform_frame', leg_on_platform_frame, 'line_orientation', 'vertical', 'display_type', 'box');
    linePlot('line', 0, 'line_orientation', 'horizontal');
    xlabel('Time frames');
    ylabel('X value [pixels]');
    ylim([-80, 80]);
    title('Mid midline position (centralyzed to the initial position)');
    set(gca, 'Position', [0.1300    0.5534    0.7750    0.3350]);
    set(gca,'FontSize',15);
    legend show;
    
    subplot(2,1,2)
    plot(pivot_plot, 'DisplayName', 'Pivot')
    linePlot('falling_platform_frame', falling_platform_frame, 'leg_retraction_frame', leg_retraction_frame, 'leg_on_platform_frame', leg_on_platform_frame, 'line_orientation', 'vertical', 'display_type', 'box');
    linePlot('line', 0, 'line_orientation', 'horizontal');
    xlabel('Time frames');
    ylabel('X value [pixels]');
    ylim([-70, 70]);
    title('Difference between up and end midline');
    sgtitle(mouse.name, 'Interpreter', 'None');
    set(gcf, 'Position', [463     1   574   954]);
    set(gca,'FontSize',15);
    legend show;
    lgd = legend;
    lgd.Location = 'southeast';
end

if strcmp(plot_bool, 'sum') %to plot midline trajectories for several mice
    to_plot = central_mid_position-mean(central_mid_position(1:start_norm));
    to_plot = to_plot(falling_platform_frame-20:min(mouse.frames,leg_on_platform_frame+20));
    plot(to_plot, markers, 'MarkerIndices',1:5:length(to_plot), 'DisplayName', 'Mid midline position');
%     linePlot('falling_platform_frame', falling_platform_frame, 'leg_retraction_frame', leg_retraction_frame, 'leg_on_platform_frame', leg_on_platform_frame, 'line_orientation', 'vertical', 'display_type', 'box');
%     linePlot('line', 0, 'line_orientation', 'horizontal');
    xlabel('Time frames');
    ylabel('X value [pixels]');
    %ylim([-60, 60]);
    title('Mid midline position (centralyzed to the initial position)');
    %set(gca, 'Position', [0.1300    0.5534    0.7750    0.3350]);
    set(gca,'FontSize',15);
    legend show;

end
if strcmp(plot_bool, 'sum2')
    to_plot = smoothdata(pivot_plot - mean(pivot_plot(1:start_norm)), 'gaussian', 10);
    to_plot = to_plot(falling_platform_frame-20:min(mouse.frames,leg_on_platform_frame+20));
    plot(to_plot, markers, 'MarkerIndices',1:5:length(to_plot), 'DisplayName', 'Pivot');
%     linePlot('falling_platform_frame', falling_platform_frame, 'leg_retraction_frame', leg_retraction_frame, 'leg_on_platform_frame', leg_on_platform_frame, 'line_orientation', 'vertical', 'display_type', 'box');
%     linePlot('line', 0, 'line_orientation', 'horizontal');
    xlabel('Time frames');
    ylabel('X value [pixels]');
    %ylim([-70, 70]);
    title('Difference between up and end midline');
    set(gcf, 'Position', [463     1   574   954]);
    set(gca,'FontSize',15);
    legend show;
    lgd = legend;
    lgd.Location = 'southeast';
end

if strcmp(stage_figure, 'true')
    figure_midline.stage = figure;
    plot(mean_midline, plot_frames, 'LineWidth', 1.5, 'DisplayName', 'Ponderated mean midline');
    hold on;
    plot(up_midline, plot_frames, 'DisplayName', 'Up midline');
    plot(mid_midline, plot_frames, 'DisplayName', 'Mid midline');
    plot(end_midline, plot_frames, 'DisplayName', 'End midline');
    set(gca,'Ydir','reverse')
    linePlot('falling_platform_frame', falling_platform_frame, 'leg_retraction_frame', leg_retraction_frame, 'leg_on_platform_frame', leg_on_platform_frame, 'line_orientation', 'horizontal', 'display_type', 'on_plot');
    linePlot('line', 0, 'line_orientation', 'vertical');
    linePlot('line', x_platform2-x_platform, 'line_orientation', 'vertical');
    linePlot('line', x_platform1-x_platform, 'line_orientation', 'vertical');
    ylabel('Time frames');
    xlabel('X value [pixels]');
    axis auto;                        % not strictly necessary
    limits = max( abs(gca().XLim) )*1.1;  % take the larger of the two "nice" endpoints
    xlim( [-limits, limits] );  
    title('Midline displacement');
%     legend('Location', 'northoutside');
    sgtitle(mouse.name, 'Interpreter', 'None');
    set(gcf, 'Position', [3     1   459   954]);
    set(gca, 'Position', [0.1198    0.0734    0.7843    0.8249]);
    set(gca,'FontSize',15);
end

end

