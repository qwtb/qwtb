function result = runmulticore2(method, functionhandle, parametercell, procno, tmpdir, verbose) %<<<1
% RUNMULTICORE2 Calculate functions by parallel processing.
% possible methods are: singlecore, singlestation, multistation
% procno: number of processors to use. If set to 0 or Inf, script will try to
%   determine number of available processors and use all of them
% tmpdir: required only for 'multicore' method, it is temporary directory for
%   signals
% verbose: if nonzero, show status of calculation to the console
% 2DO: finish description

% is this GNU Octave?
isOctave = exist('OCTAVE_VERSION') ~= 0;

% check arguments: --------------------------- %<<<1
% correct number of arguments?
if (nargin < 3 || nargin > 6)
        error('parcalc: incorrect number of arguments')
end
% correct computing method?
% correct values:
correctmatlab = {'for', 'parfor', 'cellfun',               'multicore'};
correctoctave = {'for',           'cellfun', 'parcellfun', 'multicore'};
if isOctave 
    if isempty(find(strcmpi(correctoctave, method)))
        error(['unknown parralel computing method `' method '` for GNU Octave language']);
    end
else
    if isempty(find(strcmpi(correctmatlab, method)))
        error(['unknown parralel computing method `' method '` for Matlab language']);
    end
end

% 2DO check for existing tmpdir in the case of multicore

% verbose level specified?
if (nargin < 6)
        verbose = 0;
end
% temporary directory specified?
if (nargin < 5)
        tmpdir = tempdir;
end
% number of processes specified?
if (nargin < 4)
        procno = inf;
end

% determine number of processes: --------------------------- %<<<1
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

% calculate task: --------------------------- %<<<1

% for: --------------------------- %<<<2

% parfor: --------------------------- %<<<2

% cellfun: --------------------------- %<<<2
if strcmpi(method, 'cellfun')
    % use non parallel computing by means of cellfun:
    result = cellfun(functionhandle, parametercell);
    % convert resulted struct to cell (because input is cell):
    resulttmp = cell(size(parametercell));
    for i=1:size(result,2)
            resulttmp{i}=result(i);
    end
    result = resulttmp;

% parcellfun: --------------------------- %<<<2
elseif strcmpi(method, 'parcellfun')
    % use package general and function parcellfun by J.Hajek:
    result = parcellfun(procno, functionhandle, parametercell, 'VerboseLevel', verbose);
    % convert resulted struct to cell (because input is cell):
    resulttmp = cell(size(parametercell));
    for i = 1:size(result,2)
            resulttmp{i} = result(i);
    end
    result = resulttmp;

% multicore --------------------------- %<<<2
elseif strcmpi(method, 'multicore')
    % XXX 2DO - add sources and check function
    result = {};
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
else
    error(['unknown parralel computing method `' method '`']);
end

% end function
end

% vim settings modeline: vim: foldmarker=%<<<,%>>> fdm=marker fen ft=octave textwidth=80 tabstop=4 shiftwidth=4
