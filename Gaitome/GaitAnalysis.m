%% GaitAnalysis.m
% Main code for video-based gait analysis and gait pattern scoring

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

clear
close all

% Set the save directory as ../Figures/YYMMDD/
currentDate = datetime('today', 'Format', 'yyMMdd');
saveDir = fullfile('C:\\Users\\chanh\\OneDrive\\문서\\__My Documents__\\3. Research\\Gait Analysis (Pf. Shin)\\Figures', [char(currentDate), '_PD', '\\']);

% Create the directory if it does not exist
if ~exist(saveDir, 'dir')
    mkdir(saveDir);
end

%% Import gait parameters
[tdat, ngdat_p, ePD_updrs, ePD_citpet, aPD_ledd, aPDoff_updrs, aPD_citpet, aPDon_updrs] = GetParams();

% Get each group's indices
HC_idx = tdat(:, 1) == 1;
RBD_idx = tdat(:, 1) == 2;
ePD_idx = tdat(:, 1) == 3;
aPDoff_idx = tdat(:, 1) == 4;
aPDon_idx = tdat(:, 1) == 5;
MSAC_idx = tdat(:, 1) == 6;
MSACSc_idx = tdat(:, 1) == 7;

% Get age, sex, height, updrs data from tdat
HC_age = tdat(HC_idx, 2); HC_sex = tdat(HC_idx, 3); HC_height = tdat(HC_idx, 4);
RBD_age = tdat(RBD_idx, 2); RBD_sex = tdat(RBD_idx, 3); RBD_height = tdat(RBD_idx, 4);
RBD_u1 = tdat(RBD_idx, 29); RBD_u2 = tdat(RBD_idx, 30); RBD_u3 = tdat(RBD_idx, 31);
RBD_ut = RBD_u1 + RBD_u2 + RBD_u3;
ePD_age = tdat(ePD_idx, 2); ePD_sex = tdat(ePD_idx, 3); ePD_height = tdat(ePD_idx, 4);
ePD_u1 = tdat(ePD_idx, 29); ePD_u2 = tdat(ePD_idx, 30); ePD_u3 = tdat(ePD_idx, 31); 
ePD_ut = ePD_u1 + ePD_u2 + ePD_u3; ePD_dur = tdat(ePD_idx, 32);
aPDoff_age = tdat(aPDoff_idx, 2); aPDoff_sex = tdat(aPDoff_idx, 3); aPDoff_height = tdat(aPDoff_idx, 4);
aPDoff_u1 = tdat(aPDoff_idx, 29); aPDoff_u2 = tdat(aPDoff_idx, 30); aPDoff_u3 = tdat(aPDoff_idx, 31);
aPDoff_ut = aPDoff_u1 + aPDoff_u2 + aPDoff_u3; aPDoff_dur = tdat(aPDoff_idx, 32);
aPDon_age = tdat(aPDon_idx, 2); aPDon_sex = tdat(aPDon_idx, 3); aPDon_height = tdat(aPDon_idx, 4);
aPDon_u1 = tdat(aPDon_idx, 29); aPDon_u2 = tdat(aPDon_idx, 30); aPDon_u3 = tdat(aPDon_idx, 31);
aPDon_ut = aPDon_u1 + aPDon_u2 + aPDon_u3;
MSAC_age = tdat(MSAC_idx, 2); MSAC_sex = tdat(MSAC_idx, 3); MSAC_height = tdat(MSAC_idx, 4);
MSAC_u1 = tdat(MSAC_idx, 29); MSAC_u2 = tdat(MSAC_idx, 30);
MSAC_ut = MSAC_u1 + MSAC_u2; MSAC_dur = tdat(MSAC_idx, 32);

%% Multivariate linear regression
cngdat = GaitPatternMLR(tdat, ngdat_p);
cngdat_HC = cngdat(HC_idx, :);
cngdat_RBD = cngdat(RBD_idx, :);
cngdat_ePD = cngdat(ePD_idx, :);
cngdat_aPDoff = cngdat(aPDoff_idx, :);
cngdat_aPDon = cngdat(aPDon_idx, :);
cngdat_MSAC = cngdat(MSAC_idx, :);
cngdat_MSACSc = cngdat(MSACSc_idx, :);

%============================%
% Select groups for analysis %
scoreGroup = [1, 4];         %
%============================%

% Plot gait parameter heatmap
%PlotGaitParamHeat(cngdat_HC, scoreGroup, saveDir);

%% SSM-PCA and scoring
[PCA_eigen, e, GIS_Yz, C, explained] = GaitPatternPCA(tdat, cngdat, scoreGroup, saveDir, true);

% Plot covariate matrix and explained components
PlotPCAProcess(C, explained, scoreGroup, saveDir);

% Plot gait pattern bar graph
PlotGaitPattern(GIS_Yz, scoreGroup, saveDir);

% Calculate each group's gait pattern score
score_HC = cngdat_HC * GIS_Yz;
score_RBD = cngdat_RBD * GIS_Yz;
score_ePD = cngdat_ePD * GIS_Yz;
score_aPDoff = cngdat_aPDoff * GIS_Yz;
score_aPDon = cngdat_aPDon * GIS_Yz;
score_MSAC = cngdat_MSAC * GIS_Yz;
score_MSACSc = cngdat_MSACSc * GIS_Yz;

% Normalize gait pattern score
msHC = mean(score_HC);
ssHC = std(score_HC);
score_HC = (score_HC - msHC)/ssHC;
score_RBD = (score_RBD - msHC)/ssHC;
score_ePD = (score_ePD - msHC)/ssHC;
score_aPDoff = (score_aPDoff - msHC)/ssHC;
score_aPDon = (score_aPDon - msHC)/ssHC;
score_MSAC = (score_MSAC - msHC)/ssHC;
score_MSACSc = (score_MSACSc - msHC)/ssHC;

% Plot score vs covar graph (before and after regression)
% PlotParameterRegression(tdat, ngdat_p, cngdat, GIS_Yz, 'height');

% Plot and compare multiple group pattern score
PlotPatternScore(tdat, cngdat, GIS_Yz, scoreGroup, saveDir);

% Plot and correlate score vs updrs
%PlotUPDRSCorr(aPDoff_u2, score_aPDoff, scoreGroup, "aPD", "u2", saveDir);
%PlotUPDRSCorr(ePD_ut, score_ePD, scoreGroup, "ePD", "ut", saveDir);

% Plot and correlate score vs individual updrs scores
%PlotUPDRSIndivCorr(aPDoff_updrs, score_aPDoff, scoreGroup, "aPD", "u3", saveDir)

% Compare aPD on vs off states with LEDD
%aPDoff_concat = [score_aPDoff, aPDoff_u1, aPDoff_u2, aPDoff_u3, aPDoff_ut];
%aPDoff_concat(aPDon_nanIdx, :) = [];
%aPDon_concat = [score_aPDon, aPDon_u1, aPDon_u2, aPDon_u3, aPDon_ut];
%PlotOnOffBar(aPDoff_concat, aPDon_concat, aPD_ledd, 'u3', saveDir);

% Plot CITPET correlation
% PlotCITPETCorr(score_ePD, ePD_citpet, scoreGroup, 'ALL', 'b', saveDir);
% PlotCITPETCorr(score_ePD, ePD_citpet, scoreGroup, 'Pdp', 'b', saveDir);
% PlotCITPETCorr(score_ePD, ePD_citpet, scoreGroup, 'Pdp', 'l', saveDir);
% PlotCITPETCorr(score_ePD, ePD_citpet, scoreGroup, 'Pdp', 'r', saveDir);
% PlotCITPETCorr(score_ePD, ePD_citpet, scoreGroup, 'apP_rat', 'b', saveDir);
% PlotCITPETCorr(score_ePD, ePD_citpet, scoreGroup, 'LC', 'b', saveDir);
% PlotCITPETCorr(score_aPDoff, aPD_citpet, scoreGroup, 'ALL', 'b', saveDir);
% PlotCITPETCorr(score_aPDoff, aPD_citpet, scoreGroup, 'Pdp', 'b', saveDir);
% PlotCITPETCorr(score_aPDoff, aPD_citpet, scoreGroup, 'Pdp', 'l', saveDir);
% PlotCITPETCorr(score_aPDoff, aPD_citpet, scoreGroup, 'Pdp', 'r', saveDir);
% PlotCITPETCorr(score_aPDoff, aPD_citpet, scoreGroup, 'apP_rat', 'b', saveDir);
% PlotCITPETCorr(score_aPDoff, aPD_citpet, scoreGroup, 'LC', 'b', saveDir);
