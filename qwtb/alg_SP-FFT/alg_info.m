function alginfo = alg_info() %<<<1
% Part of QWTB. Info script for algorithm FFT.
%
% See also qwtb

alginfo.id = 'SP-FFT';
alginfo.name = 'Spectrum by means of Fast Fourier Transform';
alginfo.desc = 'Calculates frequency and phase spectrum by means of Fast Fourier Transform algorithm. Result is normalized.';
alginfo.citation = '';
alginfo.remarks = '';
alginfo.license = '';
alginfo.requires = {'y', 'fs'};
alginfo.reqdesc = {'Sampled values', 'Sampling frequency'};
alginfo.returns = {'f', 'A', 'ph'};
alginfo.retdesc = {'Frequency series', 'Amplitude series', 'Phase series'};
alginfo.providesGUF = 0;
alginfo.providesMCM = 0;

% vim settings modeline: vim: foldmarker=%<<<,%>>> fdm=marker fen ft=octave textwidth=80 tabstop=4 shiftwidth=4
