%% Phase Sensitive Frequency Estimator
% Example for algorithm PSFE.
%
% PSFE is an algorithm for estimating the frequency, amplitude, and phase of the
% fundamental component in harmonically distorted waveforms. The algorithm
% minimizes the phase difference between the sine model and the sampled waveform
% by effectively minimizing the influence of the harmonic components. It uses a
% three-parameter sine-fitting algorithm for all phase calculations. The
% resulting estimates show up to two orders of magnitude smaller sensitivity to
% harmonic distortions than the results of the four-parameter sine fitting
% algorithm.
%
% See also Lapuh, R., "Estimating the Fundamental Component of Harmonically
% Distorted Signals From Noncoherently Sampled Data," Instrumentation and
% Measurement, IEEE Transactions on , vol.64, no.6, pp.1419,1424, June 2015,
% doi: 10.1109/TIM.2015.2401211, URL: http://ieeexplore.ieee.org/stamp/stamp.jsp?tp=&arnumber=7061456&isnumber=7104190'

%% Generate sample data
% Two quantities are prepared: |t| and |y|, representing 1 second of sinus
% waveform of nominal frequency 100 Hz, nominal amplitude 1 V and nominal phase
% 1 rad, sampled at sampling frequency 10 kHz.
DI = [];
Anom = 1; fnom = 100; phnom = 1;
DI.t.v = [0:1/1e4:1-1/1e4];
DI.y.v = Anom*sin(2*pi*fnom*DI.t.v + phnom);
%%
% Add noise:
DI.y.v = DI.y.v + normrnd(0, 1e-3, size(DI.y.v));

%% Call algorithm
% Use QWTB to apply algorithm |PSFE| to data |DI|.
DO = qwtb('PSFE', DI);

%% Display results
% Results is the amplitude, frequency and phase of sampled waveform.
f = DO.f.v
A = DO.A.v
ph = DO.ph.v
%%
% Errors of estimation in parts per milion:
ferrppm = (DO.f.v - fnom)/fnom .* 1e6
Aerrppm = (DO.A.v - Anom)/Anom .* 1e6
pherrppm = (DO.ph.v - phnom)/phnom .* 1e6
