function res = ismatrixP(X)
% Return true if X is a matrix in a physics sense. X is matrix if has two dimensions and both
% dimensions are greater than 1.

    S = size(X);
    res = (   length(S) == 2   &&   max(S) >= min(S)   &&   min(S) > 1   );

end
