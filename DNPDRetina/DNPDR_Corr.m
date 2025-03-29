%% Function for calculation and plotting of correlation
% This function calculates the correlation coefficients and p-values between
% each pair of columns from two input matrices (var1 and var2). It also
% plots the correlation matrix and scatter plots for significant pairs if
% the plotOn flag is set to true.
%
% Example usage:
% var1 = rand(100, 3); % 100 samples, 3 variables
% var2 = rand(100, 2); % 100 samples, 2 variables
% var1name = {'Var1_1', 'Var1_2', 'Var1_3'};
% var2name = {'Var2_1', 'Var2_2'};
% DNPDR_Corr(var1, var1name, var2, var2name, true);
%
% This will calculate the correlation between each pair of columns from var1
% and var2, and plot the correlation matrix and scatter plots for significant
% correlations.

% SPDX-FileCopyrightText: © 2025 Chanhee Jeong <chanheejeong@snu.ac.kr>
% SPDX-License-Identifier: GPL-3.0-or-later

function DNPDR_Corr(var1, var1name, var2, var2name, plotOn)
    if nargin < 5
        plotOn = false;
    end
    
    % Check if var1 and var2 have the same number of rows
    if size(var1, 1) ~= size(var2, 1)
        error('var1 and var2 must have the same number of rows');
    end

    % Check if var1name and var2name have the correct lengths
    if length(var1name) ~= size(var1, 2) || length(var2name) ~= size(var2, 2)
        error('var1name and var2name must match the number of columns in var1 and var2 respectively');
    end

    % Remove rows with NaN values in either var1 or var2
    rowsWithNaN = any(isnan(var1), 2) | any(isnan(var2), 2);
    var1(rowsWithNaN, :) = [];
    var2(rowsWithNaN, :) = [];

    % Initialize matrices to store correlation coefficients and p-values
    [~, numCols1] = size(var1);
    [~, numCols2] = size(var2);
    rho = zeros(numCols1, numCols2);
    pVal = zeros(numCols1, numCols2);

    % Calculate correlation coefficients and p-values
    for i = 1:numCols1
        for j = 1:numCols2
            [rho(i, j), pVal(i, j)] = corr(var1(:, i), var2(:, j));
        end
    end

    % Plotting if plotOn is true
    if plotOn
        % Create a figure for the correlation matrix
        figure;
        imagesc(pVal);
        colorbar;
        title('Correlation Coefficients');
        set(gca, 'XTick', 1:numCols2, 'XTickLabel', var2name, 'YTick', 1:numCols1, 'YTickLabel', var1name);
        hold on;

        % Create a custom colormap
        nSteps = 64;
        cmap = [linspace(1, 1, nSteps)', linspace(0, 1, nSteps)', linspace(0, 1, nSteps)'];
        colormap(cmap);
        clim([0 0.05]); % Set color axis limits to highlight significance

        % Display rho and p-values as text inside boxes
        for i = 1:numCols1
            for j = 1:numCols2
                if isnan(pVal(i, j))
                    patch([j-0.5 j+0.5 j+0.5 j-0.5], [i-0.5 i-0.5 i+0.5 i+0.5], 'w', 'EdgeColor', 'none');
                end
                text(j, i, sprintf('%.2f\n(p=%.3f)', rho(i, j), pVal(i, j)), 'HorizontalAlignment', 'center', 'Color', 'k');
            end
        end

        % Add horizontal and vertical lines to divide each box
        hold on;
        for i = 0.5:numCols1+0.5
            plot([0.5, numCols2+0.5], [i, i], 'k-');
        end
        for j = 0.5:numCols2+0.5
            plot([j, j], [0.5, numCols1+0.5], 'k-');
        end
        hold off;

        % Plot significant pair's scatter plots in individual figures
        for i = 1:numCols1
            for j = 1:numCols2
                if pVal(i, j) < 0.05
                    figure;
                    scatter(var1(:, i), var2(:, j), 'bo', 'filled');
                    title(sprintf('%s vs %s', var1name{i}, var2name{j}));
                    subtitle(strcat("N = ", num2str(size(var1, 1))));
                    xlabel(var1name{i}, "Interpreter", "none");
                    ylabel(var2name{j}, "Interpreter", "none");
                    % Add linear regression line
                    hold on;
                    coeffs = polyfit(var1(:, i), var2(:, j), 1);
                    fittedX = linspace(min(var1(:, i)), max(var1(:, i)), 200);
                    fittedY = polyval(coeffs, fittedX);
                    plot(fittedX, fittedY, 'r-', 'LineWidth', 2);
                    hold off;
                    % Display rho and p-value
                    posXmin = min(var1(:, i)); posXmax = max(var1(:, i)); posX = posXmin * 0.5 + posXmax * 0.5;
                    posYmax = max(var2(:, j)); posYmin = min(var2(:, j)); posY = posYmax * 0.9 + posYmin * 0.1;
                    text(posX, posY, sprintf('rho = %.2f\np = %.3f', rho(i, j), pVal(i, j)), 'HorizontalAlignment', 'center');
                end
            end
        end
    end
end