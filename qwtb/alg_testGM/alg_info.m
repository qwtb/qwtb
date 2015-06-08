function info = alg_info() %<<<1
% Part of QWTB. Info script for testGM algorithm.
% testGM is usefull only for testing QWTB toolbox. It calculates maximal value
% of the record. GUF and MCM are calculated by wrapper.
%
% See also qwtb

info.shortname = 'testGM';
info.longname = 'Test with GUF and MCM';
info.desc = 'Calculates maximum value of the measured record';
info.citation = 'see EMRP Q-Wave';
info.remarks = 'Do not use. This is only for testing QWTB';
info.requires = {'t', 'y'};
info.returns = {'max'};
info.providesGUF = 1;
info.providesMCM = 1;

% vim settings modeline: vim: foldmarker=%<<<,%>>> fdm=marker fen ft=octave textwidth=80 tabstop=4 shiftwidth=4
