%% script generate latex file for all algorithms info and save it into 
% directory ../algs_published/
clear all

dirprefix = '../algs_info_published/';

% remove all files in target directory:
delete([dirprefix '*'])

% path to qwtb:
addpath('../../qwtb');

% get all informations from qwtb:
infos = qwtb();

for i = 1:length(infos) % for all info: %<<<1
    disp(['algorithm ' infos(i).id]);
    fid = fopen([dirprefix 'info_' infos(i).id '.tex'], 'w');
    % add proper header:
    fprintf(fid, '\\begin{tightdesc}\n');
    % add basic informations:
    fprintf(fid, '\\item [Id:] %s\n', infos(i).id);
    fprintf(fid, '\\item [Name:] %s\n', infos(i).name);
    fprintf(fid, '\\item [Description:] %s\n', infos(i).desc);
    tmp = infos(i).citation;
    % match urls in citation field and format urls:
    [S, E, TE, M, T, NM, SP] = regexp (tmp, 'https?://\S+');
    if ~isempty(M)
        tmp = [];
        for j = 1:length(M)
            tmp = [tmp SP{j} '\url{' strrep(M{j},'&','\&') '}'];
        end
        tmp = [tmp SP{j+1}];
    end
    % add other informations
    fprintf(fid, '\\item [Citation:] %s\n', tmp);
    fprintf(fid, '\\item [Remarks:] %s\n', infos(i).remarks);
    fprintf(fid, '\\item [License:] %s\n', infos(i).license);
    % add informations about uncertainty calculation:
    if infos(i).providesGUF
        tmp = 'yes';
    else
        tmp = 'no';
    end
    fprintf(fid, '\\item [Provides GUF:] %s\n', tmp);
    if infos(i).providesMCM
        tmp = 'yes';
    else
        tmp = 'no';
    end
    fprintf(fid, '\\item [Provides MCM:] %s\n', tmp);
    % add list and descriptions of all input quantities: %<<<2
    % XXX this function does not differ optional/nonoptional parameters?
    [reqQ, reqQdesc, optQ, optQdesc, reqQG, reqQGdesc, optQG, optQGdesc, parQ, Qlist] = parse_alginfo_inputs(infos(i));
    % input quantites:
    fprintf(fid, '\\item [Input Quantities] \\rule{0em}{0em}\n    \\begin{tightdesc}');
        % required quantities: %<<<3
        tmp = '';
        % prepare all required grouped quantities:
        for j = 1:length(reqQG)
            if j > 1
                tmp = [tmp ',\enspace '];
            end
            for k = 1:length(reqQG{j})
                if k > 1
                    tmp = [tmp ' or '];
                end
                tmp = [tmp '\textsf{' reqQG{j}{k} '}'];
            end
        end
        % prepare all required quantities:
        for j = 1:length(reqQ)
            if (j == 1 && isempty(tmp))
                tmp = [tmp '\textsf{' reqQ{j} '}'];
            else
                tmp = [tmp ',\enspace \textsf{' reqQ{j} '}'];
            end
        end
        % write prepared to the file:
        if ~isempty(tmp)
            fprintf(fid, '\n    \\item [Required:] \n        ');
            fprintf(fid, '%s', tmp);
        end
        % optional quantities: %<<<3
        tmp = [];
        % prepare all optional grouped quantities
        for j = 1:length(optQG)
            for k = 1:length(optQG{j})
                if k == 1
                    tmp = [tmp '\textsf{' optQG{j}{k} '}'];
                else
                    tmp = [tmp ' or \textsf{' optQG{j}{k} '}'];
                end
            end
        end
        % write all optional quantities
        for j = 1:length(optQ)
            if (j == 1 && isempty(tmp))
                tmp = [tmp '\textsf{' optQ{j} '}'];
            else
                tmp = [tmp ',\enspace \textsf{' optQ{j} '}'];
            end
        end
        % write prepared to the file:
        if ~isempty(tmp)
            fprintf(fid, '\n    \\item [Optional:] \n        ');
            fprintf(fid, '%s', tmp);
        end
        % parameter quantities: %<<<3
        tmp = [];
        % prepare all parameters:
        for j = 1:length(parQ)
            if j > 1
                tmp = [tmp ',\enspace '];
            end
            tmp = [tmp '\textsf{' parQ{j} '}'];
        end
        % write prepared to the file:
        if ~isempty(tmp)
            fprintf(fid, '\n    \\item [Parameters:] \n        ');
            fprintf(fid, '%s', tmp);
        end
        % input quantities descriptions: %<<<3
        fprintf(fid, '\n    \\item [Descriptions:] \\rule{0em}{0em}\n        \\begin{tightdesc}');
        for j = 1:size(Qlist, 1)
            fprintf(fid, '\n            \\item[\\textsf{%s}] -- %s', Qlist{j,1}, Qlist{j,2});
        end
    fprintf(fid, '\n        \\end{tightdesc}\n    \\end{tightdesc}\n');
    % add list and descriptions of all output quantities: %<<<2
    fprintf(fid, '\\item [Output Quantities:] \\rule{0em}{0em}\n    \\begin{tightdesc}');
    % make a list of output quantities:
    Qlist = [{infos(i).outputs.name}; {infos(i).outputs.desc}]';
    [tmp, ind] = sort(Qlist(:,1));
    ind = ind(:,1);
    Qlist = {Qlist{ind,1}; Qlist{ind,2}}';
    for j = 1:size(Qlist,1);
        fprintf(fid, '\n        \\item[\\textsf{%s}] -- %s', Qlist{j,1}, Qlist{j,2});
    end
    fprintf(fid, '\n    \\end{tightdesc}\n');
    fprintf(fid, '\\end{tightdesc}\n');
    % close the file: %<<<2
    fclose(fid);
end % for all info:

% vim settings modeline: vim: foldmarker=%<<<,%>>> fdm=marker fen ft=octave textwidth=80 tabstop=4 shiftwidth=4
