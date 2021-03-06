function [fitresult, gof, h] = createFit(pos, dx)
%CREATEFIT(POS,DX)
%  Create a fit.
%
%  Data for 'untitled fit 1' fit:
%      X Input : pos
%      Y Output: dx
%  Output:
%      fitresult : a fit object representing the fit.
%      gof : structure with goodness-of fit info.
%
%  See also FIT, CFIT, SFIT.

%  Auto-generated by MATLAB on 17-Oct-2020 12:23:30


%% Fit: 'untitled fit 1'.
[xData, yData] = prepareCurveData( pos, dx );

% Set up fittype and options.
ft = fittype( 'sqrt(a + b*x + c*x^2)', 'independent', 'x', 'dependent', 'y' );
opts = fitoptions( 'Method', 'NonlinearLeastSquares' );
opts.Display = 'Off';
opts.MaxIter = 800;
opts.StartPoint = [0.6797, 0.6551, 0.1626]; %[0.1966 0.2511 0.6160]; % [0.6797, 0.6551, 0.1626]
opts.TolFun = 1e-09;
opts.TolX = 1e-09;

% Fit model to data.
[fitresult, gof] = fit( xData, yData, ft, opts );

% Plot fit with data.
figure( 'Name', 'untitled fit 1' );
h = plot( fitresult, '--', xData, yData );
legend( h, 'Measurement', 'Fitting', 'Location', 'SouthEast', 'Interpreter', 'tex' );
% Label axes
xlabel( 'Position', 'Interpreter', 'none' );
ylabel( 'D_{4\sigma}', 'Interpreter', 'tex' );
set(h, 'LineWidth', 1, 'MarkerSize', 15);
grid on
hold on


