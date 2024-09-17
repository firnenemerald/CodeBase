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

function [] = PlotUPDRSCorr(updrs, score, scoreGroup, groupName, updrsName)

patternName = Num2Group(scoreGroup(2));
updrsPart = "UPDRS part 1";
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

figure
hold on
scatter(updrs, score, 20, 'filled', 'MarkerFaceColor', 'b');
text(updrs + 0.2, score + 0.2, cellstr(num2str([1:length(score)]')), 'FontSize', 7);

grid on
title(groupName)
xlabel(strcat(updrsPart, '{ }', 'score'));
ylabel(strcat(patternName, '{ }', 'gait pattern score'));
% updrs_unique = unique(updrs);
% xticks(updrs_unique);
% xticklabels(string(updrs_unique));

[r, p] = corr(updrs, score);
linearfit = polyfit(updrs, score, 1);
xfit = linspace(min(updrs), max(updrs), 100);
yfit = polyval(linearfit, xfit);
plot(xfit, yfit, '-b', 'Linewidth', 2);
xlimit = xlim; ylimit = ylim;
text(xlimit(2), ylimit(2), sprintf('R = %.2f, p = %.5f', r, p), 'HorizontalAlignment', 'right');
hold off

end