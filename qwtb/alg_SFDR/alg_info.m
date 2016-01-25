function info = alg_info() %<<<1
% Part of QWTB. Info script for algorithm SFDR.
%
% See also qwtb

info.id = 'SFDR';
info.name = 'Spurious Free Dynamic Range';
info.desc = 'Calculates Spurious Free Dynamic Range of an ADC. A FFT method with Blackman windowing is used to calculate a spectrum and SFDR is estimated in decibels relative to carrier amplitude. ADC has to sample a pure sine wave. SFDR is calculated according IEEE Std 1057-2007';
info.citation = 'Implementation: Virosztek, T., Pálfi V., Renczes B., Kollár I., Balogh L., Sárhegyi A., Márkus J., Bilau Z. T., ADCTest project site: http://www.mit.bme.hu/projects/adctest 2000-2014';
info.remarks = 'Based on the ADCTest Toolbox v4.3, November 25, 2014.';
info.license = 'UNKNOWN';
info.requires = {'y'};
info.reqdesc = {'Sampled values'};
info.returns = {'SFDRdBc'};
info.retdesc = {'Spurious Free Dynamic Range in decibels relative to carrier (dBc)'};
info.providesGUF = 0;
info.providesMCM = 0;

% vim settings modeline: vim: foldmarker=%<<<,%>>> fdm=marker fen ft=octave textwidth=80 tabstop=4 shiftwidth=4
