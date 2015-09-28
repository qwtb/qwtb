function info = alg_info() %<<<1
% Part of QWTB. Info script for algorithm test(G)(M). Algorithm is usefull only
% for testing QWTB toolbox. It calculates maximal and minimal value of the
% record. GUF/MCM are calculated by wrapper.
%
% See also qwtb

info.shortname = 'testG';
info.longname = 'Test with GUF';
info.desc = 'Calculates maximum value of the measured record';
info.citation = 'see EMRP Q-Wave';
info.remarks = 'Do not use. This is only for testing QWTB';
info.requires = {'t', 'y'};
info.returns = {'max', 'min'};
info.providesGUF = 1;
info.providesMCM = 0;

% vim settings modeline: vim: foldmarker=%<<<,%>>> fdm=marker fen ft=octave textwidth=80 tabstop=4 shiftwidth=4
