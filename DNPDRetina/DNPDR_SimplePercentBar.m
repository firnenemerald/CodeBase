function DNPDR_SimplePercentBar(percentage, labels, ylabelText, titleText)
    % Function for plotting and saving simple percent bar graphs
    
    % Check if the number of labels matches the number of values in percentage
    [~, n] = size(percentage);
    if length(labels) ~= n
        error('Number of labels must match the number of columns in the percentage array');
    end

    % Set the save directory as ./figure/yyMMdd/
    timestamp1 = string(datetime('now', 'Format', 'yy-MM-dd'));
    saveDir = strcat("./figure/", timestamp1);

    % Create the directory if it does not exist
    if ~exist(saveDir, 'dir')
        mkdir(saveDir);
    end
    
    % Create the bar graph
    bar(percentage);
    
    % Add percentage text above each bar
    for i = 1:n
        text(i, percentage(i) + 3, sprintf('%.1f%%', percentage(i)), 'HorizontalAlignment', 'center');
    end
    
    % Set the x-axis labels
    set(gca, 'XTickLabel', labels);
    
    % Set the x-axis limits
    xlim([0.5, n + 0.5]);
    
    % Set the y-axis limits
    ylim([0, 100]); % Adjust for percentage
    
    % Add labels and title
    ylabel(ylabelText);
    title(titleText);
    
    % Save the figure as a .png file with a random number to ensure uniqueness
    timestamp2 = string(datetime('now', 'Format', 'yy-MM-dd_HH-mm-ss_SSSS'));
    saveas(gcf, fullfile(saveDir, strcat("sbar_", timestamp2, ".png")));
    
    % Close the figure window
    close(gcf);
end