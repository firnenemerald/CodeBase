%% PlotParameterRegression.m (ver 1.0.240824)
% Gait pattern scoring with gait parameters

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

function [] = PlotParameterRegression(tdat, ngdat, cngdat, GIS_Yz, covar)

% Covar
covarNum = 2;
switch covar
    case 'age'
        covarNum = 2;
    case 'height'
        covarNum = 4;
end

% Get each group's indices
HC_idx = tdat(:, 1) == 0;
RBD_idx = tdat(:, 1) == 1;
MSAC_idx = tdat(:, 1) == 2;
ePD_idx = tdat(:, 1) == 3;
aPDoff_idx = tdat(:, 1) == 4;
aPDon_idx = tdat(:, 1) == 5;

for idx = 0:5
    groupIdx = tdat(:, 1) == idx;
    groupName = Num2Group(idx);
    groupCovar = tdat(groupIdx, covarNum);
    
    beforeGdat = ngdat(groupIdx, :);
    beforeGscore = beforeGdat * GIS_Yz;
    afterGdat = cngdat(groupIdx, :);
    afterGscore = afterGdat * GIS_Yz;

    % Before regression plot
    figure
    hold on
    scatter(groupCovar, beforeGscore, 20, 'filled', 'MarkerFaceColor', 'b');
    
    grid on
    title([groupName, '(BEFORE regression)']);
    xlabel(covar);
    ylabel('Gait pattern score');
    covar_unique = unique(groupCovar);
    xticks(covar_unique);
    xticklabels(string(covar_unique));

    % Linear regression line
    [r, p] = corr(groupCovar, beforeGscore);
    linearfit = polyfit(groupCovar, beforeGscore, 1);
    xfit = linspace(min(groupCovar), max(groupCovar), 100);
    yfit = polyval(linearfit, xfit);
    plot(xfit, yfit, '-b', 'LineWidth', 2);
    xlimit = xlim; ylimit = ylim;
    text(xlimit(2), ylimit(2), sprintf('R = %.2f, p = %.3f', r, p), 'HorizontalAlignment', 'right');
    hold off

    % After regression plot
    figure
    hold on
    scatter(groupCovar, afterGscore, 20, 'filled', 'MarkerFaceColor', 'r');
    
    grid on
    title([groupName, '(AFTER regression)']);
    xlabel(covar);
    ylabel('Gait pattern score');
    covar_unique = unique(groupCovar);
    xticks(covar_unique);
    xticklabels(string(covar_unique));

    % Linear regression line
    [r, p] = corr(groupCovar, afterGscore);
    linearfit = polyfit(groupCovar, afterGscore, 1);
    xfit = linspace(min(groupCovar), max(groupCovar), 100);
    yfit = polyval(linearfit, xfit);
    plot(xfit, yfit, '-r', 'LineWidth', 2);
    xlimit = xlim; ylimit = ylim;
    text(xlimit(2), ylimit(2), sprintf('R = %.2f, p = %.3f', r, p), 'HorizontalAlignment', 'right');
    hold off

end