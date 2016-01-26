%% script runs matlab command `publish` on all qwtb examples
% properly works only in Matlab, GNU Octave has some errors (4.0)
% requires epstopdf, therefore probably only matlab in linux can do this
clear all

imgprefix = 'qwtb_examples_published/';
dirprefix = ['../' imgprefix];

% remove all files in target directory:
delete([dirprefix '*'])

% path to qwtb:
addpath('../../qwtb');

% list of examples:
PAEfn = {'qwtb_example_1', 'qwtb_example_2'};

for PAEi = 1:length(PAEfn)
    % for all examples
    % latex file:
    PAEcfn = [PAEfn{PAEi} '.tex']
    % run publish on example
    publish(PAEfn{PAEi}, 'format', 'latex', 'outputDir', '.');

    % reformat matlab latex output
    %%%%%%% XXX PAEstr = betterpublish(fileread(PAEcfn), 'qwtb_examples_published/');
    PAEstr = betterpublish(fileread(PAEcfn), imgprefix);
    PAEfid = fopen(PAEcfn, 'w');
    fprintf(PAEfid, '%s', PAEstr);
    fclose(PAEfid);
    movefile(PAEcfn, [dirprefix PAEcfn]);

    % image files:
    PAEeps = dir('*.eps');
    PAEeps = {PAEeps.name};
    for PAEj = 1:length(PAEeps)
        system(['epstopdf ' PAEeps{PAEj}]);
        delete([PAEeps{PAEj}]);
    end
    % image files:
    PAEpdf = dir('*.pdf');
    PAEpdf = {PAEpdf.name};
    for PAEj = 1:length(PAEpdf)
        movefile(PAEpdf{PAEj}, [dirprefix PAEpdf{PAEj}]);
    end
end % for all examples

close all

% vim settings modeline: vim: foldmarker=%<<<,%>>> fdm=marker fen ft=octave textwidth=80 tabstop=4 shiftwidth=4
