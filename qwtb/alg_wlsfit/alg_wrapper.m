function dataout = alg_wrapper(datain, calcset) %<<<1
% Part of QWTB. Wrapper script for algorithm wlsfit.
%
% See also qwtb

% Algorithm help --------------------------- %<<<1
% Algorithm inputs:
%   x: Reference values (x-values)
%   y: Observed or measured values (y-values)
%   w: weigths or y-uncertainties (all different -> heteroscedasticity)
%      if not specified or is all are equal (homoscedasticity), then ordinary least square is used.
%   n: degree of the polinomial for the regression (n>0)
%
% Algorithm outputs:
%   p: coefficients
%   s: struct
%     .y_cova: fitted y values covariance matrix
%     .unc: uncertainties on the coefficients p
%     .p_cova: coefficients covariance matrix
%     .y_hat: fitted y-values
%     .res: Residuals on the adjustment
%     .df:  Degree of freddom
%     .chi2: goodness of the fitting (Chi-squared value)
% Algorithm call:
% [p, s] = wlsfit (x, y, w, n)

% Format input data --------------------------- %<<<1
% Determine WLS or OLS, set weights and model for output:
if isfield(datain, 'w') || ~isempty(datain.y.u)
    WLS = 1;
    if isfield(datain, 'w')
        % weights defined, use them instead of uncertainties of y:
        w = datain.w.v;
        if calcset.verbose
            disp('QWTB: wlsfit wrapper: Weights are defined -> WLS fitting will be based on weights instead of y uncertainties.')
            dataout.model.v = 'Weighted Least Squares, weights based on w';
        end
    else
        disp('QWTB: wlsfit wrapper: Using WLS fitting based on y uncertainties.')
        dataout.model.v = 'Weighted Least Squares, weights based on u(y)';
        w = datain.y.u;
    end
else
    WLS = 0;
    if calcset.verbose
        disp('QWTB: wlsfit wrapper: No y uncertainties nor weights -> using OLS fitting')
        dataout.model.v = 'Ordinary Least Squares';
    end
endif  

% Call algorithm ---------------------------  %<<<1
if (WLS)
    [p, s] = wlsfit (datain.x.v, datain.y.v, w, datain.n.v);
else
    [p, s] = wlsfit (datain.x.v, datain.y.v, datain.n.v);
endif

% Format output data:  --------------------------- %<<<1
dataout.yhat.v = s.y_hat;
% get uncertainties:
d = diag(s.y_cova).^0.5;
dataout.yhat.u = d(:);
% calculate correlation matrix:
d = diag(d, 0);
dataout.yhat.c = inv(d)*s.y_cova*inv(d);

% This part set fit coefficients and also fix the order of coefficients 
% from y=C+Bx+Ax2+... to y=A+Bx+Cx2+...
dataout.coefs.v = p(end:-1:1);
dataout.coefs.u = s.unc(end:-1:1);
% For covariance matrix, in a fact we are reversing order of the basis, so we
% need to transpose the matrix along antidiagonal, that is the same as 180 deg
% rotation and transpose:
% get uncertainties:
covm = transpose(rot90(s.p_cova, 2));
d = diag(covm).^0.5;
dataout.coefs.u = d(:);
% calculate correlation matrix:
d = diag(d, 0);
dataout.coefs.c = inv(d)*covm*inv(d);

% generate inline function: %<<<2
fin = '';
dataout.exponents.v = [];
for i = 0:datain.n.v
    fin = [fin ' + p(' num2str(i+1) ').*x.^' num2str(i)];
    dataout.exponents.v = [dataout.exponents.v i];
end
dataout.func.v = inline(fin, 'x', 'p');

end % function

% vim settings modeline: vim: foldmarker=%<<<,%>>> fdm=marker fen ft=octave textwidth=80 tabstop=4 shiftwidth=4
