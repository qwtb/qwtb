%% Generate n-harmonic waveform
% Example for algorithm GenNHarm
%
% An algorithm for generating sampled waveforms with multiple harmonic or interharmonic components and noise level.

%% Generate simple sine waveform
% Consider we want to simulate a sampled voltage waveform with frequency 1,
% amplitude 1, phase 1 and offset 1. The waveform was sampled with sampling
% frequency 1 kHz and number of samples was 1000. The waveform contains also
% 3rd harmonic with amplitude of 0.1 V, and noise at level 1 mV.
DI = [];
DI.fs.v = 1e3;
DI.L.v = 1e3;
DI.f.v = [1 3];
DI.A.v = [1 0.1];
DI.ph.v = [0 pi];
DI.O.v = [0 0];
DI.noise.v = 0.001;
DO = qwtb('GenNHarm', DI);

%% Calculated THD_k1
% The output structure contains the calculated value of the THD_k1 quantity:
DO.thd_k1.v

%% Plot
% The generated waveform:
figure
plot(DO.t.v, DO.y.v, '-');
xlabel('t (s)'), ylabel('amplitude (V)')

%% Generate simple sine waveform using number of periods
% Consider we want to simulate 2.5 periods of a sine waveform.
DI = [];
DI.fs.v = 1e3;
DI.M.v = 2.5;
DI.f.v = [1];
DI.A.v = [1];
DI.ph.v = [0];
DI.O.v = [0];
DI.noise.v = 0;
DO = qwtb('GenNHarm', DI);
figure
plot(DO.t.v, DO.y.v, '-');
xlabel('t (s)'), ylabel('amplitude (V)')

%% Generate waveform with automatically calculated harmonics
% Consider waveform with 10 harmonic components, while the amplitudes of the
% harmonics will be calculated based on the supplied THD_k1 value. The |f|,
% |A|, |ph| and |O| quantities will contain only values for first harmonic. The
% rest harmonics will be added by the waveform generator.
DI = [];
DI.fs.v = 1e3;
DI.L.v = 1e3;
DI.f.v = [1];
DI.A.v = [1];
DI.ph.v = [0];
DI.O.v = [0];
DI.thd_k1.v = 0.1;
DI.nharm.v = 9;
DO = qwtb('GenNHarm', DI);
figure
plot(DO.t.v, DO.y.v, '-')
xlabel('t (s)'), ylabel('amplitude (V)')

%% Check using FFT
% We can check the generated waveform by calculating the spectrum. Output of GenNHarm will be used as input into the algorithm |SP-WFFT|.
DIspec = DO;
DIspec.fs.v = DI.fs.v;
DOspec = qwtb('SP-WFFT', DIspec);
figure
semilogy(DOspec.f.v, DOspec.A.v, 'o');
xlim([-2 12]); ylim([1e-3 10]);
