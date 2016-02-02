function alginfo = alg_info() %<<<1
% Part of QWTB. Info script for algorithm PSFE.
%
% See also qwtb

alginfo.id = 'iDFT3p';
alginfo.name = '3-point interpolated DFT frequency estimator';
alginfo.desc = 'An algorithm for estimating the frequency, amplitude, and phase of the fundamental component using interpolated discrete Fourier transform. Rectangular or Hann window can be used for DFT.';
alginfo.citation = 'Krzysztof Duda: Interpolation algorithms of DFT for parameters estimation of sinusoidal and damped sinusoidal signals. In S. M. Salih, editor, Fourier Transform - Signal Processing, chapter 1, pages 3-32, InTech, 2012. http://www.intechopen.com/books/fourier-transform-signal-processing/interpolated-dft Implemented by Rado Lapuh, 2016.';
alginfo.remarks = '';
alginfo.license = 'Implementation: MIT License';
alginfo.requires = {'t', 'y', 'window'};
alginfo.reqdesc = {'time series of sampled data', 'sampled values', 'DFT window: `Hann` or `rectangular`.'};
alginfo.returns = {'f', 'A', 'ph', 'O'};
alginfo.retdesc = {'Frequency of main signal component', 'Amplitude of main signal component', 'Phase of main signal component', 'Offset of main signal component'};
alginfo.providesGUF = 0;
alginfo.providesMCM = 0;

% vim settings modeline: vim: foldmarker=%<<<,%>>> fdm=marker fen ft=octave textwidth=80 tabstop=4 shiftwidth=4
