%% Copyright (C) 2015 Q-Wave %<<<1
%%
%% Wrapper for INL
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
        % XXX atd.
end
% format input data %<<<1
dsc.data = datain.y.v;
dsc.NoB = datain.bits.v;

dsc.name = 'tst';
dsc.comment = {['comment']};
dsc.model = 'MatlabSim';
dsc.serial = 'N/A';
dsc.channel = 1;
dsc.simulation = 1;

display_settings.results_win = 0;
display_settings.summary_win = 0;
display_settings.warning_dialog = 0;

% call INL:  %<<<1
INL = ProcessHistogramTest(dsc,display_settings);

% format output data:  %<<<1

dataout.INL.v = INL;

% vim settings modeline: vim: foldmarker=%<<<,%>>> fdm=marker fen ft=octave textwidth=80
