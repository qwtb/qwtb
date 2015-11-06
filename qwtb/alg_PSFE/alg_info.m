function alginfo = alg_info() %<<<1
% Part of QWTB. Info script for algorithm PSFE.
%
% See also qwtb

alginfo.id = 'PSFE';
alginfo.name = 'Phase Sensitive Frequency Estimator';
alginfo.desc = 'An algorithm for estimating the frequency, amplitude, and phase of the fundamental component in harmonically distorted waveforms. The algorithm minimizes the phase difference between the sine model and the sampled waveform by effectively minimizing the influence of the harmonic components. It uses a three-parameter sine-fitting algorithm for all phase calculations. The resulting estimates show up to two orders of magnitude smaller sensitivity to harmonic distortions than the results of the four-parameter sine fitting algorithm.';
alginfo.citation = 'Lapuh, R., "Estimating the Fundamental Component of Harmonically Distorted Signals From Noncoherently Sampled Data," Instrumentation and Measurement, IEEE Transactions on , vol.64, no.6, pp.1419,1424, June 2015, doi: 10.1109/TIM.2015.2401211, URL: http://ieeexplore.ieee.org/stamp/stamp.jsp?tp=&arnumber=7061456&isnumber=7104190';
alginfo.remarks = 'Very small errors, effective for harmonically distorted signals.';
alginfo.license = 'MIT License';
alginfo.requires = {'t', 'y'};
alginfo.reqdesc = {'time series of sampled data', 'sampled values'};
alginfo.returns = {'f', 'A', 'ph'};
alginfo.retdesc = {'Frequency of main signal component', 'Amplitude of main signal component', 'Phase of main signal component'};
alginfo.providesGUF = 0;
alginfo.providesMCM = 0;

% vim settings modeline: vim: foldmarker=%<<<,%>>> fdm=marker fen ft=octave textwidth=80 tabstop=4 shiftwidth=4
