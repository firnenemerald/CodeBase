function DNPDR_SimpleValueBar(values, labels, ylabelText, titleText)
    % Function for plotting and saving simple bar graphs
    
    % Check if the number of labels matches the number of values in percentage
    [~, n] = size(values);
    if length(labels) ~= n
        error('Number of labels must match the number of columns in the value array');
    end

    % Set the save directory as ./figure/yyMMdd/
    timestamp1 = string(datetime('now', 'Format', 'yy-MM-dd'));
    saveDir = strcat("./figure/", timestamp1);

    % Create the directory if it does not exist
    if ~exist(saveDir, 'dir')
        mkdir(saveDir);
    end
    
    % Color bars based on their value
    barColors = repmat([0.5, 0.5, 0.5], n, 1); % Default color is gray
    barColors(values >= 0.1, :) = repmat([1, 0, 0], sum(values >= 0.1), 1); % Red for values >= 0.1
    hold on
    for i = 1:n
        bar(i, values(i), 'FaceColor', barColors(i, :));
    end
    
    % Set the x-axis ticks and labels
    set(gca, 'XTick', 1:n, 'XTickLabel', labels);
    
    % Set the x-axis limits
    xlim([0.5, n + 0.5]);

    % Add a horizontal reference line at y = 0.05
    yline(0.1, 'r--');

    % Add labels and title
    ylabel(ylabelText);
    title(titleText);

    hold off
    
    % Save the figure as a .png file with a random number to ensure uniqueness
    timestamp2 = string(datetime('now', 'Format', 'yy-MM-dd_HH-mm-ss_SSSS'));
    saveas(gcf, fullfile(saveDir, strcat("sbar_", timestamp2, ".png")));
    
    % Close the figure window
    close(gcf);
end