function dataout = alg_wrapper(datain, calcset) %<<<1
% Part of QWTB. Wrapper script for algorithm WaveformGenerator
%
% See also qwtb
% XXX suppose first value in datain.f.v is main component

% --- Set input quantities %<<<1
% --- Sampling frequency %<<<2
if not(isfield(datain, 'fs'))
    if isfield(datain, 'Ts')
        datain.fs.v = 1/datain.Ts.v;
        if calcset.verbose
            disp('QWTB: WaveformGenerator wrapper: sampling frequency was calculated from sampling period')
        end
    else
        datain.fs.v = 1./mean(diff(datain.t.v));
        if calcset.verbose
            disp('QWTB: WaveformGenerator wrapper: sampling frequency was calculated from time series')
        end
    end
end
acquis.fs = datain.fs.v;

% --- Samples number %<<<2
if not(isfield(datain, 'l'))
    datain.l.v = 1;
if datain.l.v < 1
    error('QWTB: WaveformGenerator wrapper: quantity `l` (number of samples before t=0) must be >= 1!')
end
if (datain.l.v >= datain.L.v)
    error('QWTB: WaveformGenerator wrapper: quantity `l` (number of samples before t=0) must be smaller than quantity `L` (total number of samples)!')
end
acquis.N = datain.L.v;
acquis.n = datain.l.v;

% --- PMU frames %<<<2
if not(isfield(datain, 'Fs'))
    datain.Fs.v = 1;
end
if round(datain.fs.v/datain.Fs.v) ~= datain.fs.v/datain.Fs.v
    error('QWTB: Waveform_Generator wrapper: Ratio `fs/Fs` must be integer!')
end
acquis.Fs = datain.Fs.v;

% --- Signal components %<<<2
% suppose first value in datain.f.v is the main component
src.f0 = datain.f.v(1);

% find only harmonics
% indexes of frequencies divisible by main signal frequency:
idx = find(round(datain.f.v./src.f0) == datain.f.v./src.f0);
src.harm.rank = [datain.f.v./src.f0](idx);
src.harm.mag = datain.A.v(idx);
src.harm.pha = datain.ph.v(idx);
% rest are interharmonics
idx = find(round(datain.f.v./src.f0) ~= datain.f.v./src.f0);
src.inter.freq = datain.f.v(idx);
src.inter.mag = datain.A.v(idx);
src.inter.pha = datain.ph.v(idx);

% Waveform_Generator use cos to generate functions, so all phases has to be
% moved by pi/2:
src.harm.pha = src.harm.pha - pi/2;
src.inter.pha = src.inter.pha - pi/2;

% --- Noise %<<<1
% XXX 2DO
src.noise = 0; %datain.XXX ? XXX

% --- Modulation %<<<1
% XXX 2DO!
src.fMod.type = '';
src.fMod.df = 0;
src.fMod.f = 0;
src.fMod.ncycle = 0;
src.magMod.type = '';
src.magMod.df = 0;
src.magMod.f = 0;
src.magMod.ncycle = 0;
src.phaMod.type = '';
src.phaMod.df = 0;
src.phaMod.f = 0;
src.phaMod.ncycle = 0;

% --- Call algorithm %<<<1
[signal, srcth, ref, infos] = Waveform_Generator(acquis, src, [], '');

% --- Fix time stamps %<<<1
% XXX this is only temporary solution!


% --- Set output quantities %<<<1
dataout.t.v = signal.time;
% Fix time stamps
% XXX this is only temporary solution!
% algorithm never starts at t=0
dataout.t.v = dataout.t.v - dataout.t.v(1);

dataout.y.v = signal.y;

end % function

% vim settings modeline: vim: foldmarker=%<<<,%>>> fdm=marker fen ft=octave textwidth=80 tabstop=4 shiftwidth=4
