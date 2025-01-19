function result = EagerMean(array1, array2)
    % Check if the input arrays have the same size
    if size(array1, 1) ~= size(array2, 1) || size(array1, 2) ~= 1 || size(array2, 2) ~= 1
        error('Input arrays must have the same number of rows and one column each.');
    end
    
    % Initialize the result array
    result = zeros(size(array1));
    
    % Iterate through each element
    for i = 1:size(array1, 1)
        if isnan(array1(i)) && isnan(array2(i))
            result(i) = NaN;
        elseif isnan(array1(i))
            if array2(i) == 0
                result(i) = NaN;
            else
                result(i) = array2(i);
            end
        elseif isnan(array2(i))
            if array1(i) == 0
                result(i) = NaN;
            else
                result(i) = array1(i);
            end
        elseif array1(i) == 0 && array2(i) == 0
            result(i) = NaN;
        elseif array1(i) == 0 && array2(i) ~= 0
            result(i) = array2(i);
        elseif array2(i) == 0 && array1(i) ~= 0
            result(i) = array1(i);
        else
            result(i) = mean([array1(i), array2(i)]);
        end
    end
end