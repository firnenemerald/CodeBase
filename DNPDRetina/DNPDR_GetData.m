%% DNPDR_GetData.m
% Import DNPDRP, DNPDRC data from DNPDR_data.xlsx file

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
% (subtotal 7 variables) PID, Sex, Age, YOB, Onset_year, Dx_year, Dx_month,
% (subtotal 68 variables) UPDRS_year, UPDRS_month, UPDRS_part1 x 13, UPDRS_part2 x 13, UPDRS_part3 x 33, UPDRS_part4 x 6, HY, 
% (subtotal 3 variables) MMSE_year, MMSE_month, MMSE_score, 
% (subtotal 22 variables) KVHQ_year, KVHQ_month, KVHQ_part1 x 10, KVHQ_part2 x 10, 
% (subtotal 17 variables) PDSS_year, PDSS_month, PDSS_score x 15, 
% (subtotal 4 variables) Hue_year, Hue_month, Hue_Rt, Hue_Lt, 
% (subtotal 14 variables) VOG_year, VOG_month, HS_Lat_OD_Rt, HS_Lat_OD_Lt, HS_Lat_OS_Rt, HS_Lat_OS_Lt, HS_Acc_OD_Rt, HS_Acc_OD_Lt, HS_Acc_OS_Rt, HS_Acc_OS_Lt, HP_Gain_OD_Rt, HP_Gain_OD_Lt, HP_Gain_OS_Rt, HP_Gain_OS_Lt, 
% (subtotal 76 variables) OCT_year, OCT_month, OD_AXL, OS_AXL, OD_WRT x9, OD_RNFL x9, OD_GCL x9, OD_IPL x9, OS_WRT x9, OS_RNFL x9, OS_GCL x9, OS_IPL x9
DNPDRP_rawdata = readtable('C:/Users/chanh/OneDrive/문서/__My Documents__/CodeBase/DNPDRetina/data/DNPDR_data.xlsx', 'Sheet', 'DNPDRP', 'VariableNamingRule', 'preserve');
DNPDRP_numeric = DNPDRP_rawdata{:, vartype('numeric')};
DNPDRP = DNPDRP_numeric(:, 1:end);

%% Import DNPDRC data
% Total 4+68+3+22+17+4 = 118 variables
% (subtotal 4 variables) PID, Sex, Age, YOB,  
% (subtotal 68 variables) UPDRS_year, UPDRS_month, UPDRS_part1 x 13, UPDRS_part2 x 13, UPDRS_part3 x 33, UPDRS_part4 x 6, HY, 
% (subtotal 3 variables) MMSE_year, MMSE_month, MMSE_score, 
% (subtotal 22 variables) KVHQ_year, KVHQ_month, KVHQ_part1 x 10, KVHQ_part2 x 10, 
% (subtotal 17 variables) PDSS_year, PDSS_month, PDSS_score x 15, 
% (subtotal 4 variables) Hue_year, Hue_month, Hue_Rt, Hue_Lt
DNPDRC_rawdata = readtable('C:/Users/chanh/OneDrive/문서/__My Documents__/CodeBase/DNPDRetina/data/DNPDR_data.xlsx', 'Sheet', 'DNPDRC', 'VariableNamingRule', 'preserve');
DNPDRC_numeric = DNPDRC_rawdata{:, vartype('numeric')};
DNPDRC = DNPDRC_numeric(:, 1:end);

end