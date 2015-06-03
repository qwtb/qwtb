%% Copyright (C) 2015 Q-Wave %<<<1
%%
%% Wrapper for PSFE algorithm.
%% PSFE definition:
%% function [fa A ph] = PSFE(Record,Ts,init_guess)
%%
%% Author: Martin Šíra <msiraATcmi.cz>
%% Created: 2015
%% Version: 0.1
%% Script quality:
%%   Tested: no
%%   Contains help: no
%%   Contains example in help: no
%%   Checks inputs: no
%%   Contains tests: no
%%   Contains demo: no
%%   Optimized: no

function info = alg_info()

info.shortname = 'PSFE';
info.longname = 'Phase Sensitive Frequency Estimator';
info.desc = 'An algorithm for estimating the frequency, amplitude, and phase of the fundamental component in harmonically distorted waveforms. The algorithm minimizes the phase difference between the sine model and the sampled waveform by effectively minimizing the influence of the harmonic components. It uses a three-parameter sine-fitting algorithm for all phase calculations. The resulting estimates show up to two orders of magnitude smaller sensitivity to harmonic distortions than the results of the four-parameter sine fitting algorithm.';
info.citation = 'Lapuh, R., "Estimating the Fundamental Component of Harmonically Distorted Signals From Noncoherently Sampled Data," Instrumentation and Measurement, IEEE Transactions on , vol.64, no.6, pp.1419,1424, June 2015, doi: 10.1109/TIM.2015.2401211, URL: http://ieeexplore.ieee.org/stamp/stamp.jsp?tp=&arnumber=7061456&isnumber=7104190';
info.remarks = '';
info.requires = {'t', 'y'};
info.returns = {'f', 'A', 'ph'};
info.providesGUF = 0;
info.providesMCM = 0;

% vim settings modeline: vim: foldmarker=%<<<,%>>> fdm=marker fen ft=octave textwidth=80
