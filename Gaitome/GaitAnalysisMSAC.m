%% GaitAnalysisMSAC.m
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
saveDir = fullfile('C:\\Users\\chanh\\OneDrive\\문서\\__MyDocuments__\\3. Research\\Gait Analysis (Pf. Shin)\\Figures', [char(currentDate), '_PD', '\\']);

% Create the directory if it does not exist
if ~exist(saveDir, 'dir')
    mkdir(saveDir);
end

%% Import gait parameters
[tdat, ngdat_p, MSAC_pattern_umsar, MSAC_pattern_duration, MSAC_scoring_umsar, MSAC_scoring_duration] = GetParamsMSAC();

% Get each group's indices
HC_pattern_idx = tdat(:, 1) == 1;
HC_scoring_idx = tdat(:, 1) == 2;
MSAC_pattern_idx = tdat(:, 1) == 6;
MSAC_scoring_idx = tdat(:, 1) == 7;

% Get age, sex, height, umsars, duration data from tdat
HC_pattern_age = tdat(HC_pattern_idx, 2); HC_pattern_sex = tdat(HC_pattern_idx, 3); HC_pattern_height = tdat(HC_pattern_idx, 4);
HC_scoring_age = tdat(HC_scoring_idx, 2); HC_scoring_sex = tdat(HC_scoring_idx, 3); HC_scoring_height = tdat(HC_scoring_idx, 4);
MSAC_pattern_age = tdat(MSAC_pattern_idx, 2); MSAC_pattern_sex = tdat(MSAC_pattern_idx, 3); MSAC_pattern_height = tdat(MSAC_pattern_idx, 4);
MSAC_scoring_age = tdat(MSAC_scoring_idx, 2); MSAC_scoring_sex = tdat(MSAC_scoring_idx, 3); MSAC_scoring_height = tdat(MSAC_scoring_idx, 4);
MSAC_pattern_umsars1 = MSAC_pattern_umsar(:, 1); MSAC_pattern_umsars2 = MSAC_pattern_umsar(:, 2);
MSAC_scoring_umsars1 = MSAC_scoring_umsar(:, 1); MSAC_scoring_umsars2 = MSAC_scoring_umsar(:, 2);

%% Multivariate linear regression
cngdat = GaitPatternMLR(tdat, ngdat_p);
cngdat_HC_pattern = cngdat(HC_pattern_idx, :);
cngdat_HC_scoring = cngdat(HC_scoring_idx, :);
cngdat_MSAC_pattern = cngdat(MSAC_pattern_idx, :);
cngdat_MSAC_scoring = cngdat(MSAC_scoring_idx, :);

%================================%
% Select groups for gait pattern %
scoreGroup = [1, 6];             %
%================================%

% Plot gait parameter heatmap
%PlotGaitParamHeat(cngdat_HC, scoreGroup, saveDir);

%% SSM-PCA and scoring
[PCA_eigen, e, GIS_Yz, C, explained] = GaitPatternPCA(tdat, cngdat, scoreGroup, saveDir, false);

% Plot covariate matrix and explained components
PlotPCAProcess(C, explained, scoreGroup, saveDir);

% Plot gait pattern bar graph
PlotGaitPattern(GIS_Yz, scoreGroup, saveDir);

% Calculate each group's gait pattern score
score_HC_pattern = cngdat_HC_pattern * GIS_Yz;
score_HC_scoring = cngdat_HC_scoring * GIS_Yz;
score_MSAC_pattern = cngdat_MSAC_pattern * GIS_Yz;
score_MSAC_scoring = cngdat_MSAC_scoring * GIS_Yz;

% Normalize gait pattern score
msHC = mean(score_HC_pattern); ssHC = std(score_HC_pattern);
score_HC_pattern = (score_HC_pattern - msHC)/ssHC;
score_HC_scoring = (score_HC_scoring - msHC)/ssHC;
score_MSAC_pattern = (score_MSAC_pattern - msHC)/ssHC;
score_MSAC_scoring = (score_MSAC_scoring - msHC)/ssHC;

% Plot score vs covar graph (before and after regression)
% PlotParameterRegression(tdat, ngdat_p, cngdat, GIS_Yz, 'height');

% Plot and compare multiple group pattern score
%PlotPatternScore(tdat, cngdat, GIS_Yz, scoreGroup, saveDir);

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