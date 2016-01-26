function varargout = qwtb(varargin) 
% QWTB: Q-Wave Toolbox for data processing algorithms
%   alginfo = QWTB()
%       Gives informations on available algorithms.
%   dataout = QWTB('algid', datain, [calcset])
%       Apply algorithm with id `algid` to input data `datain` with calculation
%       settings `calcset`.
%   [] = QWTB('algid', 'example')
%       Runs example associated with algorithm 'algid'.
%   [] = QWTB('algid', 'test')
%       Runs test associated with algorithm 'algid'.
%   [] = QWTB('algid', 'addpath')
%   [] = QWTB('algid', 'rempath')
%       Add or remove algorithm path to a load path.
%   [license] = QWTB('algid', 'license')
%       Returns license of the algorithm.

% Copyright (c) 2015 by Martin Šíra

% 2DO rem all qwtb paths, add own, restore paths?
% 2DO what if path to alg_ already exist!?

    % start of qwtb function --------------------------- %<<<1
    % remove old alg_paths because if previous instance of qwtb ends with error,
    % it could left some alg directory in the path
    path_rem_all_algdirs();
    % check inputs:
    if nargin == 0
        % returns all algorithms info
        varargout{1} = get_all_alg_info();

    elseif nargin == 1 || nargin > 3
        error('QWTB: incorrect number of input arguments')

    else
        algid = varargin{1};
        % check second argument for control string:
        if ischar(varargin{2});
            if strcmpi(varargin{2}, 'test')
                % run test of the algorithm
                run_alg_test(algid);
            elseif strcmpi(varargin{2}, 'example')
                % run example of the algorithm in user space
                run_alg_example(algid);
            elseif strcmpi(varargin{2}, 'addpath')
                % add algorithm path to path()
                path_add_algdir(algid);
            elseif strcmpi(varargin{2}, 'rempath')
                % remove algorithm path from path()
                path_rem_algdir(algid);
            elseif strcmpi(varargin{2}, 'info')
                % returns info on the algorithm
                varargout{1} = get_one_alg_info(algid);
            elseif strcmpi(varargin{2}, 'license')
                % show license of the algorithm
                varargout{1} = show_license(algid);
            else
                % unknown qwtb call
                error('QWTB: second argument must be either `test`, `example`, `doc` or structure with input data');
            end % if strcmpi
        else
        % second argument is considered as input data:
            datain = varargin{2};
            if nargin == 2
                % calculation settings is missing, generate a standard one:
                calcset = get_standard_calcset();
            else
                calcset = varargin{3};
            end

            % process data:
            [dataout, calcset] = check_and_run_alg(algid, datain, calcset);
            varargout{1} = dataout;
            varargout{2} = datain;
            varargout{3} = calcset;
        end % if ischar
    end % if - input arguments

end % end qwtb function

% -------------------------------- path related functions %<<<1
function pth = qwtbdirpath() %<<<1
% returns full path to the directory with qwtb script
    % get full path to this (qwtb.m) script:
    pth = fileparts(mfilename('fullpath'));

end % function qwtbdirpath

function pth = algpath(algid) %<<<1
% returns full path to the algorithm directory
    pth = [qwtbdirpath filesep() 'alg_' algid];
end % function algpath

function alginfo = get_all_alg_info() %<<<1
% checks for directories with algorithms and returns info on all available
% algorithms

    % get directory listings:
    lis = dir([qwtbdirpath filesep() 'alg_*']);
    % get only directories:
    lis = lis([lis.isdir]);
    % prepare found algorithm counter:
    algcnt = 1;
    % for all directories
    for i = 1:size(lis,1)
        % generate full path of current tested algorithm directory:
        algdir = [qwtbdirpath filesep() lis(i).name];
        if is_alg_dir(algdir)
            addpath(algdir);
            tmp = alg_info();
            tmp.fullpath = algdir;
            msg = check_alginfo(tmp);
            if isempty(msg)
                alginfo(algcnt) = tmp;
                algcnt = algcnt + 1;
            else
                warning(['QWTB: algorithm info returned by alg_info.m in `' algdir '` has incorrect format and is excluded from results'])
                disp(msg)
            end % if check_alginfo
            rmpath(algdir);
        end
    end
end % function get_all_alg_info

function res = get_one_alg_info(algid) %<<<1
% return info structure of one algorithm
        path_add_algdir(algid);
        tmp = alg_info();
        tmp.fullpath = algpath(algid);
        msg = check_alginfo(tmp);
        if isempty(msg)
            res = tmp;
        else
            warning(['QWTB: algorithm info returned by alg_info.m in `' algdir '` has incorrect format'])
            disp(msg)
        end % if check_alginfo
        path_rem_algdir(algid);
end % function get_one_alg_info


function res = is_alg_dir(pth) %<<<1
% checks if directory in pth is directory with algorithm, i.e. path exists
% and contains scripts alg_info and alg_wrapper
% returns boolean

    res = exist(pth,'dir') == 7;
    res = res && (exist([pth '/alg_info.m'], 'file') == 2);
    res = res && (exist([pth '/alg_wrapper.m'], 'file') == 2);

end % function is_alg_dir

function path_add_algdir(algid) %<<<1
% checks and adds path of algorithm to load path
    % check directory is algorithm directory:
    if ~is_alg_dir(algpath(algid))
            error(['QWTB: algorithm `' algid '` not found'])
    end
    % add wrapper to a load path:
    addpath(algpath(algid));
end % path_add_algdir

function path_rem_algdir(algid) %<<<1
% removes path of algorithm from load path
    % get full path to this (qwtb.m) script:
    algdir = algpath(algid);
    % pathsep is added because algdir could be only part of name of other
    % algdir, and path returns path without pathsep at the end, thus if algdir
    % would be last path, it would not be found
    if ~isempty(strfind([path pathsep], [algdir pathsep]))
        rmpath(algdir);
    end
end % path_rem_algdir

function path_rem_all_algdirs() %<<<1
% removes all alg directories from paths. if qwtb ends with error, it could left
% some alg directory in the path

    % get directory listings:
    lis = dir([qwtbdirpath filesep() 'alg_*']);
    % get only directories:
    lis = lis([lis.isdir]);
    % for all directories
    for i = 1:size(lis,1)
        % generate full path of current tested algorithm directory:
        algdir = [qwtbdirpath filesep() lis(i).name];
        if is_alg_dir(algdir)
            % pathsep is added because algdir could be only part of name of other
            % algdir, and path returns path without pathsep at the end, thus if algdir
            % would be last path, it would not be found
            if ~isempty(strfind([path pathsep], [algdir pathsep]))
                rmpath(algdir)
            end
        end % if is alg dir
    end % for all dirs
end % path_rem_all_algdirs


% -------------------------------- algorithm related functions %<<<1
function [dataout, calcset] = check_and_run_alg(algid, datain, calcset) %<<<1
% checks data, settings and calls wrapper

    dataout = [];
    path_add_algdir(algid);
    % get info structure:
    alginfo = alg_info();
    % check calculation settings structure:
    calcset = check_gen_calcset(calcset);
    % check input data structure:
    datain = check_gen_datain(alginfo, datain, calcset);

    % all ok, call wrapper:
    % decide calculation mode:
    if strcmpi(calcset.unc, 'none') % no uncertainty, just calculate value: %<<<2
        if calcset.verbose
            disp('QWTB: no uncertainty calculation')
        end
        % calculate with specified algorithm:
        dataout = alg_wrapper(datain, calcset);
    elseif ( strcmpi(calcset.unc, 'guf') && not(alginfo.providesGUF) )
        % GUF required and cannot calculate GUF, raise error:
        error('QWTB: uncertainty calculation by GUF method required, but algorithm does not provide GUF uncertainty calculation')
    elseif ( strcmpi(calcset.unc, 'guf') && alginfo.providesGUF ) || ( strcmpi(calcset.unc, 'mcm') && alginfo.providesMCM )
        % uncertainty is calculated by algorithm or wrapper:
        if calcset.verbose
            disp('QWTB: uncertainty calculation by means of wrapper or algorithm')
        end
        dataout = alg_wrapper(datain, calcset);
    elseif strcmpi(calcset.unc, 'mcm') % MCM is calculated by general method: %<<<2
        if calcset.verbose 
            disp('QWTB: general mcm uncertainty calculation')
        end
        dataout = general_mcm(alginfo, datain, calcset);
    else
        % unknown settings of calcset.unc or algorithm:
        error(['QWTB: unknown settings of calcset.unc: `' calcset.unc '` or algorithm info structure concerning uncertainty calculation'])
    end % if calcset.unc
    % remove algorithm path from path:
    path_rem_algdir(algid);
end % function check_and_run_alg

function run_alg_test(algid) %<<<1
    path_add_algdir(algid);
    if ~exist('alg_test.m','file')
        disp(['QWTB: self test of algorithm `' algid '` is not implemented']);
    else
        calcset = get_standard_calcset();
        calcset.verbose = 0;
        calcset.mcm.verbose = 0;
        alg_test(calcset);
    end % if exist
    path_rem_algdir(algid);
end % run_alg_test

function run_alg_example(algid) %<<<1
    path_add_algdir(algid);
    if ~exist('alg_example.m','file')
        disp(['QWTB: example of algorithm `' algid '` is not implemented']);
    else
        calcset = get_standard_calcset();
        % run example script in base workspace so user can operate with datain,
        % dataout and calcset:
        disp(['For description of example, please take a look at script `alg_' algid filesep 'alg_example.m`.']);
        disp('Take a look at data input structure `DI`, output data structure `DO` and optionally at calculation settings structure `CS`.')
        evalin('base', 'alg_example');
    end
    path_rem_algdir(algid);
end % run_alg_example function

function [license]= show_license(algid) %<<<1
% Display license of specified algorithm.
    % construct path to the license file:
    licfilpath = [algpath(algid) filesep 'LICENSE.txt'];
    % test for license file:
    if ~exist(licfilpath, 'file')
        error(['QWTB: license file `' licfilpath '` for algorithm `' algid '` does not exist!'])
    else
        license = fileread(licfilpath);
    end
end % show_license function

function msg = check_alginfo(alginfo) %<<<1
% returns empty string if algorithm info structure complies to the qwtb format,
% else returns description of what is wrong

    if ~(length(fieldnames(alginfo)) == 13)
        msg = 'some fields are missing or redundant';
    elseif ~isfield(alginfo, 'id');
        msg = 'missing field `id`';
    elseif ~ischar(alginfo.id);
        msg = 'field `id` is not char type';
    elseif ~isfield(alginfo, 'name');
        msg = 'missing field `name`';
    elseif ~ischar(alginfo.name);
        msg = 'field `name` is not char type';
    elseif ~isfield(alginfo, 'desc');
        msg = 'missing field `desc`';
    elseif ~ischar(alginfo.desc);
        msg = 'field `desc` is not char type';
    elseif ~isfield(alginfo, 'citation');
        msg = 'missing field `citation`';
    elseif ~ischar(alginfo.citation);
        msg = 'field `citation` is not char type';
    elseif ~isfield(alginfo, 'remarks');
        msg = 'missing field `remarks`';
    elseif ~ischar(alginfo.remarks);
        msg = 'field `remarks` is not char type';
    elseif ~isfield(alginfo, 'license');
        msg = 'missing field `license`';
    elseif ~ischar(alginfo.license);
        msg = 'field `license` is not char type';
    elseif ~isfield(alginfo, 'requires');
        msg = 'missing field `requires`';
    elseif ~iscellstr(alginfo.requires);
        msg = 'field `requires` is not a cell of strings';
    elseif ~isfield(alginfo, 'reqdesc');
        msg = 'missing field `reqdesc`';
    elseif ~iscellstr(alginfo.reqdesc);
        msg = 'field `reqdesc` is not a cell of strings';
    elseif ~isequal(size(alginfo.requires), size(alginfo.reqdesc));
        msg = 'fields `requires` and `reqdesc` has different dimensions';
    elseif ~isfield(alginfo, 'returns');
        msg = 'missing field `returns`';
    elseif ~iscellstr(alginfo.returns);
        msg = 'field `returns` is not a cell of strings';
    elseif ~isfield(alginfo, 'retdesc');
        msg = 'missing field `retdesc`';
    elseif ~iscellstr(alginfo.retdesc);
        msg = 'field `retdesc` is not a cell of strings';
    elseif ~isequal(size(alginfo.returns), size(alginfo.retdesc));
        msg = 'fields `returns` and `retdesc` has different dimensions';
    elseif ~isfield(alginfo, 'providesGUF');
        msg = 'missing field `providesGUF`';
    elseif ~isfield(alginfo, 'providesMCM');
        msg = 'missing field `providesMCM`';
    elseif ~isfield(alginfo, 'fullpath');
        msg = 'missing field `fullpath`';
    elseif ~ischar(alginfo.fullpath);
        msg = 'field `fullpath` is not char type';
    else
        msg = '';
    end
end % function check_alginfo

% -------------------------------- structures related functions %<<<1
function calcset = get_standard_calcset() %<<<1
% creates a standard calculation settings
    calcset.strict = 0;
    calcset.verbose = 1;
    calcset.unc = 'none';
    calcset.cor.req = 1;
    calcset.cor.gen = 1;
    calcset.dof.req = 1;
    calcset.dof.gen = 1;
    calcset.mcm.repeats = 100;
    calcset.mcm.verbose = 1;
    calcset.mcm.method = 'singlecore';
    calcset.mcm.procno = 0;
    calcset.mcm.tmpdir = '.';
    calcset.mcm.randomize = 1;
end % function get_standard_calcset

function calcset = check_gen_calcset(calcset) %<<<1
% Checks if calculation settings complies to the qwtb format. If .strict is set
% to 0, missing fields are generated. Boolean values are reformatted to 0/1.

    % strict %<<<2
    if ~( isfield(calcset, 'strict') )
        calcset.strict = 0;
    end
    % verbose %<<<2
    if ~( isfield(calcset, 'verbose') )
        if calcset.strict
            error('QWTB: field `verbose` is missing in calculation settings structure')
        else
            calcset.verbose = 1;
        end
    end
    if calcset.verbose
        calcset.verbose = 1;
    else 
        calcset.verbose = 0;
    end
    % unc %<<<2
    if ~( isfield(calcset, 'unc') )
        if calcset.strict
            error('QWTB: field `unc` is missing in calculation settings structure')
        else
            calcset.unc = 'none';
        end
    end
    if ~( strcmpi(calcset.unc, 'none') || strcmpi(calcset.unc, 'guf') || strcmpi(calcset.unc, 'mcm') )
        error('QWTB: field `unc` has unknown value. Only `none`, `guf` and `mcm` are permitted.')
    end
    % cor %<<<2
    if ~( isfield(calcset, 'cor') )
        if calcset.strict
            error('QWTB: field `cor` is missing in calculation settings structure')
        else
            calcset.cor.req = 1;
            calcset.cor.gen = 1;
        end
    end
    % cor.req %<<<2
    if ~( isfield(calcset.cor, 'req') )
        if calcset.strict
            error('QWTB: field `cor.req` is missing in calculation settings structure')
        else
            calcset.cor.req = 1;
        end
    end
    if calcset.cor.req
        calcset.cor.req = 1;
    else
        calcset.cor.req = 0;
    end
    % cor.gen %<<<2
    if ~( isfield(calcset.cor, 'gen') )
        if calcset.strict
            error('QWTB: field `cor.gen` is missing in calculation settings structure')
        else
            calcset.cor.gen = 1;
        end
    end
    if calcset.cor.gen
        calcset.cor.gen = 1;
    else
        calcset.cor.gen = 0;
    end
    if ~( isfield(calcset, 'dof') )
        if calcset.strict
            error('QWTB: field `dof` is missing in calculation settings structure')
        else
            calcset.dof.req = 1;
            calcset.dof.gen = 1;
        end
    end
    % dof.req %<<<2
    if ~( isfield(calcset.dof, 'req') )
        if calcset.strict
            error('QWTB: field `dof.req` is missing in calculation settings structure')
        else
            calcset.dof.req = 1;
        end
    end
    if calcset.dof.req
        calcset.dof.req = 1;
    else
        calcset.dof.req = 0;
    end
    % dof.gen %<<<2
    if ~( isfield(calcset.dof, 'gen') )
        if calcset.strict
            error('QWTB: field `dof.gen` is missing in calculation settings structure')
        else
            calcset.dof.gen = 1;
        end
    end
    if calcset.dof.gen
        calcset.dof.gen = 1;
    else
        calcset.dof.gen = 0;
    end
    % mcm %<<<2
    if ~( isfield(calcset, 'mcm') )
        if calcset.strict
            error('QWTB: field `mcm` is missing in calculation settings structure')
        else
            calcset.mcm.repeats = 100;
            calcset.mcm.verbose = 1;
            calcset.mcm.method = 'singlecore';
            calcset.mcm.procno = 0;
            calcset.mcm.tmpdir = '.';
            calcset.mcm.randomize = 1;
        end
    end
    % mcm.repeats %<<<2
    if ~( isfield(calcset.mcm, 'repeats') )
        if calcset.strict
            error('QWTB: field `mcm.repeats` is missing in calculation settings structure')
        else
            calcset.mcm.repeats = 100;
        end
    end
    tmp = calcset.mcm.repeats;
    if ~(isscalarP(tmp) && tmp > 0 && abs(fix(tmp)) == tmp)
        error('QWTB: field `calcset.mcm.repeats` must be scalar positive non-zero integer!')
    end
    % mcm.verbose %<<<2
    if ~( isfield(calcset.mcm, 'verbose') )
        if calcset.strict
            error('QWTB: field `mcm.verbose` is missing in calculation settings structure')
        else
            calcset.mcm.verbose = 1;
        end
    end
    if calcset.mcm.verbose
        calcset.mcm.verbose = 1;
    else
        calcset.mcm.verbose = 0;
    end
    % mcm.method %<<<2
    if ~( isfield(calcset.mcm, 'method') )
        if calcset.strict
            error('QWTB: field `mcm.method` is missing in calculation settings structure')
        else
            calcset.mcm.method = 'singlecore';
        end
    end
    tmp = calcset.mcm.method;
    if ~( strcmpi(tmp, 'singlecore') || strcmpi(tmp, 'multicore') || strcmpi(tmp, 'multistation') )
        error('QWTB: field `mcm.method` in calculation settings has unknown value. Only values `singlecore`, `multicore` or `multistation` are permitted.')
    end
    % mcm.procno %<<<2
    if ~( isfield(calcset.mcm, 'procno') )
        if calcset.strict
            error('QWTB: field `mcm.procno` is missing in calculation settings structure')
        else
            calcset.mcm.procno = 0;
        end
    end
    tmp = calcset.mcm.procno;
    if ~(isscalarP(tmp) && abs(fix(tmp)) == tmp)
        error('QWTB: field `calcset.mcm.procno` must be scalar zero or positive integer!')
    end
    % mcm.tmpdir %<<<2
    if ~( isfield(calcset.mcm, 'tmpdir') )
        if calcset.strict
            error('QWTB: field `mcm.tmpdir` is missing in calculation settings structure')
        else
            calcset.mcm.tmpdir = '.';
        end
    end
    if ~( ischar(calcset.mcm.tmpdir) )
        error('QWTB: field `mcm.tmpdir` must be a string')
    end
    if ~( exist(calcset.mcm.tmpdir, 'dir') )
        error(['QWTB: directory ' calcset.mcm.tmpdir ' does not exist'])
    end
    % mcm.randomize %<<<2
    if ~( isfield(calcset.mcm, 'randomize') )
        if calcset.strict
            error('QWTB: field `mcm.randomize` is missing in calculation settings structure')
        else
            calcset.mcm.randomize = 1;
        end
    end
    if calcset.mcm.randomize
        calcset.mcm.randomize = 1;
    else
        calcset.mcm.randomize = 0;
    end
end % function check_calcset

function datain = check_gen_datain(alginfo, datain, calcset) %<<<1
% Checks if input data complies to the qwtb data format and has all variables
% required by algorithm. Raises error in the case of missing fields. Fields Q.d
% and Q.c are generated if permitted and required.

    for i = 1:length(alginfo.requires)
        Qname = alginfo.requires{i};
        % check for quantity: %<<<2
        if ~(isfield(datain, Qname))
                error(['QWTB: quantity `' Qname '` required but missing in input data structure. Quantity description is: `' alginfo.reqdesc{i} '`'])
        end

        % check for quantity components: %<<<2
        Q = datain.(Qname);
        % Q.v: %<<<3
        if ~(isfield(Q, 'v'))
                error(['QWTB: field `v` missing in quantity `' Qname '`'])
        end
        % Q.u: %<<<3
        if ~(isfield(Q, 'u'))
            if ~( strcmpi(calcset.unc, 'none') )
                    error(['QWTB: field `u` missing in quantity `' Qname '` and uncertainty calculation required'])
            else
                % generate empty field:
                datain.(Qname).u = [];
                Q = datain.(Qname);
            end
        end % is Q.u
        % Q.d: %<<<3
        if ~(isfield(Q, 'd'))
            if ( strcmpi(calcset.unc, 'guf') && calcset.dof.req )
                % if guf uncertainty calculation and dof is required
                if calcset.dof.gen
                    % degrees of freedom generated automatically
                    if calcset.verbose
                        disp(['QWTB: default degrees of freedom generated for quantity `' Qname '`'])
                    end
                    datain.(Qname).d = 50.*ones(size(datain.(Qname).v));
                    Q = datain.(Qname);
                else
                    error(['QWTB: field `d` missing in quantity `' Qname '`, automatic generation disabled but guf uncertainty calculation required'])
                end % if dof.gen
            else
                % generate empty field:
                datain.(Qname).d = [];
                Q = datain.(Qname);
            end % if guf & dof.req
        end % if Q.d
        % Q.c: %<<<3
        if ~(isfield(Q, 'c'))
            if ( ~strcmpi(calcset.unc, 'none') && calcset.cor.req )
                % if uncertainty calculation and correlation required
                if calcset.cor.gen
                    % correlation matrix generated automatically
                    if calcset.verbose
                        disp(['QWTB: default correlation matrix generated for quantity `' Qname '`'])
                    end
                    datain.(Qname).c = zeros(length(Q.v), length(Q.v));
                    Q = datain.(Qname);
                    % XXX previous line do not work for matrix Q!, this only works
                    % for scalar and vector!!!
                else
                    error(['QWTB: field `c` missing in quantity `' Qname '`, automatic generation disabled but uncertainty calculation required'])
                end
            else
                % generate empty field:
                datain.(Qname).c = [];
                Q = datain.(Qname);
            end % if unc & cor.req
        end % if Q.c
        % Q.r: %<<<3
        if ~( isfield(Q, 'r') )
            if strcmpi(calcset.unc, 'mcm')
                if ~( calcset.mcm.randomize )
                    error(['QWTB: field `r` missing in quantity `' Qname '` and mcm is required but automatic randomization is disabled'])
                else
                    % randomize quantity:
                    datain.(Qname).r = rand_quant(Q, calcset.mcm.repeats);
                    Q = datain.(Qname);
                    if calcset.verbose
                        disp(['QWTB: quantity ' Qname ' was randomized by QWTB']);
                    end
                end % if randomize
            else
                % generate empty field:
                datain.(Qname).r = [];
                Q = datain.(Qname);
            end % if mcm
        end % if Q.r

        % check components sizes: %<<<2
        Sv = size(Q.v);
        Su = size(Q.u);
        Sc = size(Q.c);
        Sd = size(Q.d);
        Sr = size(Q.r);

        % Q.v: %<<<3
        % if value is vector, should be row vector:
        if isvectorP(Q.v)
            if ( Sv(1) ~= 1 )
                error(['QWTB: vector quantity `' Qname '` is not row vector.'])
            end
        end

        % Q.u: %<<<3
        if ~( strcmpi(calcset.unc, 'none') )
            % dimensions must fully match Qname.v
            if ~isequal(Sv, Su)
                error(['QWTB: uncertainty matrix of quantity `' Qname '` has incorrect dimensions'])
            end
        end

        % Q.d: %<<<3
        if strcmpi(calcset.unc, 'guf') 
            if calcset.dof.req
                % dimensions must fully match Qname.v
                if ~isequal(Sv, Sd)
                    error(['QWTB: dimensions of degrees of freedom matrix do not match dimensions of value matrix in quantity `' Qname '`'])
                end
            end % if dof.req
        end % if guf

        % Q.c: %<<<3
        if (strcmpi(calcset.unc, 'guf') || strcmpi(calcset.unc, 'mcm') )
            if calcset.cor.req
                % XXX how?
                ok = 1;
                if isscalarP(Q.v)
                    if ~isequal(Sv, Sc)
                        ok = 0;
                    end
                elseif isvectorP(Q.v)
                    if ~( Sv(2) == Sc(2) && Sv(2) == Sc(1) )
                        ok = 0;
                    end
                elseif ismatrixP(Q.v)
                    % XXX 2DO how?
                else
                    error(['QWTB: quantity `' Qname '` has too many dimensions']);
                end % if scalar/vector/matrix
                if ~(ok)
                    error(['QWTB: correlation matrix of quantity `' Qname '` has incorrect dimensions'])
                end
            end % if cor.req
        end % if guf or mcm

        % Q.r: %<<<3
        if strcmpi(calcset.unc, 'mcm')
            % dimensions are same as Q.v but one dimension is equal calcset.mcm.repeats
            ok = 1;
            %%% if 
            %%%     if strcmpi(calcset.unc, 'mcm')
            %%%         % uncertainty must be randomized if general mcm will be
            %%%         % used.
            %%%         if calcset.mcm.randomize
            %%%             disp(['QWTB: quantity ' Qname ' is randomized']);
            %%%             datain.(Qname) = rand_quant(Q, calcset.mcm.repeats);
            %%%             Q = datain.(Qname);
            %%%         else
            %%%             error(['QWTB: quantity `' Qname '` is not randomized, but mcm is required and automatic randomization is disabled'])
            %%%         end % if mcm.randomize
            %%%     end % if mcm
            %%% else
            %%%     % not equal dimensions, therefore uncertainty matrix is probably
            %%%     % already randomized and prepared for monte carlo method
            if isscalarP(Q.v)
                if ~( Sr(2) == Sv(2) && Sr(1) == calcset.mcm.repeats )
                    ok = 0;
                end
            elseif isvectorP(Q.v)
                if ~( Sr(2) == Sv(2) && Sr(1) == calcset.mcm.repeats )
                    ok = 0;
                end
            elseif ismatrixP(Q.v)
                if ~( Sr(1) == Sv(1) && Sr(2) == Sv(2) && Sr(3) == calcset.mcm.repeats )
                    ok = 0;
                end
            else
                error(['QWTB: quantity `' Qname '` has too many dimensions']);
            end % if scalar/vector/matrix
            if ~(ok)
                error(['QWTB: randomized matrix of quantity `' Qname '` has incorrect dimensions (calcset.mcm.reapeats = ' num2str(calcset.mcm.repeats) ')'])
            end
        end % if mcm

    end % for every Q
end % function check_gen_datain

function r = rand_quant(Q, M) %<<<1
% generates randomize quantity Q
    if isscalarP(Q.u)
        r = Q.v + Q.u.*randn(M, 1);
    elseif isvectorP(Q.u)
        % normrnd is not used to prevent need of matlab statistical toolbox:
        tmpv = repmat(Q.v, M, 1);
        tmpu = repmat(Q.u, M, 1);
        r = tmpv + tmpu.*randn(size(tmpu));
        % XXX but this generates 2 large matrices, and one large output. maybe
        % mvnrnd with zero covariancies would be more memory efficient?
        % 2 DO correlations - mvnrnd
    elseif ismatrixP(Q.u)
        % normrnd is not used to prevent need of matlab statistical toolbox:
        tmpv = repmat(Q.v, [1, 1, M]);
        tmpu = repmat(Q.u, [1, 1, M]);
        r = tmpv + tmpu.*randn(size(tmpu));
        % 2 DO correlations - mvnrnd
    else
        error(['QWTB: quantity `' Qname '` has too many dimensions']);
    end % if scalar/vector/matrix
end % function rand_quant

function res = isscalarP(X) %<<<1
% Return true if X is a scalar in a physics sense. X is scalar if has two dimensions and both
% dimensions are equal to 1.

    S = size(X);
    res = (   length(S) == 2   &&   max(S) == min(S)   &&   min(S) == 1   );

end

function res = isvectorP(X) %<<<1
% Return true if X is a vector in a physics sense. X is vector if has two dimensions, one dimension
% is equal to one, the other dimension is greater than 1.

    S = size(X);
    res = (   length(S) == 2   &&   max(S) > min(S)   &&   min(S) == 1   );

end

function res = ismatrixP(X) %<<<1
% Return true if X is a matrix in a physics sense. X is matrix if has two dimensions and both
% dimensions are greater than 1.

    S = size(X);
    res = (   length(S) == 2   &&   max(S) >= min(S)   &&   min(S) > 1   );

end

% -------------------------------- general mcm functions %<<<1
function dataout = general_mcm(alginfo, datain, calcset) %<<<1
% Applies monte carlo method to an algorithm. It works generally, therefore all
% nuances of monte carlo method are not assured. All quantities should be
% already randomized in Q.u.

    method = calcset.mcm.method;
    M = calcset.mcm.repeats;
    isOctave = exist('OCTAVE_VERSION') ~= 0;

    % single core code --------------------------- %<<<2
    if strcmpi(method, 'singlecore') 
        for MCind = 1:M
            % following if/if section makes 20 s in total on Core i7 for M = 1e6
            if calcset.mcm.verbose
                if rem(MCind, 10000) == 0
                    disp(['QWTB: general mcm: ' num2str(MCind/1000) 'e3 iterations calculated']);
                end
            end
            % call wrapper 
            res(MCind) = call_alg(alginfo, datain, calcset, MCind);
        end
    % multi core code --------------------------- %<<<2
    elseif strcmpi(method, 'multicore') 
        % 2 DO
        % dve moznosti - cellfun @ call_alg, s tim ze repmat(datain), ale to je
        % pametove narocne, nebo zkonstruovat unc_to_val, do cell a pustit
        % cellfun na algoritmus, ale zkonstruovani muze trvat - casove narocne.
        M = calcset.mcm.repeats;
        procno = calcset.mcm.procno;
        if calcset.mcm.procno < 1
            if isOctave
                procno = nproc;
            else
                % XXX does not work. however it is not relevant because matlab
                % doesn't know how to limit number of processors in parfor
                procno = getenv('NUMBER_OF_PROCESSORS')
            end
        end % if procno < 1
        if isOctave
            % XXX where is rand and call?
            % 2DO maybe
            % f = @(in) alg_wrapper(in, calcset);
            % tmp = {datain};
            % tmp = repmat(datain, 1, M);
            % res = parcellfun(f, tmp);
            res = parcellfun(procno, @call_alg, repmat({alginfo}, 1, M), repmat({datain}, 1, M), repmat({calcset}, 1, M), num2cell([1:M]));
        else
            parfor i = 1:M
                res(i) = call_alg(alginfo, datain, calcset, i);
            end
        end
    % multi station code --------------------------- %<<<2
    elseif strcmpi(method, 'multistation') 
        % 2DO
    else
        error(['QWTB: unknown settings of calcset.mcm.method: `' method '` '])
    end
        
    % concatenate data into output structure --------------------------- %<<<2
    % .v is created by mean of outputs
    % .u is all outputs
    for i = 1:size(alginfo.returns, 2)
        % through all quantities:
        Qname = alginfo.returns{i};
        rescell = [res.(Qname)];
        rescell = {rescell.v};

        % check all outputs has the same dimensions:
        tst = cellfun('ndims', rescell);
        if ~all(tst == tst(1))
            error(['QWTB: some outputs `' Qname '.v` of general mcm has different numbers of dimensions'])
        end  % if not all tst
        for j = 1:tst(1)
            % for all dimensions
            tst2 = cellfun('size', rescell, j);
            if ~all(tst == tst(1))
                error(['QWTB: some outputs `' Qname '.v` of general mcm has different sizes'])
            end
        end % for all dimensions

        % preparation:
        if isscalarP(res(1).(Qname).v) == 1
            % quantity is scalar
            dataout.(Qname).v = mean([rescell{:}]);
            dataout.(Qname).u = std([rescell{:}]);
            dataout.(Qname).r = vertcat(rescell{:});
            dataout.(Qname).d = nan;
            dataout.(Qname).c = nan;
        elseif isvectorP(res(1).(Qname).v)
            % quantity is vector
            dataout.(Qname).v = mean(vertcat(rescell{:}));
            dataout.(Qname).u = std([rescell{:}]);
            dataout.(Qname).r = vertcat(rescell{:});
            dataout.(Qname).d = nan;
            dataout.(Qname).c = nan;
        elseif ismatrixP(res(1).(Qname).v)
            % quantity is matrix
            dataout.(Qname).v = mean(vertcat(rescell{:}), 1);
            dataout.(Qname).u = std([rescell{:}]);
            dataout.(Qname).r = vertcat(rescell{:});
            dataout.(Qname).d = nan;
            dataout.(Qname).c = nan;
        else
            error(['QWTB: output quantity `' Qname '` has too many dimensions']);
        end
    end % for concatenate
end % function

function dataout = call_alg(alginfo, datain, calcset, MCind) %<<<1
% set quantity values and call algorithm

    % copy uncertainty to values for all required quantities:
    for i = 1:length(alginfo.requires)
        % for all quantities
        Qname = alginfo.requires{i};
        datain2.(Qname) = unc_to_val(datain.(Qname), MCind, Qname);
    end % for i
    % disable calculation of uncertainty:
    calcset.unc = 'none';
    % call the algorithm:
    dataout = alg_wrapper(datain2, calcset);

end % function

function Qout = unc_to_val(Qin, MCind, Qname) %<<<1
% function copy values from randomized input uncertainty Qin.u to output value
% Qout.v and sets Qout.u and Qout.d to NaNs. Quantity name Qname is used for
% error message.
    if isscalarP(Qin.v)
        % quantity is scalar
        Qout.v = Qin.r(MCind);
        Qout.r = nan.*ones(size(Qin.v));
        Qout.d = [];
        Qout.c = [];
    elseif isvectorP(Qin.v)
        % quantity is vector
        Qout.v = Qin.r(MCind, :);
        Qout.r = nan.*ones(size(Qin.v));
        Qout.d = [];
        Qout.c = [];
    elseif ismatrixP(Qin.v)
        % quantity is matrix
        Qout.v = Qin.r(MCind, :, :);
        gout.r = nan.*ones(size(Qin.v));
        Qout.d = [];
        Qout.c = [];
    else
        % XXX tohle se musi checkovat taky na startu:!!!
        error(['QWTB: quantity `' Qname '` has too many dimensions']);
    end
%    % tohle by jenom melo presunout .u(i) do .v
%    if length(Qin.v) == 1
%        % randomizovat jen kdyz neni randomizovane, a to by mel
%        % resit nejaky kontrolor nejistot v datain
%        % XXX
%           % normrnd nemuze byt, protoze v zakladnim matlabu neni!
%        Qout.v = normrnd(Qin.v, Qin.u, [M 1]);
%    else
%        for i = 1:length(Qin.v)
%            % 2DO too slow, mvnrnd has to be used
%            % 2DO, other distributions
%            % 2DO, paralelize if no other possibility?
%           % normrnd nemuze byt, protoze v zakladnim matlabu neni!
%            Qout.v(:,i) = normrnd(Qin.v(i), Qin.u(i), [1 1]);
%        end
%    end
end % function

% vim settings modeline: vim: foldmarker=%<<<,%>>> fdm=marker fen ft=octave textwidth=80 tabstop=4 shiftwidth=4
