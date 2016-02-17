function dataout = alg_wrapper(datain, calcset)
% Part of QWTB. Wrapper script for algorithm 4PSWF.
%
% See also qwtb

% Format input data --------------------------- %<<<1
% FPSWF definition is:
% function [A, f, ph, O] = FPSWF(t, y, estf, verbose);
estf = datain.fest.v;
verbose = calcset.verbose;

N = length(datain.y.v);
if isfield(datain, 't')
    t = datain.t.v;
elseif isfield(datain, 'fs')
    Ts = 1./datain.fs.v;
    t = linspace(0, N.*Ts-Ts, N);
    if calcset.verbose
        disp('QWTB: 4PSWF wrapper: time series were calculated from sampling frequency')
    end
else
    Ts = datain.Ts.v;
    t = linspace(0, N.*Ts-Ts, N);
    if calcset.verbose
        disp('QWTB: 4PSWF wrapper: time series were calculated from sampling time')
    end
end

% Call algorithm ---------------------------  %<<<1
[A, f, ph, O] = FPSWF(t, datain.y.v, estf, verbose);

% Format output data:  --------------------------- %<<<1
dataout.A.v = A;
dataout.f.v = f;
dataout.ph.v = ph;
dataout.O.v = O;

end % function

% vim settings modeline: vim: foldmarker=%<<<,%>>> fdm=marker fen ft=octave textwidth=80 tabstop=4 shiftwidth=4
