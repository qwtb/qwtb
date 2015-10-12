%% Example of the QWTB use
% Data are simulated and QWTB is used with different algorithms.

%%
% First and example of PSFE algorithm is run. This example generates sine
% waveform in |DI| structure. This data will be used.
qwtb('PSFE', 'example')
%%
% Next uncertainties are added to the |t| and |y| structures.
DI.t.u = zeros(size(DI.t.v)) + 1e-5;
DI.y.u = zeros(size(DI.y.v)) + 1e-4;
%%
% Calculations settings is created with Monte Carlo uncertainty calculation
% method, 1000 repeats and singlecore calculation.
CS.unc = 'mcm'
CS.mcm.repeats = 1000;
CS.mcm.method = 'singlecore'
%%
% Run PSFE algorithm on input data |DI| and with calculattion settings |CS|.
DO = qwtb('PSFE',DI,CS);
%%
% Let see results - calculated value of frequency and its histogram.
DO.f.v
figure; hist(DO.f.r,50);
%%
% One can see the histogram is not gaussian function. However uncertainties
% were quite large, lets decrease it to a typical value:
DI.t.u = zeros(size(DI.t.v)) + 1e-9;
DI.y.u = zeros(size(DI.y.v)) + 1e-5;
%%
% And new results are:
DO = qwtb('PSFE',DI,CS);
DO.f.u
figure; hist(DO.f.r,50);

% % vim settings modeline: vim: foldmarker=%<<<,%>>> fdm=marker fen ft=octave textwidth=80
