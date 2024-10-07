%% GaitPatternMLR.m (ver 1.0.240822)
% Multivariate linear regeression and with age and height

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

function [cngdat] = GaitPatternMLR(tdat, ngdat)

% Get each group's indices
HC_idx = tdat(:, 1) == 1;
RBD_idx = tdat(:, 1) == 2;
ePD_idx = tdat(:, 1) == 3;
aPDoff_idx = tdat(:, 1) == 4;
aPDon_idx = tdat(:, 1) == 5;
MSAC_idx = tdat(:, 1) == 6;
MSACSc_idx = tdat(:, 1) == 7;

% Get age, sex, height data from tdat
HC_age = tdat(HC_idx, 2); HC_sex = tdat(HC_idx, 3); HC_height = tdat(HC_idx, 4);
RBD_age = tdat(RBD_idx, 2); RBD_sex = tdat(RBD_idx, 3); RBD_height = tdat(RBD_idx, 4);
ePD_age = tdat(ePD_idx, 2); ePD_sex = tdat(ePD_idx, 3); ePD_height = tdat(ePD_idx, 4);
aPDoff_age = tdat(aPDoff_idx, 2); aPDoff_sex = tdat(aPDoff_idx, 3); aPDoff_height = tdat(aPDoff_idx, 4);
aPDon_age = tdat(aPDon_idx, 2); aPDon_sex = tdat(aPDon_idx, 3); aPDon_height = tdat(aPDon_idx, 4);
MSAC_age = tdat(MSAC_idx, 2); MSAC_sex = tdat(MSAC_idx, 3); MSAC_height = tdat(MSAC_idx, 4);
MSACSc_age = tdat(MSACSc_idx, 2); MSACSc_sex = tdat(MSACSc_idx, 3); MSACSc_height = tdat(MSACSc_idx, 4);

% Get normalized gait data for each group
HC_ngdat = ngdat(HC_idx, :);
RBD_ngdat = ngdat(RBD_idx, :);
ePD_ngdat = ngdat(ePD_idx, :);
aPDoff_ngdat = ngdat(aPDoff_idx, :);
aPDon_ngdat = ngdat(aPDon_idx, :);
MSAC_ngdat = ngdat(MSAC_idx, :);
MSACSc_ngdat = ngdat(MSACSc_idx, :);

% Linear regression for HC group
coefficients = cell(size(ngdat, 2), 1);
for idx = 1:size(ngdat, 2)
    independent_var = HC_ngdat(:, idx); % Individual gait parameter as independant variables
    dependent_vars = [HC_age, HC_height]; % Age and Height as dependant variables
    [b, ~, ~] = glmfit(dependent_vars, independent_var, 'normal');
    coefficients{idx} = b;
end

% Correct each group by HC linear regression
HC_cngdat = SubgroupRegression(HC_ngdat, coefficients, HC_age, HC_height);
RBD_cngdat = SubgroupRegression(RBD_ngdat, coefficients, RBD_age, RBD_height);
ePD_cngdat = SubgroupRegression(ePD_ngdat, coefficients, ePD_age, ePD_height);
aPDoff_cngdat = SubgroupRegression(aPDoff_ngdat, coefficients, aPDoff_age, aPDoff_height);
aPDon_cngdat = SubgroupRegression(aPDon_ngdat, coefficients, aPDon_age, aPDon_height);
MSAC_cngdat = SubgroupRegression(MSAC_ngdat, coefficients, MSAC_age, MSAC_height);
MSACSc_cngdat = SubgroupRegression(MSACSc_ngdat, coefficients, MSACSc_age, MSACSc_height);

cngdat = [HC_cngdat; RBD_cngdat; ePD_cngdat; aPDoff_cngdat; aPDon_cngdat; MSAC_cngdat; MSACSc_cngdat];

end

function [cngdat] = SubgroupRegression(ngdat, coefficients, age, height)
cngdat = zeros(size(ngdat));
for idx = 1:size(ngdat, 2)
    b1 = coefficients{idx}(1);
    b2 = coefficients{idx}(2);
    b3 = coefficients{idx}(3);
    correction = b1 + b2*age + b3*height;
    cngdat(:, idx) = ngdat(:, idx) - correction;
end

end