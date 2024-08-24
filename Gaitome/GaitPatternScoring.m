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
[tdat, ngdat, ngdat_p] = GetGaitParameters();

% Do multivariate linear regression
cngdat = GaitPatternMLR(tdat, ngdat_p);

% Get each group's indices
HC_idx = tdat(:, 1) == 0;
RBD_idx = tdat(:, 1) == 1;
MSAC_idx = tdat(:, 1) == 2;
ePD_idx = tdat(:, 1) == 3;
aPDoff_idx = tdat(:, 1) == 4;
aPDon_idx = tdat(:, 1) == 5;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Select groups for analysis %
groups = [0, 4]; %%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% PCA and scoring of gait pattern
[PCA_eigen, e, GIS_Yz] = GaitPatternPCA(tdat, cngdat, groups);

% Plot score vs covar graph (before and after regression)
% PlotParameterRegression(tdat, ngdat_p, cngdat, GIS_Yz, 'height');

% Plot gait pattern bar graph
PlotGaitPattern(GIS_Yz, groups);

% Plot and compare multiple group pattern score
PlotPatternScore(tdat, cngdat, GIS_Yz, groups);
