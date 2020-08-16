function [processed_joint] = processFunction(config, joint, smooth_value, anat)
% [processed_joint] = processFunction(config, joint, anat)
% [processed_joint] = processFunction(config, joint, 'false')
%
% For each joint entered, this function will create a variable with the
% values processed according to a specific type. See below for the types.
% Processing types: r, s, f, fs, fm, fms,
% INPUT:
% "config" : structure describing the basic info of data we are handling
% "joint": joint data to process
% "anat" : if a particular anatomy must be process, where we dont have
% anymore the p value for each frames
%
% OUTPUT: 
%   structure => joint.(x,y,p).(r, s, f, fs, fm, fms)

switch nargin
    case 0
        error('Please, enter a config and a joint to process');
    case 1
        error('Please, enter a joint to process');
    case 2
        anat = 'false';
        smooth_value = config.smooth_value;
    case 3
        anat = 'false';
end

p_value = config.p_value;
short_p = config.short_p;

smooth_valueD = 10;

if strcmp(anat, 'whole_leg')
    process_types = ["r", "s", "d", "ds", "dd", "dds"];
    smooth_types = ["s", "ds", "dds"];
    to_smooth = ["r", "d", "dd"];
elseif strcmp(short_p, 'true')
    process_types = ["r", "s", "d", "ds", "dd", "dds"];
    smooth_types = ["s", "ds", "dds"];
    to_smooth = ["r", "d", "dd"];
    processed_joint.p.r = joint.p.r;
else
    process_types = ["r", "s", "f", "fs","fm","fms", "m", "d", "ds", "dd", "dds", "ms"];
    smooth_types = ["s", "fs", "fms", "ds", "dds", "ms"];
    to_smooth = ["r", "f", "fm", "d", "dd", "m"];
    processed_joint.p.r = joint.p.r;
end
%Creation of the needed variables to contain processed data: one variable per
%processing type
for i = 1:length(process_types)
    processed_joint.x.(process_types(i)) = joint.x.r;
    processed_joint.y.(process_types(i)) = joint.y.r;
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Filtering %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Filter all values below p_value
if strcmp(anat, 'false') && strcmp(short_p, 'false')
    frames = length(processed_joint.p.r);
    for i = 1:frames %We take all values
        if processed_joint.p.r(i)<p_value  % If the proba is below a threshold, we take the next relevant one
            n = i;
            %take next relevant value
            while processed_joint.p.r(n)<p_value && n<frames
                n = n+1;
                % Make sure that the next relevant value we take is the last
                % frame or previous
            end
         if i == 1 % We can't do the mean of the previous value the first value is not relavant so we take only the next one
            processed_joint.x.fm(i)= processed_joint.x.fm(n);
            processed_joint.y.fm(i)= processed_joint.y.fm(n);
         else
            % Mean of previous and next relevant value
            processed_joint.x.fm(i)=(processed_joint.x.fm(i-1)+processed_joint.x.fm(n))*0.5;
            processed_joint.y.fm(i)=(processed_joint.y.fm(i-1)+processed_joint.y.fm(n))*0.5;

            % Take previous relevant value
            processed_joint.x.f(i)=processed_joint.x.f(i-1);
            processed_joint.y.f(i)=processed_joint.y.f(i-1);
         end
        end
    end
    for i = 1:frames %We take all values
        n = i;
        if processed_joint.p.r(i)<p_value  % If the proba is below a threshold, we take the next relevant one
            %take next relevant value
            while processed_joint.p.r(n)<p_value && n<frames
                n = n+1;
                % Make sure that the next relevant value we take is the last
                % frame or previous
            end
            if i == 1 % We can't do the mean of the previous value the first value is not relavant so we take only the next one
                processed_joint.x.m(i)= processed_joint.x.m(n);
                processed_joint.y.m(i)= processed_joint.y.m(n);
            else
                %Akima interpolation
                nbframes2interpolate = n-i+2;
                frames2interpolate = [i-1 n];
                if nbframes2interpolate > 6
                    nb2add = floor(nbframes2interpolate/1.4);
                    to_check = processed_joint.p.r(i:n-1);
                    [value,idx] = maxk(to_check,nb2add);
                    idx = sort(idx);
                    xframes2interpolate = processed_joint.x.m(i-1);
                    yframes2interpolate = processed_joint.y.m(i-1);
                    newframes2interpolate = i-1;
                    for l = 1:length(idx)
                        xframes2interpolate = [xframes2interpolate processed_joint.x.m(i-1+idx(l))];
                        yframes2interpolate = [yframes2interpolate processed_joint.y.m(i-1+idx(l))];
                        newframes2interpolate = [newframes2interpolate i-1+idx(l)];
                    end
                    xframes2interpolate = [xframes2interpolate processed_joint.x.m(n)];
                    yframes2interpolate = [yframes2interpolate processed_joint.y.m(n)];
                    newframes2interpolate = [newframes2interpolate n];

                    frames2interpolate = newframes2interpolate;
                else
                    xframes2interpolate = [processed_joint.x.m(i-1) processed_joint.x.m(n)];
                    yframes2interpolate = [processed_joint.y.m(i-1) processed_joint.y.m(n)];
                end
                
                xq1 = linspace(i-1, n, nbframes2interpolate);
                px = spline(frames2interpolate,xframes2interpolate,xq1);
                py = spline(frames2interpolate,yframes2interpolate,xq1);
                 

                for m = 1:nbframes2interpolate
                    processed_joint.x.m(i+m-2) = px(m);
                    processed_joint.y.m(i+m-2) = py(m);
                end   
            end
        end
        i = i+n;
    end
elseif strcmp(anat, 'env') && strcmp(short_p, 'false') %to change
    frames = length(processed_joint.p.r);
    for i = 1:frames %We take all values
        if processed_joint.p.r(i)<p_value  % If the proba is below a threshold, we take the next relevant one
            n = i;
            %take next relevant value
            while processed_joint.p.r(n)<p_value && n<frames
                n = n+1;
                % Make sure that the next relevant value we take is the last
                % frame or previous
            end
         if i == 1 % We can't do the mean of the previous value the first value is not relavant so we take only the next one
            processed_joint.x.fm(i)= processed_joint.x.fm(n);
            processed_joint.y.fm(i)= processed_joint.y.fm(n);
         else
            % Mean of previous and next relevant value
            processed_joint.x.fm(i)=(processed_joint.x.fm(i-1)+processed_joint.x.fm(n))*0.5;
            processed_joint.y.fm(i)=(processed_joint.y.fm(i-1)+processed_joint.y.fm(n))*0.5;

            % Take previous relevant value
            processed_joint.x.f(i)=processed_joint.x.f(i-1);
            processed_joint.y.f(i)=processed_joint.y.f(i-1);
         end
       end
    end
end

 
 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Derivative %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
 %First derivative => speed
 processed_joint.x.d = diff(smoothdata(processed_joint.x.r, 'gaussian', smooth_valueD));
 processed_joint.y.d = diff(smoothdata(processed_joint.y.r, 'gaussian', smooth_valueD));
 %Second derivative => acceleration
 processed_joint.x.dd = diff(smoothdata(processed_joint.x.d, 'gaussian', smooth_valueD));
 processed_joint.y.dd = diff(smoothdata(processed_joint.y.d, 'gaussian', smooth_valueD));
%moving average function not used because induce a delay in max
%speed/accceleration

 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Smoothing %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Smooth
for i = 1:length(smooth_types)
    processed_joint.x.(smooth_types(i)) = smoothdata(processed_joint.x.(to_smooth(i)), 'gaussian', smooth_value);
    processed_joint.y.(smooth_types(i)) = smoothdata(processed_joint.y.(to_smooth(i)), 'gaussian', smooth_value);
end

end

