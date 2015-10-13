%% script runs `publish` of all algorithms
% properly works only in Matlab, GNU Octave has some errors (4.0)
% requires epstopdf

clear all
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

    % reformat matlab latex output
    PAAstr = betterpublish(fileread('alg_example.tex'), ['alg_examples_published/' PAAalgsids{PAAi}]);
    PAAfid = fopen('alg_example.tex', 'w');
    fprintf(PAAfid, '%s', PAAstr);
    fclose(PAAfid);
    movefile('alg_example.tex', ['../alg_examples_published/doc_' PAAalgsids{PAAi} '.tex']);

    % remove old path:
    qwtb(PAAalgsids{PAAi}, 'rempath');

    % image files:
    PAAeps = dir('*.eps');
    PAAeps = {PAAeps.name};
    for PAAj = 1:length(PAAeps)
        system(['epstopdf ' PAAeps{PAAj}]);
        delete([PAAeps{PAAj}]);
    end
    % image files:
    PAApdf = dir('*.pdf');
    PAApdf = {PAApdf.name};
    for PAAj = 1:length(PAApdf)
        movefile(PAApdf{PAAj}, ['../alg_examples_published/' PAAalgsids{PAAi} '_' PAApdf{PAAj}]);
    end
end % for all algorithms

close all

% vim settings modeline: vim: foldmarker=%<<<,%>>> fdm=marker fen ft=octave textwidth=80 tabstop=4 shiftwidth=4
