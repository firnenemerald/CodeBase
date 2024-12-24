function result = FindNaN(array)
    % Get the size of the input array
    [m, ~] = size(array);
    
    % Initialize the result array with ones
    result = zeros(m, 1);
    
    % Loop through each row
    for i = 1:m
        % Check if there is any NaN in the current row
        if any(isnan(array(i, :)))
            result(i) = 1;
        end
    end
end