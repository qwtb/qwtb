%## Function wlsfit calculate a polynomial fitting using
%## the Weighted Least Squares Regression algorithm
%##
%## Inputs:
%##   x: Reference values (x-values)
%##   y: Observed or measured values (y-values)
%##   w: weigths or y-uncertainties (all different -> heteroscedasticity)
%##      if not specified or is all are equal (homoscedasticity), then ordinary least square is used.
%##   n: degree of the polinomial for the regression (n>0)
%##
%##
%## Outputs:
%##   p: coefficients
%##   s: struct
%##     .y_cova: fitted y values covariance matrix
%##     .unc: uncertainties on the coefficients p
%##     .p_cova: coefficients covariance matrix
%##     .y_hat: fitted y-values
%##     .res: Residuals on the adjustment
%##     .df:  Degree of freddom
%##     .chi2: goodness of the fitting (Chi-squared value)

function [p, s] = wlsfit (x, y, w, n)

  if (nargin < 3 || nargin > 4)
    print_usage ();
  end

  ordinary = 0;
  if (nargin == 3) %#ordinary least-squares
    n = w;
    w = 1;
    ordinary = 1;
  elseif (nargin == 4)
    if (isscalar(w))
      ordinary = 1;
     else
      ordinary = 0;
    end
  end


  if not(all(size(x)==size(y)))
    error ("wlsfit: X and Y must be vectors of the same size");
  end

  if (islogical (n))
    polymask = n;
    %## n is the polynomial degree as given the polymask size; m is the
    %## effective number of used coefficients.
    n = length (polymask) - 1; m = sum (polymask) - 1;
  else
    if (not (isscalar (n) && n >= 0 && not (isinf (n) && n == fix (n))))

      error ("wlsfit: N must be a non-negative integer");
    end
    polymask = logical (ones (1, n+1)); m = n;
  end

  %## Reshape x & y into column vectors.
  l = numel (x);
  x = x(:);
  y = y(:);
  w = w(:);
  s = [];

  %## Construct the Vandermonde matrix.
  % (modified because matlab deficiency)
  v = ShortVander (x, n+1);


  if (ordinary)
    A = inv(v'*v);
    k = A*v';
    p = k * y;

    s = [];
    % Uncertainties on the coeficients

    s.p_cova = A*w;
    s.unc = sqrt(diag(s.p_cova));
    s.y_cova = v*s.p_cova*v';

    % Residuals
    s.y_hat = v * p;
    s.res  = y - s.y_hat;
    s.df = n+1;
  if is_octave()
    s.chi2 = (1/(l-(n+1)))*sumsq(s.res./w);
  else
    s.chi2 = (1/(l-(n+1)))*sumsqr(s.res./w); % because of sumsq and sumsqr difference matlab-octave
  end

  else %#weighted-least squares


    %Weighted Matrix
    ident = eye(length(y));
    wi = ident .* (w.^2);
    wi_inv=inv(wi);



    V_b = inv((v'*wi_inv)*v);
    m = (V_b * v') * wi_inv;
    p = m * y;

    % Uncertainties on the coeficients

    s.y_cova = v*V_b*v';
    s.unc = sqrt(diag(V_b));
    s.p_cova = V_b;

    % Residuals
    s.y_hat = v * p;
    s.res  = y - s.y_hat;
    s.df = n+1;

    s.chi2 = (1/(l-(n+1)))*(s.res'*wi_inv*s.res);
  end

  end % function

% this is because matlab does not know how to make vandermonde matrix with
% second input argument
function A = ShortVander(x, n)
x = x(:);  % Column vector
A = ones(length(x), n);
k = 1;
for i = n:-1:1
  A(:,i) = k;
  k = k .* x; 
  %ORIG A(:, i) = x .* A(:, i-1);
end
end % function


%% New subfunction that checks if we are in octave: added because it is needed to call
% sumsqqr() for MatLab and sumsq() to Octave in the code above
function r = is_octave ()
  persistent x;
  if (isempty (x))
    x = exist ('OCTAVE_VERSION', 'builtin');
  end
  r = x;
end

% Test
% [pw,sw]=wlsfit(Ref,C,uC,1);

