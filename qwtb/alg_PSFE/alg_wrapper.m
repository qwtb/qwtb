function dataout = alg_wrapper(datain, calcset) %<<<1
% Part of QWTB. Wrapper script for algorithm PSFE.
%
% See also qwtb

% Format input data --------------------------- %<<<1
% PSFE definition is:
% PSFE (Phase Sensitive Frequency Estimator)
%  [fa, A, ph, O] = PSFE(Record,Ts)
%
%  Input arguments
%    Record     - sampled input signal
%    Ts         - sampling time (in s)
%  Output arguments
%    fa         - estimated signal's frequency
%    A          - estimated signal's amplitude
%    ph         - estimated signal's phase
%    O          - estimated signal's offset

if isfield(datain, 'Ts')
    Ts = datain.Ts.v;
elseif isfield(datain, 'fs')
    Ts = 1/datain.fs.v;
    if calcset.verbose
        disp('QWTB: PSFE wrapper: sampling time was calculated from sampling frequency')
    end
else
    Ts = mean(diff(datain.t.v));
    if calcset.verbose
        disp('QWTB: PSFE wrapper: sampling time was calculated from time series')
    end
end

% Call algorithm ---------------------------  %<<<1
[fa A ph O] = PSFE(datain.y.v,Ts);

% Format output data:  --------------------------- %<<<1
% PSFE definition is:
% function [fa A ph] = PSFE(Record,Ts,init_guess)
% fa     - estimated signal's frequency
% A      - estimated signal's amplitude
% ph     - estimated signal's phase

dataout.f.v = fa;
dataout.A.v = A;
dataout.ph.v = ph;
dataout.O.v = O;

end % function

% vim settings modeline: vim: foldmarker=%<<<,%>>> fdm=marker fen ft=octave textwidth=80 tabstop=4 shiftwidth=4
