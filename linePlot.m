function [l, l2] = linePlot(varargin)
%UNTITLED3 Summary of this function goes here
%   Detailed explanation goes here
falling_platform_frame = [];
leg_retraction_frame = [];
leg_on_platform_frame = [];
line = [];
legend_disp_name = [];
legend_disp = 'off';
line_orientation = 'vertical';
display_type = [];
hold on;
l = [];
l2 = [];

for i = 1:2:nargin
    if strcmp(varargin{i}, 'falling_platform_frame')
        falling_platform_frame = varargin{i+1};
    elseif strcmp(varargin{i}, 'leg_retraction_frame')
        leg_retraction_frame = varargin{i+1};
    elseif strcmp(varargin{i}, 'leg_on_platform_frame')
        leg_on_platform_frame = varargin{i+1};
    elseif strcmp(varargin{i}, 'line') && not(strcmp(varargin{i}, 'line_orientation'))
        line = varargin{i+1};
    elseif strcmp(varargin{i}, 'line_orientation')
        line_orientation = varargin{i+1}; 
    elseif strcmp(varargin{i}, 'display_type')
        display_type = varargin{i+1};
    elseif strcmp(varargin{nargin}, 'off') 
        legend_disp = 'off';
    elseif strcmp(varargin{nargin}, 'on') 
        legend_disp = 'on';
        legend_disp_name = varargin{nargin-1};
    else
        %error('Input not possible');
    end
end

if strcmp(display_type, 'on_plot')  
    if strcmp(line_orientation, 'vertical')
        if not(isempty(falling_platform_frame))
            l = xline(falling_platform_frame,'-.', {'Falling', 'platform'}, 'FontSize', 12, 'Color','k');
            l.LabelVerticalAlignment = 'bottom';
            l.LabelHorizontalAlignment = 'center';
            l.Annotation.LegendInformation.IconDisplayStyle = 'off';
        end
        if not(isempty(leg_retraction_frame))
            l = xline(leg_retraction_frame,'-.', {'Leg retraction'}, 'FontSize', 12, 'Color','r');
            l.LabelVerticalAlignment = 'bottom';
            l.LabelHorizontalAlignment = 'center';
            l.Annotation.LegendInformation.IconDisplayStyle = 'off';
        end
        if not(isempty(leg_on_platform_frame))
            l = xline(leg_on_platform_frame,'-.', {'Leg back on', 'platform'}, 'FontSize', 12,'Color','b');
            l.LabelVerticalAlignment = 'bottom';
            l.LabelHorizontalAlignment = 'center';
            l.Annotation.LegendInformation.IconDisplayStyle = 'off';
        end   
        if not(isempty(line))
            if not(isempty(legend_disp_name))
                l = xline(line,'-.', {legend_disp_name}, 'FontSize', 12,'Color','b');
                l.LabelVerticalAlignment = 'bottom';
                l.LabelHorizontalAlignment = 'center';
                l.Annotation.LegendInformation.IconDisplayStyle = 'off';
            else
                l = xline(line,'-.','Color','k');
                l.Annotation.LegendInformation.IconDisplayStyle = 'off';
            end
        end
    elseif strcmp(line_orientation, 'horizontal')
        if not(isempty(falling_platform_frame))
            l = yline(falling_platform_frame,'-.', {'Falling', 'platform'}, 'FontSize', 12, 'Color','k');
            l.LabelVerticalAlignment = 'middle';
            l.LabelHorizontalAlignment = 'left';
            l.Annotation.LegendInformation.IconDisplayStyle = 'off';
        end
        if not(isempty(leg_retraction_frame))
            l = yline(leg_retraction_frame,'-.', {'Leg retraction'}, 'FontSize', 12, 'Color','r');
            l.LabelVerticalAlignment = 'middle';
            l.LabelHorizontalAlignment = 'left';
            l.Annotation.LegendInformation.IconDisplayStyle = 'off';
        end
        if not(isempty(leg_on_platform_frame))
            l = yline(leg_on_platform_frame,'-.', {'Leg back on', 'platform'}, 'FontSize', 12, 'Color','b');
            l.LabelVerticalAlignment = 'middle';
            l.LabelHorizontalAlignment = 'left';
            l.Annotation.LegendInformation.IconDisplayStyle = 'off';
        end
        if not(isempty(line))
            if not(isempty(legend_disp_name))
                l = yline(line,'-.', {legend_disp_name}, 'FontSize', 12,'Color','b');
                l.LabelVerticalAlignment = 'middle';
                l.LabelHorizontalAlignment = 'left';
                l.Annotation.LegendInformation.IconDisplayStyle = 'off';
            else
                l = yline(line,'-.','Color','k');
                l.Annotation.LegendInformation.IconDisplayStyle = 'off';
            end
        end
    else   
        error('Line orientation not found');
    end    
elseif strcmp(display_type, 'box')
    if strcmp(line_orientation, 'vertical')
        if not(isempty(falling_platform_frame))
            l2 = xline(falling_platform_frame,'-.', 'DisplayName', 'Falling platform', 'Color','k');
        end
        if not(isempty(leg_retraction_frame))
            l2 = xline(leg_retraction_frame,'-.', 'DisplayName', 'Leg retraction', 'Color','r');
        end
        if not(isempty(leg_on_platform_frame))
            l2 = xline(leg_on_platform_frame,'-.', 'DisplayName', 'Leg back on platform','Color','b');
        end
        l2.Annotation.LegendInformation.IconDisplayStyle = 'on';
        if not(isempty(line))
            if not(isempty(legend_disp_name))
                l2 = xline(line,'-.', 'DisplayName', legend_disp_name,'Color','b');
            else
                l = xline(line,'-.','Color','k');
                set(get(get(l,'Annotation'),'LegendInformation'),'IconDisplayStyle','off');
            end
        end
    elseif strcmp(line_orientation, 'horizontal')
        if not(isempty(falling_platform_frame))
            l2 = yline(falling_platform_frame,'-.', 'DisplayName', 'Falling platform', 'Color','k');
        end
        if not(isempty(leg_retraction_frame))
            l2 = yline(leg_retraction_frame,'-.', 'DisplayName', 'Leg retraction', 'Color','r');   
        end
        if not(isempty(leg_on_platform_frame))
            l2 = yline(leg_on_platform_frame,'-.', 'DisplayName', 'Leg back on platform','Color','b'); 
        end

        if not(isempty(line))
            if not(isempty(legend_disp_name))
                l2 = yline(line,'-.', 'DisplayName', legend_disp_name, 'Color','b');
            else
                l = yline(line,'-.','Color','k');
                l.Annotation.LegendInformation.IconDisplayStyle = 'off';
            end
        end
    else   
        error('Line orientation not found');
    end
else
    if strcmp(line_orientation, 'vertical')
        if not(isempty(falling_platform_frame))
            l = xline(falling_platform_frame,'-.', 'Color','k');
            l.Annotation.LegendInformation.IconDisplayStyle = 'off';
        end
        if not(isempty(leg_retraction_frame))
            l = xline(leg_retraction_frame,'-.', 'Color','r');
            l.Annotation.LegendInformation.IconDisplayStyle = 'off';
        end
        if not(isempty(leg_on_platform_frame))
            l = xline(leg_on_platform_frame,'-.','Color','b');
            l.Annotation.LegendInformation.IconDisplayStyle = 'off';
        end   
        if not(isempty(line))
            l = xline(line,'Color','#4DBEEE');
            l.Annotation.LegendInformation.IconDisplayStyle = 'off';
        end
    elseif strcmp(line_orientation, 'horizontal')
        if not(isempty(falling_platform_frame))
            l = yline(falling_platform_frame,'-.', 'Color','k');
            l.Annotation.LegendInformation.IconDisplayStyle = 'off';
        end
        if not(isempty(leg_retraction_frame))
            l = yline(leg_retraction_frame,'-.', 'Color','r');  
            l.Annotation.LegendInformation.IconDisplayStyle = 'off';
        end
        if not(isempty(leg_on_platform_frame))
            l = yline(leg_on_platform_frame,'-.','Color','b');
            l.Annotation.LegendInformation.IconDisplayStyle = 'off';
        end
        if not(isempty(line))
            l = yline(line,'-.','Color','#4DBEEE');
            l.Annotation.LegendInformation.IconDisplayStyle = 'off';
        end
    else   
        error('Line orientation not found');
    end
end
    l2.Annotation.LegendInformation.IconDisplayStyle = 'on';
    l2.FontSize = 12;
    l.Annotation.LegendInformation.IconDisplayStyle = 'off';
end

