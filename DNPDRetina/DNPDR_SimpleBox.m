function DNPDR_SimpleBox(data1, data2, items)

    numItems = size(data1, 2);
    pValues = zeros(1, numItems);
    for i = 1:numItems
        % Extract the i-th column from patients and controls
        patientScores = data1(:, i);
        controlScores = data2(:, i);
        % Perform Wilcoxon rank-sum test (Mann–Whitney U)
        pValues(i) = ranksum(patientScores, controlScores);
    end

    figure;
    hold on;
    for i = 1:numItems
        if (10 < numItems) && (numItems <= 15)
            subplot(3, 5, i);
        elseif (15 < numItems) && (numItems <= 20)
            subplot(4, 5, i);
        end

        boxplot([data1(:, i); data2(:, i)], [repmat({'Patient'}, size(data1, 1), 1); repmat({'Control'}, size(data2, 1), 1)]);
        
        if pValues(i) < 0.05
            title(items(i), 'Color', 'r');
            text(1.5, max([data1(:, i); data2(:, i)]), sprintf('p = %.4f', pValues(i)), 'HorizontalAlignment', 'center', 'Color', 'r');
        else
            title(items(i));
            text(1.5, max([data1(:, i); data2(:, i)]), sprintf('p = %.4f', pValues(i)), 'HorizontalAlignment', 'center');
        end
    end
    hold off;
end