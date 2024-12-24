%% DNPDR_GetData.m
% Get DNPDRP, DNPDRC data from data .xlsx file

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

function [DNPDRP, DNPDRC] = DNPDR_GetData()

%% Import DNPDRP data
% Total 7+68+3+22+17+4+14+76 = 211 variables

DNPDRP_table = readtable('./data/DNPDR_data.xlsx', 'Sheet', 'DNPDRP', 'VariableNamingRule', 'preserve');
% Remove unnecessary/confidential columns
DNPDRP = removevars(DNPDRP_table, {'PID', 'Name', 'DOB', 'Handedness', 'DOFVisit', 'DOFDx', 'DOFMx', 'DOFEnroll', 'UPDRS_date', 'MMSE_date', 'KVHQ_date', 'PDSS_date', 'Hue_date', 'Sample_date', 'bMR_date', 'CITPET_date', 'VOG_date', 'OCT_date'});

%% Import DNPDRC data
% Total 4+68+3+22+17+4 = 118 variables

DNPDRC_table = readtable('./data/DNPDR_data.xlsx', 'Sheet', 'DNPDRC', 'VariableNamingRule', 'preserve');
% Remove unnecessary/confidential columns
DNPDRC = removevars(DNPDRC_table, {'PID', 'Name', 'DOB', 'Handedness', 'DOFEnroll', 'UPDRS_date', 'MMSE_date', 'KVHQ_date', 'PDSS_date', 'Hue_date', 'Sample_date', 'bMR_date', 'OCT_date'});

end