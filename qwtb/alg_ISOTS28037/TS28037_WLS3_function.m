% This script is partly based on NPL's Software to Support ISO/TS 28037:2010(E)
% and was made to be used in QWTB.
%
% Inputs: MUST be collumn vectors!
%   x: independent variable, collumn vector
%   y: dependent variable, collumn vector
%   yp: prediction value (y is known, x has to be estimated)
%   uyp: uncertainty of prediction value
%   xf: forward evaluation value (x is known, y has to be estimated)
%   uxf: uncertainty of forward evaluation value
% Outputs:
%   a: intercept
%   b: slope
%   uat: better uncertainty of intercept
%   ubt: better uncertainty of intercept
%   uabt: better covariance associated with estimates of intercept and slope
%   chi_sq_obs: observed chi-squared value
%   chi_sq: 95 %% quantile of chi-squared distribution
%   model_rejected: if 1, straight-line model is rejected
%   xp: estimate of x from prediction
%   uxp: uncertainty of x from prediction
%   yf: estimate of y from forward evaluation
%   uyf: uncertainty of x forward evaluation
%
function [a, b, ua, ub, uab, chi_sq_obs, chi_sq, model_rejected, xp, uxp, yf, uyf] = TS28037_WLS3_function(x, y, yp, uyp, xf, uxf)

%% Software to support ISO/TS 28037:2010(E)

%% Introduction
% This document runs the numerical example of weighted least squares (WLS)
% with *unknown equal weights* described in *Annex E (Uncertainties known 
% up to a scale factor)*. 
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
        % x = [1.000 2.000 3.000 4.000 5.000 6.000]';
m = length(x); 

%% 
% Assign y-values. 
        % Commented out during modification of the original script into the function. This is now function input:
        % y = [3.014 5.225 7.004 9.061 11.201 12.762]';

%%
% Assign uncertainties associated with y-values. 
        % Commented out during modification of the original script into the function. The weights are set to be equal for all y values.
% uy = [1 1 1 1 1 1]'; % original line
uy = ones(size(y));

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

%% 
% Step 7.
r = w.*(y - a - b*x); 

%% 
% Step 8.
chi_sq_obs = sum(r.*r); 
% Added during modification of the original script into the function:
nu = m - 2; 
chi_sq = calc_chi_sq_95_percent_quantile(nu); 
model_rejected = chi_sq_obs > chi_sq; % if 1, straight-line model is rejected

        % Commented out during modification of the original script into the function:
        % %% Display information on screen and generate figures
        %
        % %%
        % % Measurement model.
        % fprintf('\nMODEL FOR UNCERTAINTIES ASSOCIATED WITH THE YI \n\n')
        % fprintf('ISO/TS 28037:2010(E) ANNEX E \n')
        % fprintf('EXAMPLE (UNKNOWN WEIGHTS) \n\n')
        %
        % %%
        % % Measurement data.
        % fprintf('FITTING \n')
        % fprintf(['Data representing ', num2str(m),' measurement points, unknown equal weights \n'])
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

%% Posterior estimates of standard uncertainties

% Added during modification of the original script into the function:
% (see iso standard, page 65, annex E, E.10
if m < 5
    sigmah2 = chi_sq_obs/(m - 2);
    sigmah = sqrt(sigmah2);
    u2ah = sigmah2*u2a;
    u2bh = sigmah2*u2b;
    uabh = sigmah2*uab;
            % Commented out during modification of the original script into the function. This is now function input:
            % fprintf('Posterior estimate of standard uncertainties associated with y-values \n'), fprintf('%8.3f \n\n', sigmah)
            % fprintf('Scaled standard uncertainty associated with estimate of intercept \n'), fprintf('%8.3f \n\n', sqrt(u2ah))
            % fprintf('Scaled standard uncertainty associated with estimate of slope \n'), fprintf('%8.3f \n\n', sqrt(u2bh))
            % fprintf('Scaled covariance associated with estimates of intercept and slope \n'), fprintf('%8.3f \n\n', uabh)
    % Added during modification of the original script into the function:
    ua = sqrt(u2a); % uncertainty of intercept
    ub = sqrt(u2b); % uncertainty of slope
    uab = uabh;
else
    %% Better posterior uncertainty estimates
    sigmat2 = chi_sq_obs/(m - 4);
    sigmat = sqrt(sigmat2);
    u2at = sigmat2*u2a;
    u2bt = sigmat2*u2b;
    uabt = sigmat2*uab;
            % Commented out during modification of the original script into the function. This is now function input:
            % fprintf('Better posterior estimate of standard uncertainties associated with y-values \n'), fprintf('%8.3f \n\n', sigmat)
            % fprintf('Better standard uncertainty associated with estimate of intercept \n'), fprintf('%8.3f \n\n', sqrt(u2at))
            % fprintf('Better standard uncertainty associated with estimate of slope \n'), fprintf('%8.3f \n\n', sqrt(u2bt))
            % fprintf('Better covariance associated with estimates of intercept and slope \n'), fprintf('%8.3f \n\n', uabt)
    % Added during modification of the original script into the function:
    ua = sqrt(u2a); % better uncertainty of intercept
    ub = sqrt(u2b); % better uncertainty of slope
    uab = uabt;
end % if m < 5

% Added prediction and forward evaluation (from TS28037_WLS1_function.m)
% according the note in readme.txt of the original scripts.

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

uxp = sqrt(u2xp); % uncertainty of intercept

%% Forward evaluation
yf = a + b*xf; 
ca = 1; 
cb = xf; 
cx = b; 
% Vectorized during modification of the original script into the function:
        % u2yf = ca^2*u2a + cb^2*u2b + 2*ca*cb*uab + cx^2*uxf^2; % original line
u2yf = ca.^2.*u2a + cb.^2.*u2b + 2.*ca.*cb.*uab + cx.^2.*uxf.^2; % vectorized line

uyf = sqrt(u2yf); % uncertainty of intercept

%% Acknowledgements 
% The work described here was supported by the National Measurement Office
% of the UK Department of Business, Innovation and Skills as part of its
% NMS Software Support for Metrology programme. 
