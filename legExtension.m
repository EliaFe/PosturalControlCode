function [initial_midline, initial_leg, final_midline, final_leg, leg_extension] = legExtension(config, mouse, falling_platform_frame, leg_retraction_frame)
% [initial_midline, final_midline, initial_leg, final_leg, leg_extension] = legExtension(config, mouse, falling_platform_frame, leg_retraction_frame);
%   Detailed explanation goes here

initial_midline.back = mouse.midline.mid.y.s(falling_platform_frame-1);
initial_leg.back = mouse.leg.back.y.s(falling_platform_frame-1);

final_midline.back = mouse.midline.mid.y.s(leg_retraction_frame);
final_leg.back = mouse.leg.back.y.s(leg_retraction_frame);

initial_midline.right_mirror = mouse.m2_midline.mid.y.s(falling_platform_frame-1);
initial_leg.right_mirror = mouse.leg.right_mirror.y.s(falling_platform_frame-1);

final_midline.right_mirror = mouse.m2_midline.mid.y.s(leg_retraction_frame);
final_leg.right_mirror = mouse.leg.right_mirror.y.s(leg_retraction_frame);

leg_extension.back = final_leg.back - final_midline.back;
leg_extension.right_mirror = final_leg.right_mirror - final_midline.right_mirror;
end

