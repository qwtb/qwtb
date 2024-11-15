%% script runs GNU Octave command `publish` on all qwtb examples
% properly works in GNU Octave. See previous versions to get a script working
% with Matlab
clear all

%% Settings
% path to the QWTB:
QWTBpath = '../../qwtb';
% publish directory name (directory name where the example .tex and images will
% be generated by Octave's publish() function):
publishprefix = 'qwtb_examples_published/';
% path to the publish directory relative to actual working directory:
publishpath = ['../' publishprefix];
% list of examples:
% (Matlab needs name of functions (e.g. 'qwtb_example_1'), Octave needs full
% filenames with path (e.g. '...../qwtb/qwtb_example_1.m'))
PAEfn = {'qwtb_example_1.m',...
         'qwtb_example_2.m',...
         'qwtbvar_example_1.m',...
         'qwtbvar_example_2.m'};

%% Initialization
% remove all files in target directory:
delete(fullfile(publishpath, '*'))
% add path to qwtb:
addpath(QWTBpath);
% make full paths to the publish scripts:
PAEfn = cellfun(@fullfile, repmat({QWTBpath}, size(PAEfn)), PAEfn, 'UniformOutput', false);

%% Setup publish function
options.format = 'latex';
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

%% Do for all examples:
for PAEi = 1:length(PAEfn)
    % run publish on example
    publish(PAEfn{PAEi}, options);
    % get path to actual .tex file:
    [DIR NAME EXT] = fileparts(PAEfn{PAEi});
    PAEcfn = fullfile(publishpath, [NAME '.tex']);

    % reformat Octave latex output
    PAEstr = betterpublish(fileread(PAEcfn), publishprefix, 0);
    % save changed content to the file
    PAEfid = fopen(PAEcfn, 'w');
    fprintf(PAEfid, '%s', PAEstr);
    fclose(PAEfid);

    % Change extension of all image files from .pdfcrop to .pdf:
    PAEimg = dir(fullfile(publishpath, '*.pdfcrop'));
    for PAEj = 1:length(PAEimg)
        oldpathname = fullfile(PAEimg(PAEj).folder, PAEimg(PAEj).name);
        [D F E] = fileparts(PAEimg(PAEj).name);
        newpathname = fullfile(PAEimg(PAEj).folder, [F '.pdf']);
        rename(oldpathname, newpathname);
    end
end % for all examples

close all

% vim settings modeline: vim: foldmarker=%<<<,%>>> fdm=marker fen ft=octave textwidth=80 tabstop=4 shiftwidth=4
