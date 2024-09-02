%% GaitPatternScoring.m (ver 1.0.240820)
% Gait pattern scoring with gait parameters

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

clear
close all

% Import gait parameters
[tdat, ngdat_p, aPD_ledd, aPDon_nanIdx] = GetGaitParameters();

% Get each group's indices
HC_idx = tdat(:, 1) == 0;
RBD_idx = tdat(:, 1) == 1;
MSAC_idx = tdat(:, 1) == 2;
ePD_idx = tdat(:, 1) == 3;
aPDoff_idx = tdat(:, 1) == 4;
aPDon_idx = tdat(:, 1) == 5;
MSAC_t_idx = tdat(:, 1) == 6;

% Get age, sex, height, updrs/umsar data from tdat
HC_age = tdat(HC_idx, 2); HC_sex = tdat(HC_idx, 3); HC_height = tdat(HC_idx, 4);
RBD_age = tdat(RBD_idx, 2); RBD_sex = tdat(RBD_idx, 3); RBD_height = tdat(RBD_idx, 4);
RBD_u1 = tdat(RBD_idx, 29); RBD_u2 = tdat(RBD_idx, 30); RBD_u3 = tdat(RBD_idx, 31);
RBD_ut = RBD_u1 + RBD_u2 + RBD_u3;
MSAC_age = tdat(MSAC_idx, 2); MSAC_sex = tdat(MSAC_idx, 3); MSAC_height = tdat(MSAC_idx, 4);
MSAC_u1 = tdat(MSAC_idx, 29); MSAC_u2 = tdat(MSAC_idx, 30);
ePD_age = tdat(ePD_idx, 2); ePD_sex = tdat(ePD_idx, 3); ePD_height = tdat(ePD_idx, 4);
ePD_u1 = tdat(ePD_idx, 29); ePD_u2 = tdat(ePD_idx, 30); ePD_u3 = tdat(ePD_idx, 31); 
ePD_ut = ePD_u1 + ePD_u2 + ePD_u3;
aPDoff_age = tdat(aPDoff_idx, 2); aPDoff_sex = tdat(aPDoff_idx, 3); aPDoff_height = tdat(aPDoff_idx, 4);
aPDoff_u1 = tdat(aPDoff_idx, 29); aPDoff_u2 = tdat(aPDoff_idx, 30); aPDoff_u3 = tdat(aPDoff_idx, 31);
aPDoff_ut = aPDoff_u1 + aPDoff_u2 + aPDoff_u3;
aPDon_age = tdat(aPDon_idx, 2); aPDon_sex = tdat(aPDon_idx, 3); aPDon_height = tdat(aPDon_idx, 4);
aPDon_u1 = tdat(aPDon_idx, 29); aPDon_u2 = tdat(aPDon_idx, 30); aPDon_u3 = tdat(aPDon_idx, 31);
aPDon_ut = aPDon_u1 + aPDon_u2 + aPDon_u3;
MSAC_t_age = tdat(MSAC_t_idx, 2); MSAC_t_sex = tdat(MSAC_t_idx, 3); MSAC_t_height = tdat(MSAC_t_idx, 4);
MSAC_t_u1 = tdat(MSAC_t_idx, 29); MSAC_t_u2 = tdat(MSAC_t_idx, 30);

% Do multivariate linear regression
cngdat = GaitPatternMLR(tdat, ngdat_p);
cngdat_HC = cngdat(HC_idx, :);
cngdat_RBD = cngdat(RBD_idx, :);
cngdat_MSAC = cngdat(MSAC_idx, :);
cngdat_ePD = cngdat(ePD_idx, :);
cngdat_aPDoff = cngdat(aPDoff_idx, :);
cngdat_aPDon = cngdat(aPDon_idx, :);
cngdat_MSAC_t = cngdat(MSAC_t_idx, :);

%============================%
% Select groups for analysis %
scoreGroup = [0, 2];         %
%============================%

% PCA and scoring of gait pattern
[PCA_eigen, e, GIS_Yz, C, explained] = GaitPatternPCA(tdat, cngdat, scoreGroup);

% Calculate each group's gait pattern score
% score_HC = cngdat_HC * GIS_Yz;
% score_RBD = cngdat_RBD * GIS_Yz;
% score_MSAC = cngdat_MSAC * GIS_Yz;
% score_ePD = cngdat_ePD * GIS_Yz;
% score_aPDoff = cngdat_aPDoff * GIS_Yz;
% score_aPDon = cngdat_aPDon * GIS_Yz;
% score_MSAC_t = cngdat_MSAC_t * GIS_Yz;

% Plot score vs covar graph (before and after regression)
% PlotParameterRegression(tdat, ngdat_p, cngdat, GIS_Yz, 'height');

% Plot gait pattern bar graph
% PlotGaitPattern(GIS_Yz, scoreGroup);

% Plot and compare multiple group pattern score
% PlotPatternScore(tdat, cngdat, GIS_Yz, scoreGroup);

% Plot and correlate score vs updrs
% PlotUPDRSCorr(aPDoff_u1, score_aPDoff, scoreGroup, "aPDoff", "u1");
% PlotUPDRSCorr(aPDoff_u2, score_aPDoff, scoreGroup, "aPDoff", "u2");
% PlotUPDRSCorr(aPDoff_u3, score_aPDoff, scoreGroup, "aPDoff", "u3");
% PlotUPDRSCorr(aPDoff_ut, score_aPDoff, scoreGroup, "aPDoff", "ut");

% PlotCustomBar(HC_age, MSAC_age);

% excIdx = [7, 24];
% aPDoff_concat = [score_aPDoff, aPDoff_u1, aPDoff_u2, aPDoff_u3, aPDoff_ut];
% aPDon_concat = [score_aPDon, aPDon_u1, aPDon_u2, aPDon_u3, aPDon_ut];

% aPD_ledd(excIdx, :) = [];
% aPDoff_concat(aPDon_nanIdx, :) = [];
% aPDoff_concat(excIdx, :) = [];
% aPDon_concat(excIdx, :) = [];

% PlotOnOffBar(aPDoff_concat, aPDon_concat, aPD_ledd, 'u1');