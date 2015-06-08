function varargout = qwtb(varargin) %<<<1
% QWTB: Q-Wave Toolbox
%   1 input argument: 
%     'get_algs' - finds all available algorithms and returns information
%   3 input argument: 
%     algname - short name of algorithm to use
%     datain - data structure
%     calcset - calculation settings structure

% start of function --------------------------- %<<<1
% check empty inputs:
if nargin == 0
        error('qwtb: missing input arguments')
end

if strcmp(varargin{1}, 'get_algs')  % one parameter input --------------------------- %<<<1
    % check input
    if nargin ~= 1
        error('qwtb: no input arguments expected after keyword `get_algs`')
    end

    % returns all algorithms info
    algs=[];
    % get full path to this script:
    [qwtbdir, tmp, tmp] = fileparts(mfilename('fullpath'));
    % get directory listings:
    lis = dir([qwtbdir filesep() 'alg_*']);
    % get only directories:
    lis = lis([lis.isdir]);
    % for all directories
    for i = 1:size(lis,1)
        % generate full path of current tested algorithm directory:
        algdir = [qwtbdir filesep() lis(i).name];
        isalgdir(algdir)
        if isalgdir(algdir)
            addpath(algdir);
            algs(end+1).info = alg_info();
            algs(end).info.fullpath = algdir;
            rmpath(algdir);
        end
    end
    varargout{1} = algs;
else   % three parameter input --------------------------- %<<<1
    % check input:
    if nargin ~= 3
            error('qwtb: expected three input arguments')
    end
    alg = varargin{1};
    datain = varargin{2};
    calcset = varargin{3};

    % get full path to this script:
    [qwtbdir, tmp, tmp] = fileparts(mfilename('fullpath'));
    algdir = [qwtbdir filesep() 'alg_' alg];
    % check algorithm directory:
    if ~isalgdir(algdir)
            error(['qwtb: algorithm `' alg '` not found'])
    end
    % add wrapper path:
    addpath(algdir);
    % get info structure:
    info = alg_info();
    % check calculation settings structure:
    checkcalcset(calcset);
    % check input data structure:
    mustunc = ~isempty(calcset.unc);
    checkdatain(datain, info, mustunc);

    % all ok, call wrapper:
    % decide calculation mode:
    if isempty(calcset.unc) % no uncertainty, just calculate value: %<<<2
        if calcset.verbose %<<<3
            disp('no uncertainty calculation')
        end %>>>3
        % calculate with specified algorithm:
        dataout = alg_wrapper(datain, calcset);
    elseif ( strcmpi(calcset.unc, 'guf') && not(info.providesGUF) )
        % GUF required and cannot calculate GUF, raise error %<<<2
        error('qwtb: uncertainty calculation by GUF method required, but algorithm does not provide GUF uncertainty calculation')
    elseif ( strcmpi(calcset.unc, 'guf') && info.providesGUF ) || ( strcmpi(calcset.unc, 'mcm') && info.providesMCM )
        if calcset.verbose %<<<3
            disp('uncertainty calculation by means of wrapper/algorithm')
        end %>>>3
        % uncertainty is calculated by algorithm/wrapper: %<<<2
        dataout = alg_wrapper(datain, calcset);
    elseif strcmpi(calcset.unc, 'mcm') % MCM is calculated here: %<<<2
        if calcset.verbose %<<<3
            disp('general mcm uncertainty calculation')
        end %>>>3
        dataout = general_mcm2(info, datain, calcset);
    else
        % unknown settings of calcset.unc or algorithm: %<<<2
        error(['qwtb: unknown settings of calcset.unc: `' calcset.unc '` or algorithm info structure concerning uncertainty calculation'])
    end % if calcset.unc
    % remove algorithm path from path:
    rmpath(algdir);
    varargout{1} = dataout;
end % if - input arguments

end % end qwtb function

function res = isalgdir(algpath) %<<<1
% checks if directory in algpath is directory with algorithm, i.e. path exists
% and contains scripts alg_info and alg_wrapper
% returns boolean

    res = exist(algpath,'dir') == 7;
    res = res && (exist([algpath '/alg_info.m'], 'file') == 2);
    res = res && (exist([algpath '/alg_wrapper.m'], 'file') == 2);

end

function checkdatain(datain, alginfo, mustunc) %<<<1
% checks if input data complies to the qwtb data format and has all variables
% required by algorithm
% raise error in the case of missing fields
% if mustunc = 1, uncertainty components of the quantity must be present

    % get quantities required by algorithm:
    quants = alginfo.requires;

    for i = 1:length(quants)
        % check for quantity:
        if ~(isfield(datain, quants{i}))
                error(['qwtb: quantity `' quants{i} '` required but missing in input data structure'])
        end
        % check for quantity components:
        tmp = datain.(quants{i});
        if ~(isfield(tmp, 'v'))
                error(['qwtb: field `v` missing in quantity `' quants{i} '`'])
        end
        if (~(isfield(tmp, 'u')) && mustunc)
                error(['qwtb: field `u` missing in quantity `' quants{i} '`'])
        end
        if (~(isfield(tmp, 'd')) && mustunc)
                error(['qwtb: field `d` missing in quantity `' quants{i} '`'])
        end
    end
    % 2DO check size of uncertainties for guf and mcm case (compare to calcset.mm.repeats)
    % 2DO check row/column quantities, consistent format of uncertainties
end

function checkcalcset(calcset) %<<<1
% checks if calculation settings complies to the qwtb format
    if ~( isfield(calcset, 'verbose') )
        error('qwtb: field `verbose` is missing in calculation settings structure')
    end
    if ~( isfield(calcset, 'unc') )
        error('qwtb: field `unc` is missing in calculation settings structure')
    end
    if ~( strcmpi(calcset.unc, '') || strcmpi(calcset.unc, 'guf') || strcmpi(calcset.unc, 'mcm') )
        error('qwtb: field `unc` has unknown value')
    end
    if strcmpi(calcset.unc, 'mcm')
        if ~( isfield(calcset.mcm, 'repeats') )
            error('qwtb: field `mcm.repeats` is missing in calculation settings structure')
        end
        if ~( isfield(calcset.mcm, 'verbose') )
            error('qwtb: field `mcm.verbose` is missing in calculation settings structure')
        end
        if ~( isfield(calcset.mcm, 'method') )
            error('qwtb: field `mcm.method` is missing in calculation settings structure')
        end
        tmp = calcset.mcm.method;
        if ~( strcmpi(tmp, 'singlecore') || strcmpi(tmp, 'singlestation') || strcmpi(tmp, 'multistation') )
            error('qwtb: field `mcm.method` in calculation settings has unknown value')
        end
        if strcmpi(calcset.mcm, 'singlestation') || strcmpi(calcset.mcm, 'multistation')
            if ~( isfield(calcset.mcm, 'procno') )
                error('qwtb: field `mcm.procno` is missing in calculation settings structure')
            end
            if ~( isfield(calcset.mcm, 'tmpdir') )
                error('qwtb: field `mcm.tmpdir` is missing in calculation settings structure')
            end
        end % if singlestation of multistation
    end % if mcm
    % 2DO to check:
    % tmpdir existence,
end

% vim settings modeline: vim: foldmarker=%<<<,%>>> fdm=marker fen ft=octave textwidth=80 tabstop=4 shiftwidth=4
