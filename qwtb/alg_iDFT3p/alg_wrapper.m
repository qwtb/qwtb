function dataout = alg_wrapper(datain, calcset) %<<<1
% Part of QWTB. Wrapper script for algorithm iDFT3p.
%
% See also qwtb

% Format input data --------------------------- %<<<1
% iDFT3pRect definition is:
% function [f, A, P, O] = iDFT3pRect(Record,Ts)
% iDFT3pHann definition is:
% function [f, A, P, O] = iDFT3pHann(Record,Ts)
%    Input arguments
%       Record     - sampled input Record
%       Ts         - sampling time (in s)
%    Output arguments
%       f          - estimated frequency
%       A          - estimated amplitude
%       P          - estimated phase
%       O          - estimated offset

% Call algorithm ---------------------------  %<<<1
Ts = datain.t.v(2) - datain.t.v(1);

if strcmpi(datain.window.v, 'Hann')
    [f, A, ph, O] = iDFT3pHann(datain.y.v,Ts);
else
    [f, A, ph, O] = iDFT3pRect(datain.y.v,Ts);
end

% Format output data:  --------------------------- %<<<1

dataout.f.v = f;
dataout.A.v = A;
dataout.ph.v = ph;
dataout.O.v = O;

end % function

% vim settings modeline: vim: foldmarker=%<<<,%>>> fdm=marker fen ft=octave textwidth=80 tabstop=4 shiftwidth=4
