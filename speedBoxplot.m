function [box_figure, classified_param] = speedBoxplot(config, mice, compute_param, compute_param_name, title_box, ymin, ymax)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

if nargin < 6
    ymin = [];
    ymax = [];
end
if nargin < 5
    title_box = [];
end

classified_param = [];
classified_param = paramClassfier(config, mice, classified_param, compute_param);

speed = string(fieldnames(classified_param.(compute_param)));

A1 = classified_param.(compute_param).(speed(1))';
B1 = classified_param.(compute_param).(speed(2))';
C1 = classified_param.(compute_param).(speed(3))';
D1 = classified_param.(compute_param).(speed(4))';
E1 = classified_param.(compute_param).(speed(5))';
F1 = classified_param.(compute_param).(speed(6))';
group = [ ones(size(A1)); 2 * ones(size(B1)); 3 * ones(size(C1)); 4 * ones(size(D1)); 5 * ones(size(E1)); 6 * ones(size(F1))];
box_figure = boxplot([A1; B1; C1; D1; E1; F1],group);

%set(gca,'XTickLabel',{'Speed 1','Speed 2','Speed 3','Speed 4','Speed 5','Free fall'})
ylabel(compute_param_name);
if not(isempty(ymin)) && not(isempty(ymax))
    ylim([ymin ymax]);
end
xtickpos = get(gca, 'xtick');

lab1 = ['n = ' num2str(length(A1))];
lab2 = ['n = ' num2str(length(B1))];
lab3 = ['n = ' num2str(length(C1))];
lab4 = ['n = ' num2str(length(D1))];
lab5 = ['n = ' num2str(length(E1))];
lab6 = ['n = ' num2str(length(F1))];

lab1 = ['n=' num2str(length(A1))];
lab2 = ['n=' num2str(length(B1))];
lab3 = ['n=' num2str(length(C1))];
lab4 = ['n=' num2str(length(D1))];
lab5 = ['n=' num2str(length(E1))];
lab6 = ['n=' num2str(length(F1))];


%xtl = {{'6% Speed';lab1} {'17% Speed';lab2} {'27% Speed';lab3} {'36% Speed';lab4} {'42% Speed';lab5} {'100%, Free fall';lab6}};
xtl = {{'6%';lab1;} {'17%';lab2} {'27%';lab3} {'36%';lab4} {'42%';lab5} {'100%';lab6}};
my_xticklabels(gca,xtickpos,xtl); %to have labels on 2 lines
set(gca,'FontSize',15);
if not(strcmp(title_box, 'false'))
    title(title_box, 'Interpreter', 'None', 'FontSize', 20);
end
end

