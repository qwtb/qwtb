function alginfo = alg_info() %<<<1
% Part of QWTB. Info script for algorithm ADEV.
%
% See also qwtb

alginfo.id = 'ADEV';
alginfo.name = 'Allan Deviation';
alginfo.desc = 'Compute the Allan deviation for a set of time-domain frequency data.';
alginfo.citation = 'W. J. Riley, "The Calculation of Time Domain Frequency Stability". Implementation: M. A. Hopcroft, mhopeng@gmail.com, Matlab Central.';
alginfo.remarks = 'If tau is empty array, tau values are automatically generated. Tau values must be divisible by 1/fs. Invalid values are ignored. For tau values really used in the calculation see the output. Using sigma as uncertainty is probably not correct.';
alginfo.license = 'BSD License';
alginfo.requires = {'y', 'fs', 'tau'};
alginfo.reqdesc = {'sampled values', 'sampling frequency', 'observation time'};
alginfo.returns = {'adev', 'tau'};
alginfo.retdesc = {'Allan deviation', 'observation time of result values'};
alginfo.providesGUF = 1;
alginfo.providesMCM = 0;

% vim settings modeline: vim: foldmarker=%<<<,%>>> fdm=marker fen ft=octave textwidth=80 tabstop=4 shiftwidth=4
