function alginfo = alg_info() %<<<1
% Part of QWTB. Info script for algorithm test(G)(M). Algorithm is usefull only
% for testing QWTB toolbox. It calculates maximal and minimal value of the
% record. GUF/MCM are calculated by wrapper.
%
% See also qwtb

alginfo.id = 'testGM';
alginfo.name = 'Test with GUF and MCM';
alginfo.desc = 'Calculates maximum value of the measured record';
alginfo.citation = 'see EMRP Q-Wave';
alginfo.remarks = 'Do not use. This is only for testing QWTB';
alginfo.license = 'MIT License';
alginfo.requires = {'x', 'y'};
alginfo.reqdesc = {'independent quantity', 'dependent quantity'};
alginfo.returns = {'max', 'min'};
alginfo.retdesc = {'maximal dependent quantity', 'minimal dependent quantity'};
alginfo.providesGUF = 1;
alginfo.providesMCM = 1;

% vim settings modeline: vim: foldmarker=%<<<,%>>> fdm=marker fen ft=octave textwidth=80 tabstop=4 shiftwidth=4
