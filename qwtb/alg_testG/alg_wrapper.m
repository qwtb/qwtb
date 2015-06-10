function dataout = alg_wrapper(datain, calcset) %<<<1
% Part of QWTB. Wrapper script for algorithm testGM.
% testGM is usefull only for testing QWTB toolbox. It calculates maximal value
% of the record. GUF is calculated by wrapper (fake values are
% generated).
%
% See also qwtb

% Format input data --------------------------- %<<<1
% testGM definition is: function [maxval] = testG(tseries, yseries)

% Call algorithm ---------------------------  %<<<1
maxv = testG(datain.t.v, datain.y.v);

% Calculate uncertainty --------------------------- %<<<1
if strcmpi(calcset.unc, '')
    unc = '';
elseif strcmpi(calcset.unc, 'guf')
    unc = maxv./10;
elseif strcmpi(calcset.unc, 'mcm')
    unc = '';
else
    error('qwtb wrapper: unknown value in calcset.unc')
end

% Format output data:  --------------------------- %<<<1
dataout.max.v = maxv;
dataout.max.u = unc;
dataout.max.d = 0;

end % function

% vim settings modeline: vim: foldmarker=%<<<,%>>> fdm=marker fen ft=octave textwidth=80 tabstop=4 shiftwidth=4
