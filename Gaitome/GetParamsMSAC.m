%% Import gait parameters from xlsx files

% Copyright (C) 2024 Chanhee Jeong, Pil-ung Lee, Jung Hwan Shin

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

%% Data description and coding
% HC_pattern = 26 healthy controls
% HC_scoring = 31 healthy controls
% MSAC_pattern = 35 MSA-C patients
% MSAC_scoring = 39 MSA-C patients

% PID = 8 character string
% Age, Height = integer
% Sex 1 = Male, 2 = Female

% Walking variables (9)
% step length (mean) / step length (cv)
% step time (mean) / step time (cv)
% step width (mean)
% cadence / velocity
% step length asymmetry
% arm swing asymmetry

% Turning variables (7)
% turning time (mean)
% turning step length (mean)
% turning step time (mean)
% turning step width (mean)
% turning step number (mean)
% turning cadence
% turning velocity

% Posture variables (2)
% anterior flexion angle
% dropped head angle

function [tdat, ngdat_p, MSAC_pattern_umsars, MSAC_pattern_duration, MSAC_scoring_umsars, MSAC_scoring_duration] = GetParamsMSAC()

%% Import raw data (gait extractor results)

% Import HC_pattern, HC_scoring
% [PID, Name, Age, Sex, Height, 18 params]
HC_pattern_data = readtable('data\HC_pattern.xlsx', 'VariableNamingRule', 'preserve');
HC_pattern_numeric = HC_pattern_data{:, vartype('numeric')};
HC_pattern_tdat = HC_pattern_numeric(:,2:22);
HC_scoring_data = readtable('data\HC_scoring.xlsx', 'VariableNamingRule', 'preserve');
HC_scoring_numeric = HC_scoring_data{:, vartype('numeric')};
HC_scoring_tdat = HC_scoring_numeric(:,2:22);

% Import MSAC_pattern, MSAC_scoring
% [PID, Name, Age, Sex, Height, 18 params]
MSAC_pattern_data = readtable('data\MSAC_pattern.xlsx', 'VariableNamingRule', 'preserve');
MSAC_pattern_numeric = MSAC_pattern_data{:, vartype('numeric')};
MSAC_pattern_tdat = MSAC_pattern_numeric(:, 2:22);
MSAC_pattern_umsars = MSAC_pattern_numeric(:, 23:24);
MSAC_pattern_duration = MSAC_pattern_numeric(:, 25);
MSAC_scoring_data = readtable('data\MSAC_scoring.xlsx', 'VariableNamingRule', 'preserve');
MSAC_scoring_numeric = MSAC_scoring_data{:, vartype('numeric')};
MSAC_scoring_tdat = MSAC_scoring_numeric(:, 2:22);
MSAC_scoring_umsars = MSAC_scoring_numeric(:, 23:24);
MSAC_scoring_duration = MSAC_scoring_numeric(:, 25);

% Structure data into one array: total data (tdat)
HC_pattern = [1*ones(size(HC_pattern_tdat, 1), 1), HC_pattern_tdat];
HC_scoring = [2*ones(size(HC_scoring_tdat, 1), 1), HC_scoring_tdat];
MSAC_pattern = [6*ones(size(MSAC_pattern_tdat, 1), 1), MSAC_pattern_tdat];
MSAC_scoring = [7*ones(size(MSAC_scoring_tdat, 1), 1), MSAC_scoring_tdat];
tdat = [HC_pattern; HC_scoring; MSAC_pattern; MSAC_scoring];

% Get partial gait parameters (gdat_p)
gdat_p = tdat(:, 5:22);

% Remove data with NaN element within partial gait parameters
nanIdx = any(isnan(gdat_p), 2);
tdat(nanIdx, :) = [];
gdat_p(nanIdx, :) = [];

%% Normalize data by HC group to get normalized partial gait parameters (ngdat_p)
mHC = mean(gdat_p(tdat(:, 1) == 1, :));
sHC = std(gdat_p(tdat(:, 1) == 1, :));
ngdat_p = zeros(size(gdat_p));
for idx = 1:size(gdat_p, 2)
    ngdat_p(:, idx) = (gdat_p(:, idx) - mHC(:, idx))/sHC(:, idx);
end

end