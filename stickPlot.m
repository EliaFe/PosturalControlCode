function [figure_stick, vid_name] = stickPlot(varargin)
%function [plot_figure, vid_name] = stickPlot(mouse, anatomy, process_type, start_frame, shift_frame, shift_plot, nb_frame, window, vid_bool, falling_platform_frame, leg_retraction_frame)
%
% [plot_figure, vid_name] = stickPlot(config, mouse, anatomy, process_type, start_frame, shift_frame, shift_plot, nb_frame, vid_bool, falling_platform_frame, leg_retraction_frame)
% [plot_figure, vid_name] = stickPlot(config, mouse, 'right_leg', 's', 10, 1, 30, 150, 'false', 'false', 'false', 'false')
%
% Function to produce a stick plot
%
% INUPUT:
%  "config" : structure describing the basic info of data we are handling
%  "mouse": struct with values of joints
%  "anatomy": 'leg' or 'midline'; which part we want to represent with a
%       stick view
%  "process_type": which processing of data we want, see dlcSmooth function
%  "start_frame": frame for which the stick plot begin
%  "shift_frame": in order to choose if every frame is represented or some
%       are ommitted
%  "shift_plot": translation measure between each stick
%  "nb_frame": number of frames to plot 
%  "vid_bool": if a video .mp4 of the stickPlot wanted to be produced
%  "falling_platform_frame" : to draw the limit when the platform is falling and
%  shift the stickPlot, put "false" if not wanted
%  "legRetractionBool": to draw the frame at which the leg begin to be
%  retracted
%
% OUTPUT:
%  "plot_figure": stick plot object
%  "vid_name" : name of the video produced if vid_bool is 'true', 

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
            error('First entry must be the config structure, if none config file: see function defaultConfig.');
        end
        if isa(varargin{2}, 'struct')
            mouse = varargin{2};
        else
            error('First entry must be the structure describing the mouse, see function dlcSmooth.');
        end
end

platform_delay = 9;

anatomy = 'right_leg';
process_type = 's';
start_frame = 1;
shift_frame = 1;
shift_plot = 40;
nb_frame = 100;
vid_bool = 'false';
fall_platform_bool = 'false';
leg_retraction_bool = 'false';
falling_platform_frame = 1;
leg_retraction_frame = 1;
unit = 'ms';

for i = 3:2:nargin
   if strcmp(varargin{i}, 'mouse')
       mouse = varargin{i+1};
   elseif strcmp(varargin{i}, 'anatomy')
       anatomy = varargin{i+1};
   elseif strcmp(varargin{i}, 'process_type')
       process_type = varargin{i+1};
   elseif strcmp(varargin{i}, 'start_frame')
       start_frame = varargin{i+1};
   elseif strcmp(varargin{i}, 'shift_frame')
       shift_frame = varargin{i+1};    
   elseif strcmp(varargin{i}, 'shift_plot')
       shift_plot = varargin{i+1};
   elseif strcmp(varargin{i}, 'nb_frame')
       nb_frame = varargin{i+1};
   elseif strcmp(varargin{i}, 'vid_bool')
       vid_bool = varargin{i+1};
   elseif strcmp(varargin{i}, 'unit')
       unit = varargin{i+1};
   elseif strcmp(varargin{i}, 'falling_platform_frame')
       falling_platform_frame = varargin{i+1};
       if strcmp(falling_platform_frame, 'false')
            fall_platform_bool = 'false';
       elseif strcmp(falling_platform_frame, 'true')
           falling_platform_frame = fallingPlatform(config, mouse);
           fall_platform_bool = 'true';
       else
           fall_platform_bool = 'true';
       end
   elseif strcmp(varargin{i}, 'leg_retraction_frame')
       leg_retraction_frame = varargin{i+1};
       if strcmp(leg_retraction_frame, 'false')
            leg_retraction_bool = 'false';
       elseif strcmp(leg_retraction_frame, 'true')
           leg_retraction_bool = 'true';
           leg_retraction_frame = 'ToCompute'; % This variable will be computed later
       else
          leg_retraction_bool = 'true';
       end
   elseif strcmp(varargin{i}, 'leg_on_platform_frame')
       leg_on_platform_frame = varargin{i+1};
       if strcmp(leg_on_platform_frame, 'false')
            leg_on_platform_bool = 'false';
       elseif strcmp(leg_on_platform_frame, 'true')
           leg_on_platform_bool = 'true';
           leg_on_platform_frame = 'ToCompute'; % This variable will be computed later
       else
          leg_on_platform_bool = 'true';
       end
   else
       error('Unknown input');
   end
end

nb_frame = nb_frame/shift_frame;

nb_frame = min(nb_frame, mouse.frames-1);

if strcmp(vid_bool, 'true')
    vid_name = strcat(mouse.name, 'stick', '.mp4');
    % Initialize video
    myVideo = VideoWriter(vid_name, 'MPEG-4'); %open video file
    myVideo.FrameRate = config.fps; 
    open(myVideo)
end

yplat = mean(mouse.env.right_platform2.y.s(start_frame:start_frame+10)); % Y position of the platform
x0 = start_frame;
figure_stick = plot(0,0);
figure_stick.Annotation.LegendInformation.IconDisplayStyle = 'off'; %(avoid legend for the point (0,0)
hold on;
sgtitle(mouse.name, 'Interpreter','none', 'FontSize', 20);

if strcmp(fall_platform_bool, 'true')
   start_frame = falling_platform_frame-platform_delay; %Shift the plot to begin at "platform_delay" frames before the platform is falling
   yplat = mean((mouse.env.right_platform2.y.s(start_frame:falling_platform_frame-5)+mouse.env.stable_right_platform.y.s(start_frame:falling_platform_frame-5))/2); % Y position of the platform
   x0 = -platform_delay;
   nb_frame = min(nb_frame, mouse.frames-start_frame)
end

if strcmp(leg_retraction_bool, 'true')
    if strcmp(fall_platform_bool, 'true') && strcmp(leg_retraction_frame, 'ToCompute')
        leg_retraction_frame = legRetraction(config, mouse, 'process_type', process_type, 'fallingFrame', falling_platform_frame);
    elseif strcmp(leg_retraction_frame, 'ToCompute')
        leg_retraction_frame = legRetraction(config, mouse, 'process_type', process_type);
    end
    leg_retraction_frame
    leg_retraction_frame = leg_retraction_frame - start_frame;
else
    leg_retraction_frame = 0;
end

if strcmp(leg_on_platform_bool, 'true')
    if strcmp(fall_platform_bool, 'true') && strcmp(leg_on_platform_frame, 'ToCompute')
        leg_on_platform_frame = legOnPlatform(config, mouse, 'process_type', process_type, 'falling_platform_frame', falling_platform_frame);
    elseif strcmp(leg_on_platform_frame, 'ToCompute')
        leg_on_platform_frame = legOnPlatform(config, mouse, 'process_type', process_type);
    end
    leg_on_platform_frame = leg_on_platform_frame - start_frame;
else
    leg_on_platform_frame = 0;
end

%%%%%%%%%%%%%%%%%%%%%%%%%% Right leg Sticklot %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
if strcmp(anatomy, 'right_leg')

%     label_joint = {'Midline up', 'Midline mid', 'IC', 'Hip', 'Knee', 'Ankle', 'Paw', 'Toe'};
    label_joint = {'Midline mid', 'IC', 'Hip', 'Knee', 'Ankle', 'Paw', 'Toe'};
   if strcmp(config.model, 'Long_drop_full')
        label_joint = {'Midline mid', 'Hip', 'Knee', 'Ankle', 'Paw', 'Toe'};
   else
        label_joint = {'Midline mid', 'IC', 'Hip', 'Knee', 'Ankle', 'Paw', 'Toe'};
   end
%     joint = ["ic", "hip", "knee", "ankle", "mtp", "toe"];  
    joint = string(fieldnames(mouse.right));
    x_coord = zeros(nb_frame, length(label_joint));
    y_coord = zeros(nb_frame, length(label_joint));

    for i=1:nb_frame
%         temp_x = mouse.midline.up.x.(process_type)(start_frame+i*shift_frame,1);
%         temp_y = mouse.midline.up.y.(process_type)(start_frame+i*shift_frame,1);
% 
%         temp_x = [temp_x mouse.midline.mid.x.(process_type)(start_frame+i*shift_frame,1)];
%         temp_y = [temp_y mouse.midline.mid.y.(process_type)(start_frame+i*shift_frame,1)];

         temp_x = mouse.midline.mid.x.(process_type)(start_frame+i*shift_frame,1);
         temp_y = mouse.midline.mid.y.(process_type)(start_frame+i*shift_frame,1);
        for j=1:length(joint)
            temp_x = [temp_x, mouse.right.(joint(j)).x.(process_type)(start_frame+i*shift_frame,1)];
            temp_y = [temp_y, mouse.right.(joint(j)).y.(process_type)(start_frame+i*shift_frame,1)];
        end
        x_coord(i,:) = i*shift_plot+temp_x;
        y_coord(i,:) = -yplat+temp_y;
    end
    
    % To define the reference point for the labels
    x1 = mean(x_coord(1,:));   
    
    % Plotting the stick and the joints
    if strcmp(vid_bool, 'true')
        plotStickPlot(config, x_coord, y_coord, figure_stick, nb_frame, label_joint, platform_delay, fall_platform_bool, leg_retraction_frame, leg_retraction_bool, leg_on_platform_frame, leg_on_platform_bool, x1, shift_plot, x0, unit, myVideo)
    else
        plotStickPlot(config, x_coord, y_coord, figure_stick, nb_frame, label_joint, platform_delay, fall_platform_bool, leg_retraction_frame, leg_retraction_bool, leg_on_platform_frame, leg_on_platform_bool, x1, shift_plot, x0, unit)
    end
    if strcmp(vid_bool, 'false')
        vid_name = 'No gif created';
    end
%%%%%%%%%%%%%%%%%%%%%%%%%% Right leg moving Sticklot %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
elseif strcmp(anatomy, 'right_leg_moving')

    label_joint = {'Midline up', 'Midline mid', 'IC', 'Hip', 'Knee', 'Ankle', 'Paw', 'Toe'};
    joint = ["ic", "hip", "knee", "ankle", "mtp", "toe"];    
    x_coord = zeros(nb_frame, length(label_joint));
    y_coord = zeros(nb_frame, length(label_joint));

    for i=1:nb_frame
        temp_x = mouse.midline.up.x.(process_type)(start_frame+i*shift_frame,1);
        temp_y = mouse.midline.up.y.(process_type)(start_frame+i*shift_frame,1);

        temp_x = [temp_x mouse.midline.mid.x.(process_type)(start_frame+i*shift_frame,1)];
        temp_y = [temp_y mouse.midline.mid.y.(process_type)(start_frame+i*shift_frame,1)];
        for j=1:length(joint)
            temp_x = [temp_x, mouse.right.(joint(j)).x.(process_type)(start_frame+i*shift_frame,1)];
            temp_y = [temp_y, mouse.right.(joint(j)).y.(process_type)(start_frame+i*shift_frame,1)];
        end
        x_coord(i,:) = i*shift_plot+temp_x;
        y_coord(i,:) = -yplat+temp_y;
    end
    
    % To define the reference point for the labels
    x1 = mean(x_coord(1,:));   
    %x1 = 1.6
    % Plotting the stick and the joints
    if strcmp(vid_bool, 'true')
        plotStickPlot(config, x_coord, y_coord, figure_stick, nb_frame, label_joint, platform_delay, fall_platform_bool, leg_retraction_frame, leg_retraction_bool, leg_on_platform_frame, leg_on_platform_bool, x1, shift_plot, x0, unit, myVideo)
    else
        plotStickPlot(config, x_coord, y_coord, figure_stick, nb_frame, label_joint, platform_delay, fall_platform_bool, leg_retraction_frame, leg_retraction_bool, leg_on_platform_frame, leg_on_platform_bool, x1, shift_plot, x0, unit)
    end
    if strcmp(vid_bool, 'false')
        vid_name = 'No gif created';
    end

    %%%%%%%%%%%%%%%%%%%%%%%%%% Back Sticklot %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
elseif strcmp(anatomy, 'back')

    label_joint = {'Toe', 'Paw', 'Ankle', 'Knee', 'Hip', 'IC', 'Midline', 'IC', 'Hip', 'Knee', 'Ankle', 'Paw', 'Toe'};
    joint = ["ic", "hip", "knee", "ankle", "mtp", "toe"];
    
    joint_left = ["mtp", "ankle", "knee", "hip", "ic"];
    
    x_coord = zeros(nb_frame, length(label_joint));
    y_coord = zeros(nb_frame, length(label_joint));

    for i=1:nb_frame
        temp_x = mouse.left.toe.x.(process_type)(start_frame+i*shift_frame,1);
        temp_y = mouse.left.toe.y.(process_type)(start_frame+i*shift_frame,1);
        for j=1:length(joint_left)
            temp_x = [temp_x, mouse.left.(joint_left(j)).x.(process_type)(start_frame+i*shift_frame,1)];
            temp_y = [temp_y, mouse.left.(joint_left(j)).y.(process_type)(start_frame+i*shift_frame,1)];
        end
        temp_x = [temp_x, mouse.midline.mid.x.(process_type)(start_frame+i*shift_frame,1)];
        temp_y = [temp_y, mouse.midline.mid.y.(process_type)(start_frame+i*shift_frame,1)];
        
        for j=1:length(joint)
            temp_x = [temp_x, mouse.right.(joint(j)).x.(process_type)(start_frame+i*shift_frame,1)];
            temp_y = [temp_y, mouse.right.(joint(j)).y.(process_type)(start_frame+i*shift_frame,1)];
        end
%         x_coord(i,:) = 2*i*shift_plot+temp_x;
%         y_coord(i,:) = -yplat+1.5*i*shift_plot+temp_y;
         x_coord(i,:) = i*shift_plot+temp_x;
         y_coord(i,:) = -yplat+temp_y;
    end
    
    % To define the reference point for the labels
    x1 = mean(x_coord(1,:));   
    
    % Plotting the stick and the joints
    if strcmp(vid_bool, 'true')
        plotStickPlot(config, x_coord, y_coord, figure_stick, nb_frame, label_joint, platform_delay, fall_platform_bool, leg_retraction_frame, leg_retraction_bool, leg_on_platform_frame, leg_on_platform_bool, x1, shift_plot, x0, unit, myVideo)
    else
        plotStickPlot(config, x_coord, y_coord, figure_stick, nb_frame, label_joint, platform_delay, fall_platform_bool, leg_retraction_frame, leg_retraction_bool, leg_on_platform_frame, leg_on_platform_bool, x1, shift_plot, x0, unit)
    end
    if strcmp(vid_bool, 'false')
        vid_name = 'No gif created';
    end
    %%%%%%%%%%%%%%%%%%%%%%%%%% All Sticklot %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
elseif strcmp(anatomy, 'all')

    label_joint = {'Toe', 'Paw', 'Ankle', 'Knee', 'Hip', 'IC', 'Midline', 'IC', 'Hip', 'Knee', 'Ankle', 'Paw', 'Toe'};
    joint = ["ic", "hip", "knee", "ankle", "mtp", "toe"];
    
    joint_left = ["mtp", "ankle", "knee", "hip", "ic"];
    
    label_joint2 = {'Midline up', 'Midline mid'};

    x_coord = zeros(nb_frame, length(label_joint));
    y_coord = zeros(nb_frame, length(label_joint));
    x_coord2 = zeros(nb_frame, length(label_joint2));
    y_coord2 = zeros(nb_frame, length(label_joint2));
    
    for i=1:nb_frame
        temp_x = mouse.left.toe.x.(process_type)(start_frame+i*shift_frame,1);
        temp_y = mouse.left.toe.y.(process_type)(start_frame+i*shift_frame,1);
        
        temp_x2 = mouse.midline.mid.x.(process_type)(start_frame+i*shift_frame,1);
        temp_y2 = mouse.midline.mid.y.(process_type)(start_frame+i*shift_frame,1);
        
        temp_x2 = [temp_x2, mouse.midline.up.x.(process_type)(start_frame+i*shift_frame,1)];
        temp_y2 = [temp_y2, mouse.midline.up.y.(process_type)(start_frame+i*shift_frame,1)];

        for j=1:length(joint_left)
            temp_x = [temp_x, mouse.left.(joint_left(j)).x.(process_type)(start_frame+i*shift_frame,1)];
            temp_y = [temp_y, mouse.left.(joint_left(j)).y.(process_type)(start_frame+i*shift_frame,1)];
        end
        temp_x = [temp_x, mouse.midline.mid.x.(process_type)(start_frame+i*shift_frame,1)];
        temp_y = [temp_y, mouse.midline.mid.y.(process_type)(start_frame+i*shift_frame,1)];
        
        for j=1:length(joint)
            temp_x = [temp_x, mouse.right.(joint(j)).x.(process_type)(start_frame+i*shift_frame,1)];
            temp_y = [temp_y, mouse.right.(joint(j)).y.(process_type)(start_frame+i*shift_frame,1)];
        end
%         x_coord(i,:) = 2*i*shift_plot+temp_x;
%         y_coord(i,:) = -yplat+1.5*i*shift_plot+temp_y;
         x_coord(i,:) = i*shift_plot+temp_x;
         y_coord(i,:) = -yplat+temp_y;
         
         x_coord2(i,:) = i*shift_plot+temp_x2;
         y_coord2(i,:) = -yplat+temp_y2;
    end
    
    % To define the reference point for the labels
    x1 = mean(x_coord(1,:));   
    
    % Plotting the stick and the joints
    if strcmp(vid_bool, 'true')
        plotStickPlot(config, x_coord, y_coord, figure_stick, nb_frame, label_joint, platform_delay, fall_platform_bool, leg_retraction_frame, leg_retraction_bool, leg_on_platform_frame, leg_on_platform_bool, x1, shift_plot, x0, unit, myVideo)
        hold on;
        plotStickPlot(config, x_coord2, y_coord2, figure_stick, nb_frame, label_joint2, platform_delay, fall_platform_bool, leg_retraction_frame, leg_retraction_bool, leg_on_platform_frame, leg_on_platform_bool, x1, shift_plot, x0, unit, myVideo)
    else
        plotStickPlot(config, x_coord, y_coord, figure_stick, nb_frame, label_joint, platform_delay, fall_platform_bool, leg_retraction_frame, leg_retraction_bool, leg_on_platform_frame, leg_on_platform_bool, x1, shift_plot, x0, unit)
        hold on;
        plotStickPlot(config, x_coord2, y_coord2, figure_stick, nb_frame, label_joint2, platform_delay, fall_platform_bool, leg_retraction_frame, leg_retraction_bool, leg_on_platform_frame, leg_on_platform_bool, x1, shift_plot, x0, unit)
    end
    if strcmp(vid_bool, 'false')
        vid_name = 'No gif created';
    end
    
    %%%%%%%%%%%%%%%%%%%%%%%%%% Left leg Sticklot %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
elseif strcmp(anatomy, 'left_leg')

    label_joint = {'Midline', 'IC', 'Hip', 'Knee', 'Ankle', 'Paw', 'Toe'};
    joint = ["ic", "hip", "knee", "ankle", "mtp", "toe"];    
    x_coord = zeros(nb_frame, length(label_joint));
    y_coord = zeros(nb_frame, length(label_joint));

    for i=1:nb_frame
        temp_x = mouse.midline.mid.x.(process_type)(start_frame+i*shift_frame,1);
        temp_y = mouse.midline.mid.y.(process_type)(start_frame+i*shift_frame,1);
        for j=1:length(joint)
            temp_x = [temp_x, mouse.left.(joint(j)).x.(process_type)(start_frame+i*shift_frame,1)];
            temp_y = [temp_y, mouse.left.(joint(j)).y.(process_type)(start_frame+i*shift_frame,1)];
        end
        x_coord(i,:) = i*shift_plot+temp_x;
        y_coord(i,:) = -yplat+temp_y;
    end
    
    % To define the reference point for the labels
    x1 = mean(x_coord(1,:));   
    
    % Plotting the stick and the joints
    if strcmp(vid_bool, 'true')
        plotStickPlot(config, x_coord, y_coord, figure_stick, nb_frame, label_joint, platform_delay, fall_platform_bool, leg_retraction_frame, leg_retraction_bool, leg_on_platform_frame, leg_on_platform_bool, x1, shift_plot, x0, unit, myVideo)
    else
        plotStickPlot(config, x_coord, y_coord, figure_stick, nb_frame, label_joint, platform_delay, fall_platform_bool, leg_retraction_frame, leg_retraction_bool, leg_on_platform_frame, leg_on_platform_bool, x1, shift_plot, x0, unit)
    end
    if strcmp(vid_bool, 'false')
        vid_name = 'No gif created';
    end
 
%%%%%%%%%%%%%%%%%%%%%%%%%% M2 Right Leg Sticklot %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
elseif strcmp(anatomy, 'm2_right_leg')

    label_joint = {'Midline up', 'Midline mid', 'IC', 'Hip', 'Knee', 'Ankle', 'Paw', 'Toe'};
    joint = ["ic", "hip", "knee", "ankle", "mtp", "toe"];    
    x_coord = zeros(nb_frame, length(label_joint));
    y_coord = zeros(nb_frame, length(label_joint));

    for i=1:nb_frame
        temp_x = mouse.m2_midline.up.x.(process_type)(start_frame+i*shift_frame,1);
        temp_y = mouse.m2_midline.up.y.(process_type)(start_frame+i*shift_frame,1);

        
        temp_x = [temp_x mouse.m2_midline.mid.x.(process_type)(start_frame+i*shift_frame,1)];
        temp_y = [temp_y mouse.m2_midline.mid.y.(process_type)(start_frame+i*shift_frame,1)];
        for j=1:length(joint)
            temp_x = [temp_x, mouse.m2_right.(joint(j)).x.(process_type)(start_frame+i*shift_frame,1)];
            temp_y = [temp_y, mouse.m2_right.(joint(j)).y.(process_type)(start_frame+i*shift_frame,1)];
        end
        x_coord(i,:) = i*shift_plot+temp_x;
        y_coord(i,:) = -yplat+temp_y;
    end
    
    % To define the reference point for the labels
    x1 = mean(x_coord(1,:));   
    
    % Plotting the stick and the joints
   if strcmp(vid_bool, 'true')
        plotStickPlot(config, x_coord, y_coord, figure_stick, nb_frame, label_joint, platform_delay, fall_platform_bool, leg_retraction_frame, leg_retraction_bool, leg_on_platform_frame, leg_on_platform_bool, x1, shift_plot, x0, unit, myVideo)
    else
        plotStickPlot(config, x_coord, y_coord, figure_stick, nb_frame, label_joint, platform_delay, fall_platform_bool, leg_retraction_frame, leg_retraction_bool, leg_on_platform_frame, leg_on_platform_bool, x1, shift_plot, x0, unit)
    end
    if strcmp(vid_bool, 'false')
        vid_name = 'No gif created';
    end

%%%%%%%%%%%%%%%%%%%%%%%%%% M1 Left Leg Sticklot %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
elseif strcmp(anatomy, 'm1_left_leg')

    label_joint = {'Midline', 'IC', 'Hip', 'Knee', 'Ankle', 'Paw', 'Toe'};
    joint = ["ic", "hip", "knee", "ankle", "mtp", "toe"];    
    x_coord = zeros(nb_frame, length(label_joint));
    y_coord = zeros(nb_frame, length(label_joint));

    for i=1:nb_frame
        temp_x = mouse.m1_midline.mid.x.(process_type)(start_frame+i*shift_frame,1);
        temp_y = mouse.m1_midline.mid.y.(process_type)(start_frame+i*shift_frame,1);
        for j=1:length(joint)
            temp_x = [temp_x, mouse.m1_left.(joint(j)).x.(process_type)(start_frame+i*shift_frame,1)];
            temp_y = [temp_y, mouse.m1_left.(joint(j)).y.(process_type)(start_frame+i*shift_frame,1)];
        end
        x_coord(i,:) = i*shift_plot+temp_x;
        y_coord(i,:) = -yplat+temp_y;
    end
    
    % To define the reference point for the labels
    x1 = mean(x_coord(1,:));   
    
    % Plotting the stick and the joints
    if strcmp(vid_bool, 'true')
        plotStickPlot(config, x_coord, y_coord, figure_stick, nb_frame, label_joint, platform_delay, fall_platform_bool, leg_retraction_frame, leg_retraction_bool, leg_on_platform_frame, leg_on_platform_bool, x1, shift_plot, x0, unit, myVideo)
    else
        plotStickPlot(config, x_coord, y_coord, figure_stick, nb_frame, label_joint, platform_delay, fall_platform_bool, leg_retraction_frame, leg_retraction_bool, leg_on_platform_frame, leg_on_platform_bool, x1, shift_plot, x0, unit)
    end
    if strcmp(vid_bool, 'false')
        vid_name = 'No gif created';
    end

%%%%%%%%%%%%%%%%%%%%%%%%%% pivot Sticklot %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
elseif strcmp(anatomy, 'pivot')
    
    label_joint = {'Left IC', 'Right IC'};
    joint = "ic";    
    x_coord = zeros(nb_frame, length(label_joint));
    y_coord = zeros(nb_frame, length(label_joint));

    for i=1:nb_frame
        temp_x = mouse.left.ic.x.(process_type)(start_frame+i*shift_frame,1);
        temp_y = mouse.left.ic.y.(process_type)(start_frame+i*shift_frame,1);
        for j=1:length(joint)
            temp_x = [temp_x, mouse.right.(joint(j)).x.(process_type)(start_frame+i*shift_frame,1)];
            temp_y = [temp_y, mouse.right.(joint(j)).y.(process_type)(start_frame+i*shift_frame,1)];
        end
        x_coord(i,:) = i*shift_plot+temp_x;
        y_coord(i,:) = -yplat+temp_y;
    end
    % To define the reference point for the labels
    x1 = mean(x_coord(1,:));   
    
    % Plotting the stick and the joints
    if strcmp(vid_bool, 'true')
        plotStickPlot(config, x_coord, y_coord, figure_stick, nb_frame, label_joint, platform_delay, fall_platform_bool, leg_retraction_frame, leg_retraction_bool, leg_on_platform_frame, leg_on_platform_bool, x1, shift_plot, x0, unit, myVideo)
    else
        plotStickPlot(config, x_coord, y_coord, figure_stick, nb_frame, label_joint, platform_delay, fall_platform_bool, leg_retraction_frame, leg_retraction_bool, leg_on_platform_frame, leg_on_platform_bool, x1, shift_plot, x0, unit)
    end
    if strcmp(vid_bool, 'false')
        vid_name = 'No gif created';
    end
    
%%%%%%%%%%%%%%%%%%%%%%%%%% right_side Sticklot %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

elseif strcmp(anatomy, 'right_side')
    label_joint1 = {'Nose', 'Head', 'Neck', 'Midline up', 'Midline mid', 'Midline end', 'Tail base'};
    label_joint2 = {'', 'IC', 'Hip', 'Knee', 'Ankle', 'Paw', 'Toe'};
    all_label = {'Nose', 'Head', 'Neck', 'Midline up', 'Midline mid', 'Midline end', 'Tail base', 'Skeleton', 'IC', 'Hip', 'Knee', 'Ankle', 'Paw', 'Toe'};
    joint1 = ["head", "neck", "up", "mid", "end"];
    joint2 = ["ic", "hip", "knee", "ankle", "mtp", "toe"];
    
    x_coord1 = zeros(nb_frame, length(label_joint1));
    y_coord1 = zeros(nb_frame, length(label_joint1));
    x_coord2 = zeros(nb_frame, length(label_joint2));
    y_coord2 = zeros(nb_frame, length(label_joint2));
    
    for i=1:nb_frame
        temp_x1 = mouse.m2_midline.nose.x.(process_type)(start_frame+i*shift_frame,1);
        temp_y1 = mouse.m2_midline.nose.y.(process_type)(start_frame+i*shift_frame,1);
        
        temp_x2 = mouse.m2_midline.mid.x.(process_type)(start_frame+i*shift_frame,1);
        temp_y2 = mouse.m2_midline.mid.y.(process_type)(start_frame+i*shift_frame,1);
        
        for j=1:length(joint1)
            temp_x1 = [temp_x1, mouse.m2_midline.(joint1(j)).x.(process_type)(start_frame+i*shift_frame,1)];
            temp_y1 = [temp_y1, mouse.m2_midline.(joint1(j)).y.(process_type)(start_frame+i*shift_frame,1)];
        end
        
        temp_x1 = [temp_x1, mouse.m2_tail.base.x.(process_type)(start_frame+i*shift_frame,1)];
        temp_y1 = [temp_y1, mouse.m2_tail.base.y.(process_type)(start_frame+i*shift_frame,1)];
        
        for j=1:length(joint2)
            temp_x2 = [temp_x2, mouse.m2_right.(joint2(j)).x.(process_type)(start_frame+i*shift_frame,1)];
            temp_y2 = [temp_y2, mouse.m2_right.(joint2(j)).y.(process_type)(start_frame+i*shift_frame,1)];
        end
%         x_coord1(i,:) = temp_x1;
%         y_coord1(i,:) = -yplat+i*shift_plot+temp_y1;
        x_coord1(i,:) = i*shift_plot+temp_x1;
        y_coord1(i,:) = -yplat+temp_y1;
         
%         x_coord2(i,:) = temp_x2;
%         y_coord2(i,:) = -yplat+i*shift_plot+temp_y2;         
        x_coord2(i,:) = i*shift_plot+temp_x2;
        y_coord2(i,:) = -yplat+temp_y2;
    end
    
    % To define the reference point for the labels
    x1 = mean(x_coord1(1,:));   
    
    % Plotting the stick and the joints
    if strcmp(vid_bool, 'true')
        plotStickPlot(config, x_coord1, y_coord1, figure_stick, nb_frame, label_joint1, platform_delay, fall_platform_bool, leg_retraction_frame, leg_retraction_bool, leg_on_platform_frame, leg_on_platform_bool, x1, shift_plot, x0, unit, myVideo)
        hold on;
        plotStickPlot(config, x_coord2, y_coord2, figure_stick, nb_frame, label_joint2, platform_delay, fall_platform_bool, leg_retraction_frame, leg_retraction_bool, leg_on_platform_frame, leg_on_platform_bool, x1, shift_plot, x0, unit, myVideo)
    else
        plotStickPlot(config, x_coord1, y_coord1, figure_stick, nb_frame, label_joint1, platform_delay, fall_platform_bool, leg_retraction_frame, leg_retraction_bool, leg_on_platform_frame, leg_on_platform_bool, x1, shift_plot, x0, unit) 
        hold on;
        plotStickPlot(config, x_coord2, y_coord2, figure_stick, nb_frame, label_joint2, platform_delay, fall_platform_bool, leg_retraction_frame, leg_retraction_bool, leg_on_platform_frame, leg_on_platform_bool, x1, shift_plot, x0, unit)
        legend(all_label)
    end
    if strcmp(vid_bool, 'false')
        vid_name = 'No gif created';
    end
%%%%%%%%%%%%%%%%%%%%%%%%%% left_side Sticklot %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

elseif strcmp(anatomy, 'left_side')
    label_joint1 = {'Nose', 'Head', 'Neck', 'Midline up', 'Midline mid', 'Midline end', 'Tail base'};
    label_joint2 = {'', 'IC', 'Hip', 'Knee', 'Ankle', 'Paw', 'Toe'};
    all_label = {'Nose', 'Head', 'Neck', 'Midline up', 'Midline mid', 'Midline end', 'Tail base', 'Skeleton', 'IC', 'Hip', 'Knee', 'Ankle', 'Paw', 'Toe'};
    joint1 = ["head", "neck", "up", "mid", "end"];
    joint2 = ["ic", "hip", "knee", "ankle", "mtp", "toe"];
    
    x_coord1 = zeros(nb_frame, length(label_joint1));
    y_coord1 = zeros(nb_frame, length(label_joint1));
    x_coord2 = zeros(nb_frame, length(label_joint2));
    y_coord2 = zeros(nb_frame, length(label_joint2));
    
    for i=1:nb_frame
        temp_x1 = mouse.m1_midline.nose.x.(process_type)(start_frame+i*shift_frame,1);
        temp_y1 = mouse.m1_midline.nose.y.(process_type)(start_frame+i*shift_frame,1);
        
        temp_x2 = mouse.m1_midline.mid.x.(process_type)(start_frame+i*shift_frame,1);
        temp_y2 = mouse.m1_midline.mid.y.(process_type)(start_frame+i*shift_frame,1);
        
        for j=1:length(joint1)
            temp_x1 = [temp_x1, mouse.m1_midline.(joint1(j)).x.(process_type)(start_frame+i*shift_frame,1)];
            temp_y1 = [temp_y1, mouse.m1_midline.(joint1(j)).y.(process_type)(start_frame+i*shift_frame,1)];
        end
        
        temp_x1 = [temp_x1, mouse.m1_tail.base.x.(process_type)(start_frame+i*shift_frame,1)];
        temp_y1 = [temp_y1, mouse.m1_tail.base.y.(process_type)(start_frame+i*shift_frame,1)];
        
        for j=1:length(joint2)
            temp_x2 = [temp_x2, mouse.m1_left.(joint2(j)).x.(process_type)(start_frame+i*shift_frame,1)];
            temp_y2 = [temp_y2, mouse.m1_left.(joint2(j)).y.(process_type)(start_frame+i*shift_frame,1)];
        end
%         x_coord(i,:) = 2*i*shift_plot+temp_x;
%         y_coord(i,:) = -yplat+1.5*i*shift_plot+temp_y;
         x_coord1(i,:) = i*shift_plot+temp_x1;
         y_coord1(i,:) = -yplat+temp_y1;
         
         x_coord2(i,:) = i*shift_plot+temp_x2;
         y_coord2(i,:) = -yplat+temp_y2;
    end
    
    % To define the reference point for the labels
    x1 = mean(x_coord1(1,:));   
    
    % Plotting the stick and the joints
    if strcmp(vid_bool, 'true')
        plotStickPlot(config, x_coord1, y_coord1, figure_stick, nb_frame, label_joint1, platform_delay, fall_platform_bool, leg_retraction_frame, leg_retraction_bool, leg_on_platform_frame, leg_on_platform_bool, x1, shift_plot, x0, unit, myVideo)
        hold on;
        plotStickPlot(config, x_coord2, y_coord2, figure_stick, nb_frame, label_joint2, platform_delay, fall_platform_bool, leg_retraction_frame, leg_retraction_bool, leg_on_platform_frame, leg_on_platform_bool, x1, shift_plot, x0, unit, myVideo)
    else
        plotStickPlot(config, x_coord1, y_coord1, figure_stick, nb_frame, label_joint1, platform_delay, fall_platform_bool, leg_retraction_frame, leg_retraction_bool, leg_on_platform_frame, leg_on_platform_bool, x1, shift_plot, x0, unit) 
        hold on;
        plotStickPlot(config, x_coord2, y_coord2, figure_stick, nb_frame, label_joint2, platform_delay, fall_platform_bool, leg_retraction_frame, leg_retraction_bool, leg_on_platform_frame, leg_on_platform_bool, x1, shift_plot, x0, unit)
        legend(all_label)
    end
    if strcmp(vid_bool, 'false')
        vid_name = 'No gif created';
    end
%%%%%%%%%%%%%%%%%%%%%%%%%% Head Sticklot %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
elseif strcmp(anatomy, 'head')
    
    label_joint = {'Nose', 'Head', 'Neck'};
    joint = ["nose", "head", "neck"];
    side = "m2_midline";
    x_coord = zeros(nb_frame, length(label_joint));
    y_coord = zeros(nb_frame, length(label_joint));
    for i=1:nb_frame
        for j=1:length(joint)
            temp_x(1,j) = -mouse.(side).(joint(j)).x.(process_type)(start_frame+i*shift_frame,1);
            temp_y(1,j) = mouse.(side).(joint(j)).y.(process_type)(start_frame+i*shift_frame,1);
        end
        x_coord(i,:) = i*shift_plot+temp_x;
        y_coord(i,:) = -yplat+temp_y;
    end
    % To define the reference point for the labels
    x1 = mean(x_coord(1,:));   
    
    % Plotting the stick and the joints
    if strcmp(vid_bool, 'true')
        plotStickPlot(config, x_coord, y_coord, figure_stick, nb_frame, label_joint, platform_delay, fall_platform_bool, leg_retraction_frame, leg_retraction_bool, leg_on_platform_frame, leg_on_platform_bool, x1, shift_plot, x0, unit, myVideo)
    else
        plotStickPlot(config, x_coord, y_coord, figure_stick, nb_frame, label_joint, platform_delay, fall_platform_bool, leg_retraction_frame, leg_retraction_bool, leg_on_platform_frame, leg_on_platform_bool, x1, shift_plot, x0, unit)
    end
    if strcmp(vid_bool, 'false')
        vid_name = 'No gif created';
    end
%%%%%%%%%%%%%%%%%%%%%%%%%% Midline Sticklot %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
elseif strcmp(anatomy, 'midline')
    
    label_joint = {'Midline up', 'Midline mid', 'Midline end', 'Tail base'};
    joint = ["up", "mid", "end"];
    side = "midline";
    x_coord = zeros(nb_frame, length(label_joint));
    y_coord = zeros(nb_frame, length(label_joint));
    for i=1:nb_frame
        for j=1:length(joint)
            temp_x(1,j) = -mouse.(side).(joint(j)).x.(process_type)(start_frame+i*shift_frame,1);
            temp_y(1,j) = mouse.(side).(joint(j)).y.(process_type)(start_frame+i*shift_frame,1);
        end
        temp_x(1,length(label_joint)) = -mouse.tail.base.x.(process_type)(start_frame+i*shift_frame,1);
        temp_y(1,length(label_joint)) = mouse.tail.base.y.(process_type)(start_frame+i*shift_frame,1);
 
        x_coord(i,:) = i*shift_plot+temp_x;
        y_coord(i,:) = -yplat+temp_y;
    end
    % To define the reference point for the labels
    x1 = mean(x_coord(1,:));   
    
    % Plotting the stick and the joints
    if strcmp(vid_bool, 'true')
        plotStickPlot(config, x_coord, y_coord, figure_stick, nb_frame, label_joint, platform_delay, fall_platform_bool, leg_retraction_frame, leg_retraction_bool, leg_on_platform_frame, leg_on_platform_bool, x1, shift_plot, x0, unit, myVideo)
    else
        plotStickPlot(config, x_coord, y_coord, figure_stick, nb_frame, label_joint, platform_delay, fall_platform_bool, leg_retraction_frame, leg_retraction_bool, leg_on_platform_frame, leg_on_platform_bool, x1, shift_plot, x0, unit)
    end
    if strcmp(vid_bool, 'false')
        vid_name = 'No gif created';
    end
%%%%%%%%%%%%%%%%%%%%%%%%%% End Sticklot %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

else
    error('Anatomy not found, please enter "leg" or "midline"');
end

if strcmp(vid_bool, 'true')
    close(myVideo);
end
end

