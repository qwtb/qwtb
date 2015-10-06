function info = alg_info() %<<<1
% Part of QWTB. Info script for testGM algorithm.
% testG is usefull only for testing QWTB toolbox. It calculates maximal value
% of the record. GUF is calculated by wrapper.
%
% See also qwtb

info.shortname = 'INL';
info.longname = 'Integral Non-Linearity of ADC';
info.desc = 'Calculates Integral Non-Linearity of an ADC. ADC has to sample sinewave, ADC codes are required.';
info.citation = ''; % 2DO
info.remarks = '';
info.requires = {'t', 'y'};
info.returns = {'INL'};
info.providesGUF = 0;
info.providesMCM = 0;

% vim settings modeline: vim: foldmarker=%<<<,%>>> fdm=marker fen ft=octave textwidth=80 tabstop=4 shiftwidth=4
