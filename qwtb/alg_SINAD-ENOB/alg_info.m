function alginfo = alg_info() %<<<1
% Part of QWTB. Info script for algorithm SINAD-ENOB
%
% See also qwtb

alginfo.id = 'SINAD-ENOB';
alginfo.name = 'Ratio of signal to noise and distortion and Effective number of bits (in time space)';
alginfo.desc = ' Algorithm calculates Ratio of signal to noise and distortion and Effective number of bits in time space, therefore it is suitable for noncoherent measurements. Requires estimates of the main signal component parameters: frequency, amplitude, phase and offset. If these values are estimated by four parameter sine wave fit, the SINAD and ENOB will be calculated according IEEE Std 1241-2000. A large sine wave should be applied to the ADC input. Almost any error source in the sine wave input other than gain accuracy and dc offset can affect the test result.';
alginfo.citation = 'IEEE Std 1241-2000, pages 52 - 54';
alginfo.remarks = '';
alginfo.license = 'MIT License';
alginfo.requires = {'t', 'y', 'f', 'A', 'ph', 'O', 'bitres', 'range'};
alginfo.reqdesc = {'time vector', 'sampled values', 'frequency of the main signal component', 'amplitude of the main signal component', 'phase of the main signal component', 'offset of the main signal component', 'bit resolution of an ADC', 'Full scale range of an ADC'};
alginfo.returns = {'SINADdB', 'ENOB'};
alginfo.retdesc = {'Ratio of signal to noise and distortion in decibels relative to the amplitude of the main signal component ', 'Effective number of bits'};
alginfo.providesGUF = 0;
alginfo.providesMCM = 0;

% vim settings modeline: vim: foldmarker=%<<<,%>>> fdm=marker fen ft=octave textwidth=80 tabstop=4 shiftwidth=4
