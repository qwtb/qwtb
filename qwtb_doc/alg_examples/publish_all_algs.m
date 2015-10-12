%% script runs `publish` of all algorithms
% properly works only in Matlab, GNU Octave has some errors (4.0)
% works only in linux, windows is missing proper shell

if ispc
    % windows system:
    error('you have to use a better operating system!')
end

clear all
% % remove old list of algorithms:
% system('rm allalgslist.tex')
% remove old figures:
system('rm *.eps')

% path to qwtb:
addpath('../../qwtb');

% get all algs:
algs = qwtb();
PAAalgsids = {algs.id};

for PAAi = 1:length(PAAalgsids)
    % for every algorithm
    disp(['publish on algorithm: ' PAAalgsids{PAAi}]);
    % addpath of algorithm
    qwtb(PAAalgsids{PAAi}, 'addpath');
    % run publish on example
    publish('alg_example', 'format', 'latex', 'outputDir', '.');

    % reformat matlab latex output, copy files etc:
    system(['./betterpublish alg_example.tex ' PAAalgsids{PAAi}])

    % remove old path:
    qwtb(PAAalgsids{PAAi}, 'rempath');
end % for all algorithms

close all

% vim settings modeline: vim: foldmarker=%<<<,%>>> fdm=marker fen ft=octave textwidth=80 tabstop=4 shiftwidth=4
