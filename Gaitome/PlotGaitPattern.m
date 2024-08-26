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

% Standard bar graph for gait pattern
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

% Heatmap for gait pattern
figure;
hold on

hm_data = GIS_Yz;
for idx = 1:paramLength
    if GIS_Yz(idx) > 1
        hm_data(idx) = GIS_Yz(idx);
    elseif GIS_Yz(idx) < -1
        hm_data(idx) = GIS_Yz(idx);
    else
        hm_data(idx) = 0;
    end
end

numColors = 256;
colormap(customColormap(numColors));

imagesc(hm_data');
colorbar;

[numRows, numCols] = size(hm_data');
for row = 1:numRows
    for col = 1:numCols
        text(col, row, num2str(hm_data(col, row), '%0.2f'), ...
             'HorizontalAlignment', 'center', ...
             'VerticalAlignment', 'middle');
    end
end

title(expTitle);
subtitle('Gait pattern heatmap');
xlabel('Gait parameters');
ylabel(colorbar, 'Gait pattern (normalized)');

xticks(1:paramLength)
xticklabels(bar_xlabel);

set(gca, 'GridColor', 'k');  % Set grid color to black
set(gca, 'GridLineStyle', '-');
set(gca, 'LineWidth', 1.5);
grid on;  % Enable grid
axis equal tight;  % Equal scaling and tight fitting

hold off

end

function cmap = customColormap(numColors)
    cmap = zeros(numColors, 3); % Initialize a numColors-by-3 matrix to hold RGB values

    % Middle of the colormap (for values close to zero)
    middleIndex = floor(numColors/2);

    % Intensify red for positive values
    for i = middleIndex+1:numColors
        intensity = (i - middleIndex) / (numColors - middleIndex);
        cmap(i, :) = [1, 1-intensity, 1-intensity]; % Fill with shades of red
    end

    % Intensify blue for negative values
    for i = 1:middleIndex
        intensity = (middleIndex - i + 1) / middleIndex;
        cmap(i, :) = [1-intensity, 1-intensity, 1]; % Fill with shades of blue
    end

    % Neutral color at middleIndex
    cmap(middleIndex, :) = [1, 1, 1]; % White or choose another neutral color
end