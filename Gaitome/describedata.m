%% describedata.m (ver 1.1.240923)
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

function [desc] = describedata(arr, flag)
    N = length(arr);
    Avg = mean(arr);
    Std = std(arr);
    Min = min(arr);
    Med = median(arr);
    Max = max(arr);
    basicstats = table(N, Avg, Std, Min, Med, Max);

    switch flag
        case 'table'
            desc = basicstats;
        case 'avg'
            desc = string(Avg) + " ± " + string(Std) + " [" + string(Min) + ", " + string(Max) + "]";
        case 'sex'
            desc = string(sum(arr==1)) + "/" + string(sum(arr==2));
    end
end