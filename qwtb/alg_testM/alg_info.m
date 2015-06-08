function info = alg_info() %<<<1
% Part of QWTB. Info script for testGM algorithm.
% testM is usefull only for testing QWTB toolbox. It calculates maximal value
% of the record. MCM is calculated by wrapper.
%
% See also qwtb

info.shortname = 'testM';
info.longname = 'Test without GUF, with MCM';
info.desc = 'Calculates maximum value of the measured record';
info.citation = 'see EMRP Q-Wave';
info.remarks = 'Do not use. This is only for testing QWTB';
info.requires = {'t', 'y'};
info.returns = {'max'};
info.providesGUF = 0;
info.providesMCM = 1;

% vim settings modeline: vim: foldmarker=%<<<,%>>> fdm=marker fen ft=octave textwidth=80 tabstop=4 shiftwidth=4
