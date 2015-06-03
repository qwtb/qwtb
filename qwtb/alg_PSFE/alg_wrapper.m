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

function dataout = alg_wrapper(datain, calcset)
checkdatain = 0; %XXX
% check input data:  %<<<1
if checkdatain
        % these ifs as a function script, adn write what is missing, or where is the problem
        % this script should only provide list of strings with datain names
        if not(isfield(checkdatain.t.v))
                dataout.error = 'data in check error'
        end
        if not(isfield(checkdatain.y.v))
                dataout.error = 'data in check error'
        end
end
% format input data %<<<1
% PSFE input arguments:
% Record     - sampled input signal
% Ts         - sampling time (in s)
% init_guess: 0 - FFT max bin, 1 - IPDFT, negative initial frequency estimate

Record = datain.y.v;
Ts = datain.t.v(2) - datain.t.v(1);
init_guess = 1;

% call PSFE:  %<<<1
[fa A ph] = PSFE(Record,Ts,init_guess);

% format output data:  %<<<1
% PSFE output arguments:
% fa     - estimated signal's frequency
% A      - estimated signal's amplitude
% ph     - estimated signal's phase

dataout.f.v = fa;
dataout.f.u = 0;
dataout.f.d = 0;

dataout.A.v = A;
dataout.A.u = 0;
dataout.A.d = 0;

dataout.ph.v = ph;
dataout.ph.u = 0;
dataout.ph.d = 0;


% vim settings modeline: vim: foldmarker=%<<<,%>>> fdm=marker fen ft=octave textwidth=80
