function alginfo = alg_info() %<<<1
% Part of QWTB. Info script for algorithm OADEV.
%
% See also qwtb

alginfo.id = 'OADEV';
alginfo.name = 'Overlapping Allan Deviation';
alginfo.desc = 'Compute the overlapping Allan deviation for a set of time-domain frequency data.';
alginfo.citation = 'D.A. Howe, D.W. Allan and J.A. Barnes, "Properties of Signal Sources and Measurement Methods'', Proc. 35th Annu. Symp. on Freq. Contrl., pp. 1-47, May 1981. Implementation: Implementation by M. A. Hopcroft, mhopeng@gmail.com, Matlab Central, online: http://www.mathworks.com/matlabcentral/fileexchange/26441-allan-overlap Test data by W. J. Riley, "The Calculation of Time Domain Frequency Stability", online: http://www.wriley.com/paper1ht.htm';
alginfo.remarks = 'If tau is empty array, tau values are automatically generated. Tau values must be divisible by 1/fs. Invalid values are ignored. For tau values really used in the calculation see the output. Using sigma as uncertainty is probably not correct.';
alginfo.license = 'BSD License';
alginfo.requires = {'y', 'fs', 'tau'};
alginfo.reqdesc = {'sampled values', 'sampling frequency', 'observation time'};
alginfo.returns = {'oadev', 'tau'};
alginfo.retdesc = {'overlapping Allan deviation', 'observation time of result values'};
alginfo.providesGUF = 1;
alginfo.providesMCM = 0;

% vim settings modeline: vim: foldmarker=%<<<,%>>> fdm=marker fen ft=octave textwidth=80 tabstop=4 shiftwidth=4
