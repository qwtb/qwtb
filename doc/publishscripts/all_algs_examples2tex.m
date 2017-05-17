%% script runs matlab command `publish` on all algorithms examples
% properly works only in Matlab, GNU Octave has some errors (4.0)
% requires epstopdf, therefore probably only matlab in linux can do this
clear all

imgprefix = 'algs_examples_published/';
dirprefix = ['../doc/' imgprefix];

% remove all files in target directory:
delete([dirprefix '*'])

% path to qwtb:
cd('../../qwtb');
addpath('../doc/publishscripts');

% get all algs:
algs = qwtb();
PAAalgsids = {algs.id};

for PAAi = 1:length(PAAalgsids)
    % for every algorithm:
    disp(['publish on algorithm: ' PAAalgsids{PAAi}]);
    % addpath of algorithm:
    qwtb(PAAalgsids{PAAi}, 'addpath');
    % run publish on example:
    publish('alg_example', 'format', 'latex', 'outputDir', '.');

    % reformat matlab latex output:
    PAAstr = betterpublish(fileread('alg_example.tex'), [imgprefix PAAalgsids{PAAi}]);
    % open latex file:
    PAAfid = fopen('alg_example.tex', 'w');
    fprintf(PAAfid, '%s', PAAstr);
    fclose(PAAfid);
    % rename output latex file by algorithm id:
    movefile('alg_example.tex', [dirprefix 'doc_' PAAalgsids{PAAi} '.tex']);

    % remove old path:
    qwtb(PAAalgsids{PAAi}, 'rempath');

    % convert image files to pdf:
    PAAeps = dir('*.eps');
    PAAeps = {PAAeps.name};
    for PAAj = 1:length(PAAeps)
        system(['epstopdf ' PAAeps{PAAj}]);
        delete([PAAeps{PAAj}]);
    end
    % rename image files:
    PAApdf = dir('*.pdf');
    PAApdf = {PAApdf.name};
    for PAAj = 1:length(PAApdf)
        movefile(PAApdf{PAAj}, [dirprefix PAAalgsids{PAAi} '_' PAApdf{PAAj}]);
    end
end % for all algorithms

close all

cd('../doc/publishscripts');

% vim settings modeline: vim: foldmarker=%<<<,%>>> fdm=marker fen ft=octave textwidth=80 tabstop=4 shiftwidth=4
