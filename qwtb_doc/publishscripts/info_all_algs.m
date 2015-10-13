%% script makes latex file for all algorithms info

clear all

% path to qwtb:
addpath('../../qwtb');

infos = qwtb();

for i = 1:length(infos)
    disp(['algorithm ' infos(i).id]);
    fid = fopen(['../alg_examples_published/info_' infos(i).id '.tex'], 'w')
    fprintf(fid, '\\begin{tightdesc}\n');
    fprintf(fid, '\\item [\\textsf{.id}] --- %s\n', infos(i).id);
    fprintf(fid, '\\item [\\textsf{.name}] --- %s\n', infos(i).name);
    fprintf(fid, '\\item [\\textsf{.desc}] --- %s\n', infos(i).desc);
    tmp = infos(i).citation;
    % match urls:
    [S, E, TE, M, T, NM, SP] = regexp (tmp, 'http://\S+');
    if ~isempty(M)
        disp('not empty')
        for j = 1:length(M)
            tmp = [SP{j, 1} '\url{' strrep(M{1},'&','\&') '}' SP{j, 2}];
        end
    end
    fprintf(fid, '\\item [\\textsf{.citation}] --- %s\n', tmp);
    fprintf(fid, '\\item [\\textsf{.remarks}] --- %s\n', infos(i).remarks);
    fprintf(fid, '\\item [\\textsf{.license}] --- %s\n', infos(i).license);
    fprintf(fid, '\\item [\\textsf{.requires}] \\rule{0em}{0em}\n');
        fprintf(fid, '\\begin{tightdesc}\n');
        for j = 1:length(infos(i).requires)
            fprintf(fid, '\\item [\\textsf{%s}] --- %s\n', infos(i).requires{j}, infos(i).reqdesc{j});
        end
        fprintf(fid, '\\end{tightdesc}\n');
    fprintf(fid, '\\item [\\textsf{.returns}] \\rule{0em}{0em}\n');
        fprintf(fid, '\\begin{tightdesc}\n');
        for j = 1:length(infos(i).returns)
            fprintf(fid, '\\item [\\textsf{%s}] --- %s\n', infos(i).returns{j}, infos(i).retdesc{j});
        end
        fprintf(fid, '\\end{tightdesc}\n');
    if infos(i).providesGUF
        tmp = 'yes';
    else
        tmp = 'no';
    end
    fprintf(fid, '\\item [\\textsf{.providesGUF}] --- %s\n', tmp);
    if infos(i).providesMCM
        tmp = 'yes';
    else
        tmp = 'no';
    end
    fprintf(fid, '\\item [\\textsf{.providesMCM}] ---  %s\n', tmp);
    fprintf(fid, '\\end{tightdesc}\n');
    fclose(fid);
end


% vim settings modeline: vim: foldmarker=%<<<,%>>> fdm=marker fen ft=octave textwidth=80 tabstop=4 shiftwidth=4
