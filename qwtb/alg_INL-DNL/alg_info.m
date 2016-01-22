function info = alg_info() %<<<1
% Part of QWTB. Info script for algorithm INL-DNL.
%
% See also qwtb

info.id = 'INL-DNL';
info.name = 'Integral and Differential Non-Linearity of ADC';
info.desc = 'Calculates Integral and Differential Non-Linearity of an ADC. The histogram of measured data is used to calculate INL and DNL estimators. ADC has to sample a pure sine wave. To estimate all transition levels the amplitude of the sine wave should overdrive the full range of the ADC by at least 120%. If not so, non estimated transition levels will be assumed to be 0 and the results may be less accurate. As an input ADC codes are required.';
info.citation = 'Estimators are based on Tamás Virosztek, MATLAB-based ADC testing with sinusoidal excitation signal (in Hungar- ian), B.Sc. Thesis, 2011. Implementation: Virosztek, T., Pálfi V., Renczes B., Kollár I., Balogh L., Sárhegyi A., Márkus J., Bilau Z. T., ADCTest project site: http://www.mit.bme.hu/projects/adctest 2000-2014';
info.remarks = 'Based on the ADCTest Toolbox v4.3, November 25, 2014.';
info.license = 'UNKNOWN';
info.requires = {'bitres', 'codes'};
info.reqdesc = {'Bit resolution of the ADC', 'Sampled values represented as ADC codes (not converted to voltage)'};
info.returns = {'INL'};
info.retdesc = {'Integral Non-Linearity'};
info.returns = {'DNL'};
info.retdesc = {'Differential Non-Linearity'};
info.providesGUF = 0;
info.providesMCM = 0;

% vim settings modeline: vim: foldmarker=%<<<,%>>> fdm=marker fen ft=octave textwidth=80 tabstop=4 shiftwidth=4
