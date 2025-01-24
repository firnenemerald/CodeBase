%% DNPDR_DistributionBar.m
% Plot custom bar graph to visualize data

% Copyright (C) 2024 Chanhee Jeong

function [] = DNPDR_DistributionBar(var, varName, group, showText)

arguments
    var (:, :) double
    varName (1, 1) string
    group (1, :) string
    showText (1, 1) logical = true  % New argument with default value true
end

% Count total points and NaN data
totalNum = size(var, 1);
nanCount = sum(isnan(var(:, 1)));

% Remove NaN values for calculations
var_clean = var(~isnan(var(:, 1)), :);

m = mean(var_clean, 1); se = std(var_clean, 1)/sqrt(size(var_clean, 1));

figure
hold on

barX = categorical(group);
barX = reordercats(barX, group);

bar(barX, m, 'EdgeColor', 'black', 'FaceColor', [0.5, 0.5, 0.5], 'FaceAlpha', 0.5);
errorbar(barX, m, se, 'LineStyle', 'none', 'LineWidth', 2, 'Color', 'black');

for i = 1:size(var, 2)
    scatter(barX(i), var(:, i), 15, 'o', 'filled', 'MarkerFaceColor', 'black', 'MarkerEdgeColor', 'white');

    if showText  % Only show text if showText is true
        [uniqueVals, ~, ic] = unique(var(:, i));
        valCounts = accumarray(ic, 1);
        for j = 1:length(uniqueVals)
            if ~isnan(uniqueVals(j))
                text(barX(i), uniqueVals(j), sprintf('(%d)', valCounts(j)), ...
                    'HorizontalAlignment', 'left', 'VerticalAlignment', 'middle', ...
                    'FontSize', 8, 'Position', [i+0.1, uniqueVals(j), 0.2], "Interpreter", "none");
            end
        end
    end
end

title(varName, "Interpreter", "none");

% Add text for datapoint count
text(size(var, 2) + 1, max(var_clean, [], "all"), sprintf('n = %d (exc. = %d)', totalNum, nanCount), ...
    'HorizontalAlignment', 'right', 'VerticalAlignment', 'bottom', 'FontSize', 10, "Interpreter", "none");

hold off

end
