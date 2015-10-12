function info = alg_info() %<<<1
% Part of QWTB. Info script for algorithm FPSWF
%
% See also qwtb

info.id = 'FPSWF';
info.name = 'Four Parameter Sine Wave Fit';
info.desc = 'Fits a sine wave to the recorded data by means of least squares using 4 parameter model. Different functions are used when run in MATLAB or GNU Octave.';
info.citation = '';
info.remarks = 'Algorithm is very sensitive to distortion. Algorithm requires good estimate of frequency.';
info.license = '';
info.requires = {'t', 'y'};
info.reqdesc = {'Time series of sampled data', 'Sampled values'};
info.returns = {'f', 'A', 'ph', 'O'};
info.retdesc = {'Frequency of main signal component', 'Amplitude of main signal component', 'Phase of main signal component', 'Offset of signal'};
info.providesGUF = 0;
info.providesMCM = 0;

% vim settings modeline: vim: foldmarker=%<<<,%>>> fdm=marker fen ft=octave textwidth=80 tabstop=4 shiftwidth=4
