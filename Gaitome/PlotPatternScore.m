%% PlotPatternScore.m (ver 1.0.240823)
% Plot and compare gait pattern scores

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

function [] = PlotPatternScore(tdat, cngdat, GIS_Yz, groups)

X_name = Num2Group(groups(1));
Y_name = Num2Group(groups(2));
expTitle = strcat(X_name, {' '}, 'vs', {' '}, Y_name);

% Get each group's indices
HC_idx = tdat(:, 1) == 0;
RBD_idx = tdat(:, 1) == 1;
MSAC_idx = tdat(:, 1) == 2;
ePD_idx = tdat(:, 1) == 3;
aPDoff_idx = tdat(:, 1) == 4;
aPDon_idx = tdat(:, 1) == 5;

% Get each group's corrected normalized gait parameters
cngdat_HC = cngdat(HC_idx, :);
cngdat_RBD = cngdat(RBD_idx, :);
cngdat_MSAC = cngdat(MSAC_idx, :);
cngdat_ePD = cngdat(ePD_idx, :);
cngdat_aPDoff = cngdat(aPDoff_idx, :);
cngdat_aPDon = cngdat(aPDon_idx, :);

% Calculate each group's gait pattern score
score_HC = cngdat_HC * GIS_Yz;
score_RBD = cngdat_RBD * GIS_Yz;
score_MSAC = cngdat_MSAC * GIS_Yz;
score_ePD = cngdat_ePD * GIS_Yz;
score_aPDoff = cngdat_aPDoff * GIS_Yz;
score_aPDon = cngdat_aPDon * GIS_Yz;

group_HC = cell(sum(HC_idx), 1);
group_HC(:, 1) = cellstr('HC');
group_RBD = cell(sum(RBD_idx), 1);
group_RBD(:, 1) = cellstr('RBD');
group_ePD = cell(sum(ePD_idx), 1);
group_ePD(:, 1) = cellstr('ePD');
group_aPDoff = cell(sum(aPDoff_idx), 1);
group_aPDoff(:, 1) = cellstr('aPDoff');
group_aPDon = cell(sum(aPDon_idx), 1);
group_aPDon(:, 1) = cellstr('aPDon');
group = [group_HC; group_RBD; group_ePD; group_aPDoff; group_aPDon];

% Calculate mean and standard error values
mean_HC = mean(score_HC);
se_HC = std(score_HC)/sqrt(length(score_HC));
mean_RBD = mean(score_RBD);
se_RBD = std(score_RBD)/sqrt(length(score_RBD));
mean_MSAC = mean(score_MSAC);
se_MSAC = std(score_MSAC)/sqrt(length(score_MSAC));
mean_ePD = mean(score_ePD);
se_ePD = std(score_MSAC)/sqrt(length(score_MSAC));
mean_aPDoff = mean(score_aPDoff);
se_aPDoff = std(score_aPDoff)/sqrt(length(score_aPDoff));
mean_aPDon = mean(score_aPDon);
se_aPDon = std(score_aPDon)/sqrt(length(score_aPDon));

%% Statistical analysis (ANOVA post-hoc Tukey)
score = [score_HC; score_RBD; score_ePD; score_aPDoff; score_aPDon];
[p, table, stats] = anova1(score, group, 'on');

%% Draw bar graph
figure;
hold on

bar_groups = {'HC', 'RBD', 'ePD', 'aPDoff', 'aPDon'};
bar_means = [mean_HC, mean_RBD, mean_ePD, mean_aPDoff, mean_aPDon];
bar_ses = [se_HC, se_RBD, se_ePD, se_aPDoff, se_aPDon];

% Plot bar
barX = categorical(bar_groups);
barX = reordercats(barX, bar_groups);
bar(barX, bar_means, 'EdgeColor', 'black', 'FaceAlpha', 0.5);

% Plot errorbar
errorbar(barX, bar_means, bar_ses, 'LineStyle', 'none', 'LineWidth', 2, 'Color', 'black');

% Plot individual datapoints
scatter(ones(size(score_HC)) * find(barX == 'HC'), score_HC, 15, 'o', 'MarkerEdgeColor', 'red', 'jitter', 'on', 'jitterAmount', 0.15);
scatter(ones(size(score_RBD)) * find(barX == 'RBD'), score_RBD, 15, 'o', 'MarkerEdgeColor', 'red', 'jitter', 'on', 'jitterAmount', 0.15);
scatter(ones(size(score_ePD)) * find(barX == 'ePD'), score_ePD, 15, 'o', 'MarkerEdgeColor', 'red', 'jitter', 'on', 'jitterAmount', 0.15);
scatter(ones(size(score_aPDoff)) * find(barX == 'aPDoff'), score_aPDoff, 15, 'o', 'MarkerEdgeColor', 'red', 'jitter', 'on', 'jitterAmount', 0.15);
scatter(ones(size(score_aPDon)) * find(barX == 'aPDon'), score_aPDon, 15, 'o', 'MarkerEdgeColor', 'red', 'jitter', 'on', 'jitterAmount', 0.15);

% Title and axis labels
title(expTitle);
xlabel('Groups')
ylabel('Gait pattern score')

grid on
hold off

end