function alginfo = alg_info() %<<<1
% Part of QWTB. Info script for algorithm ADEV.
%
% See also qwtb

alginfo.id = 'FFOAV';
alginfo.name = 'Fast Fully Overlapped Allan Variance';
alginfo.desc = 'Fast, parallelizeable algorithm to calculate Fully Overlapped Allan Variance for generating smooth Allan Deviation plots whose serial running time is $\Theta(N^2)$.';
alginfo.citation = 'S. M. Yadav, S. K. Shastri, G. B. Chakravarthi, V. Kumar, D. R. A and V. Agrawal, "A Fast, Parallel Algorithm for Fully Overlapped Allan Variance and Total Variance for Analysis and Modelling of Noise in Inertial Sensors," in IEEE Sensors Letters. doi: 10.1109/LSENS.2018.2829799. Github repository: https://github.com/shrikanth95/Fast-Parallel-Fully-Overlapped-Allan-Variance-and-Total-Variance';
alginfo.remarks = 'If sampling frequency |fs| is not supplied, wrapper will calculate |fs| from sampling time |Ts| or if not supplied, mean of differences of time series |t| is used to calculate |Ts|. The output is recaldulated to return deviation to correspond other algorithms.';

alginfo.license = 'MIT License';

alginfo.inputs(1).name = 'fs';
alginfo.inputs(1).desc = 'Sampling frequency';
alginfo.inputs(1).alternative = 1;
alginfo.inputs(1).optional = 0;
alginfo.inputs(1).parameter = 0;

alginfo.inputs(2).name = 'Ts';
alginfo.inputs(2).desc = 'Sampling time';
alginfo.inputs(2).alternative = 1;
alginfo.inputs(2).optional = 0;
alginfo.inputs(2).parameter = 0;

alginfo.inputs(3).name = 't';
alginfo.inputs(3).desc = 'Time series';
alginfo.inputs(3).alternative = 1;
alginfo.inputs(3).optional = 0;
alginfo.inputs(3).parameter = 0;

alginfo.inputs(4).name = 'y';
alginfo.inputs(4).desc = 'Sampled values';
alginfo.inputs(4).alternative = 0;
alginfo.inputs(4).optional = 0;
alginfo.inputs(4).parameter = 0;

alginfo.outputs(1).name = 'oadev';
alginfo.outputs(1).desc = 'Overlapped Allan deviation';

alginfo.outputs(2).name = 'tau';
alginfo.outputs(2).desc = 'Observation time of resulted values';

alginfo.providesGUF = 0;
alginfo.providesMCM = 0;

% vim settings modeline: vim: foldmarker=%<<<,%>>> fdm=marker fen ft=octave textwidth=80 tabstop=4 shiftwidth=4
