%% DNPDR_PlotLR.m (ver 1.0.241012)
% Plot linear regression results

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

function [] = DNPDR_PlotLR(indVar, depVar, group)

arguments
    indVar (:, 1) double
    depVar (:, 1) double
    group (1, 2) string
end

% Count total points and NaN data
totalPoints = length(indVar);
nanCount = sum(isnan(indVar) | isnan(depVar));

% Remove NaN values
indVar_clean = indVar(~isnan(indVar) & ~isnan(depVar));
depVar_clean = depVar(~isnan(indVar) & ~isnan(depVar));

figure;
hold on

% Scatter plot
pointEdgeColor = [1, 1, 1];
pointFaceColor = [0.3, 0.3, 0.3];
scatter(indVar_clean, depVar_clean, 20, 'o', 'MarkerEdgeColor', pointEdgeColor, 'MarkerFaceColor', pointFaceColor);

% Linear regression line
[r, p] = corr(indVar_clean, depVar_clean);
linearfit = polyfit(indVar_clean, depVar_clean, 1);
xfit = linspace(min(indVar_clean), max(indVar_clean), 100);
yfit = polyval(linearfit, xfit);
plot(xfit, yfit, '-b', 'LineWidth', 2);

% Set axis limits
xlim([min(indVar_clean)-1, max(indVar_clean)+1]);
ylim([min(depVar_clean)-1, max(depVar_clean)+1]);
xlimit = xlim; ylimit = ylim;

% Title and axis labels
title(strcat(group(1), " vs ", group(2)), "Interpreter", "none");
xlabel(group(1), "Interpreter", "none");
ylabel(group(2), "Interpreter", "none");

% Display R and p-value
if p < 0.05
    textColor = 'red';
else
    textColor = 'black';
end
text(xlimit(2), ylimit(2), sprintf('R = %.2f, p = %.3f\n(n = %d, excluded = %d)', ...
    r, p, totalPoints-nanCount, nanCount), ...
    'HorizontalAlignment', 'right', 'VerticalAlignment', 'top', 'Color', textColor);
hold off

end
