function varargout = qwtb(varargin) %<<<1
% QWTB: Q-Wave Toolbox
%   0 input arguments: 
%     finds all available algorithms and returns information
%   2 input arguments: 
%     algname - short name of algorithm to use
%     datain - data structure
%   3 input arguments: 
%     algname - short name of algorithm to use
%     datain - data structure
%     calcset - calculation settings structure

    % start of qwtb function --------------------------- %<<<1
    % check inputs:
    if nargin == 0
        % returns all algorithms info
        varargout{1} = get_all_alg_info();

    elseif nargin == 1 || nargin > 3
        error('QWTB: incorrect number of input arguments')

    else
        alg = varargin{1};
        datain = varargin{2};
        if nargin == 2
            % calculation settings is missing, generate a standard one:
            calcset = get_standard_calcset();
        else
            calcset = varargin{3};
        endif

        % process data:
        [dataout, calcset] = qwtb_alg(alg, datain, calcset);
        varargout{1} = dataout;
        varargout{2} = datain;
        varargout{3} = calcset;
    end % if - input arguments

end % end qwtb function

function algs = get_all_alg_info() %<<<1
% checks for directories with algorithms and returns info on all available
% algorithms

    algs=[];
    % get full path to this (qwtb.m) script:
    [qwtbdir, tmp, tmp] = fileparts(mfilename('fullpath'));
    % get directory listings:
    lis = dir([qwtbdir filesep() 'alg_*']);
    % get only directories:
    lis = lis([lis.isdir]);
    % for all directories
    for i = 1:size(lis,1)
        % generate full path of current tested algorithm directory:
        algdir = [qwtbdir filesep() lis(i).name];
        if is_alg_dir(algdir)
            addpath(algdir);
            algs(end+1).info = alg_info();
            algs(end).info.fullpath = algdir;
            rmpath(algdir);
        end
    end
end % function get_all_alg_info

function res = is_alg_dir(algpath) %<<<1
% checks if directory in algpath is directory with algorithm, i.e. path exists
% and contains scripts alg_info and alg_wrapper
% returns boolean

    res = exist(algpath,'dir') == 7;
    res = res && (exist([algpath '/alg_info.m'], 'file') == 2);
    res = res && (exist([algpath '/alg_wrapper.m'], 'file') == 2);

end % function is_alg_dir

function [dataout, calcset] = qwtb_alg(alg, datain, calcset) %<<<1
% checks data, settings and calls wrapper

    dataout = [];
    % get full path to this (qwtb.m) script:
    [qwtbdir, tmp, tmp] = fileparts(mfilename('fullpath'));
    algdir = [qwtbdir filesep() 'alg_' alg];
    % check algorithm directory:
    if ~is_alg_dir(algdir)
            error(['QWTB: algorithm `' alg '` not found'])
    end
    % add wrapper to a load path:
    addpath(algdir);
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
        dataout = general_mcm2(alginfo, datain, calcset);
    else
        % unknown settings of calcset.unc or algorithm:
        error(['QWTB: unknown settings of calcset.unc: `' calcset.unc '` or algorithm info structure concerning uncertainty calculation'])
    end % if calcset.unc
    % remove algorithm path from path:
    rmpath(algdir);
end % function qwtb_alg

function calcset = get_standard_calcset() %<<<1
% creates a standard calculation settings
    calcset.strict = 0;
    calcset.verbose = 1;
    calcset.unc = 'none';
    calcset.corr.req = 1;
    calcset.corr.gen = 1;
    calcset.dof.req = 1;
    calcset.dof.gen = 1;
    calcset.mcm.repeats = 100;
    calcset.mcm.verbose = 1;
    calcset.mcm.method = 'singlecore';
    calcset.mcm.procno = 1;
    calcset.mcm.tmpdir = '.';
    calcset.mcm.randomize = 1;
end % function get_standard_calcset

function calcset = check_gen_calcset(calcset) %<<<1
% Checks if calculation settings complies to the qwtb format. If .strict is set
% to 0, missing fields are generated.

    if ~( isfield(calcset, 'strict') )
        calcset.strict = 0;
    endif
    if ~( isfield(calcset, 'verbose') )
        if calcset.strict
            error('QWTB: field `verbose` is missing in calculation settings structure')
        else
            calcset.verbose = 1;
        end
    end
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
    if ~( isfield(calcset, 'cor') )
        if calcset.strict
            error('QWTB: field `cor` is missing in calculation settings structure')
        else
            calcset.cor.req = 1;
            calcset.cor.gen = 1;
        end
    end
    if ~( isfield(calcset.cor, 'req') )
        if calcset.strict
            error('QWTB: field `cor.req` is missing in calculation settings structure')
        else
            calcset.cor.req = 1;
        end
    end
    if ~( isfield(calcset.cor, 'gen') )
        if calcset.strict
            error('QWTB: field `cor.gen` is missing in calculation settings structure')
        else
            calcset.cor.gen = 1;
        end
    end
    if ~( isfield(calcset, 'dof') )
        if calcset.strict
            error('QWTB: field `dof` is missing in calculation settings structure')
        else
            calcset.dof.req = 1;
            calcset.dof.gen = 1;
        end
    end
    if ~( isfield(calcset.dof, 'req') )
        if calcset.strict
            error('QWTB: field `dof.req` is missing in calculation settings structure')
        else
            calcset.dof.req = 1;
        end
    end
    if ~( isfield(calcset.dof, 'gen') )
        if calcset.strict
            error('QWTB: field `dof.gen` is missing in calculation settings structure')
        else
            calcset.dof.gen = 1;
        end
    end
    if ~( isfield(calcset, 'mcm') )
        if calcset.strict
            error('QWTB: field `mcm` is missing in calculation settings structure')
        else
            calcset.mcm.repeats = 100;
            calcset.mcm.verbose = 1;
            calcset.mcm.method = 'singlecore';
            calcset.mcm.procno = 1;
            calcset.mcm.tmpdir = '.';
            calcset.mcm.randomize = 1;
        end
    end
    if ~( isfield(calcset.mcm, 'repeats') )
        if calcset.strict
            error('QWTB: field `mcm.repeats` is missing in calculation settings structure')
        else
            calcset.mcm.repeats = 100;
        end
    end
    if ~( isfield(calcset.mcm, 'verbose') )
        if calcset.strict
            error('QWTB: field `mcm.verbose` is missing in calculation settings structure')
        else
            calcset.mcm.verbose = 1;
        end
    end
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
    if ~( isfield(calcset.mcm, 'procno') )
        if calcset.strict
            error('QWTB: field `mcm.procno` is missing in calculation settings structure')
        else
            calcset.mcm.procno = 1;
        end
    end
    if ~( isfield(calcset.mcm, 'tmpdir') )
        if calcset.strict
            error('QWTB: field `mcm.tmpdir` is missing in calculation settings structure')
        else
            calcset.mcm.tmpdir = '.';
        end
    end
    if ~( isfield(calcset.mcm, 'randomize') )
        if calcset.strict
            error('QWTB: field `mcm.randomize` is missing in calculation settings structure')
        else
            calcset.mcm.randomize = 1;
        end
    end
    % 2DO to check:
    % tmpdir existence,
end % function check_calcset

function datain = check_gen_datain(alginfo, datain, calcset) %<<<1
% Checks if input data complies to the qwtb data format and has all variables
% required by algorithm. Raises error in the case of missing fields. Fields Q.d
% and Q.c are generated if permitted and required.

    for i = 1:length(alginfo.requires)
        Qname = alginfo.requires{i};
        % check for quantity: %<<<2
        if ~(isfield(datain, Qname))
                error(['QWTB: quantity `' Qname '` required but missing in input data structure'])
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
        r = normrnd(Q.v, Q.u, M, 1);
    elseif isvectorP(Q.u)
        r = normrnd(repmat(Q.v, M, 1), repmat(Q.u, M, 1));
        % XXX but this generates 2 large matrices, and one large output. maybe
        % mvnrnd with zero covariancies would be more memory efficient?
        % 2 DO correlations - mvnrnd
    elseif ismatrixP(Q.u)
        r = normrnd(repmat(Q.v, 1, 1, M), repmat(Q.u, 1, 1, M));
        % 2 DO correlations - mvnrnd
    else
        error(['QWTB: quantity `' Qname '` has too many dimensions']);
    end % if scalar/vector/matrix
end % function rand_quant

% vim settings modeline: vim: foldmarker=%<<<,%>>> fdm=marker fen ft=octave textwidth=80 tabstop=4 shiftwidth=4
