function DNPDR_SimpleBar(logicalArray, labels, ylabelText, titleText)
    % Check if the input logicalArray is a logical matrix
    if ~islogical(logicalArray)
        error('Input must be a logical array');
    end
    
    % Check if the number of labels matches the number of columns in logicalArray
    [m, n] = size(logicalArray);
    if length(labels) ~= n
        error('Number of labels must match the number of columns in the logical array');
    end

    % Set the save directory as ./figure/
    saveDir = './figure';

    % Create the directory if it does not exist
    if ~exist(saveDir, 'dir')
        mkdir(saveDir);
    end

    % Calculate the proportion of 1's in each column
    proportions = sum(logicalArray) / m * 100; % Convert to percentage
    
    % Create the bar graph
    bar(proportions);
    
    % Add percentage text above each bar
    for i = 1:n
        text(i, proportions(i) + 3, sprintf('%.1f%%', proportions(i)), 'HorizontalAlignment', 'center');
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
    timestamp = string(datetime('now', 'Format', 'yy-MM-dd_HH-mm-ss_SSSS'));
    saveas(gcf, fullfile(saveDir, strcat("sbar_", timestamp, ".png")));
    
    % Close the figure window
    close(gcf);
end