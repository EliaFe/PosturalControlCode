function [classified_speed] = platformSpeedClassifier(platform_speed, free_fall_bool)
%UNTITLED4 Summary of this function goes here
%   Detailed explanation goes here
% free_fall_bool is when the speed computation for the free fall is messy,
% to be carefull though because the speed may not be max even with the free
% fall

if nargin ==1
    free_fall_bool = 'false';
end
% 
% if platform_speed>0 && platform_speed<1.1
%     classified_speed = 1;
% elseif platform_speed>2 && platform_speed<3
%     classified_speed = 2;
% elseif platform_speed>3.5 && platform_speed<4.5
%     classified_speed = 3;
% elseif platform_speed>5 && platform_speed<6
%     classified_speed = 4;
% elseif platform_speed>6 && platform_speed<8.5
%     classified_speed = 5;
% elseif platform_speed>9.5 || strcmp(free_fall_bool, 'true') %Free fall
%     classified_speed = 6;
% else
%     msg = 'Speed does not meet criteria. Platform speed value: %s.';
%     msg=sprintf(msg, platform_speed);
%     error(msg);
% end

% if platform_speed>0 && platform_speed<1.9
%     classified_speed = 1;
% elseif platform_speed>2.7 && platform_speed<4
%     classified_speed = 2;
% elseif platform_speed>4.8 && platform_speed<5.6
%     classified_speed = 3;
% elseif platform_speed>5.7 && platform_speed<6.8
%     classified_speed = 4;
% elseif platform_speed>6.95 && platform_speed<9.4
%     classified_speed = 5;
% elseif platform_speed>11 || strcmp(free_fall_bool, 'true') %Free fall
%     classified_speed = 6;
% else
%     msg = 'Speed does not meet criteria. Platform speed value: %s.';
%     msg=sprintf(msg, platform_speed);
%     error(msg);
% end

if platform_speed>0 && platform_speed<1.9
    classified_speed = 1;
elseif platform_speed>2.5 && platform_speed<4
    classified_speed = 2;
elseif platform_speed>4.2 && platform_speed<5.6
    classified_speed = 3;
elseif platform_speed>5.7 && platform_speed<6.8
    classified_speed = 4;
elseif platform_speed>6.8 && platform_speed<9.4 %6.95
    classified_speed = 5;
elseif platform_speed>11 || strcmp(free_fall_bool, 'true') %Free fall
    classified_speed = 6;
else
    msg = 'Speed does not meet criteria. Platform speed value: %s.';
    msg=sprintf(msg, platform_speed);
    error(msg);
end
