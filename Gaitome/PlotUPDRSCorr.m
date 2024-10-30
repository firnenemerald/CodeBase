%% PlotUPDRSCorr.m (ver 1.1.240924)
% UPDRS correlation with gait pattern score

% Copyright (C) 2024 Pil-ung Lee, Chanhee Jeong, Jung Hwan Shin

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

function [] = PlotUPDRSCorr(updrs, score, scoreGroup, groupName, updrsName, saveDir)

patternName = Num2Group(scoreGroup(2));
updrsPart = "UPDRS part 3";
switch updrsName
    case "u1"
        updrsPart = "UPDRS part 1";
    case "u2"
        updrsPart = "UPDRS part 2";
    case "u3"
        updrsPart = "UPDRS part 3";
    case "ut"
        updrsPart = "UPDRS total";
end

figu = figure;
hold on

pointEdgeColor = [1, 1, 1];
pointFaceColor = [0.3, 0.3, 0.3];
scatter(updrs, score, 20, 'o', 'MarkerEdgeColor', pointEdgeColor, 'MarkerFaceColor', pointFaceColor);
% text(updrs + 0.2, score + 0.2, cellstr(num2str([1:length(score)]')), 'FontSize', 7);

title(groupName)
xlabel(strcat(updrsPart, '{ }', 'score'));
ylabel(strcat(patternName, '{ }', 'gait pattern Z-score'));
switch groupName
    case 'aPD'
        xlim([2, 35]);
        ylim([0, 10]);
    case 'ePD'
        xlim([0, 55]);
        ylim([0, 4.5]);
end
% updrs_unique = unique(updrs);
% xticks(updrs_unique);
% xticklabels(string(updrs_unique));

[r, p] = corr(updrs, score);
linearfit = polyfit(updrs, score, 1);
xfit = linspace(min(updrs), max(updrs), 100);
yfit = polyval(linearfit, xfit);
plot(xfit, yfit, '-r', 'Linewidth', 1.5);
xlimit = xlim; ylimit = ylim;
text(xlimit(2), ylimit(2), sprintf('R = %.2f, p = %.5f', r, p), 'HorizontalAlignment', 'right');
hold off

saveas(figu, strcat(saveDir, 'G_', groupName, '_S_', patternName, '_corr'), 'svg');
saveas(figu, strcat(saveDir, 'G_', groupName, '_S_', patternName, '_corr'), 'png');

end