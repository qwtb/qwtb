function alginfo = alg_info() %<<<1
% Part of QWTB. Info script for algorithm GenNHarm.
%
% See also qwtb

alginfo.id = 'GenNHarm';
alginfo.name = 'Basic signal generator';
alginfo.desc = 'An algorithm for generating sampled waveforms with multiple harmonic or interharmonic components, noise level and quantization.';
alginfo.citation = 'N/A';
alginfo.remarks = 'If sampling time |Ts| is not supplied, wrapper will calculate |Ts| from sampling frequency |fs| or if not supplied, mean of differences of time series |t| is used to calculate |Ts|.';
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

alginfo.inputs(5).name = 'f';
alginfo.inputs(5).desc = 'Main signal frequency';
alginfo.inputs(5).alternative = 0;
alginfo.inputs(5).optional = 0;
alginfo.inputs(5).parameter = 1;

alginfo.inputs(5).name = 'A';
alginfo.inputs(5).desc = 'Main signal amplitude';
alginfo.inputs(5).alternative = 0;
alginfo.inputs(5).optional = 0;
alginfo.inputs(5).parameter = 1;

alginfo.inputs(5).name = 'ph';
alginfo.inputs(5).desc = 'Main signal phase';
alginfo.inputs(5).alternative = 0;
alginfo.inputs(5).optional = 0;
alginfo.inputs(5).parameter = 1;

alginfo.inputs(5).name = 'O';
alginfo.inputs(5).desc = 'Main signal offset';
alginfo.inputs(5).alternative = 0;
alginfo.inputs(5).optional = 0;
alginfo.inputs(5).parameter = 1;

alginfo.inputs(5).name = 'THD';
alginfo.inputs(5).desc = 'Total harmonic distortion';
alginfo.inputs(5).alternative = 0;
alginfo.inputs(5).optional = 0;
alginfo.inputs(5).parameter = 1;

alginfo.inputs(5).name = 'nharm';
alginfo.inputs(5).desc = 'Number of harmonics';
alginfo.inputs(5).alternative = 0;
alginfo.inputs(5).optional = 0;
alginfo.inputs(5).parameter = 1;

alginfo.outputs(1).name = 'y';
alginfo.outputs(1).desc = 'Samples';

alginfo.providesGUF = 0;
alginfo.providesMCM = 0;

% vim settings modeline: vim: foldmarker=%<<<,%>>> fdm=marker fen ft=octave textwidth=80 tabstop=4 shiftwidth=4
