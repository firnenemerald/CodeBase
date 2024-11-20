function PlotCustomCorr(var1, var2, varargin)
    % PlotCustomCorr - Creates a scatter plot with linear regression line
    % 
    % Inputs:
    %   var1 - First variable (x-axis)
    %   var2 - Second variable (y-axis)
    %   varargin - Optional name-value pairs:
    %       'XLabel' - Label for x-axis
    %       'YLabel' - Label for y-axis
    %       'Title' - Plot title
    %       'MarkerSize' - Size of scatter points (default: 50)
    %       'Alpha' - Transparency of points (default: 0.6)
    
    % Generate patient numbers based on the size of var1
    patientNumbers = 1:size(var1, 1); % Automatically generate patient numbers

    % Parse optional inputs
    inputParserObj = inputParser; % Renamed variable
    addParameter(inputParserObj, 'XLabel', '');
    addParameter(inputParserObj, 'YLabel', '');
    addParameter(inputParserObj, 'Title', '');
    addParameter(inputParserObj, 'MarkerSize', 50);
    addParameter(inputParserObj, 'Alpha', 0.6);
    parse(inputParserObj, varargin{:});
    
    % Remove NaN values
    validIdx = ~isnan(var1) & ~isnan(var2);
    x = var1(validIdx);
    y = var2(validIdx);
    patientNumbers = patientNumbers(validIdx); % Filter patient numbers accordingly
    
    % Check if x and y are vectors
    if ~isvector(x) || ~isvector(y)
        error('x and y must be vectors.');
    end
    
    % Calculate correlation and p-value
    [R, P] = corrcoef(x, y);
    r = R(1,2);
    p = P(1,2);
    
    % Create scatter plot
    scatter(x, y, inputParserObj.Results.MarkerSize, 'filled', ... % Updated access
        'MarkerFaceAlpha', inputParserObj.Results.Alpha, ... % Updated access
        'MarkerEdgeColor', 'none');
    
    % Fit linear regression
    coeffs = polyfit(x, y, 1);
    xFit = linspace(min(x), max(x), 100);
    yFit = polyval(coeffs, xFit);
    
    % Add regression line
    hold on;
    plot(xFit, yFit, 'r-', 'LineWidth', 2);
    
    % Annotate each point with the corresponding patient number
    for i = 1:length(x)
        text(x(i), y(i), num2str(patientNumbers(i)), 'VerticalAlignment', 'bottom', 'HorizontalAlignment', 'right');
    end
    
    hold off;
    
    % Add labels and title
    if ~isempty(inputParserObj.Results.XLabel)
        xlabel(inputParserObj.Results.XLabel);
    end
    if ~isempty(inputParserObj.Results.YLabel)
        ylabel(inputParserObj.Results.YLabel);
    end
    if ~isempty(inputParserObj.Results.Title)
        title(inputParserObj.Results.Title);
    end
    
    % Add correlation statistics text
    text(0.05, 0.95, sprintf('r = %.3f\np = %.3f', r, p), ... % Updated format for p-value
        'Units', 'normalized', ...
        'VerticalAlignment', 'top');
    
    % Make plot look nice
    box on;
    grid on;
end
