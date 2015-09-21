function res = isscalarP(X)
% Return true if X is a scalar in a physics sense. X is scalar if has two dimensions and both
% dimensions are equal to 1.

    S = size(X);
    res = (   length(S) == 2   &&   max(S) == min(S)   &&   min(S) == 1   );

end
