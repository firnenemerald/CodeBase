%% PlotPCACovar.m (ver 1.0.240923)
% Plot SSM-PCA covariate matrix in a heatmap fashion

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

function [] = PlotPCAProcess(C, explained, scoreGroup, saveDir)

gName = Num2Group(scoreGroup(2));

pcac = figure;
imagesc(C);
clim([-10, 15]);
colormap(redblue);
colorbar
saveas(pcac, strcat(saveDir, gName, '_PCAcovmat'), 'svg');
saveas(pcac, strcat(saveDir, gName, '_PCAcovmat'), 'png');

pcae = figure;
bar(explained);
xlim([0, 20]);
yline(5);
saveas(pcae, strcat(saveDir, gName, '_PCAexplained'), 'svg');
saveas(pcae, strcat(saveDir, gName, '_PCAexplained'), 'png');

end