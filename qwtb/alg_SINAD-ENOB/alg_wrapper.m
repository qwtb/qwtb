function dataout = alg_wrapper(datain, calcset) %<<<1
% Part of QWTB. Wrapper script for algorithm ENOB-SINAD.
%
% See also qwtb

% Format input data --------------------------- %<<<1
% algorithm definition is:
% function [SINAD, ENOB] = sinad(t, y, f, A, ph, O, NoB, FSR)

% Call algorithm ---------------------------  %<<<1
[SINAD, ENOB] = sinad(datain.t.v, datain.y.v, datain.f.v, datain.A.v, datain.ph.v, datain.O.v, datain.bitres.v, datain.range.v);

% Format output data:  --------------------------- %<<<1
dataout.ENOB.v = ENOB;
% convert to decibels (relative to main signal component):
dataout.SINADdB.v = 20.*log10(SINAD);

end % function

% vim settings modeline: vim: foldmarker=%<<<,%>>> fdm=marker fen ft=octave textwidth=80 tabstop=4 shiftwidth=4
