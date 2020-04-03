function dataout = alg_wrapper(datain, calcset) %<<<1
% Part of QWTB. Wrapper script for algorithm FFOAV.
%
% See also qwtb

% Format input data --------------------------- %<<<1
% fast_FOAV definition is:
% foav = fast_FOAV(x)

if isfield(datain, 'fs')
    fs = datain.fs.v;
elseif isfield(datain, 'Ts')
    fs = 1/datain.Ts.v;
    if calcset.verbose
        disp('QWTB: ADEV wrapper: sampling frequency was calculated from sampling time')
    end
else
    fs = 1./mean(diff(datain.t.v));
    if calcset.verbose
        disp('QWTB: ADEV wrapper: sampling frequency was calculated from time series')
    end
end

% Unfortunately fast_FOAV do not calculate tau values of the returned data.
% Generate tau values, calculation must be in this form, otherwise rounding errors can occur:
TAU = [1/fs : 1/fs : length(datain.y.v)./fs./2];

% Call algorithm ---------------------------  %<<<1
foav = fast_FOAV(datain.y.v);

% Format output data:  --------------------------- %<<<1
% convert variance to deviation:
dataout.oadev.v = foav'.^0.5;
dataout.tau.v = TAU;

end % function

% vim settings modeline: vim: foldmarker=%<<<,%>>> fdm=marker fen ft=octave textwidth=80 tabstop=4 shiftwidth=4
