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

figure;

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
switch paramLength
    case 16
        bar_xlabel = {'step length', 'step time', 'step width', 'cadence', 'velocity', 'step length asymmetry', 'arm swing asymmetry', 'turning time', 'turning step length', 'turning step time', 'turning step width', 'turning step number', 'turning cadence', 'turning velocity', 'ant. flx. angle', 'dropped head angle'};
    case 24
        bar_xlabel = {'step length', 'step length (cv)', 'step time', 'step time (cv)','step width', 'step width (cv)', 'cadence', 'velocity', 'step length asymmetry', 'arm swing asymmetry', 'turning time', 'turning time (cv)', 'turning step length', 'turning step length (cv)', 'turning step time', 'turning step time(cv)', 'turning step width', 'turning step width (cv)', 'turning step number', 'turning step number (cv)', 'turning cadence', 'turning velocity'};
end
xticklabels(bar_xlabel);

ax = gca;
for idx = 1:paramLength
    ax.XTickLabel{idx} = sprintf('\\color[rgb]{%f,%f,%f}%s', bar_colors(idx, :), bar_xlabel{idx});
end
ax.XAxis.TickLabelInterpreter = 'tex';

end