%% PlotCITPETCorr.m (ver 1.0.240903)
% CITPET correlation with gait pattern score

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

function [] = PlotCITPETCorr(score_ePD, ePD_citpet, scoreGroup, roiName, latName)

ePD_nanIdx = any(isnan(ePD_citpet), 2);
score_ePD(ePD_nanIdx, :) = [];
ePD_citpet(ePD_nanIdx, :) = [];

patternName = Num2Group(scoreGroup(2));

% Interesting roi = Pdp(b), Pdp(l), Pdp(r), apP_rat(b), LC(b)
% Get interested roi's column
roiList1 = {'Sd', 'C', 'Cda', 'Cva', 'Ct', 'Cb', 'P', 'Pda', 'Pva', 'Pdp', 'Pvp', 'GP', 'GPa', 'GPp', 'Sv', 'DRN', 'LC', 'SN', 'STN'};
roiList2 = {'S_asym', 'C_asym', 'P_asym'};
roiList3 = {'PC_rat', 'CP_rat', 'apP_rat'};

columnNum = 0;
if isscalar(find(strcmpi(roiList1, roiName)))
    columnNum = find(strcmpi(roiList1, 'C'));
    switch latName
        case 'b'
            columnNum = columnNum;
        case 'l'
            columnNum = columnNum + 19;
        case 'r'
            columnNum = columnNum + 38;
    end
elseif isscalar(find(strcmpi(roiList2, roiName)))
    columnNum = find(strcmpi(roiList2, roiName)) + 57;
elseif isscalar(find(strcmpi(roiList3, roiName)))
    columnNum = find(strcmpi(roiList3, roiName)) + 60;
    switch latName
        case 'b'
            columnNum = columnNum;
        case 'l'
            columnNum = columnNum + 3;
        case 'r'
            columnNum = columnNum + 6;
    end
elseif (roiName == 'ALL')
    PlotCITPETCorrTable();
end

citData = ePD_citpet(:, columnNum);

figure
hold on
scatter(citData, score_ePD, 20, 'filled', 'MarkerFaceColor', 'b');

grid on
title('(ePD) CIT PET roi value vs gait score');
xlabel(strcat('roi = ', '{ }', roiName, '{ }', '(', latName, ')'));
ylabel(strcat(patternName, '{ }', 'gait pattern score'));

[r, p] = corr(citData, score_ePD);
linearfit = polyfit(citData, score_ePD, 1);
xfit = linspace(min(citData), max(citData), 100);
yfit = polyval(linearfit, xfit);

plot(xfit, yfit, '-b', 'Linewidth', 2);
xlimit = xlim; ylimit = ylim;
text(xlimit(2), ylimit(2), sprintf('R = %.2f, p = %.5f', r, p), 'HorizontalAlignment', 'right');
hold off

end

function [] = PlotCITPETCorrTable(score_ePD, ePD_citpet, scoreGroup)

corrTable = zeros(1, size(ePD_citpet, 2));
for idxA = 1:size(ePD_citpet, 2)
    [r, ~] = corr(ePD_citpet(:, idxA), score_ePD);
    corrTable(1, idxA) = r;
end

figure
imagesc(corrTable);
colorbar;

end