%% PlotGaitPattern.m (ver 1.0.240823)
% Plot gait pattern extracted from PCA

% Copyright (C) 2024 Jung Hwan Shin, Pil-ung Lee, Chanhee Jeong

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

function [] = PlotGaitPattern(GIS_Yz, groups)

X_name = Num2Group(groups(1));
Y_name = Num2Group(groups(2));
expTitle = strcat(X_name, {' '}, 'vs', {' '}, Y_name);

paramLength = length(GIS_Yz);
switch paramLength
    case 16
        bar_xlabel = {'step length', 'step time', 'step width', 'cadence', 'velocity', 'step length asymmetry', 'arm swing asymmetry', 'turning time', 'turning step length', 'turning step time', 'turning step width', 'turning step number', 'turning cadence', 'turning velocity', 'ant. flx. angle', 'dropped head angle'};
    case 24
        bar_xlabel = {'step length', 'step length (cv)', 'step time', 'step time (cv)','step width', 'step width (cv)', 'cadence', 'velocity', 'step length asymmetry', 'arm swing asymmetry', 'turning time', 'turning time (cv)', 'turning step length', 'turning step length (cv)', 'turning step time', 'turning step time(cv)', 'turning step width', 'turning step width (cv)', 'turning step number', 'turning step number (cv)', 'turning cadence', 'turning velocity'};
end

%% Standard bar graph for gait pattern
figure;
hold on

% Set specific color if z-score >1 (red) or <1 (blue)
bar_handle = bar(GIS_Yz);
bar_handle.FaceColor = 'flat';

bar_colors = zeros(paramLength, 3);
for idx = 1:paramLength
    if GIS_Yz(idx) > 1
        bar_handle.CData(idx, :) = [164/256,112/256,194/256];
        bar_colors(idx, :) = [164/256,112/256,194/256];
    elseif GIS_Yz(idx) < -1
        bar_handle.CData(idx, :) = [166/256,218/256,81/256];
        bar_colors(idx, :) = [166/256,218/256,81/256];
    else
        bar_handle.CData(idx, :) = [95/256,96/256,98/256];
        bar_colors(idx, :) = [95/256,96/256,98/256];
    end
end

% Title and axis labels
title(expTitle);
xlabel('Gait parameters')
ylabel('Z-score')

% X-axis tick labels
xticks(1:paramLength)
xticklabels(bar_xlabel);

ax = gca;
for idx = 1:paramLength
    ax.XTickLabel{idx} = sprintf('\\color[rgb]{%f,%f,%f}%s', bar_colors(idx, :), bar_xlabel{idx});
end
ax.XAxis.TickLabelInterpreter = 'tex';

hold off

%% Heatmap for gait pattern

% Create custom colormap with white for the range [-1, 1] and gradient outside

data = GIS_Yz';
cmap = [linspace(0, 1, 128)', linspace(0, 1, 128)', ones(128,1); ...  % Blue to white
        ones(128,1), linspace(1, 0, 128)', linspace(1, 0, 128)'];     % White to red

% Plot the heatmap
figure;
imagesc(data);
colormap(cmap);
colorbar;
clim([-3, 3]);

% Set x-ticks and labels
xticks(1:16);
xticklabels(bar_xlabel);
xtickangle(45); % Rotate x-tick labels

% Set y-tick label
yticks(1);
yticklabels({'Z-score'});

% Annotate each cell with the corresponding GIS_Yz value
for i = 1:length(GIS_Yz)
    text(i, 1, sprintf('%.2f', GIS_Yz(i)), 'HorizontalAlignment', 'center', 'VerticalAlignment', 'middle');
end

% Set labels and title
title(expTitle);
xlabel('Gait parameters');
ylabel('Z-score');

end