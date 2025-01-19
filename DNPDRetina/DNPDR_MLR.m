function var_mlr = DNPDR_MLR(var, varName, age, dur, axl, plotOn)
    % Check if plotOn is provided, if not, set to false
    if nargin < 6
        plotOn = false;
    end

    % Remove rows with NaN values in var
    validRows = all(~isnan(var), 2);
    var_valid = var(validRows, :);
    age_valid = age(validRows, :);
    dur_valid = dur(validRows, :);
    axl_valid = axl(validRows, :);

    % Initialize var_mlr
    var_mlr_valid = zeros(size(var_valid));

    % Perform multiple linear regression for each column of var_valid
    for i = 1:size(var_valid, 2)
        tbl = table(var_valid(:, i), age_valid, dur_valid, axl_valid, 'VariableNames', {'Var', 'Age', 'Dur', 'Axl'});
        lm = fitlm(tbl, 'Var ~ Age + Dur + Axl');
        var_mlr_valid(:, i) = lm.Residuals.Raw + mean(var_valid(:, i)); % Add mean value of var_valid after correction
    end

    % Create the final var_mlr with NaNs in the original positions
    var_mlr = NaN(size(var));
    var_mlr(validRows, :) = var_mlr_valid;

    % Plotting if plotOn is true
    if plotOn
        for i = 1:size(var_valid, 2)
            figure;
            subplot(3, 1, 1);
            scatter(age_valid, var_valid(:, i), 'ro', 'filled', 'SizeData', 9); % Filled circles with half size
            hold on;
            scatter(age_valid, var_mlr_valid(:, i), 'bo', 'filled', 'SizeData', 9); % Filled circles with half size
            xlabel('Age(yr)');
            ylabel(varName(i));
            legend('Original', 'Corrected');
            title(strcat("Age(yr) vs ", varName(i)));
            subtitle(strcat("N = ", num2str(sum(validRows))));
            % Add linear regression lines
            lm_var = fitlm(age_valid, var_valid(:, i));
            lm_var_mlr = fitlm(age_valid, var_mlr_valid(:, i));
            plot(age_valid, lm_var.Fitted, 'r');
            plot(age_valid, lm_var_mlr.Fitted, 'b');
            legend('Original', 'Corrected');
            
            % Display linear regression equations
            eqn_orig = sprintf('y = %.2fx + %.2f', lm_var.Coefficients.Estimate(2), lm_var.Coefficients.Estimate(1));
            eqn_corr = sprintf('y = %.2fx + %.2f', lm_var_mlr.Coefficients.Estimate(2), lm_var_mlr.Coefficients.Estimate(1));
            text(min(age_valid), max(var_valid(:, i)), eqn_orig, 'Color', 'r');
            text(min(age_valid), max(var_valid(:, i)) - 0.1 * range(var_valid(:, i)), eqn_corr, 'Color', 'b');
            
            % Display rho value and p-values
            [rho, pval] = corr(age_valid, var_valid(:, i));
            text(min(age_valid), max(var_valid(:, i)) - 0.2 * range(var_valid(:, i)), sprintf('rho = %.3f, p = %.3f', rho, pval), 'Color', 'k');

            subplot(3, 1, 2);
            scatter(dur_valid, var_valid(:, i), 'ro', 'filled', 'SizeData', 9); % Filled circles with half size
            hold on;
            scatter(dur_valid, var_mlr_valid(:, i), 'bo', 'filled', 'SizeData', 9); % Filled circles with half size
            xlabel('Disease Duration(yr)');
            ylabel(varName(i));
            legend('Original', 'Corrected');
            title(strcat("Disease Duration(yr) vs ", varName(i)));
            subtitle(strcat("N = ", num2str(sum(validRows))));
            % Add linear regression lines
            lm_var = fitlm(dur_valid, var_valid(:, i));
            lm_var_mlr = fitlm(dur_valid, var_mlr_valid(:, i));
            plot(dur_valid, lm_var.Fitted, 'r');
            plot(dur_valid, lm_var_mlr.Fitted, 'b');
            legend('Original', 'Corrected');
            
            % Display linear regression equations
            eqn_orig = sprintf('y = %.2fx + %.2f', lm_var.Coefficients.Estimate(2), lm_var.Coefficients.Estimate(1));
            eqn_corr = sprintf('y = %.2fx + %.2f', lm_var_mlr.Coefficients.Estimate(2), lm_var_mlr.Coefficients.Estimate(1));
            text(min(dur_valid), max(var_valid(:, i)), eqn_orig, 'Color', 'r');
            text(min(dur_valid), max(var_valid(:, i)) - 0.1 * range(var_valid(:, i)), eqn_corr, 'Color', 'b');
            
            % Display rho value and p-values
            [rho, pval] = corr(dur_valid, var_valid(:, i));
            text(min(dur_valid), max(var_valid(:, i)) - 0.2 * range(var_valid(:, i)), sprintf('rho = %.3f, p = %.3f', rho, pval), 'Color', 'k');

            subplot(3, 1, 3);
            scatter(axl_valid, var_valid(:, i), 'ro', 'filled', 'SizeData', 9); % Filled circles with half size
            hold on;
            scatter(axl_valid, var_mlr_valid(:, i), 'bo', 'filled', 'SizeData', 9); % Filled circles with half size
            xlabel('Axial Length(mm)');
            ylabel(varName(i));
            legend('Original', 'Corrected');
            title(strcat("Axial Length(mm) vs ", varName(i)));
            subtitle(strcat("N = ", num2str(sum(validRows))));
            % Add linear regression lines
            lm_var = fitlm(axl_valid, var_valid(:, i));
            lm_var_mlr = fitlm(axl_valid, var_mlr_valid(:, i));
            plot(axl_valid, lm_var.Fitted, 'r');
            plot(axl_valid, lm_var_mlr.Fitted, 'b');
            legend('Original', 'Corrected');
            
            % Display linear regression equations
            eqn_orig = sprintf('y = %.2fx + %.2f', lm_var.Coefficients.Estimate(2), lm_var.Coefficients.Estimate(1));
            eqn_corr = sprintf('y = %.2fx + %.2f', lm_var_mlr.Coefficients.Estimate(2), lm_var_mlr.Coefficients.Estimate(1));
            text(min(axl_valid), max(var_valid(:, i)), eqn_orig, 'Color', 'r');
            text(min(axl_valid), max(var_valid(:, i)) - 0.1 * range(var_valid(:, i)), eqn_corr, 'Color', 'b');
            
            % Display rho value and p-values
            [rho, pval] = corr(axl_valid, var_valid(:, i));
            text(min(axl_valid), max(var_valid(:, i)) - 0.2 * range(var_valid(:, i)), sprintf('rho = %.3f, p = %.3f', rho, pval), 'Color', 'k');
        end
    end
end