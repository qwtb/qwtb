function dataout = alg_wrapper(datain, calcset)
% Part of QWTB. Wrapper script for algorithm ISOTS28037
%
% See also qwtb

% WLS1 - uncertainties in y, equal
% WLS2 - unknown uncertainties in y, equal
% WLS3 - unknown uncertainties in y, only known weigths, posterior y uncertainties estimation.

% GDR2 - uncertainties in both x and y
% GDR2 - uncertainties in both x and y, and covariances between x and y.
% GGMR - implements u(x), u(y), full covariance matrices U_x, and U_y
%
% Algorithms in WLS1 and WLS2 are identical, WLS1 got also forward prediction,
% so file WLS2 is not usefull. WLS3 is usefull if no uncertainties are known.
% QWTB do not know covariances between x and y, so GDR2 is not used.

% Check existence of all needed functions from the algorithm --------------------------- %<<<1
% This check takes about 0.0002 s (iCore7)
funcs = {...
'algm_gdr1_steps_2_to_5',...
'algm_wls_steps_1_to_8',...
'calc_chi_sq_95_percent_quantile',...
};
for k = 1:numel(funcs)
    found(k) = exist(funcs{k});
end
if any(not(found(k)))
    printf(' /-----------------------------------------------------------------\\ \n')
    printf('//-----------------------------------------------------------------\\\\\n')
    printf('|| Files of the original algorithm were not found.                 ||\n')
    printf('|| Unfortunately, due to NPL license, the alg_ISOTS28037 algorithm ||\n')
    printf('|| cannot be freely distributed.                                   ||\n')
    printf('|| Please download zip file from:.                                 ||\n')
    printf('|| https://standards.iso.org/iso/ts/28037/                         ||\n')
    printf('|| or                                                              ||\n')
    printf('|| https://www.npl.co.uk/resources/software/iso-ts-28037-2010e     ||\n')
    printf('|| unzip, and copy the content of matlab directory right into      ||\n')
    printf('|| the directory qwtb/alg_ISOTS28037.                              ||\n')
    printf('|| Then run the calculation again.                                 ||\n')
    printf('|| Ask NPL to release their scripts under a better license.        ||\n')
    printf('||-----------------------------------------------------------------||\n')
    printf('|| Specifically you need 3 files:                                  ||\n')
    printf('||   algm_gdr1_steps_2_to_5.m                                      ||\n')
    printf('||   algm_wls_steps_1_to_8.m                                       ||\n')
    printf('||   calc_chi_sq_95_percent_quantile.m                             ||\n')
    printf('\\\\-----------------------------------------------------------------//\n')
    printf(' \\-----------------------------------------------------------------/ \n')
    error('Algorithm ISOTS28037 not found, you have to download it by yourself.')
end

% Format input data --------------------------- %<<<1
% forward evaluation values:
if ~isfield(datain, 'xhat')
    datain.xhat.v = [];
    datain.xhat.u = [];
end
% optional parameter tolerance:
if not(isfield(datain, 'tol'))
    datain.tol.v = 1e-7;
end

% check if uncertainties in x:
if isempty(datain.x.u)
    % no uncertainties in x, WLS model will be used
    if isempty(datain.y.u)
        % call WLS3 %<<<1
        % no uncertainties in x nor y, WLS3 model will be used
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
        [a, b, ua, ub, uab, chi_sq_obs, chi_sq, model_rejected, xp, uxp, yf, uyf] = TS28037_WLS3_function(...
            datain.x.v(:),...
            datain.y.v(:),...
            [],...
            [],...
            datain.xhat.v(:),...
            datain.xhat.u(:));
        dataout.coefs.v = [b a];
        dataout.coefs.u = [ub ua];
        % XXX convert covariance into correlation matrix!
        dataout.exponents.v = [0 1];
        dataout.func.v = @(x,p) p(1) + x.*p(2);
        dataout.model.v = 'ISO/TS 28037:2010(E) WLS, posterior uncertainty estimates';
        dataout.yhat.v = yf;
        dataout.yhat.u = uyf;
        dataout.chisq_obs.v = chi_sq_obs;
        dataout.chisq.v = chi_sq;
        dataout.model_rejected.v = model_rejected;
    else % if isempty(datain.y.u)
        % call WLS1 %<<<1
        % uncertainties in x nor y, WLS1 model will be used
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
        [a, b, ua, ub, uab, chi_sq_obs, chi_sq, model_rejected, xp, uxp, yf, uyf] = TS28037_WLS1_function(...
            datain.x.v(:),...
            datain.y.v(:),...
            datain.y.u(:),...
            [],...
            [],...
            datain.xhat.v(:),...
            datain.xhat.u(:));
        dataout.coefs.v = [b a];
        dataout.coefs.u = [ub ua];
        % XXX convert covariance into correlation matrix!
        dataout.exponents.v = [0 1];
        dataout.func.v = @(x,p) p(1) + x.*p(2);
        dataout.model.v = 'ISO/TS 28037:2010(E) WLS';
        dataout.yhat.v = yf;
        dataout.yhat.u = uyf;
        dataout.chisq_obs.v = chi_sq_obs;
        dataout.chisq.v = chi_sq;
        dataout.model_rejected.v = model_rejected;
    end % if isempty(datain.y.u)
else % if isempty(datain.x.u)
    % call GDR1 %<<<1
    % uncertainties in x, GDR model will be used
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
    [a, b, ua, ub, uab, chi_sq_obs, chi_sq, model_rejected, xp, uxp, yf, uyf] = TS28037_GDR1_function(...
        datain.x.v(:),...
        datain.y.v(:),...
        datain.x.u(:),...
        datain.y.u(:),...
        datain.tol.v(:),...
        [],...
        [],...
        datain.xhat.v(:),...
        datain.xhat.u(:));
    dataout.coefs.v = [b a];
    dataout.coefs.u = [ub ua];
    % XXX convert covariance into correlation matrix!
    dataout.exponents.v = [0 1];
    dataout.func.v = @(x,p) p(1) + x.*p(2);
    dataout.model.v = 'ISO/TS 28037:2010(E) GDR';
    dataout.yhat.v = yf;
    dataout.yhat.u = uyf;
    dataout.chisq_obs.v = chi_sq_obs;
    dataout.chisq.v = chi_sq;
    dataout.model_rejected.v = model_rejected;

end % if isempty(datain.x.u)

end % function

% vim settings modeline: vim: foldmarker=%<<<,%>>> fdm=marker fen ft=octave textwidth=80 tabstop=4 shiftwidth=4
