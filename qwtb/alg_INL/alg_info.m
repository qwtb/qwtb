%% Copyright (C) 2015 Q-Wave %<<<1
%%
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

info.shortname = 'INL';
info.longname = 'Integral Non-Linearity';
info.desc = 'returns INL';
info.requires = {'t', 'y'};

% vim settings modeline: vim: foldmarker=%<<<,%>>> fdm=marker fen ft=octave textwidth=80
