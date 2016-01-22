function info = alg_info() %<<<1
% Part of QWTB. Info script for algorithm INL.
%
% See also qwtb

info.id = 'INL';
info.name = 'Integral Non-Linearity of ADC';
info.desc = 'Calculates Integral Non-Linearity of an ADC. ADC has to sample sinewave, ADC codes are required.';
info.citation = 'Virosztek, T., Pálfi V., Renczes B., Kollár I., Balogh L., Sárhegyi A., Márkus J., Bilau Z. T., ADCTest project site: http://www.mit.bme.hu/projects/adctest 2000-2014';
info.remarks = 'Based on the ADCTest Toolbox v4.3, November 25, 2014.';
info.license = 'UNKNOWN';
info.requires = {'t', 'codes'};
info.reqdesc = {'time series of sampled data', 'Sampled values represented as ADC codes (not converted to voltage)'};
info.returns = {'INL'};
info.retdesc = {'INL'};
info.providesGUF = 0;
info.providesMCM = 0;

% vim settings modeline: vim: foldmarker=%<<<,%>>> fdm=marker fen ft=octave textwidth=80 tabstop=4 shiftwidth=4
