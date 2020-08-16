function [classified_param] = paramClassfier(config, mice, classified_param, param)
%UNTITLED10 Summary of this function goes here
%   Detailed explanation goes here

classified_param1 = [];
classified_param2 = [];
classified_param3 = [];
classified_param4 = [];
classified_param5 = [];
classified_param6 = [];

for i = 1:size(mice,2)
    if mice(i).charact.classified_speed == 1
        if strcmp(mice(i).charact.leg_retraction_success, 'true')
            classified_param1 = [classified_param1, mice(i).charact.(param)];
        end
    elseif mice(i).charact.classified_speed == 2
        if strcmp(mice(i).charact.leg_retraction_success, 'true')
            classified_param2 = [classified_param2, mice(i).charact.(param)];
        end
    elseif mice(i).charact.classified_speed == 3
        if strcmp(mice(i).charact.leg_retraction_success, 'true')
            classified_param3 = [classified_param3, mice(i).charact.(param)];
        end
    elseif mice(i).charact.classified_speed == 4
        if strcmp(mice(i).charact.leg_retraction_success, 'true')
            classified_param4 = [classified_param4, mice(i).charact.(param)];
        end
    elseif mice(i).charact.classified_speed == 5
        if strcmp(mice(i).charact.leg_retraction_success, 'true')
            classified_param5 = [classified_param5, mice(i).charact.(param)];
        end
    elseif mice(i).charact.classified_speed == 6
        if strcmp(mice(i).charact.leg_retraction_success, 'true')
            classified_param6 = [classified_param6, mice(i).charact.(param)];
        end
    end
end

classified_param.(param).speed1(:) = classified_param1;
classified_param.mean.(param).mean1 = median(classified_param1);
classified_param.(param).speed2(:) = classified_param2;
classified_param.mean.(param).mean2 = median(classified_param2);
classified_param.(param).speed3(:) = classified_param3;
classified_param.mean.(param).mean3 = median(classified_param3);
classified_param.(param).speed4(:) = classified_param4;
classified_param.mean.(param).mean4 = median(classified_param4);
classified_param.(param).speed5(:) = classified_param5;
classified_param.mean.(param).mean5 = median(classified_param5);
classified_param.(param).speed6(:) = classified_param6;
classified_param.mean.(param).mean6 = median(classified_param6);

end

