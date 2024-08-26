%% PlotUPDRSCorr.m (ver 1.0.240825)
% UPDRS correlation with gait pattern score

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

function [] = PlotUPDRSCorr(updrs, score)

figure
hold on
scatter(updrs, score, 20, 'filled', 'MarkerFaceColor', 'b');

grid on
title('RBD')
subtitle('UPDRS part 3 score vs Gait pattern score');
xlabel('UPDRS part 3 score');
ylabel('Gait pattern score');
updrs_unique = unique(updrs);
xticks(updrs_unique);
xticklabels(string(updrs_unique));

[r, p] = corr(updrs, score);
linearfit = polyfit(updrs, score, 1);
xfit = linspace(min(updrs), max(updrs), 100);
yfit = polyval(linearfit, xfit);
plot(xfit, yfit, '-b', 'Linewidth', 2);
xlimit = xlim; ylimit = ylim;
text(xlimit(2), ylimit(2), sprintf('R = %.2f, p = %.5f', r, p), 'HorizontalAlignment', 'right');
hold off

end