%% PlotGaitPatternDiff.m (ver 1.0.240924)
% Plot gait pattern difference with heatmap

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

function [] = PlotGaitPatternDiff(saveDir)

aPDoff_var = load(strcat(saveDir, 'aPDoff', '_GIS_Yz.mat'), 'GIS_Yz');
aPDoff_Yz = aPDoff_var.GIS_Yz;
ePD_var = load(strcat(saveDir, 'ePD', '_GIS_Yz.mat'), 'GIS_Yz');
ePD_Yz = ePD_var.GIS_Yz;
data = (aPDoff_Yz - ePD_Yz)';

paramLength = length(data);
switch paramLength
    case 16
        bar_xlabel = {'step length', 'step time', 'step width', 'cadence', 'velocity', 'step length asymmetry', 'arm swing asymmetry', 'turning time', 'turning step length', 'turning step time', 'turning step width', 'turning step number', 'turning cadence', 'turning velocity', 'ant. flx. angle', 'dropped head angle'};
    case 24
        bar_xlabel = {'step length', 'step length (cv)', 'step time', 'step time (cv)','step width', 'step width (cv)', 'cadence', 'velocity', 'step length asymmetry', 'arm swing asymmetry', 'turning time', 'turning time (cv)', 'turning step length', 'turning step length (cv)', 'turning step time', 'turning step time(cv)', 'turning step width', 'turning step width (cv)', 'turning step number', 'turning step number (cv)', 'turning cadence', 'turning velocity', 'ant. flx. angle', 'dropped head angle'};
end

cmap = [linspace(0, 1, 128)', linspace(0, 1, 128)', ones(128,1); ...  % Blue to white
    ones(128,1), linspace(1, 0, 128)', linspace(1, 0, 128)'];     % White to red

figdiff = figure("Position", [0, 0, 1200, 200]);
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
%yticklabels({'Z-score'});

% Annotate each cell with the corresponding data value
for i = 1:length(data)
    text(i, 1, sprintf('%.2f', data(i)), 'HorizontalAlignment', 'center', 'VerticalAlignment', 'middle');
end

% Set labels and title
title('aPD - ePD pattern');
xlabel('Gait parameters');
%ylabel('Z-score');

saveas(figdiff, strcat(saveDir, 'aPDePDdiffHeat'), 'svg');
saveas(figdiff, strcat(saveDir, 'aPDePDdiffHeat'), 'png');

end