%% PlotGaitParamHeat.m (ver 1.1.241024)
% Plot gait parameters in a heatmap

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

function [] = PlotGaitParamHeat(cngdat, scoreGroup, saveDir)

gName = Num2Group(scoreGroup(2));

gph = figure;
imagesc([cngdat]);
%yline(size(cngdat_aPDoff, 1)+0.5, "LineWidth", 2, "Color", [0 0 0], "Alpha", 1);
%yline(size(cngdat_aPDoff, 1)+size(cngdat_HC, 1)+0.5, "LineWidth", 2, "Color", [0 0 0], "Alpha", 1);
clim([-3, 3]);
colormap(redblue)
colorbar
axis off

saveas(gph, strcat(saveDir, gName, '_GaitParamHeat'), 'svg');
saveas(gph, strcat(saveDir, gName, '_GaitParamHeat'), 'png');

end