function [mouse] = dlcSmooth(config, file_name, path_name, new_values)
% [mouse] = dlcSmooth(config, file_name, path_name, new_value)
% [mouse] = dlcSmooth(config, file_name, path_name)
%
% Post processing function to smooth DLC data output. 
%
% INPUT:
%   => criteria to determine if the data are good and which processing is the most suitable
% "config" : structure describing the basic info of data we are handling
% "file_name" : name of the file we are interested in
% "path_name" : path of corresponding to the file_name
% "new_values": not to use !!!, this input is important for the cutFrame
% function
%
% OUTPUT: 
% structure => mouse.(midline,right,tail).(...).(x,y,p).(r, s, fs, fms, out)
% This structure will depend on the model
% "midline": up, mid, bottom
% "right": hip, knee, ankle, mtp, toe, stable_platform, platform.(x1,y1,p1,x2,y2,p2,x3,y3,p3)
% "tail": beg, end
%
% PROCESSING TYPES:
% r: raw data
% f: filtered, take in account only values for which p_value is higher that
%   0.7, if p<0.7, take the relevant previous value
% fm: same as f, if p<0.7, take the mean of the relevant previous and
%   next values
% s: smoothed
% fs: filtered and smoothed
% fms: mean filtered and smoothed
% out: outliers removed
% m: spline interpolation

%model = 'Full_platform_videos';
%model = 'Long_drop_full';
%model = 'Mirror_Vsmall';
%model = 'Mirror_WT';

switch nargin
    case 0
        config = defaultConfig();
        [~, labels, values, file_name, path_name]=importDlcFile();
        new_values = [];
    case 1 
        [~, labels, values, file_name, path_name]=importDlcFile();
        new_values = [];
    case 2
        path_name = '';
        disp('No path entered');
        new_values = [];
    case 3
        new_values = [];
    case 4
        values = new_values;
end

dlc_model = config.dlc_model;
mirror_setup = config.mirror_setup;
anatomy = config.anatomy;
p_value = config.p_value;
smooth_value = config.smooth_value;
smooth_value_platform = config.smooth_value_platform;


if isempty(new_values) % Normal file importation
    [~, labels, values, file_name, path_name]=importDlcFile(file_name, path_name);
else % File importation with values entered thanks to the cutFrame function => reduce the number of frames and synchrnoize all mouse with the falling of the platform
    [~, labels, ~, file_name, path_name]=importDlcFile(file_name, path_name);
end

mouse.name = extractBefore(file_name,"DLC");
if contains(mouse.name, 'WT(Adv x Piezo doubel het)')
    mouse.name = replace(mouse.name, 'WT(Adv x Piezo doubel het)', 'WT C57BL/6J');
end
    
mouse.file_name = file_name;
mouse.path = path_name;
mouse.frames = size(values,1);
coord_struct = ["x","y", "p"];
coord_csv = ["x","y", "likelihood"];

% Check that anatomy searched and dlc_model are possible
if not(strcmp(anatomy, 'all')) && not(strcmp(anatomy, 'short'))  && not(strcmp(anatomy, 'front')) && not(strcmp(anatomy, 'head')) && not(strcmp(anatomy, 'tail')) && not(strcmp(anatomy, 'only_platform'))
    error('Anatomy not found, please enter "all", "short", "only_platform", "front", "head" or "tail"');
end

if not(strcmp(dlc_model, 'random')) && not(strcmp(dlc_model, 'Full_platform_videos')) && not(strcmp(dlc_model, 'Long_drop_full')) && not(strcmp(dlc_model, 'Long_drop_full_short')) && not(strcmp(dlc_model, 'Mirror_Vsmall')) && not(strcmp(dlc_model, 'Mirror_WT'))
    error('Model not found, please enter "random", "Full_platform_videos", "Long_drop_full", "Long_drop_full_short", "Mirror_Vsmall" or "Mirror_WT"');
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Full_platform_videos %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    
if strcmp(dlc_model, 'Full_platform_videos') || strcmp(dlc_model, 'random')

    part_struct = "midline";
    joint_struct = ["up", "mid", "end"]; 
    joint_csv = ["up", "mid", "end"];

    mouse = mouseStruct(config, mouse, labels, values, part_struct, part_struct, joint_struct, joint_csv, coord_struct, coord_csv);

    part_struct = "tail";
    joint_struct = ["base", "mid"]; 
    joint_csv = ["beggining", "mid"];

    mouse = mouseStruct(config, mouse, labels, values, part_struct, part_struct, joint_struct, joint_csv, coord_struct, coord_csv);

    part_struct = ["right", "left"];
    joint_struct = ["hip", "knee", "ankle", "mtp", "toe"];
    joint_csv = ["hip", "knee", "ankle", "mtp", "toe"];

    mouse = mouseStruct(config, mouse, labels, values, part_struct, part_struct, joint_struct, joint_csv, coord_struct, coord_csv);

    part_struct = "env";
    part_csv= "";
    joint_struct = ["stable_right_platform", "right_platform1", "right_platform2", "right_platform3"];
    joint_csv = ["stable right plateform", "right plateform", "right plateform 2", "right plateform 3"];

    mouse = mouseStruct(config, mouse, labels, values, part_struct, part_csv, joint_struct, joint_csv, coord_struct, coord_csv, smooth_value_platform);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Long_drop_full %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    
elseif strcmp(dlc_model, 'Long_drop_full') || strcmp(dlc_model, 'Long_drop_full_short')

    part_struct = "midline";
    joint_struct = ["up", "mid", "end"]; 
    joint_csv = ["up", "mid", "end"];

    mouse = mouseStruct(config, mouse, labels, values, part_struct, part_struct, joint_struct, joint_csv, coord_struct, coord_csv);

    if not(strcmp(dlc_model, 'Long_drop_full_short'))
    part_struct = "tail";
    joint_struct = ["base", "mid"]; 
    joint_csv = ["beggining", "mid"];

    mouse = mouseStruct(config, mouse, labels, values, part_struct, part_struct, joint_struct, joint_csv, coord_struct, coord_csv);
    end
    
    part_struct = "right";
    joint_struct = ["hip", "knee", "ankle", "mtp", "toe"];
    joint_csv = ["hip", "knee", "ankle", "mtp", "toe"];

    mouse = mouseStruct(config, mouse, labels, values, part_struct, part_struct, joint_struct, joint_csv, coord_struct, coord_csv);

    if not(strcmp(dlc_model, 'Long_drop_full_short'))
    part_struct = "left";
    joint_struct = ["hip", "knee", "ankle", "mtp", "toe"];
    joint_csv = ["hip", "knee", "ankle", "paw", "toe"];

    mouse = mouseStruct(config, mouse, labels, values, part_struct, part_struct, joint_struct, joint_csv, coord_struct, coord_csv);
    end
    
    part_struct = "env";
    part_csv= "";
    joint_struct = ["stable_right_platform", "right_platform1", "right_platform2", "right_platform3"];
    joint_csv = ["stable right plateform", "right plateform", "right plateform 2", "right plateform 3"];

    mouse = mouseStruct(config, mouse, labels, values, part_struct, part_csv, joint_struct, joint_csv, coord_struct, coord_csv, smooth_value_platform);

    %leg only - sum of joint
    side = ["right"];        
    side_name = ["back"]; 

    for k = 1:length(side)
        mouse.leg.(side_name(k)).x.r = mouse.(side(k)).hip.x.r+mouse.(side(k)).knee.x.r+mouse.(side(k)).ankle.x.r+mouse.(side(k)).mtp.x.r;
        mouse.leg.(side_name(k)).y.r = mouse.(side(k)).hip.y.r+mouse.(side(k)).knee.y.r+mouse.(side(k)).ankle.y.r+mouse.(side(k)).mtp.y.r;
        mouse.leg.(side_name(k)) = processFunction(config, mouse.leg.(side_name(k)), config.smooth_value, 'whole_leg');
    end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Mirror_Vsmall %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
elseif strcmp(dlc_model, 'Mirror_Vsmall')  

    part_struct = "midline";
    part_csv = "midline";
    joint_struct = ["up", "mid", "end"]; 
    joint_csv = ["up", "mid", "end"];

    mouse = mouseStruct(config, mouse, labels, values, part_struct, part_csv, joint_struct, joint_csv, coord_struct, coord_csv);

    part_struct = "tail";
    part_csv = "tail";
    joint_struct = ["base", "mid"]; 
    joint_csv = ["beggining", "mid"];

    mouse = mouseStruct(config, mouse, labels, values, part_struct, part_csv, joint_struct, joint_csv, coord_struct, coord_csv);

    part_struct = ["right", "m_right"];
    part_csv = ["right", "m right"];
    joint_struct = ["hip", "knee", "ankle", "mtp", "toe"];
    joint_csv = ["hip", "knee", "ankle", "mtp", "toe"];

    mouse = mouseStruct(config, mouse, labels, values, part_struct, part_csv, joint_struct, joint_csv, coord_struct, coord_csv);

    part_struct = "env";
    part_csv= "";
    joint_struct = ["stable_platform", "right_platform1", "right_platform2", "right_platform3"];
    joint_csv = ["stable right plateform", "right plateform", "right plateform 2", "right plateform 3"];

    mouse = mouseStruct(config, mouse, labels, values, part_struct, part_csv, joint_struct, joint_csv, coord_struct, coord_csv, smooth_value_platform);

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Mirror_WT %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
elseif strcmp(dlc_model, 'Mirror_WT')    
    
    %env
    part_struct = "env";
    part_csv = "";
    joint_struct = ["stable_right_platform", "right_platform1", "right_platform2", "right_platform3", "c1", "cm1", "spm1", "pm1", "pm2", "pm3", "c3", "cm3", "c4", "cm4", "box1", "box1m1", "box1m2", "box2", "box2m1", "box2m2"];
    joint_csv = ["stable right plateform", "right plateform", "right plateform 2", "right plateform 3", "c1", "cm1", "spm1", "pm1", "pm2", "pm3", "c3", "cm3", "c4", "cm4", "box1", "box1m1", "box1m2", "box2", "box2m1", "box2m2"];

    mouse = mouseStruct(config, mouse, labels, values, part_struct, part_csv, joint_struct, joint_csv, coord_struct, coord_csv, smooth_value_platform);

    if not(strcmp(anatomy, 'only_platform'))
    %midline
    part_struct = ["midline", "m1_midline", "m2_midline"];
    part_csv = ["", "m1", "m2"];
    joint_struct = ["up", "mid", "end"];
    joint_csv = ["up midline", "mid midline", "end midline"];
    
    mouse = mouseStruct(config, mouse, labels, values, part_struct, part_csv, joint_struct, joint_csv, coord_struct, coord_csv);

    if strcmp(anatomy, 'head') || strcmp(anatomy, 'all') || strcmp(anatomy, 'short') || strcmp(anatomy, 'tail')
        %head
        part_struct = ["m1_midline", "m2_midline"];
        part_csv = ["m1", "m2"];
        joint_struct = ["nose", "head", "neck"];
        joint_csv = ["nose", "head", "neck"];
        mouse = mouseStruct(config, mouse, labels, values, part_struct, part_csv, joint_struct, joint_csv, coord_struct, coord_csv);
        
        %mouse.anat.nose.x.r = mouse.m1_midline.nose.x.r*mouse.m1_midline.nose.p+mouse.m
    end
    
    if strcmp(anatomy, 'head') || strcmp(anatomy, 'all')
        %head
        part_struct = "head";
        part_csv = "";
        joint_struct = ["nose", "right_ear", "left_ear"];
        joint_csv = ["nose", "right ear", "left ear"];
        mouse = mouseStruct(config, mouse, labels, values, part_struct, part_csv, joint_struct, joint_csv, coord_struct, coord_csv);
    end
        
    if strcmp(anatomy, 'front') || strcmp(anatomy, 'all')
        %frontlimb
        part_struct = "frontlimb";
        part_csv = "frontlimb"; 
        joint_struct = ["right", "left", "m1_right", "m1_left", "m2_right", "m2_left"];
        joint_csv = ["right", "left", "m1 right", "m1 left", "m2 right", "m2 left"];
        mouse = mouseStruct(config, mouse, labels, values, part_struct, part_csv, joint_struct, joint_csv, coord_struct, coord_csv);
    end
        
    if strcmp(anatomy, 'tail') || strcmp(anatomy, 'all')
        %tail
        part_struct = ["tail", "m1_tail", "m2_tail"];
        part_csv = ["", "m1", "m2"];
        joint_struct = ["base", "mid"];
        joint_csv = ["tail base", "mid tail"];
        mouse = mouseStruct(config, mouse, labels, values, part_struct, part_csv, joint_struct, joint_csv, coord_struct, coord_csv);
    end
        %leg
        part_struct = ["right", "left", "m1_left", "m2_right"];
        part_csv = ["right", "left", "m1 left", "m2 right"]; 
        joint_struct = ["ic", "hip", "knee", "ankle", "mtp", "toe"];
        joint_csv = ["ic", "hip", "knee", "ankle", "mtp", "toe"];   

        mouse = mouseStruct(config, mouse, labels, values, part_struct, part_csv, joint_struct, joint_csv, coord_struct, coord_csv);

        %right & left
        joint_struct = ["elbow", "ic", "hip", "knee", "ankle", "mtp", "toe"];
        joint_csv = ["elbow", "ic", "hip", "knee", "ankle", "mtp", "toe"];
        part_struct = ["m2_right", "m1_left"];
        part_csv = ["m2 right", "m1 left"]; 

        mouse = mouseStruct(config, mouse, labels, values, part_struct, part_csv, joint_struct, joint_csv, coord_struct, coord_csv);

        %leg only - sum of joint
        side = ["right", "m2_right"];        
        side_name = ["back", "right_mirror"]; 
        
        for k = 1:length(side)
            mouse.leg.(side_name(k)).x.r = mouse.(side(k)).hip.x.r+mouse.(side(k)).knee.x.r+mouse.(side(k)).ankle.x.r+mouse.(side(k)).mtp.x.r;
            mouse.leg.(side_name(k)).y.r = mouse.(side(k)).hip.y.r+mouse.(side(k)).knee.y.r+mouse.(side(k)).ankle.y.r+mouse.(side(k)).mtp.y.r;
            mouse.leg.(side_name(k)) = processFunction(config, mouse.leg.(side_name(k)), config.smooth_value, 'whole_leg');
        end
    end
end    
end

