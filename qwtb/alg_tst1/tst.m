function [val, unc] = tst(tseries, yseries, getunc)
% returns maximum of recored values
        val = max(yseries);
        if unc
                unc = 0.1.*val;
        else
                unc = 0;
        endif
end
