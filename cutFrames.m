function [mouse] = cutFrames(config, mouse, falling_platform_frame, leg_on_platform_frame, start_cut, end_cut)
%UNTITLED4 Summary of this function goes here
%   Detailed explanation goes here

switch nargin
    case{0,1}
        error('Not enough input arguments');
    case 2
        [falling_platform_frame, ~] = fallingPlatform(config, mouse);
        [leg_on_platform_frame, leg_on_platform_success] = legOnPlatform(config, mouse);
        start_cut = 50;
        end_cut = 120;
    case 3
        [leg_on_platform_frame, leg_on_platform_success] = legOnPlatform(config, mouse);
        start_cut = 50;
        end_cut = 120;
    case 4
        start_cut = 50;
        end_cut = 120;
    case 5
        end_cut = 120;
end

[~, ~, values, ~, ~] = importDlcFile(mouse.file_name, mouse.path);

if strcmp(leg_on_platform_frame, 'false')
    leg_on_platform_frame = 0;
end

if strcmp(falling_platform_frame, 'true')
    [falling_platform_frame, ~] = fallingPlatform(config, mouse);
end

if strcmp(leg_on_platform_frame, 'true')
    [leg_on_platform_frame, leg_on_platform_success] = legOnPlatform(config, mouse);
end


start_cut = max([1, falling_platform_frame-start_cut]); 
    
if falling_platform_frame > mouse.frames-end_cut
    end_cut = mouse.frames;
elseif falling_platform_frame + end_cut < leg_on_platform_frame
    end_cut = min([mouse.frames, leg_on_platform_frame + 50]); %to make sure that we don't cut before the leg is back on the platform
else
    end_cut = falling_platform_frame+end_cut;
end

new_values = values(start_cut:end_cut,:);

[mouse] = dlcSmooth(config, mouse.file_name, mouse.path, config.anatomy, new_values);
end

