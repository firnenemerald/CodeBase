function DNPDR_LogicalBox2(var1, var1name, var2, var2name, plotOn)
    if nargin < 5
        plotOn = false;
    end

    % Check if var1 and var2 have the same number of rows
    if size(var1, 1) ~= size(var2, 1)
        error('var1 and var2 must have the same number of rows');
    end

    % Remove rows with NaN values in either var1 or var2
    rowsWithNaN = any(isnan(var1), 2) | any(isnan(var2), 2);
    var1(rowsWithNaN, :) = [];
    var2(rowsWithNaN, :) = [];

    numsig = 0;

    % Make sum of var1
    var1 = sum(var1, 2);

    % Iterate for each column pair to get statistics
    size2 = size(var2, 2);
    pvalues = zeros(1, size2);
    for j = 1:size2
        col1 = var1 ~= 0;
        col2 = var2(:, j);
        col2_0 = col2(~col1);
        col2_1 = col2(~~col1);
        [h, p] = ttest2(col2_0, col2_1);
        if p < 0.05
            numsig = numsig + 1;
        end
        pvalues(1, j) = p;
    end

    disp(numsig)

    % Plot results as subplots
    if plotOn
        figure;
        hold on;
        for j = 1:size2
            subplot(4, 10, 1 + 10*(j-1))
            col1 = var1(:, 1) ~= 0;
            col2 = var2(:, j);
            col2_0 = col2(~col1);
            col2_1 = col2(~~col1);
            boxplot([col2_0; col2_1], [repmat({'Sx (-)'}, size(col2_0, 1), 1); repmat({'Sx (+)'}, size(col2_1, 1), 1)]);
            
            if pvalues(1, j) < 0.05
                title(var2name(j), 'Color', 'r');
                xlabel('Total', 'Color', 'r');
                text(1.5, max([col2_0; col2_1]), sprintf('p = %.4f', pvalues(1, j)), 'HorizontalAlignment', 'center', 'Color', 'r');
            else
                title(var2name(j));
                xlabel('Total');
                text(1.5, max([col2_0; col2_1]), sprintf('p = %.4f', pvalues(1, j)), 'HorizontalAlignment', 'center');
            end
        end
    end
    hold off;
end