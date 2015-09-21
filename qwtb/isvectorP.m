function res = isvectorP(X)
% Return true if X is a vector in a physics sense. X is vector if has two dimensions, one dimension
% is equal to one, the other dimension is greater than 1.

    S = size(X);
    res = (   length(S) == 2   &&   max(S) > min(S)   &&   min(S) == 1   );

end
