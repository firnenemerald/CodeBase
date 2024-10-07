%% GaitPatternPCA.m (ver 1.0.240821)
% Principal component analysis between two groups

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

function [PCA_eigen, e, GIS_Yz, C, explained] = GaitPatternPCA(tdat, cngdat, groups, saveDir, saveFlag)

groupX = groups(1);
groupY = groups(2);

X_idx = tdat(:, 1) == groupX;
Y_idx = tdat(:, 1) == groupY;

X_name = Num2Group(groupX);
Y_name = Num2Group(groupY);

expTitle = strcat(X_name, {' '}, 'vs', {' '}, Y_name);

% Training data and index
PCA_train = [cngdat(X_idx, :); cngdat(Y_idx, :)];
PCA_index = [zeros(sum(X_idx), 1); ones(sum(Y_idx), 1)];
PCA_size = sum(X_idx) + sum(Y_idx);

% Normalize for each row data
PCA_trainz = zeros(size(PCA_train));
for idx = 1:PCA_size
    PCA_trainz(idx, :) = zscore(PCA_train(idx, :));
end
PCA_trainzc = PCA_trainz - mean(PCA_trainz);

% Construct the C matrix
C = zeros(PCA_size, PCA_size);
for idxA = 1:PCA_size
    for idxB = 1:PCA_size
        C(idxA, idxB) = sum(PCA_trainzc(idxA, :).*PCA_trainzc(idxB, :));
    end
end

% Do PCA analysis
[coeff, score, ~, ~, explained, mu] = pca(C);
PCA_eigen = PCA_trainzc' * score;

% Make combination of components
tt = 0;
for idxA = 1:5
    temp = nchoosek(1:5, idxA);
    for idxB = 1:nchoosek(5, idxA)
        tt = tt + 1;
        CCC(tt, 1) = {temp(idxB, :)};
    end
end

% Make model for each combination
for idxA = 1:length(CCC)
    temp = cell2mat(CCC(idxA));
    for idxB = 1:length(temp)
        pred = score(:, temp);
        %mdl = fitglm(pred, PCA_index > 0, 'Distribution', 'binomial', 'Link', 'logit');
        mdl = fitglm(pred, PCA_index > 0, 'Distribution', 'binomial', 'Link', 'logit', 'LikelihoodPenalty', 'jeffreys-prior');
        lscore = mdl.Fitted.Probability;
        [X, Y, T, AUC] = perfcurve((PCA_index > 0), lscore, 'true');
        e = mdl.Coefficients.SE(2:end);
        AIC = mdl.ModelCriterion.AICc;
        AUClist(idxA, 1) = AUC;
        AIClist(idxA, 1) = AIC;
    end
end

% Indexing for best model
mind = find(AUClist == max(AUClist));
mind = mind(end);

pred = score(:, cell2mat(CCC(mind)));
%mdl = fitglm(pred, PCA_index > 0, 'Distribution', 'binomial', 'Link', 'logit');
mdl = fitglm(pred, PCA_index > 0, 'Distribution', 'binomial', 'Link', 'logit', 'LikelihoodPenalty', 'jeffreys-prior');
lscore = mdl.Fitted.Probability;
[X, Y, T, AUC] = perfcurve((PCA_index > 0), lscore, 'true');
e = mdl.Coefficients.Estimate(2:end);
AIC = mdl.ModelCriterion.AICc;

% Plot and save ROC curve to file if saveFlag is true
if saveFlag == true
    figROC = figure;
    plot(X, Y);
    title(expTitle, "Interpreter", "none");
    aucText = sprintf('%s\nAUC = %.2f', expTitle, AUC);
    text(0.5, 0.5, aucText, 'FontSize', 16, 'HorizontalAlignment', 'center');
    pbaspect([1, 1, 1]);
    
    saveas(figROC, strcat(saveDir, Y_name, '_PCArocurve'), 'svg');
    saveas(figROC, strcat(saveDir, Y_name, '_PCArocurve'), 'png');
end

num_e = length(e);

if num_e >= 4
    GIS_Y = PCA_eigen(:,1)*e(1) + PCA_eigen(:,2)*e(2)  + PCA_eigen(:,3)*e(3) + PCA_eigen(:,4)*e(4);
elseif num_e == 3
    GIS_Y = PCA_eigen(:,1)*e(1) + PCA_eigen(:,2)*e(2)  + PCA_eigen(:,3)*e(3);
elseif num_e == 2
    GIS_Y = PCA_eigen(:,1)*e(1) + PCA_eigen(:,2)*e(2);
elseif num_e == 1
    GIS_Y = PCA_eigen(:,1)*e(1);
else
    disp('e has no elements');
end

GIS_Yz = zscore(GIS_Y);

end