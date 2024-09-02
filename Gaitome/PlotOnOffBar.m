%% PlotOnOffBar.m (ver 1.0.240831)
% Plot custom bar graph to visualize data

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

function [] = PlotOnOffBar(aPDoff_concat, aPDon_concat, aPD_ledd, updrsName)

updrsPart = "UPDRS part 1";
aPDoff_con = aPDoff_concat(:, [1, 2]);
aPDon_con = aPDon_concat(:, [1, 2]);
switch updrsName
    case "u1"
        updrsPart = "UPDRS part 1";
        aPDoff_con = aPDoff_concat(:, [1, 2]);
        aPDon_con = aPDon_concat(:, [1, 2]);
    case "u2"
        updrsPart = "UPDRS part 2";
        aPDoff_con = aPDoff_concat(:, [1, 3]);
        aPDon_con = aPDon_concat(:, [1, 3]);
    case "u3"
        updrsPart = "UPDRS part 3";
        aPDoff_con = aPDoff_concat(:, [1, 4]);
        aPDon_con = aPDon_concat(:, [1, 4]);
    case "ut"
        updrsPart = "UPDRS total";
        aPDoff_con = aPDoff_concat(:, [1, 5]);
        aPDon_con = aPDon_concat(:, [1, 5]);
end

mean_s_off = mean(aPDoff_con(:, 1)); se_s_off = std(aPDoff_con(:, 1))/sqrt(length(aPDoff_con(:, 1)));
mean_u_off = mean(aPDoff_con(:, 2)); se_u_off = std(aPDoff_con(:, 2))/sqrt(length(aPDoff_con(:, 2)));
mean_s_on = mean(aPDon_con(:, 1)); se_s_on = std(aPDon_con(:, 1))/sqrt(length(aPDon_con(:, 1)));
mean_u_on = mean(aPDon_con(:, 2)); se_u_on = std(aPDon_con(:, 2))/sqrt(length(aPDon_con(:, 2)));

scores = [aPDoff_con(:, 1), aPDon_con(:, 1)];
updrss = [aPDoff_con(:, 2), aPDon_con(:, 2)];

fig1 = figure;
hold on

minValue = floor(min(scores));
maxValue = ceil(max(scores));
binWidth = 1.0;
binEdges = minValue:binWidth:maxValue + binWidth;

histogram(aPDoff_con(:, 1), 'BinEdges', binEdges, 'Normalization', 'probability', 'FaceColor', [0, 0, 1], 'EdgeColor', 'black', 'FaceAlpha', 0.5);
histogram(aPDon_con(:, 1), 'BinEdges', binEdges, 'Normalization', 'probability', 'FaceColor', [1, 0, 0], 'EdgeColor', 'black', 'FaceAlpha', 0.5);
d_gait = cohens_d(aPDoff_con(:, 1), aPDon_con(:, 1));

title('Distribution of gait score')
subtitle(sprintf('Cohen''s d: %.2f', d_gait))
xlabel('Gait score');
ylabel('Probability');
legend({'OFF medication', 'ON medication'});

grid on
hold off

fig2 = figure;
hold on

minValue = floor(min(updrss));
maxValue = ceil(max(updrss));
binWidth = 1.0;
binEdges = minValue:binWidth:maxValue + binWidth;

histogram(aPDoff_con(:, 2), 'BinEdges', binEdges, 'Normalization', 'probability', 'FaceColor', [0, 0, 1], 'EdgeColor', 'black', 'FaceAlpha', 0.5);
histogram(aPDon_con(:, 2), 'BinEdges', binEdges, 'Normalization', 'probability', 'FaceColor', [1, 0, 0], 'EdgeColor', 'black', 'FaceAlpha', 0.5);
d_updrs = cohens_d(aPDoff_con(:, 2), aPDon_con(:, 2));

title(strcat('Distribution of', {' '}, updrsPart, {' '}, 'score'));
subtitle(sprintf('Cohen''s d: %.2f', d_updrs));
xlabel(strcat(updrsPart, {' '}, 'score'));
ylabel('Probability');
legend({'OFF medication', 'ON medication'});

grid on
hold off

fig3 = figure;
hold on

bar_groups = {'Medication OFF', 'Medication ON'};
bar_means = [mean_s_off, mean_s_on];
bar_ses = [se_s_off, se_s_on];

[~, p] = ttest2(scores(:, 1), scores(:, 2));

barX = categorical(bar_groups);
barX = reordercats(barX, bar_groups);
bh = bar(barX, bar_means, 'EdgeColor', 'black', 'FaceAlpha', 0.5);
errorbar(barX, bar_means, bar_ses, 'LineStyle', 'none', 'LineWidth', 2, 'Color', 'black');

scatter(ones(size(scores(:, 1))) * find(barX == 'Medication OFF'), scores(:, 1), 15, 'o', 'MarkerEdgeColor', 'blue');
scatter(ones(size(scores(:, 2))) * find(barX == 'Medication ON'), scores(:, 2), 15, 'o', 'MarkerEdgeColor', 'red');

for idx = 1:length(scores(:, 1))
    plot([1, 2], [scores(idx, 1), scores(idx, 2)], 'k-', 'LineWidth', 1);
end

bh.FaceColor = 'flat';
bh.CData(1, :) = [1, 1, 1];
bh.CData(2, :) = [1, 1, 1];

title('Gait score (Med Off vs Med On)');
subtitle(sprintf('p = %.9f', p));
xlabel('Groups');
ylabel('Gait score');

hold off

fig4 = figure;
hold on

bar_groups = {'Medication OFF', 'Medication ON'};
bar_means = [mean_u_off, mean_u_on];
bar_ses = [se_u_off, se_u_on];

[~, p] = ttest2(updrss(:, 1), updrss(:, 2));

barX = categorical(bar_groups);
barX = reordercats(barX, bar_groups);
bh = bar(barX, bar_means, 'EdgeColor', 'black', 'FaceAlpha', 0.5);
errorbar(barX, bar_means, bar_ses, 'LineStyle', 'none', 'LineWidth', 2, 'Color', 'black');

scatter(ones(size(updrss(:, 1))) * find(barX == 'Medication OFF'), updrss(:, 1), 15, 'o', 'MarkerEdgeColor', 'blue');
scatter(ones(size(updrss(:, 2))) * find(barX == 'Medication ON'), updrss(:, 2), 15, 'o', 'MarkerEdgeColor', 'red');

for idx = 1:length(updrss(:, 1))
    plot([1, 2], [updrss(idx, 1), updrss(idx, 2)], 'k-', 'LineWidth', 1);
end

bh.FaceColor = 'flat';
bh.CData(1, :) = [1, 1, 1];
bh.CData(2, :) = [1, 1, 1];

title(strcat(updrsPart, {' '}, 'score (Med OFF vs Med ON)'));
subtitle(sprintf('p = %.9f', p));
xlabel('Groups');
ylabel(strcat(updrsPart, {' '}, 'score'));

hold off

diff_score = aPDoff_con(:, 1) - aPDon_con(:, 1);
diff_updrs = aPDoff_con(:, 2) - aPDon_con(:, 2);

%% LEDD vs Gait score
fig5 = figure;
hold on;

scatter(aPD_ledd, diff_score, 20, 'filled', 'MarkerFaceColor', 'b');

% Linear regression line
[r, p] = corr(aPD_ledd, diff_score);
linearfit = polyfit(aPD_ledd, diff_score, 1);
xfit = linspace(min(aPD_ledd), max(aPD_ledd), 100);
yfit = polyval(linearfit, xfit);
plot(xfit, yfit, '-b', 'LineWidth', 2);
xlimit = xlim; ylimit = ylim;
text(xlimit(2), ylimit(2), sprintf('R = %.2f, p = %.5f', r, p), 'HorizontalAlignment', 'right');

grid on
title('Gait score difference vs LEDD');
xlabel('LEDD');
ylabel('Gait score difference');

hold off

%% LEDD vs Gait score
fig6 = figure;
hold on;

scatter(aPD_ledd, diff_updrs, 20, 'filled', 'MarkerFaceColor', 'b');

% Linear regression line
[r, p] = corr(aPD_ledd, diff_updrs);
linearfit = polyfit(aPD_ledd, diff_updrs, 1);
xfit = linspace(min(aPD_ledd), max(aPD_ledd), 100);
yfit = polyval(linearfit, xfit);
plot(xfit, yfit, '-b', 'LineWidth', 2);
xlimit = xlim; ylimit = ylim;
text(xlimit(2), ylimit(2), sprintf('R = %.2f, p = %.5f', r, p), 'HorizontalAlignment', 'right');

grid on
title(strcat(updrsPart, {' '}, 'score difference vs LEDD'));
xlabel('LEDD');
ylabel(strcat(updrsPart, {' '}, 'score difference'));

hold off

end

function d = cohens_d(group1, group2)

n1 = length(group1);
n2 = length(group2);

mean1 = mean(group1);
mean2 = mean(group2);

s1 = std(group1);
s2 = std(group2);

% Pooled standard deviation
s_pooled = sqrt(((n1 - 1) * s1^2 + (n2 - 1) * s2^2) / (n1 + n2 - 2));

d = abs(mean2 - mean1) / s_pooled;

end