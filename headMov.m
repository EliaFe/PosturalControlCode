function [head_forward, head_upward, step_forward, figure_head] = headMov(varargin)
%UNTITLED Summary of this function goes here
% Study if the head move forward

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
head_forward = 0;
head_upward = 0;
step_forward = 0;
mouse_type = 'random';
process_type = 's';
plot_bool = 'false';
p_value = config.p_value;
falling_platform_frame = 0;
leg_retraction_frame = 0;
leg_on_platform_frame = 0;
figure_head = [];

for i = 3:2:nargin
   if strcmp(varargin{i}, 'mouse_type')
       mouse_type = varargin{i+1};
   elseif strcmp(varargin{i}, 'process_type')
       process_type = varargin{i+1};
   elseif strcmp(varargin{i}, 'falling_platform_frame')
       falling_platform_frame = varargin{i+1};
   elseif strcmp(varargin{i}, 'leg_retraction_frame')
       leg_retraction_frame = varargin{i+1};
   elseif strcmp(varargin{i}, 'leg_on_platform_frame')
       leg_on_platform_frame = varargin{i+1};
   elseif strcmp(varargin{i}, 'plot_bool')
       plot_bool = varargin{i+1};
   elseif strcmp(varargin{i}, 'stage_figure')
       stage_figure = varargin{i+1};
   end
end

if falling_platform_frame == 0
    falling_platform_frame = fallingPlatform(config, mouse);
end

if strcmp(falling_platform_frame, 'true')
    falling_platform_frame = fallingPlatform(config, mouse);
end

if leg_retraction_frame == 0
    leg_retraction_frame = legRetraction(config, mouse, 'falling_platform_frame', falling_platform_frame);
end

if strcmp(leg_retraction_frame, 'true')
    leg_retraction_frame = legRetraction(config, mouse, 'falling_platform_frame', falling_platform_frame);
end

if leg_on_platform_frame == 0
    leg_on_platform_frame = legOnPlatform(config, mouse, 'falling_platform_frame', falling_platform_frame);
end

if strcmp(leg_on_platform_frame, 'true')
    leg_on_platform_frame = legOnPlatform(config, mouse, 'falling_platform_frame', falling_platform_frame);
end

process_type = {'r', 's'};
%dlcAnatomyPlot(config, mouse, process_type, 'head');

%     dlcAnatomyPlot(config, mouse, process_type, 'leg');
%     set(gcf, 'Position',  [1011    2    668    953]);


process_type =  'r';
degree = 2;

center_mirror1 = mean(mouse.env.cm3.x.(process_type));
center_mirror2 = mean(mouse.env.spm1.x.(process_type));

head1x = mouse.m1_midline.head.x.(process_type) - center_mirror1;
head2x = -(mouse.m2_midline.head.x.(process_type) - center_mirror2);
nose1x = mouse.m1_midline.nose.x.(process_type) - center_mirror1;
nose2x = -(mouse.m2_midline.nose.x.(process_type) - center_mirror2);
midline1x = mouse.m1_midline.up.x.(process_type) - center_mirror1;
midline2x = -(mouse.m2_midline.up.x.(process_type) - center_mirror2);
midline2_1x = mouse.m1_midline.mid.x.(process_type) - center_mirror1;
midline2_2x = -(mouse.m2_midline.mid.x.(process_type) - center_mirror2);

head = (head1x.*(mouse.m1_midline.head.p.r).^degree+head2x.*(mouse.m2_midline.head.p.r).^degree)./((mouse.m1_midline.head.p.r).^degree+(mouse.m2_midline.head.p.r).^degree);
nose = (nose1x.*(mouse.m1_midline.nose.p.r).^degree+nose2x.*(mouse.m2_midline.nose.p.r).^degree)./((mouse.m1_midline.nose.p.r).^degree+(mouse.m2_midline.nose.p.r).^degree);
midline = (midline1x.*(mouse.m1_midline.up.p.r).^degree+midline2x.*(mouse.m2_midline.up.p.r).^degree)./((mouse.m1_midline.up.p.r).^degree+(mouse.m2_midline.up.p.r).^degree);
midline2 = (midline2_1x.*(mouse.m1_midline.mid.p.r).^degree+midline2_2x.*(mouse.m2_midline.mid.p.r).^degree)./((mouse.m1_midline.mid.p.r).^degree+(mouse.m2_midline.mid.p.r).^degree);

if strcmp(plot_bool, 'true')
    nbfigure = 2;
    nbfigure2 = 2;
    
    figure_head.general = figure;
    subplot(nbfigure,nbfigure2,1)
    plot(smoothdata(nose1x, 'gaussian', 10), 'DisplayName', 'Nose mirror 1');
    hold on;
    plot(smoothdata(nose2x, 'gaussian', 10), 'DisplayName', 'Nose mirror 2');
    plot(smoothdata(nose, 'gaussian', 10), 'LineWidth', 1.5, 'DisplayName', 'Nose ponderated mean');
    plot(smoothdata(head1x, 'gaussian', 10), 'DisplayName', 'Head mirror 1');
    plot(smoothdata(head2x, 'gaussian', 10), 'DisplayName', 'Head mirror 2');
    plot(smoothdata(head, 'gaussian', 10), 'LineWidth', 1.5, 'DisplayName', 'Head ponderated mean');
    plot(smoothdata(midline1x, 'gaussian', 10), 'DisplayName', 'Up midline mirror 1');
    plot(smoothdata(midline2x, 'gaussian', 10), 'DisplayName', 'Up midline mirror 2');
    plot(smoothdata(midline, 'gaussian', 10), 'LineWidth', 1.5, 'DisplayName', 'Up midline ponderated mean');
    plot(smoothdata(midline2_1x, 'gaussian', 10), 'DisplayName', 'Mid midline mirror 1');
    plot(smoothdata(midline2_2x, 'gaussian', 10), 'DisplayName', 'Mid midline mirror 2');
    plot(smoothdata(midline2, 'gaussian', 10), 'LineWidth', 1.5, 'DisplayName', 'Mid midline ponderated mean');
    legend show;
    linePlot('line_orientation', 'vertical', 'falling_platform_frame', falling_platform_frame, 'leg_retraction_frame', leg_retraction_frame, 'leg_on_platform_frame', leg_on_platform_frame, 'line', 0);
    ylabel('X mirror value - Z back view [Pixel]');
    xlabel('Time frames');
%     figure;
%     subplot(nbfigure,1,1)
%     plot(smoothdata(head1x, 'gaussian', 10));
%     hold on;
%     plot(smoothdata(head2x, 'gaussian', 10));
%     plot(smoothdata(head, 'gaussian', 10));
%     linePlot('line_orientation', 'vertical', 'falling_platform_frame', falling_platform_frame, 'leg_retraction_frame', leg_retraction_frame, 'leg_on_platform_frame', leg_on_platform_frame, 'line', 0);
%     ylabel('X mirror value - Z back view [Pixel]');
%     xlabel('Time frames');
%     legend('Head mirror 1', 'Head mirror 2', 'Head ponderated mean');
% 
%     subplot(nbfigure,1,2)
%     plot(smoothdata(nose1x, 'gaussian', 10));
%     hold on;
%     plot(smoothdata(nose2x, 'gaussian', 10));
%     plot(smoothdata(nose, 'gaussian', 10));
%     linePlot('line_orientation', 'vertical', 'falling_platform_frame', falling_platform_frame, 'leg_retraction_frame', leg_retraction_frame, 'leg_on_platform_frame', leg_on_platform_frame, 'line', 0);
%     ylabel('X mirror value - Z back view [Pixel]');
%     xlabel('Time frames');
%     legend('Nose mirror 1', 'Nose mirror 2', 'Nose ponderated mean');
% 
%     subplot(nbfigure,1,3)
%     plot(smoothdata(midline1x, 'gaussian', 10));
%     hold on;
%     plot(smoothdata(midline2x, 'gaussian', 10));
%     plot(smoothdata(midline, 'gaussian', 10));
%     linePlot('line_orientation', 'vertical', 'falling_platform_frame', falling_platform_frame, 'leg_retraction_frame', leg_retraction_frame, 'leg_on_platform_frame', leg_on_platform_frame, 'line', 0);
%     ylabel('X mirror value - Z back view [Pixel]');
%     xlabel('Time frames');
%     legend('Up midline mirror 1', 'Up midline mirror 2', 'Up midline ponderated mean');

    subplot(nbfigure,nbfigure2, 3)
    %diff_head_midline = smoothdata(head, 'gaussian', 10)-smoothdata(midline, 'gaussian', 10);
    diff_head_midline = smoothdata(mouse.m2_midline.up.x.s, 'gaussian', 10) - smoothdata(mouse.m2_midline.head.x.s, 'gaussian', 10);
    d =  sqrt((mouse.m2_midline.head.x.s-mouse.m2_midline.nose.x.s).^2 + (mouse.m2_midline.head.y.s-mouse.m2_midline.nose.y.s).^2);
    maxd = max(d);
    norm_d = d./maxd;
    norm_d_plot = norm_d.*100;
        
    %diff_head_midline = diff_head_midline - 
    diff_head_midline_norm = diff_head_midline./norm_d;
    
    plot(diff_head_midline-mean(diff_head_midline));
    linePlot('line_orientation', 'vertical', 'falling_platform_frame', falling_platform_frame, 'leg_retraction_frame', leg_retraction_frame, 'leg_on_platform_frame', leg_on_platform_frame, 'line', 0);
    yline(0,'-.','Color','k');
%    ylim([-40 80])
    ylabel('X mirror value - Z back view [Pixel]');
    xlabel('Time frames');
    title('Diff ponderated mean between head and midline');
    set(gcf, 'Position',  [9     2   994   953])
    sgtitle(mouse.name, 'Interpreter', 'none');
    
    subplot(nbfigure, nbfigure2, 2)
    plot(norm_d_plot);
    ylim([0 100]);
    ylabel('Length [%]');
    xlabel('Time frame');
    title('Normalized distance Head - Nose')
    linePlot('line_orientation', 'vertical', 'falling_platform_frame', falling_platform_frame, 'leg_retraction_frame', leg_retraction_frame, 'leg_on_platform_frame', leg_on_platform_frame, 'display_type', 'on_plot');
    %set(gcf, 'Position', [1077           3         604         482]);
    
    subplot(nbfigure, nbfigure2, 4)
%     plot(diff_head_midline_norm-mean(diff_head_midline_norm));
%     hold on;
    plot(diff_head_midline-mean(diff_head_midline));
    linePlot('line_orientation', 'vertical', 'falling_platform_frame', falling_platform_frame, 'leg_retraction_frame', leg_retraction_frame, 'leg_on_platform_frame', leg_on_platform_frame, 'line', 0);
    yline(0,'-.','Color','k');
%    ylim([-40 80])
    ylabel('X mirror value - Z back view [Pixel]');
    xlabel('Time frames');
    title('Normalized diff ponderated mean between head and midline');
    %legend('Normalized', 'Raw')
    %set(gcf, 'Position',  [9     2   994   953])
    set(gcf, 'Position',  [1           2        1680         953]);
sgtitle(mouse.name, 'Interpreter', 'none');
    
end

if strcmp(stage_figure, 'true')
    figure_head.stage = figure;
    diff_head_midline = smoothdata(head, 'gaussian', 10)-smoothdata(midline, 'gaussian', 10);
    diff_head_midline = diff_head_midline - mean(diff_head_midline(1:falling_platform_frame-1));
    plot(diff_head_midline);
    linePlot('falling_platform_frame', falling_platform_frame, 'leg_on_platform_frame', leg_on_platform_frame, 'leg_retraction_frame', leg_retraction_frame, 'line_orientation', 'vertical', 'display_type', 'on_plot');
    %linePlot('line_orientation', 'vertical', 'falling_platform_frame', falling_platform_frame, 'leg_retraction_frame', leg_retraction_frame, 'leg_on_platform_frame', leg_on_platform_frame, 'display_type', 'on_plot');
    yline(0,'-.','Color','k');
    ylabel('X mirror value - Z back view [Pixel]');
    xlabel('Time frames');
    ylim([-20 20]);
    title('Diff ponderated mean between head and midline');
    set(gcf, 'Position', [463         552        1206         403]);
    set(gca, 'Position', [0.0553    0.1086    0.9165    0.7648]);
    sgtitle(mouse.name, 'Interpreter', 'none');
    set(gca,'FontSize',15);
    legend('off');
end
end

