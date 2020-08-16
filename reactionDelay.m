function [reaction_delay_frame, reaction_delay_ms] = reactionDelay(config, falling_platform_frame, leg_retraction_frame)
% [reaction_delay_frame, reaction_delay_ms] = reactionDelay(config, falling_platform_frame, leg_retraction_frame)
% 
% Compute the timing of reaction of the mouse based on the 2 entry
% parameters
fps = config.fps;

reaction_delay_frame = leg_retraction_frame-falling_platform_frame;
reaction_delay_ms = reaction_delay_frame/fps*1000;
end

