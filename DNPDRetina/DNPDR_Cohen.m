function DNPDR_Cohen(var1, var1name, var2, var2name, plotOn)
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

    % Initialize arrays to store Cohen's d values and p-values
    cohenDValues = zeros(size(var1, 2), size(var2, 2));
    pValues = zeros(size(var1, 2), size(var2, 2));

    for i = 1:size(var1, 2)
        for j = 1:size(var2, 2)
            % Convert non-zero elements of var1(:, i) to 1
            binaryVar1 = var1(:, i) ~= 0;

            % Separate var2(:, j) into two groups based on binaryVar1
            groupA = var2(binaryVar1, j); % non-zero elements in var1(:, i)
            groupB = var2(~binaryVar1, j); % zero elements in var1(:, i)

            % Calculate means and standard deviations
            meanA = mean(groupA);
            meanB = mean(groupB);
            stdA = std(groupA);
            stdB = std(groupB);

            % Calculate pooled standard deviation
            pooledStd = sqrt(((length(groupA) - 1) * stdA^2 + (length(groupB) - 1) * stdB^2) / (length(groupA) + length(groupB) - 2));

            % Calculate Cohen's d
            cohenD = - (meanA - meanB) / pooledStd;
            cohenDValues(i, j) = cohenD;

            % Perform independent t-test
            [~, p] = ttest2(groupA, groupB);
            pValues(i, j) = p;

            % Plot histograms if Cohen's d is equal or larger than 0.2
            if cohenD >= 0.2
                figure;
                histogram(groupA, 'FaceColor', 'r', 'EdgeColor', 'k');
                hold on;
                histogram(groupB, 'FaceColor', 'b', 'EdgeColor', 'k');
                hold off;
                title(strcat("Historgram for ", var2name(j), ": ", var1name(i), " positivity"));
                subtitle(strcat("N = ", num2str(size(var1, 1)), " / Cohen's D = ", num2str(cohenD)));
                legend(strcat(var1name(i), " positive"), strcat(var1name(i), " negative"));
            end
        end
    end

    % Plot imagesc of Cohen's d values
    if plotOn
        figure;
        imagesc(cohenDValues);
        colorbar;

        % Create a custom colormap
        nSteps = 64;
        cmap = [linspace(1, 1, nSteps)', linspace(1, 0, nSteps)', linspace(1, 0, nSteps)'];
        colormap(cmap);
        clim([0.2 0.8]); % Set color axis limits to highlight significance

        title('Cohen''s d values');
        set(gca, 'XTick', 1:length(var2name), 'XTickLabel', var2name);
        set(gca, 'YTick', 1:length(var1name), 'YTickLabel', var1name);

        % Add boxes and display Cohen's d values
        for i = 1:size(cohenDValues, 1)
            for j = 1:size(cohenDValues, 2)
                % Display Cohen's d value
                text(j, i, sprintf('%.2f\n(p=%.3f)', cohenDValues(i, j), pValues(i, j)), 'HorizontalAlignment', 'center', 'VerticalAlignment', 'middle', 'Color', 'k');
                
                % Draw rectangle around each box
                rectangle('Position', [j-0.5, i-0.5, 1, 1], 'EdgeColor', 'k');
            end
        end
    end
end