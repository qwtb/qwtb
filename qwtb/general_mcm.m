function dataout = general_mcm(info, datain, calcset) %<<<1
% mcm_GENERAL Part of QWWTB. Calculates uncertainty of algorithm in path by
% means of mcm. Suppose quantities are already randomized.
% 2DO: finish description

%% check arguments: --------------------------- %<<<1
%% correct number of arguments?
%if (nargin < 3 || nargin > 6)
%        error('parcalc: incorrect number of arguments')
%end
%% correct computing method?
%% correct values:
%correctmatlab = {'for', 'parfor', 'cellfun',               'multicore'};
%correctoctave = {'for',           'cellfun', 'parcellfun', 'multicore'};
%if isOctave 
%    if isempty(find(strcmpi(correctoctave, method)))
%        error(['unknown parralel computing method `' method '` for GNU Octave language']);
%    end
%else
%    if isempty(find(strcmpi(correctmatlab, method)))
%        error(['unknown parralel computing method `' method '` for Matlab language']);
%    end
%end
%
%% 2DO check for existing tmpdir in the case of multicore

% set values: --------------------------- %<<<1
% is this GNU Octave?
isOctave = exist('OCTAVE_VERSION') ~= 0;

verbose = calcset.mcm.verbose;
tmpdir = calcset.mcm.tmpdir;
procno = calcset.mcm.procno;
method = calcset.mcm.method;
M = calcset.mcm.repeats;

% Values from nonrandomized data --------------------------- %<<<1
% get value from original (nonrandomized) data:
% (this will be result.Q.v, i.e. different from mean(Q.u), uncertainty
% calculation in wrapper is suppressed)
% (it also checks valid calculation before starting time consuming MCM)
wcalcset = calcset;
wcalcset.unc = 'none';
nonrnddataout = alg_wrapper(datain, wcalcset);

% Randomization --------------------------- %<<<1
% XXX 2DO randomize in loop or here?
if calcset.mcm.verbose %<<<3
    tic
end %>>>3
datain = mcm_randomize(info, datain, calcset);
if calcset.mcm.verbose %<<<3
    disp('randomization done')
    toc
end %>>>3
% MCM calculation:

% calculate task: --------------------------- %<<<1
% possible methods are: singlecore, singlestation, multistation
if strcmpi(method, 'singlecore') % single core code --------------------------- %<<<2
    % this is very crude, inefficient but general method
    if verbose %<<<3
        disp('single core mcm calculation')
    end %>>>3

    % set calculation settings for wrapper to NO uncertainty:
    wcalcset = calcset;
    wcalcset.unc = 'none';

    % list of input quantities:
    quantsin = info.requires;
    % list of output quantities:
    quantsout = info.returns;
    % for loop of mcm:
    for i = 1:M
        if verbose %<<<3
            if ~mod(i, 1e4)
                disp(['MCM iteration ' num2str(i)])
            end
        end %>>>3
        % randomized uncertainty -> input value:
        for j = 1:length(quantsin)
            tmpdatain.(quantsin{j}).v = datain.(quantsin{j}).u(i, :);
        end
        % call wrapper:
        tmp = alg_wrapper(tmpdatain, wcalcset);
        % result value -> output uncertainty:
        for j = 1:length(quantsout)
            dataout.(quantsout{j}).u(i, :) = tmp.(quantsout{j}).v;
        end
    end % for i, mcm loop
else
    error('2DO')
    % determine number of processes: --------------------------- %<<<2
    if ( procno==inf || procno<1 )
        % detect number of cpus:
        % correctly should be: (doesn't work in octave 3.2):
        %cpus=nproc
        % else use following:
        if isunix
                % unix os:
                pid = fopen('/proc/cpuinfo'); 
                procno = length(strfind(char(fread(pid)'),'processor')); 
                fclose(pid);
        else 
                % expecting windows:
                [status output]=system('echo %number_of_processors%'); 
                procno=str2num(output);
        end
    end
    if ~strcmpi(method, 'multistation')
        if isOctave % octave single station code --------------------------- %<<<2
            % 2DO prepare data to cells
            %% convert resulted struct to cell (because input is cell):
            %resulttmp = cell(size(parametercell));
            %for i=1:size(result,2)
            %        resulttmp{i}=result(i);
            %end
            %result = resulttmp;
            %f = @(datain)alg_wrapper(datain, calcset)
            % use package general and function parcellfun by J.Hajek:
            %result = parcellfun(procno, f, paramcell, 'VerboseLevel', verbose);
            % convert resulted struct to cell (because input is cell):
            %resulttmp = cell(size(parametercell));
            %for i = 1:size(result,2)
            %        resulttmp{i} = result(i);
            %end
            %result = resulttmp;
            error('2DO')
        else % matlab single station code --------------------------- %<<<2
            % % identical (but parfor) to single core code - how to unite?
            % % set calculation settings for wrapper to NO uncertainty:
            % wcalcset = calcset;
            % wcalcset.unc = 'none';

            % % list of input quantities:
            % quantsin = info.requires;
            % % list of output quantities:
            % quantsout = info.returns;
            % % for loop of mcm:
            % parfor i = 1:M
            %     if verbose %<<<3
            %         if ~mod(i, 1e4)
            %             disp(['MCM iteration ' num2str(i)])
            %         end
            %     end %>>>3
            %     % randomized uncertainty -> input value:
            %     for j = 1:length(quantsin)
            %         tmpdatain.(quantsin{j}).v = datain.(quantsin{j}).u(i, :);
            %     end
            %     % call wrapper:
            %     tmp = alg_wrapper(tmpdatain, wcalcset);
            %     % result value -> output uncertainty:
            %     for j = 1:length(quantsout)
            %         dataout.(quantsout{j}).u(i, :) = tmp.(quantsout{j}).v;
            %     end
            % end % parfor i, mcm loop
            %         % Matlab code
            %         % parfor
            error('2DO')
        end % if isOctave
    else % multi station code: --------------------------- %<<<2
        % XXX 2DO - add sources and check function
        %result = {};
        %% use package multicore and function startmulticoremaster by Markus Buehren
        %% run slave processess:
        %fidIn=[];
        %fidOut=[];
        %fidPid=[];
        %for i=1:procno-1
        %    [curfidIn, curfidOut, curfidPid] = popen2 ('octave', '-q');
        %    fidIn=[fidIn curfidIn];
        %    fidOut=[fidOut curfidOut];
        %    fidPid=[fidPid curfidPid];
        %    input_str = ['startmulticoreslave(''',tmpdir,''');'];
        %    fputs (fidIn, input_str);
        %    fputs (fidIn, sprintf('\n'));
        %end
        %result = startmulticoremaster(functionhandle, parametercell, tmpdir, inf);

        %% Close the secondary process
        %% should be used: 
        %% correctly should be: (doesn't work in octave 3.2):
        %%pclose(fidPid(i))
        %% else use following (leave zombies):
        %for i=1:procno-1
        %    fclose(fidIn(i));
        %    fclose(fidOut(i));
        %    [err, msg] = kill (fidPid(i), 9);
        %end
        error('2DO')
    end
end % if singlecore

quants = info.returns;
% unite nonrandomized data and MCM calculation:
% (quantity values from nonrandomized calculation):
for i=1:length(quants)
    dataout.(quants{i}).v = nonrnddataout.(quants{i}).v;
end

end % end function

function datain2 = mcm_randomize(alginfo, datain, calcset) %<<<1
% randomizes datain structure for MCM

    % list of quantities required by algorithm:
    quants = alginfo.requires;
    M = calcset.mcm.repeats;

    for i = 1:length(quants)
        % randomize for all quantities:
        tmp = datain.(quants{i});
        if length(tmp.v) == 1
            % randomizovat jen kdyz neni randomizovane, a to by mel
            % resit nejaky kontrolor nejistot v datain
            % XXX
            tmp.u = normrnd(tmp.v, tmp.u, [M 1]);
        else
            tmpu = tmp.u;
            tmp.u = zeros(M, length(tmp.v));
            for j = 1:length(tmp.v)
                % 2DO too slow, mvnrnd has to be used
                % 2DO, other distributions
                tmp.u(:,j) = normrnd(tmp.v(j), tmpu(j), [M 1]);
            end
        end
        datain2.(quants{i}) = tmp;
    end % for i
end

% vim settings modeline: vim: foldmarker=%<<<,%>>> fdm=marker fen ft=octave textwidth=80 tabstop=4 shiftwidth=4
