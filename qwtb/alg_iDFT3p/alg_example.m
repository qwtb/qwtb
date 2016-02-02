%% Phase Sensitive Frequency Estimator
% Example for algorithm iDFT3p.
%
% iDFT3p is an algorithm for estimating the frequency, amplitude, and phase of the fundamental
% component using interpolated discrete Fourier transform. Rectangular or Hann window can be used
% for DFT.';
% See also Krzysztof Duda: Interpolation algorithms of DFT for parameters estimation of sinusoidal
% and damped sinusoidal signals. In S. M. Salih, editor, Fourier Transform - Signal Processing,
% chapter 1, pages 3-32, InTech, 2012.
% http://www.intechopen.com/books/fourier-transform-signal-processing/interpolated-dft
% Implemented by Rado Lapuh, 2016.';

%% Generate sample data
% Two quantities are prepared: |t| and |y|, representing 0.5 second of sinus waveform of nominal
% frequency 100 Hz, nominal amplitude 1 V and nominal phase 1 rad, sampled at sampling frequency 10
% kHz, with offset 0.1 V. The sampling is not coherent.
DI = [];
Anom = 1; fnom = 100; phnom = 1; Onom = 0.1;
DI.t.v = [0:1/1e4:0.5];
DI.y.v = Anom*sin(2*pi*fnom*DI.t.v + phnom) + Onom;

%% Call algorithm
% First a rectangular window will be used to estimate main signal properties.
DI.window.v = 'rectangular';
% Use QWTB to apply algorithm |iDFT3p| to data |DI| and put results into |DO_r|.
DO_r = qwtb('iDFT3p', DI);
% Next a Hann window will be used to estimate main signal properties Results will be put into
% |DO_h|.
DI.window.v = 'Hann';
DO_h = qwtb('iDFT3p', DI);

%% Display results
% Results is the amplitude, frequency and phase of sampled waveform. For rectangular window, the
% error from nominal in parts per milion is:
f_re = (DO_r.f.v - fnom)./fnom .* 1e6
A_re = (DO_r.A.v - Anom)./Anom .* 1e6
ph_re = (DO_r.ph.v - phnom)./phnom .* 1e6
O_re = (DO_r.O.v - Onom)./Onom .* 1e6
%%
% For Hann window:
f_he = (DO_h.f.v - fnom)./fnom .* 1e6
A_he = (DO_h.A.v - Anom)./Anom .* 1e6
ph_he = (DO_h.ph.v - phnom)./phnom .* 1e6
O_he = (DO_h.O.v - Onom)./Onom .* 1e6