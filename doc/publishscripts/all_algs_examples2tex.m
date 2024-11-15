%% script runs GNU Octave command `publish` on all algorithms examples
% properly works in GNU Octave. See previous versions to get a script working
% with Matlab
clear all

%% Settings
% path to the QWTB:
QWTBpath = '../../qwtb';
% publish directory name (directory name where the example .tex and images will
% be generated by Octave's publish() function):
publishprefix = 'algs_examples_published/';
% path to the publish directory relative to actual working directory:
publishpath = ['../' publishprefix];

%% Setup publish function
options.format = 'latex';
% this must be relative to qwtb directory:
options.outputDir = publishpath;
% pdfcrop is needed to produce properly cropped pdf images. Unfortunately it
% will generate image files with .pdfcrop extension:
options.imageFormat = 'pdfcrop';
% options.maxWidth = [];
% options.maxHeight = [];
options.useNewFigure = true;
options.evalCode = true;
options.catchError = true;
% options.codeToEvaluate = '';
options.maxOutputLines = Inf;
options.showCode = true;

%% Initialization 
% remove all files in target directory:
delete(fullfile(publishpath, '*'))

% path to qwtb:
addpath(QWTBpath);

% get all algs:
algs = qwtb();
PAAalgsids = {algs.id};

for PAAi = 1:length(PAAalgsids)
    % for every algorithm:
    disp(['publish on algorithm: ' PAAalgsids{PAAi}]);
    % addpath of algorithm:
    qwtb(PAAalgsids{PAAi}, 'addpath');
    % run publish on example:
    % Octave needs direct file path to the .m file
    publish(fullfile(QWTBpath, ['alg_' PAAalgsids{PAAi}], 'alg_example.m'), options); % XXX 'format', 'latex', 'outputDir', '.');

    % reformat matlab latex output:
    % PAAstr = betterpublish(fileread('alg_example.tex'), [imgprefix PAAalgsids{PAAi}]);
    texfile = fullfile(publishpath, 'alg_example.tex');
    PAAstr = betterpublish(fileread(texfile), [publishprefix PAAalgsids{PAAi} '_'], 1);
    % open latex file:
    PAAfid = fopen(texfile, 'w');
    fprintf(PAAfid, '%s', PAAstr);
    fclose(PAAfid);
    % rename output latex file by algorithm id:
    movefile(texfile, fullfile(publishpath, ['doc_' PAAalgsids{PAAi} '.tex']));

    % remove old path:
    qwtb(PAAalgsids{PAAi}, 'rempath');

    % Change extension of all image files from .pdfcrop to .pdf and rename
    % according the algorithm:
    PAEimg = dir(fullfile(publishpath, '*.pdfcrop'));
    for PAEj = 1:length(PAEimg)
        oldpathname = fullfile(PAEimg(PAEj).folder, PAEimg(PAEj).name);
        [D F E] = fileparts(PAEimg(PAEj).name);
        newpathname = fullfile(publishpath, [PAAalgsids{PAAi} '_' F '.pdf']);
        rename(oldpathname, newpathname);
    end
end % for all algorithms

close all

% vim settings modeline: vim: foldmarker=%<<<,%>>> fdm=marker fen ft=octave textwidth=80 tabstop=4 shiftwidth=4
