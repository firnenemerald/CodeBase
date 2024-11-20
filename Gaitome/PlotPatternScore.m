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

function [] = PlotPatternScore(tdat, cngdat, GIS_Yz, groups, saveDir)

X_name = Num2Group(groups(1));
Y_name = Num2Group(groups(2));
expTitle = strcat(X_name, {' '}, 'vs', {' '}, Y_name);

% Get each group's indices
HC_idx = tdat(:, 1) == 1;
RBD_idx = tdat(:, 1) == 2;
ePD_idx = tdat(:, 1) == 3;
aPDoff_idx = tdat(:, 1) == 4;
aPDon_idx = tdat(:, 1) == 5;
MSACSc_idx = tdat(:, 1) == 7;

% Get each group's corrected normalized gait parameters
cngdat_HC = cngdat(HC_idx, :);
cngdat_RBD = cngdat(RBD_idx, :);
cngdat_ePD = cngdat(ePD_idx, :);
cngdat_aPDoff = cngdat(aPDoff_idx, :);
cngdat_aPDon = cngdat(aPDon_idx, :);
cngdat_MSACSc = cngdat(MSACSc_idx, :);

% Calculate each group's gait pattern score
score_HC = cngdat_HC * GIS_Yz;
score_RBD = cngdat_RBD * GIS_Yz;
score_ePD = cngdat_ePD * GIS_Yz;
score_aPDoff = cngdat_aPDoff * GIS_Yz;
score_aPDon = cngdat_aPDon * GIS_Yz;
score_MSACSc = cngdat_MSACSc * GIS_Yz;

% Normalize gait pattern score
msHC = mean(score_HC);
ssHC = std(score_HC);
score_HC = (score_HC - msHC)/ssHC;
score_RBD = (score_RBD - msHC)/ssHC;
score_ePD = (score_ePD - msHC)/ssHC;
score_aPDoff = (score_aPDoff - msHC)/ssHC;
score_aPDon = (score_aPDon - msHC)/ssHC;
score_MSACSc = (score_MSACSc - msHC)/ssHC;

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
group_MSACSc = cell(sum(MSACSc_idx), 1);
group_MSACSc(:, 1) = cellstr('MSAC');

% Calculate mean and standard error values
mean_HC = mean(score_HC);
se_HC = std(score_HC)/sqrt(length(score_HC));
mean_RBD = mean(score_RBD);
se_RBD = std(score_RBD)/sqrt(length(score_RBD));
mean_ePD = mean(score_ePD);
se_ePD = std(score_ePD)/sqrt(length(score_ePD));
mean_aPDoff = mean(score_aPDoff);
se_aPDoff = std(score_aPDoff)/sqrt(length(score_aPDoff));
mean_aPDon = mean(score_aPDon);
se_aPDon = std(score_aPDon)/sqrt(length(score_aPDon));
mean_MSACSc = mean(score_MSACSc);
se_MSACSc = std(score_MSACSc)/sqrt(length(score_MSACSc));

%% Statistical analysis (ANOVA post-hoc Tukey)
score = [score_HC; score_RBD; score_MSACSc]; %%%%% CHANGE HERE %%%%%
group = [group_HC; group_RBD; group_MSACSc]; %%%%% CHANGE HERE %%%%%
[p, table, stats] = anova1(score, group, 'on');
headingObj = findall(0,'Type','uicontrol','Tag','Heading');
headingObj(1).String = [expTitle, 'ANOVA table'];

[c, ~, ~, gnames] = multcompare(stats, 'alpha', 0.05, 'ctype', 'hsd');
tbl = array2table(c,"VariableNames", ["Group A","Group B","Lower Limit","A-B","Upper Limit","P-value"]);
tbl.("Group A") = gnames(tbl.("Group A"));
tbl.("Group B") = gnames(tbl.("Group B"))

%% Draw bar graph
barComp = figure;
hold on

bar_groups = {'HC', 'RBD', 'MSAC'}; %%%%% CHANGE HERE %%%%%
bar_means = [mean_HC, mean_RBD, mean_MSACSc]; %%%%% CHANGE HERE %%%%%
bar_ses = [se_HC, se_RBD, se_MSACSc]; %%%%% CHANGE HERE %%%%%

% Plot bar
barX = categorical(bar_groups);
barX = reordercats(barX, bar_groups);
bar(barX, bar_means, 'EdgeColor', 'black', 'FaceColor', [0.5, 0.5, 0.5], 'FaceAlpha', 0.5);

% Plot individual datapoints
pointEdgeColor = [1, 1, 1];
pointFaceColor = [0.3, 0.3, 0.3];
pointJitterAmount = 0.12;
%%%%% CHANGE HERE %%%%%
scatter(ones(size(score_HC)) * find(barX == 'HC'), score_HC, 15, 'o', 'MarkerEdgeColor', pointEdgeColor, 'MarkerFaceColor', pointFaceColor, 'jitter', 'on', 'jitterAmount', pointJitterAmount);
scatter(ones(size(score_RBD)) * find(barX == 'RBD'), score_RBD, 15, 'o', 'MarkerEdgeColor', pointEdgeColor, 'MarkerFaceColor', pointFaceColor, 'jitter', 'on', 'jitterAmount', pointJitterAmount);
%scatter(ones(size(score_ePD)) * find(barX == 'ePD'), score_ePD, 15, 'o', 'MarkerEdgeColor', pointEdgeColor, 'MarkerFaceColor', pointFaceColor, 'jitter', 'on', 'jitterAmount', pointJitterAmount);
%scatter(ones(size(score_aPDoff)) * find(barX == 'aPDoff'), score_aPDoff, 15, 'o', 'MarkerEdgeColor', pointEdgeColor, 'MarkerFaceColor', pointFaceColor, 'jitter', 'on', 'jitterAmount', pointJitterAmount);
scatter(ones(size(score_MSACSc)) * find(barX == 'MSAC'), score_MSACSc, 15, 'o', 'MarkerEdgeColor', pointEdgeColor, 'MarkerFaceColor', pointFaceColor, 'jitter', 'on', 'jitterAmount', pointJitterAmount);

% Plot errorbar
errorbar(barX, bar_means, bar_ses, 'LineStyle', 'none', 'LineWidth', 2, 'Color', 'black');

% Title and axis labels
title(expTitle);
xlabel('Groups')
ylabel('Gait pattern Z-score')
ylim([-4, 10]);

hold off

%saveas(barComp, strcat(saveDir, Y_name, '_groupcomp'), 'svg');
%saveas(barComp, strcat(saveDir, Y_name, '_groupcomp'), 'png');

end