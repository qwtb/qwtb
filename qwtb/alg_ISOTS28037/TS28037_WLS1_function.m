% This script is partly based on NPL's Software to Support ISO/TS 28037:2010(E)
% and was made to be used in QWTB.
%
% Inputs: MUST be collumn vectors!
%   x: independent variable, collumn vector
%   y: dependent variable, collumn vector
%   uy: uncertainty of dependent variable, collumn vector
%   yp: prediction value (y is known, x has to be estimated)
%   uyp: uncertainty of prediction value
%   xf: forward evaluation value (x is known, y has to be estimated)
%   uxf: uncertainty of forward evaluation value
% Outputs:
%   a: intercept
%   b: slope
%   ua: uncertainty of intercept
%   ub: uncertainty of intercept
%   uab: covariance associated with estimates of intercept and slope
%   chi_sq_obs: observed chi-squared value
%   chi_sq: 95 %% quantile of chi-squared distribution
%   model_rejected: if 1, straight-line model is rejected
%   xp: estimate of x from prediction
%   uxp: uncertainty of x from prediction
%   yf: estimate of y from forward evaluation
%   uyf: uncertainty of x forward evaluation
%
function [a, b, ua, ub, uab, chi_sq_obs, chi_sq, model_rejected, xp, uxp, yf, uyf] = TS28037_WLS1_function(x, y, uy, yp, uyp, xf, uxf)

%% Software to support ISO/TS 28037:2010(E)

%% Introduction
% This document runs the numerical example of weighted least squares (WLS)
% with *known equal weights* described in *Clause 6 (Model for 
% uncertainties associated with the y_i)*, and performs the prediction 
% described in *11.1 EXAMPLE 1* and forward evaluation described in 
% *11.2 EXAMPLE*. 
%
% Users of MATLAB may run the code in the corresponding M-file directly to 
% obtain the results given in ISO/TS 28037:2010(E) and may also modify the 
% data and run the code on the new data.
% 
% For users who do not have access to MATLAB, the software may be used as
% the basis for preparing implementations in other programming languages.
%
% The software is provided with a <NPL_TS_28037(2010)_MSC_L_10_001.pdf 
% software licence agreement> (REF: MSC/L/10/001) and the use of the 
% software is subject to the terms laid out in that agreement. By running 
% the M-code, the user accepts the terms of the agreement. 

        % Commented out during modification of the original script into the function:
        % close all
        % clear
        % format short

%% Assign measurement data

%%
% Assign x-values. 
        % Commented out during modification of the original script into the function. This is now function input:
        % x = [1.0 2.0 3.0 4.0 5.0 6.0]'; 
m = length(x); 

%% 
% Assign y-values. 
        % Commented out during modification of the original script into the function. This is now function input:
        % y = [3.3 5.6 7.1 9.3 10.7 12.1]'; 

%%
% Assign uncertainties associated with y-values. 
        % Commented out during modification of the original script into the function. This is now function input:
        % uy = [0.5 0.5 0.5 0.5 0.5 0.5]'; 

%% Obtain estimates of the straight line calibration function parameters and associated standard uncertainties and covariance
% Solve the weighted least squares problem to obtain best fit straight-line parameters. 

%% 
% Step 1.
w = ones(m, 1)./uy; 
F2 = sum(w.*w); 

%% 
% Step 2.
g0 = (sum(w.*w.*x))/F2; 
h0 = (sum(w.*w.*y))/F2; 

%% 
% Step 3.
g = w.*(x - g0); 
h = w.*(y - h0); 

%% 
% Step 4.
G2 = sum(g.*g); 

%% 
% Step 5.
b = (sum(g.*h))/G2; 
a = h0 - b*g0; 

%% 
% Step 6.
u2a = 1/F2 + g0^2/G2; 
u2b = 1/G2; 
uab = -g0/G2; 
% Added during modification of the original script into the function:
ua = sqrt(u2a); % uncertainty of intercept
ub = sqrt(u2b); % uncertainty of slope

%% 
% Step 7.
r = w.*(y - a - b*x); 

%% 
% Step 8.
chi_sq_obs = sum(r.*r); 
nu = m - 2; 

%% 
% Step 9. 
chi_sq = calc_chi_sq_95_percent_quantile(nu); 

% Added during modification of the original script into the function:
model_rejected = chi_sq_obs > chi_sq; % if 1, straight-line model is rejected

        % Commented out during modification of the original script into the function:
        % %% Display information on screen and generate figures 
        % 
        % %% 
        % % Measurement model. 
        % fprintf('\nMODEL FOR UNCERTAINTIES ASSOCIATED WITH THE YI \n\n')
        % fprintf('ISO/TS 28037:2010(E) CLAUSE 6 \n') 
        % fprintf('EXAMPLE (EQUAL WEIGHTS) \n\n')
        % 
        % %% 
        % % Measurement data. 
        % fprintf('FITTING \n')
        % fprintf(['Data representing ', num2str(m),' measurement points, equal weights \n'])
        % for i = 1:m
        %   fprintf('%8.1f %8.1f %8.1f \n', [x(i), y(i), uy(i)]) 
        % end 
        % fprintf('\n')
        % 
        % %% 
        % % Calculation tableau: see <write_wls_tableau.html write_wls_tableau.m>.
        % write_wls_tableau(x, y, w, g0, h0, g, h, a, b, r, '%8.3f ');
        % 
        % %%  
        % % Solution estimates. 
        % fprintf('Estimate of intercept \n'), fprintf('%8.3f \n\n', a)
        % fprintf('Estimate of slope \n'), fprintf('%8.3f \n\n', b)
        % 
        % %%
        % % Standard uncertainties associated with solution estimates. 
        % fprintf('Standard uncertainty associated with estimate of intercept \n'), fprintf('%8.3f \n\n', sqrt(u2a))
        % fprintf('Standard uncertainty associated with estimate of slope \n'), fprintf('%8.3f \n\n', sqrt(u2b))
        % fprintf('Covariance associated with estimates of intercept and slope \n'), fprintf('%8.3f \n\n', uab)
        % 
        % %% 
        % % Validation of the model. 
        % fprintf('VALIDATION \n')
        % fprintf('Degrees of freedom \n'), fprintf('%4u \n\n', nu)
        % fprintf('Observed chi-squared value \n'), fprintf('%9.3f \n\n', chi_sq_obs)
        % fprintf('95 %% quantile of chi-squared distribution with %u degrees of freedom', nu), fprintf('\n%9.3f \n\n', chi_sq)
        % if chi_sq_obs > chi_sq 
        %   fprintf('CHI-SQUARED TEST FAILED - STRAIGHT-LINE MODEL IS REJECTED \n\n')
        % else
        %   fprintf('CHI-SQUARED TEST PASSED - STRAIGHT-LINE MODEL IS ACCEPTED \n\n')
        % end 
        %
        % %% 
        % % Figures. 
        % set(0, 'DefaultLineLineWidth', 2)
        % set(0, 'DefaultAxesFontSize', 12)
        % set(0, 'DefaultAxesFontWeight', 'bold')
        % figure, hold on
        % errorbar(x, y, uy, 'ko', 'MarkerFaceColor', 'k', 'MarkerSize', 6)
        % plot(x, a + b*x, 'b-')
        % xlabel('\it x', 'FontName', 'Times', 'FontSize', 14)
        % ylabel('\it y', 'FontName', 'Times', 'FontSize', 14)
        % axis1 = axis; 
        % figure, hold on
        % for i = 1:m 
        %   plot([x(i), x(i)], [0, r(i)], 'k-')
        %   plot(x(i), r(i), 'ko', 'MarkerFaceColor', 'w', 'MarkerSize', 6)
        % end
        % plot([axis1(1), axis1(2)], [0, 0], 'b--')
        % xlabel('\it x', 'FontName', 'Times', 'FontSize', 14)
        % ylabel('\it r', 'FontName', 'Times', 'FontSize', 14)

%% Prediction
        % Commented out during modification of the original script into the function. This is now function input:
        % yp = 10.5; 
        % uyp = 0.5; 
xp = (yp - a)/b; 
ca = -1/b; 
cb = -(yp - a)/(b^2); 
cy = 1/b; 
% Vectorized during modification of the original script into the function:
        % u2xp = ca^2*u2a + cb^2*u2b + 2*ca*cb*uab + cy^2*uyp^2;  % original line
u2xp = ca.^2.*u2a + cb.^2.*u2b + 2.*ca.*cb.*uab + cy.^2.*uyp.^2;  % vectorized line
% Added during modification of the original script into the function:
uxp = sqrt(u2xp); % uncertainty of intercept
        % Commented out during modification of the original script into the function:
        % fprintf('ISO/TS 28037:2010(E) 11.1 \n') 
        % fprintf('EXAMPLE 1 \n\n')
        % fprintf('PREDICTION \n')
        % fprintf('Measured y-value \n'), fprintf('%8.3f \n\n', yp)
        % fprintf('Standard uncertainty associated with measured y-value \n'), fprintf('%8.3f \n\n', uyp)
        % fprintf('Estimate of x \n'), fprintf('%8.3f \n\n', xp)
        % fprintf('Sensitivity coefficient wrt a \n'), fprintf('%8.3f \n\n', ca)
        % fprintf('Sensitivity coefficient wrt b \n'), fprintf('%8.3f \n\n', cb) 
        % fprintf('Sensitivity coefficient wrt y \n'), fprintf('%8.3f \n\n', cy) 
        % fprintf('Standard uncertainty associated with estimate of x \n'), fprintf('%8.3f \n\n', sqrt(u2xp))

%% Forward evaluation
        % Commented out during modification of the original script into the function. This is now function input:
        % xf = 3.5; 
        % uxf = 0.2; 
yf = a + b*xf; 
ca = 1; 
cb = xf; 
cx = b; 
% Vectorized during modification of the original script into the function:
        % u2yf = ca^2*u2a + cb^2*u2b + 2*ca*cb*uab + cx^2*uxf^2; % original line
u2yf = ca.^2.*u2a + cb.^2.*u2b + 2.*ca.*cb.*uab + cx.^2.*uxf.^2; % vectorized line
% Added during modification of the original script into the function:
uyf = sqrt(u2yf); % uncertainty of intercept
        % Commented out during modification of the original script into the function:
        % fprintf('ISO/TS 28037:2010(E) 11.2 \n') 
        % fprintf('EXAMPLE \n\n')
        % fprintf('FORWARD EVALUATION \n')
        % fprintf('Measured x-value \n'), fprintf('%8.3f \n\n', xf)
        % fprintf('Standard uncertainty associated with measured x-value \n'), fprintf('%8.3f \n\n', uxf)
        % fprintf('Estimate of y \n'), fprintf('%8.3f \n\n', yf)
        % fprintf('Sensitivity coefficient wrt a \n'), fprintf('%8.3f \n\n', ca)
        % fprintf('Sensitivity coefficient wrt b \n'), fprintf('%8.3f \n\n', cb) 
        % fprintf('Sensitivity coefficient wrt x \n'), fprintf('%8.3f \n\n', cx) 
        % fprintf('Standard uncertainty associated with estimate of y \n'), fprintf('%8.3f \n\n', sqrt(u2yf))

%% Acknowledgements 
% The work described here was supported by the National Measurement Office
% of the UK Department of Business, Innovation and Skills as part of its
% NMS Software Support for Metrology programme. 

end % function
