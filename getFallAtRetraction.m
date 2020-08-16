function [fall_at_retraction] = getFallAtRetraction(config, mouse, falling_platform_frame, leg_retraction_frame)
%UNTITLED5 Summary of this function goes here
%   Detailed explanation goes here

% y1 = mean(mouse.env.right_platform1.y.s(1:falling_platform_frame-1));
% y2 = mean(mouse.env.right_platform2.y.s(1:falling_platform_frame-1));
% y3 = mean(mouse.env.right_platform3.y.s(1:falling_platform_frame-1));

% yf1 = mouse.env.right_platform1.y.s(leg_retraction_frame);
% yf2 = mouse.env.right_platform2.y.s(leg_retraction_frame);
% yf3 = mouse.env.right_platform3.y.s(leg_retraction_frame);

y1 = mean(mouse.env.pm1.y.s(1:falling_platform_frame-1));
y2 = mean(mouse.env.pm2.y.s(1:falling_platform_frame-1));
y3 = mean(mouse.env.pm3.y.s(1:falling_platform_frame-1));

yf1 = mouse.leg.right_mirror.y.s(leg_retraction_frame);

initial_height = (y1 + y2 + y3)/3;
%height_at_retraction = (yf1 + yf2 + yf3)/3;
height_at_retraction = yf1;

fall_at_retraction = height_at_retraction-initial_height;

end

