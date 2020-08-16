function config = defaultConfig()
% Config file constructor by default
% "smooth_value" : smoothing smooth_value for smoothing function
% "p_value" : threshold of p_value to filter
% "fps" : frames per second of the video
% "model": DLC model we are using

config.p_value = 0.3;
config.smooth_value = 6;
config.smooth_valueD = 10;
config.fps = 120;
config.model = 'random';
config.smooth_value_platform = 3;
end

