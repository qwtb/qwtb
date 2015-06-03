function info = alg_info()

info.shortname = 'tst1';
info.longname = 'Test';
info.desc = 'calculates maximum value of the measured record';
info.citation = 'see Deliverable D4.4.1';
info.remarks = 'do not use, purpose of this is only for testing of the QWTB'
info.requires = {'t', 'y'};
info.returns = {'max'};
info.providesGUF = 1;
info.providesMMC = 1;

% vim settings modeline: vim: foldmarker=%<<<,%>>> fdm=marker fen ft=octave textwidth=80
