function [] = plotPlatform(config, mouse, process_type, falling_platform_frame, stopping_platform_frame)
% [] = plotPlatform(mouse, process_type)
%  plotPlatform(mouse, process_type)
%
% Function to plot the y position of the right moving and stable
% platforms, other figure plot speed and acceleration
%
% INPUT:
% "mouse"
% "process_type": type of processing, see dlcSmooth function
%
% OUTPUT:
% none

switch nargin
    case 0
        config = defaultConfig();
        [all_table, labels, numbers, file_name, path_name]=importDlcFile();
        [mouse] = dlcSmooth(config, file_name, path_name);
        process_type = 's';
        [falling_platform_frame, stopping_platform_frame] = fallingPlatform(config, mouse);
    case 1
        [all_table, labels, numbers, file_name, path_name]=importDlcFile();
        [mouse] = dlcSmooth(config, file_name, path_name);
        process_type = 's';
        [falling_platform_frame, stopping_platform_frame] = fallingPlatform(config,mouse);
    case 2
        process_type='s';
        [falling_platform_frame, stopping_platform_frame] = fallingPlatform(config, mouse);
    case 3
        [falling_platform_frame, stopping_platform_frame] = fallingPlatform(config, mouse);
end

frames = mouse.frames;

figure;
nb1 = 2;
nb2 = 2;
subplot(nb1, nb2, 1)
plot(mouse.env.stable_right_platform.y.(process_type), '-o','MarkerIndices',1:10:frames, 'MarkerSize', 5)
hold on;
plot(mouse.env.right_platform1.y.(process_type),'-+','MarkerIndices',1:10:frames, 'MarkerSize', 5)
plot(mouse.env.right_platform2.y.(process_type),'-v','MarkerIndices',1:10:frames, 'MarkerSize', 5)
plot(mouse.env.right_platform3.y.(process_type),'-d','MarkerIndices',1:10:frames, 'MarkerSize', 5)
legend('Stable','Platform 1','Platform 2','Platform 3');
xline(falling_platform_frame,'-.','Color','k');
xline(stopping_platform_frame,'-.','Color','k');

subplot(nb1, nb2, 2)
plot(mouse.env.right_platform1.y.d);
hold on;
plot(mouse.env.right_platform2.y.d);
plot(mouse.env.right_platform3.y.d);
legend('V Platform 1', 'V Platform 2','V Platform 3');
xline(falling_platform_frame,'-.','Color','k');
xline(stopping_platform_frame,'-.','Color','k');

subplot(nb1, nb2, 3)
plot(mouse.env.right_platform1.y.ds);
hold on;
plot(mouse.env.right_platform2.y.ds);
plot(mouse.env.right_platform3.y.ds);
legend('Vs Platform 1', 'Vs Platform 2','Vs Platform 3');
xline(falling_platform_frame,'-.','Color','k');
xline(stopping_platform_frame,'-.','Color','k');

subplot(nb1, nb2, 4)
plot(mouse.env.right_platform1.y.dds)
hold on;
plot(mouse.env.right_platform2.y.dds)
plot(mouse.env.right_platform3.y.dds);
legend('A Platform 1', 'A Platform 2','A Platform 3');
xline(falling_platform_frame,'-.','Color','k');
xline(stopping_platform_frame,'-.','Color','k');

sgtitle(mouse.name, 'Interpreter','none');
    set(gcf, 'Position',  [179           8        1305         947])
end

