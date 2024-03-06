function alginfo = alg_info() %<<<1
% Part of QWTB. Info script for algorithm Waveform Generator.
%
% See also qwtb

alginfo.id = 'WaveformGenerator';
alginfo.name = '';
alginfo.desc = 'Complex waveform generator with harmonics, interharmonics, modulation abilities, reference output and reference values for phasor measurement units.';
alginfo.citation = 'First version of the algorithm: U. Pogliano, J.-P. Braun, B. Voljc, and R. Lapuh, ‘Software Platform for PMU Algorithm Testing’, IEEE Transactions on Instrumentation and Measurement, vol. 62, no. 6, pp. 1400–1406, Jun. 2013, doi: 10.1109/TIM.2013.2239051.';
alginfo.remarks = 'If sampling time |Ts| is not supplied, wrapper will calculate |Ts| from sampling frequency |fs| or if not supplied, mean of differences of time series |t| is used to calculate |Ts|. First frequency in |f| is considered as the main signal frequency. Modulation is not yet ready.';
alginfo.license = 'MIT License';

alginfo.inputs(1).name = 'Ts';
alginfo.inputs(1).desc = 'Sampling time';
alginfo.inputs(1).alternative = 1;
alginfo.inputs(1).optional = 0;
alginfo.inputs(1).parameter = 0;

alginfo.inputs(2).name = 'fs';
alginfo.inputs(2).desc = 'Sampling frequency';
alginfo.inputs(2).alternative = 1;
alginfo.inputs(2).optional = 0;
alginfo.inputs(2).parameter = 0;

alginfo.inputs(3).name = 't';
alginfo.inputs(3).desc = 'Time series';
alginfo.inputs(3).alternative = 1;
alginfo.inputs(3).optional = 0;
alginfo.inputs(3).parameter = 0;

alginfo.inputs(4).name = 'L';
alginfo.inputs(4).desc = 'Number of samples';
alginfo.inputs(4).alternative = 0;
alginfo.inputs(4).optional = 0;
alginfo.inputs(4).parameter = 0;

alginfo.inputs(5).name = 'l';
alginfo.inputs(5).desc = 'Number of samples before t=0';
alginfo.inputs(5).alternative = 0;
alginfo.inputs(5).optional = 1;
alginfo.inputs(5).parameter = 0;

alginfo.inputs(6).name = 'Fs';
alginfo.inputs(6).desc = 'PMU frames per second';
alginfo.inputs(6).alternative = 0;
alginfo.inputs(6).optional = 1;
alginfo.inputs(6).parameter = 0;

alginfo.inputs(7).name = 'f';
alginfo.inputs(7).desc = 'Frequency of signal components';
alginfo.inputs(7).alternative = 0;
alginfo.inputs(7).optional = 0;
alginfo.inputs(7).parameter = 0;

alginfo.inputs(8).name = 'A';
alginfo.inputs(8).desc = 'Amplitude of signal components';
alginfo.inputs(8).alternative = 0;
alginfo.inputs(8).optional = 0;
alginfo.inputs(8).parameter = 0;

alginfo.inputs(9).name = 'ph';
alginfo.inputs(9).desc = 'Phase of signal components';
alginfo.inputs(9).alternative = 0;
alginfo.inputs(9).optional = 0;
alginfo.inputs(9).parameter = 0;

alginfo.outputs(1).name = 't';
alginfo.outputs(1).desc = 'Time stamps';

alginfo.outputs(2).name = 'y';
alginfo.outputs(2).desc = 'Samples';

%XXX 2DO modulation, noise

alginfo.providesGUF = 0;
alginfo.providesMCM = 0;

% vim settings modeline: vim: foldmarker=%<<<,%>>> fdm=marker fen ft=octave textwidth=80 tabstop=4 shiftwidth=4
