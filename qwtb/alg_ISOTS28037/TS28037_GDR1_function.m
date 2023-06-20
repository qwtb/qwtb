% This script is partly based on NPL's Software to Support ISO/TS 28037:2010(E)
% and was made to be used in QWTB.
%
% Inputs: MUST be collumn vectors!
%   x: independent variable, collumn vector
%   y: dependent variable, collumn vector
%   ux: uncertainty of independet variable, collumn vector
%   uy: uncertainty of dependent variable, collumn vector
%   tol_multiplier: multiplier of the tolerance limit for covergence criteria
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
function [a, b, ua, ub, uab, chi_sq_obs, chi_sq, model_rejected, xp, uxp, yf, uyf] = TS28037_GDR1_function(x, y, ux, uy, tol_multiplier, yp, uyp, xf, uxf)

%% Software to support ISO/TS 28037:2010(E)

%% Introduction
% This document runs the numerical example of generalized distance 
% regression (GDR) described in *Clause 7 (Model for uncertainties 
% associated with the x_i and the y_i)*. 
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
        % x = [1.2 1.9 2.9 4.0 4.7 5.9]';
m = length(x);

%% 
% Assign y-values. 
        % Commented out during modification of the original script into the function. This is now function input:
        % y = [3.4 4.4 7.2 8.5 10.8 13.5]';

%%
% Assign uncertainties associated with x-values. 
        % Commented out during modification of the original script into the function. This is now function input:
        % ux = [0.2 0.2 0.2 0.2 0.2 0.2]';

%%
% Assign uncertainties associated with y-values. 
        % Commented out during modification of the original script into the function. This is now function input:
        % uy = [0.2 0.2 0.2 0.4 0.4 0.4]';

%% Obtain estimates of the straight line calibration function parameters and associated standard uncertainties and covariance
% Solve the generalized distance regression problem to obtain best fit straight-line parameters. 

%% 
% Step 1. Initial approximation using weighted least squares: see 
% <algm_wls_steps_1_to_8.html algm_wls_steps_1_to_8.m>.
[ai, bi, u2ai, u2bi, uabi, wi, g0i, h0i, gi, hi, G2i, ri, Ri] = algm_wls_steps_1_to_8(x, y, uy); 

%% 
% Round approximations to parameters in step 1 to four decimal places. 
% (This step is included to produce the results given in ISO/TS 28037:2010: 
% the step would not generally be performed.)
ai = round(10000*ai)/10000;
at{1} = ai; 
bi = round(10000*bi)/10000;
bt{1} = bi; 

%% 
% Loop through steps 2 to 5 until convergence criteria are satisfied. 
% (In this example, convergence is considered to have been achieved when 
% the magnitudes of the increments deltaa and deltab in a and b are no
% greater than 0.00005. For general user data, it is suggested that 
% convergence is considered to have been achieved when the magnitudes of 
% all increments *relative to the initial approximations to the 
% straight-line parameters* are no greater than 1e-7. In this case, the 
% tolerance can be assigned using the command tol = 1e-7*norm([ai, bi]);) 

%% 
% Assign tolerances and initialize variables. 
% Commented out during modification of the original script into the function.
        % tol = 0.00005;
% Tolerance set during modification of the original script into the function
% according description in previous paragraph:
tol = tol_multiplier.*norm([ai bi]);
da{1} = []; db{1} = [];
t{1} = []; xs{1} = []; z{1} = []; f{1} = []; g{1} = []; h{1} = []; F2{1} = []; 
g0{1} = []; h0{1} = []; gt{1} = []; ht{1} = []; Gt2{1} = []; r{1} = []; 

%% 
% Steps 2 to 5: see 
% <algm_gdr1_steps_2_to_5.html algm_gdr1_steps_2_to_5.m>.
ind = 1;
[at, bt, da, db, t, xs, z, f, g, h, F2, g0, h0, gt, ht, Gt2, r] ...
  = algm_gdr1_steps_2_to_5(x, ux, y, uy, at, bt, da, db, ...
      t, xs, z, f, g, h, F2, g0, h0, gt, ht, Gt2, r, ind); 

while (abs(da{ind}) > tol) || (abs(db{ind}) > tol)
%% 
% Update iteration number. 
  ind = ind + 1; 

%% 
% Step 6. Repeat steps 2 to 5 until convergence has been achieved: see 
% <algm_gdr1_steps_2_to_5.html algm_gdr1_steps_2_to_5.m>.
  [at, bt, da, db, t, xs, z, f, g, h, F2, g0, h0, gt, ht, Gt2, r] ...
    = algm_gdr1_steps_2_to_5(x, ux, y, uy, at, bt, da, db, ...
        t, xs, z, f, g, h, F2, g0, h0, gt, ht, Gt2, r, ind); 
end 
a = at{ind+1}; 
b = bt{ind+1}; 

%%
% Step 7. Evaluate uncertainties. 
u2a = 1/F2{ind} + g0{ind}^2/Gt2{ind};
u2b = 1/Gt2{ind};
uab = -g0{ind}/Gt2{ind};
% Added during modification of the original script into the function:
ua = sqrt(u2a); % uncertainty of intercept
ub = sqrt(u2b); % uncertainty of slope

%%
% Step 8. Form observed chi-squared value and degrees of freedom. 
chi_sq_obs = sum(r{ind}.*r{ind}); 
nu = m - 2; 

%% 
% Step 9. Calculate 95 % quantile of chi-squared distribution: see 
% <calc_chi_sq_95_percent_quantile.html calc_chi_sq_95_percent_quantile.m>.
chi_sq = calc_chi_sq_95_percent_quantile(nu); 

% Added during modification of the original script into the function:
model_rejected = chi_sq_obs > chi_sq; % if 1, straight-line model is rejected

        % Commented out during modification of the original script into the function:
        % %% Display information on screen and generate figures 
        % 
        % %% 
        % % Measurement model. 
        % fprintf('\nMODEL FOR UNCERTAINTIES ASSOCIATED WITH THE XI AND THE YI \n\n')
        % fprintf('ISO/TS 28037:2010(E) CLAUSE 7 \n') 
        % fprintf('EXAMPLE \n\n')
        % 
        % %% 
        % % Measurement data. 
        % fprintf('FITTING \n')
        % fprintf(['Data representing ', num2str(m),' measurement points \n'])
        % for i = 1:m
        %   fprintf('%8.1f %8.1f %8.1f %8.1f \n', [x(i), ux(i), y(i), uy(i)]) 
        % end 
        % fprintf('\n')
        % 
        % %% 
        % % Calculation tableau for WLS problem: see 
        % % <write_wls_tableau.html write_wls_tableau.m>.
        % fprintf('Initial approximations to parameters \n')
        % write_wls_tableau(x, y, wi, g0i, h0i, gi, hi, ai, bi, ri, '%9.4f ');
        % 
        % %%  
        % % Initial approximations to parameters. 
        % fprintf('Initial approximation to intercept \n'), fprintf('%9.4f \n\n', ai)
        % fprintf('Initial approximation to slope \n'), fprintf('%9.4f \n\n', bi)
        % 
        % %% 
        % % Calculation tableau for each iteration: see 
        % % <write_gdr1_tableaux.html write_gdr1_tableaux.m>.
        % for niter = 1:ind 
        %   write_gdr1_tableaux(x, ux, y, uy, t, xs, z, f, g, h, g0, h0, gt, ht, ...
        %                     at, bt, da, db, r, niter, '%9.4f');
        % end 
        %    
        % %%
        % % Solution estimates. 
        % fprintf('Estimate of intercept \n'), fprintf('%9.4f \n\n', a)
        % fprintf('Estimate of slope \n'), fprintf('%9.4f \n\n', b)
        % 
        % %% 
        % % Standard uncertainties associated with solution estimates. 
        % fprintf('Standard uncertainty associated with estimate of intercept \n'), fprintf('%9.4f \n\n', sqrt(u2a))
        % fprintf('Standard uncertainty associated with estimate of slope \n'), fprintf('%9.4f \n\n', sqrt(u2b))
        % fprintf('Covariance associated with estimates of intercept and slope \n'), fprintf('%9.4f \n\n', uab)
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
        % plot_errorbar2(x, ux, y, uy, 'k.', 'k-')
        % plot(xs{ind}, at{ind} + bt{ind}*xs{ind}, 'ro'); 
        % plot(xs{ind}, at{ind} + bt{ind}*xs{ind}, 'b-')
        % xlabel('\it x', 'FontName', 'Times', 'FontSize', 14)
        % ylabel('\it y', 'FontName', 'Times', 'FontSize', 14)
        % axis1 = axis; 
        % figure, hold on
        % for i = 1:m 
        %   plot([x(i), x(i)], [0, r{ind}(i)], 'k-')
        %   plot(x(i), r{ind}(i), 'ko', 'MarkerFaceColor', 'w', 'MarkerSize', 6)
        % end
        % plot([axis1(1), axis1(2)], [0, 0], 'b--')
        % xlabel('\it x', 'FontName', 'Times', 'FontSize', 14)
        % ylabel('\it r', 'FontName', 'Times', 'FontSize', 14)

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
