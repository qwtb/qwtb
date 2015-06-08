function info = alg_info() %<<<1
% Part of QWTB. Info script for testGM algorithm.
% testG is usefull only for testing QWTB toolbox. It calculates maximal value
% of the record. GUF is calculated by wrapper.
%
% See also qwtb

info.shortname = 'testG';
info.longname = 'Test with GUF, without MCM';
info.desc = 'Calculates maximum value of the measured record';
info.citation = 'see EMRP Q-Wave';
info.remarks = 'Do not use. This is only for testing QWTB';
info.requires = {'t', 'y'};
info.returns = {'max'};
info.providesGUF = 1;
info.providesMCM = 0;

% vim settings modeline: vim: foldmarker=%<<<,%>>> fdm=marker fen ft=octave textwidth=80 tabstop=4 shiftwidth=4
