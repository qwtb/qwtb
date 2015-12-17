%% script runs `publish` of all examples
% properly works only in Matlab, GNU Octave has some errors (4.0)
% requires epstopdf

clear all
% remove old figures:
system('rm *.eps');

% path to qwtb:
addpath('../../qwtb');

% list of examples:
PAEfn = {'qwtb_example_1', 'qwtb_example_2'};

for PAEi = 1:length(PAEfn)
    % latex file:
    PAEcfn = [PAEfn{PAEi} '.tex']
    % run publish on example
    publish(PAEfn{PAEi}, 'format', 'latex', 'outputDir', '.');

    % reformat matlab latex output
    PAEstr = betterpublish(fileread(PAEcfn), 'qwtb_examples_published/');
    PAEfid = fopen(PAEcfn, 'w');
    fprintf(PAEfid, '%s', PAEstr);
    fclose(PAEfid);
    movefile(PAEcfn, ['../qwtb_examples_published/' PAEcfn]);

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
        movefile(PAEpdf{PAEj}, ['../qwtb_examples_published/' PAEpdf{PAEj}]);
    end
end


close all

% vim settings modeline: vim: foldmarker=%<<<,%>>> fdm=marker fen ft=octave textwidth=80 tabstop=4 shiftwidth=4
