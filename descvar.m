%% descvar.m (ver 1.2.241012)
% Basic descriptive statistics for 1-d data

% Copyright (C) 2024 Chanhee Jeong

% This program is free software: you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation, either version 3 of the License, or
% (at your option) any later version.

% This program is distributed in the hope that it will be useful,
% but WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
% GNU General Public License for more details.

% You should have received a copy of the GNU General Public License
% along with this program.  If not, see <https://www.gnu.org/licenses/>.

function [desc] = descvar(arr, flag)
    arguments
        arr (:,1) double
        flag char {mustBeMember(flag, ["table", "desc", "sex"])} = "desc"
    end

    % Count N/A values
    NA_count = sum(isnan(arr));
    
    % Remove N/A values for calculations
    arr_clean = arr(~isnan(arr));

    N = length(arr_clean);
    Avg = mean(arr_clean);
    Std = std(arr_clean);
    Min = min(arr_clean);
    Med = median(arr_clean);
    Max = max(arr_clean);
    statsTable = table(N, NA_count, Avg, Std, Min, Med, Max);

    switch flag
        case 'table'
            desc = statsTable;
        case 'desc'
            desc = string(Avg) + " ± " + string(Std) + " [" + string(Min) + ", " + string(Max) + "]" + ...
                   " (N=" + string(N) + ", NA=" + string(NA_count) + ")";
        case 'sex'
            desc = string(sum(arr_clean==1)) + "/" + string(sum(arr_clean==2)) + ...
                   " (NA=" + string(NA_count) + ")";
    end
end