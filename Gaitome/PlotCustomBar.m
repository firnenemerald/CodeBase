%% PlotCustomBar.m (ver 1.0.240828)
% Plot custom bar graph to visualize data

% Copyright (C) 2024 Chanhee Jeong

% This program is free software: you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation, either version 3 of the License, or
% (at your option) any later version.

% This program is distributed in the hope that it will be useful,
% but WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
% GNU General Public License for more details.

% You should have received a copy of the GNU General Public License
% along with this program.  If not, see <https://www.gnu.org/licenses/>.

function [] = PlotCustomBar(var1, var2)

figure;
hold on

mean1 = mean(var1); se1 = std(var1)/sqrt(length(var1));
mean2 = mean(var2); se2 = std(var2)/sqrt(length(var2));

[h, p] = ttest2(var1, var2);

bar_groups = {'Med OFF', 'Med ON'};
bar_means = [mean1, mean2];
bar_ses = [se1, se2];

barX = categorical(bar_groups);
barX = reordercats(barX, bar_groups);
bar(barX, bar_means, 'EdgeColor', 'black', 'FaceAlpha', 0.5);
errorbar(barX, bar_means, bar_ses, 'LineStyle', 'none', 'LineWidth', 2, 'Color', 'black');

scatter(ones(size(var1)) * find(barX == 'Med OFF'), var1, 15, 'o', 'MarkerEdgeColor', 'blue', 'jitter', 'on', 'jitterAmount', 0.15);
scatter(ones(size(var2)) * find(barX == 'Med ON'), var2, 15, 'o', 'MarkerEdgeColor', 'red', 'jitter', 'on', 'jitterAmount', 0.15);

title('Score (Med OFF vs Med ON)');
formatted_p = sprintf('%.5f', p);
subtitle(['p = ', formatted_p]);
xlabel('Groups');
ylabel('Score');

grid on
hold off

end