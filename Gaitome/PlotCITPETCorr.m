%% PlotCITPETCorr.m (ver 1.1.240923)
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

function [] = PlotCITPETCorr(score, citpet, scoreGroup, roiName, latName, saveDir)

citpet_nanIdx = any(isnan(citpet), 2);
score(citpet_nanIdx, :) = [];
citpet(citpet_nanIdx, :) = [];

patternName = Num2Group(scoreGroup(2));

% Interesting roi = Pdp(b), Pdp(l), Pdp(r), apP_rat(b), LC(b)
% Get interested roi's column
roiList1 = {'Sd', 'C', 'Cda', 'Cva', 'Ct', 'Cb', 'P', 'Pda', 'Pva', 'Pdp', 'Pvp', 'GP', 'GPa', 'GPp', 'Sv', 'DRN', 'LC', 'SN', 'STN'};
roiList2 = {'S_asym', 'C_asym', 'P_asym'};
roiList3 = {'PC_rat', 'CP_rat', 'apP_rat'};

columnNum = 0;
if isscalar(find(strcmpi(roiList1, roiName)))
    columnNum = find(strcmpi(roiList1, roiName));
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
    PlotCITPETCorrTable(score, citpet, patternName, saveDir);
    return
end

citData = citpet(:, columnNum);

figure
hold on
scatter(citData, score, 20, 'filled', 'MarkerFaceColor', 'b');

grid on
title('CIT PET roi value vs gait score');
xlabel(strcat('roi = ', {' '}, roiName, {' '}, '(', latName, ')'), "Interpreter", "none");
ylabel(strcat(patternName, {' '}, 'gait pattern score'), "Interpreter", "none");

[r, p] = corr(citData, score);
linearfit = polyfit(citData, score, 1);
xfit = linspace(min(citData), max(citData), 100);
yfit = polyval(linearfit, xfit);

plot(xfit, yfit, '-b', 'Linewidth', 2);
xlimit = xlim; ylimit = ylim;
text(xlimit(2), ylimit(2), sprintf('R = %.2f, p = %.5f', r, p), 'HorizontalAlignment', 'right');
hold off

end

function [] = PlotCITPETCorrTable(score, citpet, patternName, saveDir)

roiNum = size(citpet, 2);
corrTable = zeros(1, roiNum);
signTable = ones(1, roiNum);
for idx = 1:roiNum
    [r, p] = corr(citpet(:, idx), score);
    corrTable(1, idx) = r;
    signTable(1, idx) = p;
end

sign_threshold = -log10(0.05);
signTrue = signTable;
signTable = -log10(signTable);
signTable(signTable < sign_threshold) = NaN;

corrTable1 = corrTable(:, 1:19);
corrTable2 = corrTable(:, 20:38);
corrTable3 = corrTable(:, 39:57);
corrTable4 = corrTable(:, 58:69);
signTable1 = signTable(:, 1:19);
signTable2 = signTable(:, 20:38);
signTable3 = signTable(:, 39:57);
signTable4 = signTable(:, 58:69);
signTrue1 = signTrue(:, 1:19);
signTrue2 = signTrue(:, 20:38);
signTrue3 = signTrue(:, 39:57);
signTrue4 = signTrue(:, 58:69);

figCIT = figure("WindowState", "maximized");
hold on
myCmap = [1, 1, 1; linspace(1, 1, 255)', linspace(1, 0, 255)', linspace(1, 0, 255)'];

subplot(4, 1, 1)
ax1 = gca;
ax1.PlotBoxAspectRatio = [roiNum, 1, 1];
imagesc(signTable1);

% Apply custom colormap
colormap(myCmap);
bound_low = min(sign_threshold, max(signTable));
bound_high = max(sign_threshold, max(signTable));
if bound_high > bound_low
    clim([bound_low, bound_high]);
end
colorbar;
ylabel(colorbar, '-log10(p-value)');

% Title and axis ticks
title('Both');
label_X = {'Sd', 'C', 'Cda', 'Cva', 'Ct', 'Cb', 'P', 'Pda', 'Pva', 'Pdp', 'Pvp', 'GP', 'GPa', 'GPp', 'Sv', 'DRN', 'LC', 'SN', 'STN'};
label_Y = {sprintf('Pearson''s R (p-value)')};
ax1.XTick = 1:19;
ax1.XTickLabel = label_X;
ax1.YTick = 1;
ax1.YTickLabel = label_Y;
ax1.TickLabelInterpreter = 'none';

% Add text inside each box
for i = 1:19
    text(ax1, i, 1, sprintf('%.3f\n(%.5f)', corrTable1(i), signTrue1(i)), 'HorizontalAlignment', 'center', 'VerticalAlignment', 'middle', 'Color', 'k', 'FontSize', 6);
end

hold on
% Manually add lines as box borders
plot(ax1, [0.5, 19.5], [0.5, 0.5], 'k-', 'LineWidth', 1);
plot(ax1, [0.5, 19.5], [1.5, 1.5], 'k-', 'LineWidth', 1);
for i = 0.5:19.5
    plot(ax1, [i, i], [0.5, 1.5], 'k-', 'LineWidth', 1);
end
hold off

subplot(4, 1, 2)
ax2 = gca;
ax2.PlotBoxAspectRatio = [roiNum, 1, 1];
imagesc(signTable2);

% Apply custom colormap
colormap(myCmap);
bound_low = min(sign_threshold, max(signTable));
bound_high = max(sign_threshold, max(signTable));
if bound_high > bound_low
    clim([bound_low, bound_high]);
end
colorbar;
ylabel(colorbar, '-log10(p-value)');

% Title and axis ticks
title('Left');
label_X = {'Sd', 'C', 'Cda', 'Cva', 'Ct', 'Cb', 'P', 'Pda', 'Pva', 'Pdp', 'Pvp', 'GP', 'GPa', 'GPp', 'Sv', 'DRN', 'LC', 'SN', 'STN'};
label_Y = {sprintf('Pearson''s R (p-value)')};
ax2.XTick = 1:19;
ax2.XTickLabel = label_X;
ax2.YTick = 1;
ax2.YTickLabel = label_Y;
ax2.TickLabelInterpreter = 'none';

% Add text inside each box
for i = 1:19
    text(ax2, i, 1, sprintf('%.3f\n(%.5f)', corrTable2(i), signTrue2(i)), 'HorizontalAlignment', 'center', 'VerticalAlignment', 'middle', 'Color', 'k', 'FontSize', 6);
end

hold on
% Manually add lines as box borders
plot(ax2, [0.5, 19.5], [0.5, 0.5], 'k-', 'LineWidth', 1);
plot(ax2, [0.5, 19.5], [1.5, 1.5], 'k-', 'LineWidth', 1);
for i = 0.5:19.5
    plot(ax2, [i, i], [0.5, 1.5], 'k-', 'LineWidth', 1);
end
hold off

subplot(4, 1, 3)
ax3 = gca;
ax3.PlotBoxAspectRatio = [roiNum, 1, 1];
imagesc(signTable3);

% Apply custom colormap
colormap(myCmap);
bound_low = min(sign_threshold, max(signTable));
bound_high = max(sign_threshold, max(signTable));
if bound_high > bound_low
    clim([bound_low, bound_high]);
end
colorbar;
ylabel(colorbar, '-log10(p-value)');

% Title and axis ticks
title('Right');
label_X = {'Sd', 'C', 'Cda', 'Cva', 'Ct', 'Cb', 'P', 'Pda', 'Pva', 'Pdp', 'Pvp', 'GP', 'GPa', 'GPp', 'Sv', 'DRN', 'LC', 'SN', 'STN'};
label_Y = {sprintf('Pearson''s R (p-value)')};
ax3.XTick = 1:19;
ax3.XTickLabel = label_X;
ax3.YTick = 1;
ax3.YTickLabel = label_Y;
ax3.TickLabelInterpreter = 'none';

% Add text inside each box
for i = 1:19
    text(ax3, i, 1, sprintf('%.3f\n(%.5f)', corrTable3(i), signTrue3(i)), 'HorizontalAlignment', 'center', 'VerticalAlignment', 'middle', 'Color', 'k', 'FontSize', 6);
end

hold on
% Manually add lines as box borders
plot(ax3, [0.5, 19.5], [0.5, 0.5], 'k-', 'LineWidth', 1);
plot(ax3, [0.5, 19.5], [1.5, 1.5], 'k-', 'LineWidth', 1);
for i = 0.5:19.5
    plot(ax3, [i, i], [0.5, 1.5], 'k-', 'LineWidth', 1);
end
hold off

subplot(4, 1, 4)
ax4 = gca;
ax4.PlotBoxAspectRatio = [roiNum, 1, 1];
imagesc(signTable4);

% Apply custom colormap
colormap(myCmap);
bound_low = min(sign_threshold, max(signTable));
bound_high = max(sign_threshold, max(signTable));
if bound_high > bound_low
    clim([bound_low, bound_high]);
end
colorbar;
ylabel(colorbar, '-log10(p-value)');

% Title and axis ticks
title('Others');
label_X = {'S_asym', 'C_asym', 'P_asym', 'PC_rat (b)', 'CP_rat (b)', 'apP_rat (b)', 'PC_rat (l)', 'CP_rat (l)', 'apP_rat (l)', 'PC_rat (r)', 'CP_rat (r)', 'apP_rat (r)'};
label_Y = {sprintf('Pearson''s R (p-value)')};
ax4.XTick = 1:12;
ax4.XTickLabel = label_X;
ax4.YTick = 1;
ax4.YTickLabel = label_Y;
ax4.TickLabelInterpreter = 'none';

% Add text inside each box
for i = 1:12
    text(ax4, i, 1, sprintf('%.3f\n(%.5f)', corrTable4(i), signTrue4(i)), 'HorizontalAlignment', 'center', 'VerticalAlignment', 'middle', 'Color', 'k', 'FontSize', 6);
end

hold on
% Manually add lines as box borders
plot(ax4, [0.5, 12.5], [0.5, 0.5], 'k-', 'LineWidth', 1);
plot(ax4, [0.5, 12.5], [1.5, 1.5], 'k-', 'LineWidth', 1);
for i = 0.5:12.5
    plot(ax4, [i, i], [0.5, 1.5], 'k-', 'LineWidth', 1);
end
hold off

saveas(figCIT, strcat(saveDir, patternName, '_CITPETCorr'), 'svg');
saveas(figCIT, strcat(saveDir, patternName, '_CITPETCorr'), 'png');

end