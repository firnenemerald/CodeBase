function outputArray = RemoveNaN(inputArray)
    % Find rows with NaN
    rowsWithNaN = any(isnan(inputArray), 2);
    
    % Remove rows with NaN
    outputArray = inputArray(~rowsWithNaN, :);
end