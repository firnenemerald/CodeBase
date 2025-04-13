%% Function to get DNPDRP, DNPDRC data from .xlsx file

% SPDX-FileCopyrightText: © 2024 Chanhee Jeong <chanheejeong@snu.ac.kr>
% SPDX-License-Identifier: GPL-3.0-or-later

function [DNPDRP, DNPDRC] = DNPDR_GetData()

%% Get DNPDRP (Patient) data
% Total 7+68+3+22+17+4+14+76 = 211 variables

DNPDRP_table = readtable('./data/DNPDR_data.xlsx', 'Sheet', 'DNPDRP', 'VariableNamingRule', 'preserve');
% Remove unnecessary/confidential columns
DNPDRP = removevars(DNPDRP_table, {'PID', 'Name', 'DOB', 'Handedness', 'DOFVisit', 'DOFDx', 'DOFMx', 'DOFEnroll', 'UPDRS_date', 'MMSE_date', 'KVHQ_date', 'PDSS_date', 'Hue_date', 'Sample_date', 'bMR_date', 'CITPET_date', 'VOG_date', 'OCT_date'});

%% Get DNPDRC (Control) data
% Total 4+68+3+22+17+4 = 118 variables

DNPDRC_table = readtable('./data/DNPDR_data.xlsx', 'Sheet', 'DNPDRC', 'VariableNamingRule', 'preserve');
% Remove unnecessary/confidential columns
DNPDRC = removevars(DNPDRC_table, {'PID', 'Name', 'DOB', 'Handedness', 'DOFEnroll', 'UPDRS_date', 'MMSE_date', 'KVHQ_date', 'PDSS_date', 'Hue_date', 'Sample_date', 'bMR_date', 'OCT_date'});

end