function dataout = alg_wrapper(datain, calcset)
% Part of QWTB. Wrapper script for algorithm FPSWF.
%
% See also qwtb

% Format input data --------------------------- %<<<1
% FPSWF definition is:
% function [A, f, ph, O] = FPSWF(t, y, estf, verbose);
t = datain.t.v;
y = datain.y.v;
estf = datain.f.v;
verbose = calcset.verbose;

% Call algorithm ---------------------------  %<<<1
[A, f, ph, O] = FPSWF(t, y, estf, verbose);

% Format output data:  --------------------------- %<<<1
dataout.A.v = A;
dataout.f.v = f;
dataout.ph.v = ph;
dataout.O.v = O;

end % function

% vim settings modeline: vim: foldmarker=%<<<,%>>> fdm=marker fen ft=octave textwidth=80 tabstop=4 shiftwidth=4
