function [] = plotStickPlot(config, x_coord, y_coord, plot_figure, nb_frame, labelJoint, platformDelay, fallPlatform_bool, legRetraction_frame, legRetraction_bool, leg_on_platform_frame, leg_on_platform_bool, x1, shiftPlot, x0, unit, myVideo)
% Function to plot the stick and the joints of the stickPlot 
vid_bool = 'false';
switch nargin
    case 17
        vid_bool = 'true';
end
fps = config.fps;

if strcmp(unit, 'ms')
    xlim([x1-4*shiftPlot x1+shiftPlot*(8+nb_frame)]);
    if fps == 90
        xticks(x1:9/2*shiftPlot:(x1+shiftPlot*(10+nb_frame)))
        xticklabels(x0/fps*1000:9/2/fps*1000:(x0+nb_frame+10)/fps*1000)
    else
        xticks(x1:3*shiftPlot:(x1+shiftPlot*(6+170)))
        xticklabels(x0/fps*1000:3/fps*1000:(x0+170+5)/fps*1000)
    end
    xlabel('Time [ms]');
    ylabel('Joint y position [Pixels]');
    ymax = max(max(y_coord))+0.5*(abs(max(max(y_coord))));
    ymin = min(min(y_coord))-0.5*(abs(max(max(y_coord))));
    linePlot('line', 0, 'line_orientation', 'horizontal')
    ylim([ymin ymax])
elseif strcmp(unit, 'frames')
    xlim([x1-12*shiftPlot x1+shiftPlot*(11+nb_frame)]);
    xlabel('Time [Frames]');
    ylabel('Joint y position [Pixels]');
    ymax = max(max(y_coord))+0.5*(abs(max(max(y_coord))));
    ymin = min(min(y_coord))-0.5*(abs(max(max(y_coord))));
    linePlot('line', 0, 'line_orientation', 'horizontal')  
    ylim([ymin ymax])
    daspect([1 1 1])
else
    error('Unit not handled');
end
set(gcf, 'Position', [ 1         528        1680         420]);
%set(gca, 'Position', [0.0375    0.1100    0.9512    0.8150]);
for i = 1:nb_frame
    %Set the stick in red for the falling platform frame
    if i == platformDelay && strcmp(fallPlatform_bool, 'true')
        color1 = '#C70039';
        labelMarkerColor = {color1, color1, color1, color1, color1, color1, color1, color1, color1, color1, color1, color1, color1, color1, color1, color1, color1, color1, color1, color1};
        markerSize = 20;
        line = 3;

    %Set the stick in green for the leg retraction frame    
    elseif i == legRetraction_frame && strcmp(legRetraction_bool, 'true')
        color1 = '#009A1E';
        labelMarkerColor = {color1, color1, color1, color1, color1, color1, color1, color1, color1, color1, color1, color1, color1, color1, color1, color1, color1, color1, color1, color1};
        markerSize = 20;
        line = 3;
    elseif i == leg_on_platform_frame && strcmp(leg_on_platform_bool, 'true')
        color1 = '#1A40DA';
        labelMarkerColor = {color1, color1, color1, color1, color1, color1, color1, color1, color1, color1, color1, color1, color1, color1, color1, color1, color1, color1, color1, color1};
        markerSize = 20;
        line = 3;
    else
        labelMarkerColor = {'#4DBEEE', '#0072BD', '#7E2F8E', '#A2142F', '#D95319', '#EDB120', '#77AC30', '#00CC00' '#00FF00' '#33FF33','#4DBEEE', '#0072BD', '#7E2F8E', '#A2142F', '#D95319', '#EDB120', '#77AC30', '#00CC00' '#00FF00' '#33FF33', '#4DBEEE', '#0072BD', '#7E2F8E', '#A2142F', '#D95319', '#EDB120', '#77AC30', '#00CC00' '#00FF00' '#33FF33','#4DBEEE', '#0072BD', '#7E2F8E', '#A2142F', '#D95319', '#EDB120', '#77AC30', '#00CC00' '#00FF00' '#33FF33'};
        color1 = 'k';
        markerSize = 10;
        line = 1;
    end
        
    % Plotting of the joints
    for j=1:length(labelJoint)
        if i == 1
            plot(x_coord(i,j), y_coord (i,j), 'Color', color1, 'Marker', '.', 'MarkerSize', markerSize, 'MarkerEdgeColor', string(labelMarkerColor(1,j)), 'DisplayName', string(labelJoint(1,j)));
        else
            plot(x_coord(i,j), y_coord (i,j), 'Color', color1, 'Marker', '.', 'MarkerSize', markerSize, 'MarkerEdgeColor', string(labelMarkerColor(1,j)));
        end
    end
    
    %Display the legend only one time
    if i==1
        legend('AutoUpdate','off');
    end
    
    %Draw the lines between joints
    plot(x_coord(i,:), y_coord(i,:), 'LineWidth', line, 'Color', color1);
    hold on;
    plot_figure.Annotation.LegendInformation.IconDisplayStyle = 'off';
    if strcmp(vid_bool, 'true')
        % Capture the plot as an image 
        frame = getframe(gcf); %get frame
        writeVideo(myVideo, frame);
    end 
set(gca, 'FontSize', 12)
set(gcf, 'Color', 'w');
set(gca, 'Color', 'w');
end
end

