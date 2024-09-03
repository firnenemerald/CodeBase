%% GetGaitParameters.m (ver 1.0.240821)
% Import gait parameters from excel files
% Excel files contain extracted gait parameters

% Copyright (C) 2024 Jung Hwan Shin, Pil-ung Lee, Chanhee Jeong

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

%% Data description & coding
% HC_tdat = 30 healthy controls' (age + sex + height) + 24 gait parameters
% RBD_tdat = 60 RBD patients' (age + sex + height) + gait parameters + UPDRS scores
% MSAC_tdat = 36 MSA patients' (age + sex + height) + gait parameters
% ePD_tdat = 44 early PD patients' (age + sex + height) + gait parameters + UPDRS scores
% aPDoff_tdat = 33 medication off advanced PD patients' (age + sex + height) + gait parameters + UPDRS scores
% aPDon_tdat = ?? medication on advanced PD patients' (age + sex + height) + gait parameters + UPDRS scores

% Each tdat data is sorted by age
% Sex 1 = Male, 2 = Female

% Walking variables (10)
% 1 - step length (mean)
% 2 - step length (cv)
% 3 - step time (mean)
% 4 - step time (cv)
% 5 - step width (mean)
% 6 - step width (cv)
% 7 - cadence
% 8 - velocity
% 9 - step length asymmetry
% 10 - arm swing asymmetry

% Turning variables (12)
% 11 - turning time (mean)
% 12 - turning time (cv)
% 13 - turning step length (mean)
% 14 - turning step length (cv)
% 15 - turning step time (mean)
% 16 - turning step time (cv)
% 17 - turning step width (mean)
% 18 - turning step width (cv)
% 19 - turning step number (mean)
% 20 - turning step number (cv)
% 21 - turning cadence
% 22 - turning velocity

% Posture variables (2)
% 23 - anterior flexion angle
% 24 - dropped head angle

function [tdat, ngdat_p, aPD_ledd, aPDon_nanIdx, ePD_citpet] = GetGaitParameters()

%% Import raw data (.xlsx from gait extractor)
% Import HC_tdat
HC_data = readtable('data\HC_tdat.xlsx', 'VariableNamingRule', 'preserve');
HC_numeric = HC_data{:, vartype('numeric')};
HC_tdat = HC_numeric(:,2:31);

% Import RBD_tdat
RBD_data = readtable('data\RBD_tdat.xlsx', 'VariableNamingRule', 'preserve');
RBD_numeric = RBD_data{:, vartype('numeric')};
RBD_tdat = RBD_numeric(:, 2:31);

% Import MSAC_tdat
MSAC_data = readtable('data\MSAC_tdat.xlsx', 'VariableNamingRule', 'preserve');
MSAC_numeric = MSAC_data{:, vartype('numeric')};
MSAC_tdat = MSAC_numeric(:,2:31);

MSAC_total_data = readtable('data\MSAC_tdat_41.xlsx', 'VariableNamingRule', 'preserve');
MSAC_total_numeric = MSAC_total_data{:, vartype('numeric')};
MSAC_total_tdat = MSAC_total_numeric(:, 2:31);

% Import ePD_tdat
ePD_data = readtable('data\ePD_tdat.xlsx', 'VariableNamingRule', 'preserve');
ePD_numeric = ePD_data{:, vartype('numeric')};
ePD_tdat = ePD_numeric(:,2:31);
ePD_citpet = ePD_numeric(:, 75:143);

% Import aPDoff_tdat
aPDoff_data = readtable('data\aPDoff_tdat.xlsx', 'VariableNamingRule', 'preserve');
aPDoff_numeric = aPDoff_data{:, vartype('numeric')};
aPDoff_tdat = aPDoff_numeric(:, 2:31);
aPD_ledd = aPDoff_numeric(:, 33);

% Import aPDon_tdat
aPDon_data = readtable('data\aPDon_tdat.xlsx', 'VariableNamingRule', 'preserve');
aPDon_numeric = aPDon_data{:, vartype('numeric')};
aPDon_tdat = aPDon_numeric(:, 2:31);

% Structure data
HC = [0*ones(size(HC_tdat, 1), 1), HC_tdat];
RBD = [1*ones(size(RBD_tdat, 1), 1), RBD_tdat];
MSAC = [2*ones(size(MSAC_tdat, 1), 1), MSAC_tdat];
ePD = [3*ones(size(ePD_tdat, 1), 1), ePD_tdat];
aPDoff = [4*ones(size(aPDoff_tdat, 1), 1), aPDoff_tdat];
aPDon = [5*ones(size(aPDon_tdat, 1), 1), aPDon_tdat];
MSAC_t = [6*ones(size(MSAC_total_tdat, 1), 1), MSAC_total_tdat];

% Remove outliers
% RBD(30, :) = [];
% RBD_updrs(30, :) = [];
% ePD([7, 24, 30, 35], :) = [];
% ePD_updrs([7, 24, 30, 35], :) = [];
% aPDoff(24, :) = [];
% aPDoff_updrs(24, :) = [];

% Concatenate data into a single variable
tdat = [HC; RBD; MSAC; ePD; aPDoff; aPDon; MSAC_t];

% Partial gait parameter is acquired by omitting cv parameters:
% step length (cv), step time (cv), step width (cv), turning time (cv), turning step length (cv),
% turning step time (cv), turning step width (cv), turning step number (cv)
gdat = tdat(:, 5:28);
gdat_p = gdat;
gdat_p(:, [2, 4, 6, 12, 14, 16, 18, 20]) = [];

% Remove data with an NaN element
nanIdx = any(isnan(gdat_p), 2);
tdat(nanIdx, :) = [];
gdat_p(nanIdx, :) = [];

aPDon_nanIdx = any(isnan(aPDon), 2);
aPD_ledd(aPDon_nanIdx, :) = [];

%% Normalize data by HC group
mHC = mean(gdat_p(tdat(:, 1) == 0, :));
sHC = std(gdat_p(tdat(:, 1) == 0, :));
ngdat_p = zeros(size(gdat_p));
for idx = 1:size(gdat_p, 2)
    ngdat_p(:, idx) = (gdat_p(:, idx) - mHC(:, idx))/sHC(:, idx);
end

end