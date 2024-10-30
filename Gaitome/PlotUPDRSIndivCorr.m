%% PlotUPDRSIndivCorr.m
% UPDRS individual score correlation with gait pattern score

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

% Primarily only look at updrs part 3 scores

function [] = PlotUPDRSIndivCorr(updrs, score, scoreGroup, groupName, updrsName, saveDir)

updrs_u3 = updrs(:, 18:42);

patternName = Num2Group(scoreGroup(2));

% Create descriptive tags for UPDRS Part 3
u3_tags = {"Speech", "Facial expression", "Resting tremor (LLE)", "Resting tremor (RLE)", ...
           "Resting tremor (LUE)", "Resting tremor (RUE)", "Tremor (chin, tongue)", ...
           "Action tremor (LUE)", "Action tremor (RUE)", "Action tremor (LLE)", ...
           "Action tremor (RLE)", "Rigidity (LUE)", "Rigidity (RUE)", "Rigidity (LLE)", ...
           "Rigidity (RLE)", "Rigidity (neck)", "Hand movement (Lt)", "Hand movement (Rt)", ...
           "Leg agility (Lt)", "Leg agility (Rt)", "Arise from chair", "Posture", "Gait", ...
           "Postural instability", "Bradykinesia"};

% Calculate correlation and p-values
[r, p] = corr(updrs_u3, score);

% Create a mask for significant correlations
mask = p < 0.05;

% Calculate figure size to maintain aspect ratio
numCols = size(r, 1);
numRows = size(r, 2);
figWidth = 1500;
figHeight = figWidth * (numRows / numCols);

% Create heatmap
figure('Position', [100, 100, figWidth, figHeight]);
h = imagesc(r');
colormap(redblue);
clim([0, 0.6]);  % Set color limits
colorbar;

% Apply mask to hide non-significant correlations
set(h, 'AlphaData', mask');

xlabel('UPDRS Part 3 Items');
ylabel('Gait Pattern Scores');

% Remove ticks but keep labels
set(gca, 'XTick', 1:25, 'XTickLabel', u3_tags, 'XTickLabelRotation', 90, 'TickLength', [0 0]);
set(gca, 'YTick', 1:length(scoreGroup), 'YTickLabel', scoreGroup, 'TickLength', [0 0]);

% Set aspect ratio
daspect([3 1 1]);

% Draw grid lines
hold on;
for i = 0.5:1:25.5
    plot([i i], [0.5 length(scoreGroup)+0.5], 'k-', 'LineWidth', 0.5);
end
for j = 0.5:1:length(scoreGroup)+0.5
    plot([0.5 25.5], [j j], 'k-', 'LineWidth', 0.5);
end
hold off;

% Add text to each cell
for i = 1:size(r, 1)
    for j = 1:size(r, 2)
        % Format p-value to avoid scientific notation
        if p(i,j) < 0.01
            p_str = sprintf('%.5f', p(i,j));
        else
            p_str = sprintf('%.2f', p(i,j));
        end
        
        text(i, j, sprintf('%.3f\n(%s)', r(i,j), p_str), ...
             'HorizontalAlignment', 'center', 'VerticalAlignment', 'middle', ...
             'FontSize', 6, 'Color', 'k');
    end
end

% Adjust layout and save figure
sgtitle(sprintf('UPDRS Part 3 Individual Correlations with %s', groupName));
set(gcf, 'Units', 'Normalized', 'OuterPosition', [0 0 1 1]);

% Save the figure
if ~exist(saveDir, 'dir')
    mkdir(saveDir);
end
saveas(gcf, fullfile(saveDir, sprintf('UPDRS_IndivCorr_%s.png', updrsName)));

end
