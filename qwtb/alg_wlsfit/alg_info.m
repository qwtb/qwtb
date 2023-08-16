function alginfo = alg_info() %<<<1
% Part of QWTB. Info script for algorithm 'wlsfit'.
%
% See also qwtb

alginfo.id = 'wlsfit';
alginfo.name = 'Weighted Least Square Fitting Algortihm';
alginfo.desc = 'Least Square fitting algortihm using ordinary (OLS) or weighted (WLS) fitting on a n-positive polynomial order. If uncertainty of |y| is defined, WLS is used. If value of |w| is defined, it is used instead of unc. of |y|. If no |w| nor unc. of |y|, OLS is used.';
alginfo.citation = '';
alginfo.remarks = 'Implemented by Ricardo Iuzzolino, Estefania Luna, INTI';
alginfo.license = 'MIT License';

alginfo.inputs(1).name = 'x';
alginfo.inputs(1).desc = 'Reference values';
alginfo.inputs(1).alternative = 1;
alginfo.inputs(1).optional = 0;
alginfo.inputs(1).parameter = 0;

alginfo.inputs(2).name = 'y';
alginfo.inputs(2).desc = 'Observed or measured values, y.u is used as weights for the case of WLS';
alginfo.inputs(2).alternative = 0;
alginfo.inputs(2).optional = 0;
alginfo.inputs(2).parameter = 0;

alginfo.inputs(3).name = 'n';
alginfo.inputs(3).desc = 'Degree of the polynomial for the regression (n>0)';
alginfo.inputs(3).alternative = 0;
alginfo.inputs(3).optional = 0;
alginfo.inputs(3).parameter = 1;

alginfo.inputs(4).name = 'w';
alginfo.inputs(4).desc = 'Weigths - if defined, y.u is replaced by weights. If not defined, y.u is used as weghts.';
alginfo.inputs(4).alternative = 0;
alginfo.inputs(4).optional = 1;
alginfo.inputs(4).parameter = 1;

alginfo.outputs(1).name = 'coefs';
alginfo.outputs(1).desc = 'Fitted coefficients';

alginfo.outputs(2).name = 'exponents';
alginfo.outputs(2).desc = 'Exponents of polynomial used to fit';

alginfo.outputs(3).name = 'yhat';
alginfo.outputs(3).desc = 'Fitted values y';

alginfo.outputs(4).name = 'func';
alginfo.outputs(4).desc = 'Anonymous function constructed for exponents with parameters `x` and `coefs.v`';

alginfo.outputs(5).name = 'model';
alginfo.outputs(5).desc = 'Model used for calculation.';

alginfo.providesGUF = 1;
alginfo.providesMCM = 0;


% vim settings modeline: vim: foldmarker=%<<<,%>>> fdm=marker fen ft=octave textwidth=80 tabstop=4 shiftwidth=4
