function alginfo = alg_info() %<<<1
% Part of QWTB. Info script for algorithm CCC
%
% See also qwtb

% GDR1 - implements u(x), u(y)
% GDR2 - implements u(x), u(y) and covariances between x, y
% GGMR - implements u(x), u(y), full covariance matrices U_x, and U_y

alginfo.id = 'ISOTS28037';
alginfo.name = 'NPL’s Software to Support ISO/TS 28037:2010(E)';
alginfo.desc = 'NPL’s Software to Support ISO/TS 28037:2010(E) software implements the algorithms described in the ISO Technical Specification "Determination and use of straight-line calibration functions" and has been developed by the National Physical Laboratory (NPL) in the United Kingdom. The software is available as a compressed ZIP folder from the web sites of NPL at www.npl.co.uk/mathematics-scientific-computing/software-support-for-metrology/software-downloads-(ssfm) and the International Organization for Standardization at standards.iso.org/iso/ts/28037/. Downloadable at https://www.npl.co.uk/resources/software/iso-ts-28037-2010e';
alginfo.citation = 'https://standards.iso.org/iso/ts/28037/, https://www.npl.co.uk/resources/software/iso-ts-28037-2010e';
alginfo.remarks = 'Implements methods WSL, GDR. GMR nor GGMR are not implemented.';
alginfo.license = 'NPL license';

alginfo.inputs(1).name = 'x';
alginfo.inputs(1).desc = 'Independent variable';
alginfo.inputs(1).alternative = 0;
alginfo.inputs(1).optional = 0;
alginfo.inputs(1).parameter = 0;

alginfo.inputs(2).name = 'y';
alginfo.inputs(2).desc = 'Dependent variable';
alginfo.inputs(2).alternative = 0;
alginfo.inputs(2).optional = 0;
alginfo.inputs(2).parameter = 0;

alginfo.inputs(3).name = 'tol';
alginfo.inputs(3).desc = 'Tolerance for convergence of iterative method GDR. Iterations stops when increments of parameters a, b is smaller than tol*norm([a b]).';
alginfo.inputs(3).alternative = 0;
alginfo.inputs(3).optional = 1;
alginfo.inputs(3).parameter = 1;

alginfo.inputs(4).name = 'xhat';
alginfo.inputs(4).desc = 'Independent variable values to be (extra/inter)polated (forward evaluated).';
alginfo.inputs(4).alternative = 0;
alginfo.inputs(4).optional = 1;
alginfo.inputs(4).parameter = 0;

alginfo.outputs(1).name = 'coefs';
alginfo.outputs(1).desc = 'Fitted coefficients';

alginfo.outputs(2).name = 'exponents';
alginfo.outputs(2).desc = 'Exponents of polynomial used to fit, for now only [0 1] possible';

alginfo.outputs(3).name = 'yhat';
alginfo.outputs(3).desc = 'Fitted values y';

alginfo.outputs(4).name = 'func';
alginfo.outputs(4).desc = 'Inline function constructed for exponents with parameters `x` and `coefs.v`';

alginfo.outputs(5).name = 'model';
alginfo.outputs(5).desc = 'Model used for calculation.';

alginfo.outputs(6).name = 'chisq';
alginfo.outputs(6).desc = '95 % quantile of chi-squared distribution';

alginfo.outputs(7).name = 'model_rejected';
alginfo.outputs(7).desc = 'If 1, straight-line model is rejected. Estimated as chi_sq_obs > chi_sq.';

alginfo.providesGUF = 1;
alginfo.providesMCM = 0;

% vim settings modeline: vim: foldmarker=%<<<,%>>> fdm=marker fen ft=octave textwidth=80 tabstop=4 shiftwidth=4
