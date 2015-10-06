%% script runs `publish` of all algorithms
% properly works only in Matlab, GNU Octave has some errors (4.0)
% XXX
% 2DO pdf output is USletter, but works out of box. latex and html output links
% images absolutely, therefore incorrect paths. wkhtml is nice and colours
% resembles standard matlab help but small font, latex->dvipdf seems ok, no
% colours, good font
clear all

% path to qwtb:
addpath('../../qwtb');

% get all algs:
algs = qwtb();
algsids = {algs.id};

for i = 1:length(algsids)
    % for every algorithm
    disp(['publish on algorithm: ' algsids{i}]);
    % addpath of algorithm
    qwtb(algsids{i}, 'addpath')
    % run publish on example
    resfil = publish('alg_example', 'format', 'pdf', 'outputDir', '.')
    % rename resulting pdf to a correct name so it do not get overwritten in
    % next loop iteration
    if ispc
        system(['cp ' resfil ' doc_' algsids{i} '.pdf']);
    else
        system(['mv ' resfil ' doc_' algsids{i} '.pdf']);
    end
    %qwtb(algsids{i}, 'addpath')
    %publish('alg_example', 'format', 'html', 'outputDir', '.')
    qwtb(algsids{i}, 'rempath')
end % for all algorithms

% vim settings modeline: vim: foldmarker=%<<<,%>>> fdm=marker fen ft=octave textwidth=80 tabstop=4 shiftwidth=4
