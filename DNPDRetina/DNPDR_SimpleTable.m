function DNPDR_SimpleTable(values, xLabel, yLabel, tableTitle)
    % Check if the input dimensions match
    [m, n] = size(values);
    if length(xLabel) ~= n
        error('Length of xLabel must match the number of rows in values');
    end
    if length(yLabel) ~= m
        error('Length of yLabel must match the number of columns in values');
    end
    
    % Create a figure
    figure;
    
    % Create the table
    uitable('Data', values, 'ColumnName', xLabel, 'RowName', yLabel, 'Units', 'Normalized', 'Position', [0, 0, 1, 1]);
    
    % Add the title
    title(tableTitle);
end