function dataout = alg_wrapper(datain, calcset)

% format input data %<<<1
% tst input arguments are: function res = tst(tseries, yseries)

% call tst:  %<<<1
if strcmpi(calcset.unc, 'guf')
        getunc = 1;
else
        getunc = 0;
endif

[maxv, unc] = tst(datain.t.v, datain.y.v, getunc);

% format output data:  %<<<1
dataout.max.v = maxv;

% calculate uncertainty (provided by this script):
if ( strcmpi(calcset.unc, '') || strcmpi(calcset.unc, 'guf') )
        dataout.max.u = unc;
        dataout.max.d = 50;
elseif strcmpi(calcset.unc, 'mmc')
        dataout.max.u = normrnd(dataout.max.v, 2, calcset.unc.repeat, 1);
        dataout.max.d = size(dataout.max.u);
end

end

% vim settings modeline: vim: foldmarker=%<<<,%>>> fdm=marker fen ft=octave textwidth=80
