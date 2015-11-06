function info = alg_info() %<<<1
% Part of QWTB. Info script for algorithm FPSWF
%
% See also qwtb

info.id = 'FPSWF';
info.name = 'Four Parameter Sine Wave Fit';
info.desc = 'Fits a sine wave to the recorded data by means of least squares fitting using 4 parameter (frequency, amplitude, phase and offset) model. An estimate of signal frequency is required. Due to non-linear characteristic, converge is not always achieved. When run in Matlab, function `lsqnonlin` in Optimization toolbox is used. When run in GNU Octave, function `leasqr` in GNU Octave Forge package optim is used.';
info.citation = '';
info.remarks = 'Algorithm works essentially only for simple sine wave. Algorithm is very sensitive to distortion. Algorithm requires good estimate of signal frequency.';
info.license = 'MIT License';
info.requires = {'t', 'y', 'fest'};
info.reqdesc = {'Time series of sampled data', 'Sampled values', 'Estimate of signal frequency'};
info.returns = {'f', 'A', 'ph', 'O'};
info.retdesc = {'Frequency of main signal component', 'Amplitude of main signal component', 'Phase of main signal component', 'Offset of signal'};
info.providesGUF = 0;
info.providesMCM = 0;

% vim settings modeline: vim: foldmarker=%<<<,%>>> fdm=marker fen ft=octave textwidth=80 tabstop=4 shiftwidth=4
