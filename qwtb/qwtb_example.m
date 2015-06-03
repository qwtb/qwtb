%% Example of the QWTB use
% Data are simulated and QWTB is used with different algorithms.

%% First prepare simulated data. Suppose ADC sampled sinewave, ADC returned codes:
% Sine wave:
t=[0:1/1e3:20];
y = sin(2*pi*t);

%%
% Add noise:
y = y + normrnd(0,1e-3,size(y));
bits = 10;

%%
% Calculate codes values. It is simualted by quantization and scaling. Usually
% it can be obtained directly by the ADC. Suppose ADC range is -1..1:
codes = y;
rmin = -1;
rmax = 1;
levels = 2.^bits - 1;
codes(codes<rmin) = rmin;
codes(codes>rmax) = rmax;
codes = round((codes-rmin)./2.*levels);

%%
% Introduce ADC error. Instead of generating code 700 ADC erroneously generates 710:
codes(codes==700) = 710;

%%
% The time series returned by ADC is:
figure
%plot(t, (y+1).*1/2.*levels, t, codes);
stairs(t, codes);

%%
% Data is simulated, now create data structure for QWTB.
datain.t.v=t;
datain.y.v = codes;
datain.bits.v = 10;

% Calculation settings structure. Uncertainties are not required.
calcset.unc = '';

% -----------------------------------------------------------------------
%% 1. example use of QWTB - get signal phase:
% Calculate frequency by means of PSFE:
dataout = qwtb('PSFE', datain, calcset);
disp(['calculated frequency is: ' num2str(dataout.f.v, 9) ' Hz'])

%% 2. example use of QWTB - get INL of ADC:
% Calculate integral nonlinearity by means of ADCToolbox:
dataout = qwtb('INL', datain, calcset);
figure
plot(dataout.INL.v)
title('Integral nonlinearity')

% vim settings modeline: vim: foldmarker=%<<<,%>>> fdm=marker fen ft=octave textwidth=80
