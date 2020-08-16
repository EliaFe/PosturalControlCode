function [ponderated_mean, joint] = ponderatedMean(config, mouse, process_type, degree, coord, joint1, joint2, joint3)
% mean_midline2 = ponderatedMean(config, mouse, process_type, degree, coord, joint1, joint2, joint3)
%   Detailed explanation goes here

if strcmp(process_type, 'default')
    process_type = 's';
end
if strcmp(degree, 'default')
    degree = 2;
end
if nargin == 7
   ponderated_mean = (joint1.(coord).(process_type).*joint1.p.r.^degree+joint2.(coord).(process_type).*joint2.p.r.^degree)./(joint1.p.r.^degree+joint2.p.r.^degree);
end

if nargin == 8
   ponderated_mean = (joint1.(coord).(process_type).*joint1.p.r.^degree+joint2.(coord).(process_type).*joint2.p.r.^degree+joint3.(coord).(process_type).*joint3.p.r.^degree)./(joint1.p.r.^degree+joint2.p.r.^degree+joint3.p.r.^degree);
end
end

