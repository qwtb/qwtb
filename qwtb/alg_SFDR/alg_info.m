function alginfo = alg_info() %<<<1
% XXX add it takes up to 5 harmonics? does it?
% Part of QWTB. Info script for algorithm SFDR.
%
% See also qwtb

alginfo.id = 'SFDR';
alginfo.name = 'Spurious Free Dynamic Range';
alginfo.desc = 'Calculates Spurious Free Dynamic Range of a signal based on an amplitude spectrum.';
alginfo.citation = 'Implementation: Martin Sira';
alginfo.remarks = 'Samples are expected in quantity `y`, and algorithm `SP-WFFT` is used to calculate the amplitude spectrum. Alternatively a spectrum can be directly delivered in quantity `A`, use of blackman DFT window is expected.';
alginfo.license = 'MIT';

alginfo.inputs(1).name = 'y';
alginfo.inputs(1).desc = 'Sampled values';
alginfo.inputs(1).alternative = 1;
alginfo.inputs(1).optional = 0;
alginfo.inputs(1).parameter = 0;

alginfo.inputs(2).name = 'A';
alginfo.inputs(2).desc = 'Amplitude spectrum';
alginfo.inputs(2).alternative = 1;
alginfo.inputs(2).optional = 0;
alginfo.inputs(2).parameter = 0;


alginfo.outputs(1).name = 'SFDR';
alginfo.outputs(1).desc = 'Spurious Free Dynamic Range, relative to carrier (V/V)';

alginfo.outputs(2).name = 'SFDRdBc';
alginfo.outputs(2).desc = 'Spurious Free Dynamic Range, relative to carrier, in decibel (dB)';

alginfo.providesGUF = 0;
alginfo.providesMCM = 0;

% vim settings modeline: vim: foldmarker=%<<<,%>>> fdm=marker fen ft=octave textwidth=80 tabstop=4 shiftwidth=4
