function varargout = qwtbvar(varargin)
% NOT FINISHED, IN DEVELOPEMENT PHASE - XXX fix for new possibilities
% QWTBVAR: Variator for  Q-Wave Toolbox
%   [jobfn] = QWTBVAR(algid, datain, datainvar, calcset)
%       Variates inputs 'datain' according 'datainvar' and applies them one
%       by one into QWTB with settings 'calcset'. Returns path to the
%       calculation plan 'jobfn'.
%   [jobfn] = QWTBVAR(jobfn)
%       Continues interrupted calculation according calculation plan 'jobfn'.
%   [H] = QWTBVAR(jobfn, varx, vary)
%   [H, x, y] = QWTBVAR(jobfn, varx, vary)
%       Plots 'vary' vs 'varx' from results of calculation described in 'jobfn'.
%   [H] = QWTBVAR(jobfn, varx, vary, varz)
%   [H, x, y, z] = QWTBVAR(jobfn, varx, vary, varz)
%       Plots 'varz' vs 'varx' and 'vary' from results of calculation
%       described in 'jobfn'.
%   [x, y] = QWTBVAR(jobfn, varx, vary)
%   [x, y, z] = QWTBVAR(jobfn, varx, vary, varz)
%       Returns only data, the plot is not generated.
%
%   Inputs:
%   'algid' - id of an algorithm, as in QWTB. For available algorithms, run
%       'qwtb()'.
%   'datain' - input data, the same as described in QWTB.
%   'datainvar' - input data that will be variated, see lower.
%   'calcset' - calculation settings, the same as described in QWTB, with
%       additional structre .var.*, see lower.
%   'jobfn' - path and name of a file containing description of the calculation
%   'varx', 'vary', 'varz' - input or output quantities. Strings should
%       contain name of input or output quantity and optionally the field,
%       e.g. 'x', 'y', 'x.v', 'y.v', 'y.u' etc.
%   
%   Outputs: 
%   'jobfn' - path and name of a file containing description of the calculation
%   'H' - handle to the 2D/3D figure
%   'x', 'y', 'z' - vectors of the requested values used for plot.
%
%   Variated data:
%   This structure should contain only quantities (Q) with fields (f) that
%   will be varied. Q.f in 'datainvar' should have size of one dimension
%   larger than Q.f in 'datain', and this dimension in 'datain' must be
%   one.
%   Examples:
%       Scalar:
%           datain.x.v = 6
%           datainvar.x.v = [6 7]
%           Sizes of dimensions of 'x.v' in 'datain' are: [1 1], and in
%           'datainvar' are [1 2].
%       Vector:
%           datain.x.v = [6 6]
%           datainvar.x.v = [6 6; 7 7]
%           Sizes of dimensions of 'x.v' in 'datain' are: [1 2], and in
%           'datainvar' are [2 2].
%       Matrix
%           datain.x.v = [6 6; 6 6]
%           datainvar.x.v = cat(3, [6 6; 6 6], [7 7; 7 7])
%           Sizes of dimensions of 'x.v' in 'datain' are: [2 2 1], and in
%           'datainvar' are [2 2 2].
%
%           Note: following is also valid:
%           datain.x.v = [6 6; 6 6]
%           datainvar.x.v = cat(5, [6 6; 6 6], [7 7; 7 7])
%           Sizes are [2 2 1 1 1] and [2 2 1 1 2];
%
%   Calculation settings structure
%   Up to description in QWTB, it can contain additional optional field
%   '.var', that is a structure with following optional fields (nominal
%   value):
%   '.dir' - ('.') directory for variation jobs and results.
%   '.fnprefix' - ('') filename prefix for variation jobs and results.
%   '.cleanfiles' (0) if 1, delete old jobs and results with colliding
%   filenames during preparation of calculation (but not during
%   continuation)
%   '.smalloutput' - (1) large data of quantities in datain and dataout are not
%   saved. This affects fields .c (correlation matrix) and .r (randomized
%   values).
%   'method' - ('singlecore'), singlecore,multicore,multistaion
%   'procno' - (1)
%   'chunks_per_proc' - (1) number of calculation jobs for one process
%
%   Plotting
%   The script tries to plot requested data. Using QWTBVAR('somepath',
%   'x','y') will plot 2D figure with uncertainties for both x and y axes,
%   if results file contained it. Using QWTBVAR('somepath', 'x.v','y.u')
%   will plot 2D figure with dependence of uncertainty of y on value of x.
%   The same apply to the 3D plotting.
%
%   User function
%   'algid' does not have to be full QWTB algorithm but can be a user
%   function. The function must have two inputs: 'datain' and
%   'calculation_settings', and three outputs: 'dataout', 'datain' and
%   'calculation_settings'.
%   Example of user function working with quantity Q:
%       function [dataout, datain, cs] = userfunction(datain, cs)
%               dataout.x.v = 2.*datain.x.v;
%       end

% Copyright (c) 2019 by Martin Šíra

% Internal documentation:  %<<<1

% Inputs/outputs scheme: %<<<2
%   mode        |o|i|   out1  | out2  | out3  | out4  |  in1     | in2   | in3   | in4       | in5     | in6    |
%   ------------|-|-|---------|-------|-------|-------|----------|-------|-------|-----------|---------|--------|
%   continue    |1|2|   jobfn |       |       |       | 'cont'   | jobfn |       |           |         |        |
%
%   do job      |1|3|   jobfn |       |       |       | 'job'    | jobfn | jobids|           |         |        | %XXX add to help
%
%   calculate   |1|4|   jobfn |       |       |       | 'calc'   | algid | datain| datainvar |         |        | %XXX add this possibility
%   calculate   |1|5|   jobfn |       |       |       | 'calc'   | algid | datain| datainvar | calcset |        |
%
%   2D plot     |-|4|   -     | -     | -     | -     | 'plot2D' | jobfn | varx  | vary      |         |        |
%   2D plot     |-|5|   -     | -     | -     | -     | 'plot2D' | jobfn | varx  | vary      | consts  |        |
%   2D plot     |1|-|   H     |       |       |       | -        | -     | -     | -         | -       |        |
%   2D plot     |2|-|   x     | y     |       |       | -        | -     | -     | -         | -       |        |
%   2D plot     |3|-|   H     | x     | y     |       | -        | -     | -     | -         | -       |        |
%
%   3D plot     |-|5|   H     | -     | -     | -     | 'plot3D' | jobfn | varx  | vary      | varz    |
%   3D plot     |-|6|   H     | -     | -     | -     | 'plot3D' | jobfn | varx  | vary      | varz    | consts |
%   3D plot     |1|-|   H     |       |       |       | -        | -     | -     | -         | -       | -      |
%   3D plot     |3|-|   x     | y     | z     |       | -        | -     | -     | -         | -       | -      |
%   3D plot     |4|-|   H     | x     | y     | z     | -        | -     | -     | -         | -       | -      |
%
%   (o|i - number of output|input arguments, outX - output arguments, inX -
%   input arguments, H - handle to output figure)

% Description of the calculation job %<<<2
% job.id            - id of variation combination id
% job.jobfn         - filename of the main job file with calculation description
%                   (where this structure is stored)
% job.count         - total number of variation calculations
% job.resultfn      - cell of strings, full paths with the partial result files
% job.fullresultfn  - string of filename with final total result
% job.algid         - string with algorithm (input of qwtbvar)
% job.datain        - datain, has values of all nonvariated variables and standard
%                   values of variated variables (input of qwtbvar)
% job.datainvar     - datain with variated variables (input of qwtbvar)
% job.calcset       - calculation settings (input of qwtbvar)
% job.varlist       - structure with list of variated quantities.
% job.calcplan      - structure with calculation plan

% Description of the list of variated quantities and plan of calculation %<<<2
%   List of variated quantities:
% varlist.Q{}           - list of quantities to be variated (e.g. 'x', 'x', 'y')
% varlist.f{}           - list of fields to be variated (e.g. 'v', 'u', 'v')
% varlist.Qf{}          - composed quantity and field 'Q.f'
% varlist.n             - number of parameters to variate (numel(.Q), that is
%                         the same as numel(.f))
% varlist.dim()         - array of dimension of Q{i}.f{i} to be variated. E.g.
%                         index of the dimension of DIvar.Q.f that is missing in
%                         DI.Q.f.
% varlist.dimsz()       - array of size of dimension Q{i}.f{i} to be variated
%                         (e.g. both quantities to be variated are scalars, so
%                         variations are vectors, but 1st variation vector got 2
%                         elements, and 2nd got 3 elments, so
%                         dimsz = [2 3]; prod() of this denotes number of
%                         variations)
%
%   Calculation plan:
%   (values for particular calculation jobs)
% calcplan.Q{}          - cell of names of quantity to be changed from default
%                         (datain) value to one variated (datainvar) value in
%                         particular job. Number of cells is equal to jobs
%                         (variations).
% calcplan.f{}          - cell of names of fields of Q{i} to be variated.
% calcplan.dim()        - actual dimension of DIvar.Q.f that contains variated
%                         values of the field. i.e. dimension, through which
%                         values are changing for variation of DI.Q.f (variated
%                         parameter). Dimension of Q.f. that should be variated.
% calcplan.dimsz()      - number of variations for actual Q.f. Size of dimension 
%                         of Q.f that should be variated.
% calcplan.dimidx()     - index of the variated value (value goes through
%                         1:dimsz(i) for actual Q{i}.f{i}) (e.g. for datain
%                         x.v=[1], and datainvar x.v=[4 5 6], if dimidx=2 than
%                         at 2nd calculation x.v=2)
% calcplan.mg           - meshgrid of the plan (if any). Cell of arrays.
%                         Multidimensional meshgrid.
% calcplan.job_ids      - indexes of jobs for all variations (1:job.count)
% calcplan.ndimjobids   - n-dimensional matrix with jobids, for recreation of
%                         ndimensional matrix of results
% calcplan.axes.Q       - axes of meshgrid (same as varlist.Q)
% calcplan.XXXaxes.f    - axes of meshgrid
% calcplan.XXXaxes.Qf   - axes of meshgrid
% 
% Description of the resulting n-dimensional matrices

% -------------------------------- main function %<<<1
% main qwtbvar function %<<<1
    % determine inputs:
    % check basic things %<<<2
    if nargin < 2
        error(err_msg_gen(6)); % bad call
    end % if nargin < 2
    if ~ischar(varargin{1})
        error(err_msg_gen(9, char(varargin{1}))); % bad mode
    end % if ~ischar(varargin{1})

    % check mode 'continue' %<<<2
    if strcmpi('cont', deblank(varargin{1}))
        % continuation of unfinished calculation
        if nargin > 2
            error(err_msg_gen(6)); % bad call
        end % if nargin > 2
        jobfn = varargin{1};
        % check inputs - only type of variable, content is checked in subfunctions
        if ~ischar(jobfn)
            error(err_msg_gen(1)); % bad jobfn
        end % if % ~ischar(jobfn)
        % continue calculation
        job = run_calculation(jobfn);
        % return actual job filename:
        varargout{1} = job.jobfn;

    % check mode 'job' %<<<2
    elseif strcmpi('job', deblank(varargin{1}))
        % calculating particualr jobs
        if nargin == 3
            jobfn = varargin{2};
            job_ids = varargin{3};
        else
            error(err_msg_gen(6)); % bad call
        end % if nargin ==

        varargout{1} = calculate_job(jobfn, job_ids);

    % check mode 'calculate' %<<<2
    elseif strcmpi('calc', deblank(varargin{1}))
        % setting up and starting calculation
        if nargin == 4
            algid = varargin{2};
            datain = varargin{3};
            datainvar = varargin{4};
            calcset = check_gen_calcset();
        elseif nargin == 5
            algid = varargin{2};
            datain = varargin{3};
            datainvar = varargin{4};
            calcset = varargin{5};
        else
            error(err_msg_gen(6)); % bad call
        end % if nargin ==
        % check inputs - only type of variable, content is checked in subfunctions
        if ~ischar(algid)
            error(err_msg_gen(2)); % bad algid name
        end % if % ~ischar(algid)
        if ~isstruct(datain)
            error(err_msg_gen(3)); % bad datain structure
        end % if % ~ischar(datain)
        if ~isstruct(datainvar)
            error(err_msg_gen(4)); % bad datainvar structure
        end % if % ~ischar(datainvar)
        if ~isstruct(calcset)
            error(err_msg_gen(5)); % bad calcset structure
        end % if % ~ischar(calcset)
        % check calcset
        calcset = check_gen_calcset(calcset);
        % prepare job
        job = prepare_var(algid, datain, datainvar, calcset);
        % do calculation
        job = run_calculation(job);
        varargout{1} = job.jobfn;

    % check mode 'plot2D' %<<<2
    elseif strcmpi('plot2D', deblank(varargin{1}))
        % plotting of 2D data
        if nargin == 4
            jobfn = varargin{2};
            varx = varargin{3};
            vary = varargin{4};
            consts = struct();
        elseif nargin == 5
            jobfn = varargin{2};
            varx = varargin{3};
            vary = varargin{4};
            consts = varargin{5};
        else
            error(err_msg_gen(6)); % bad call
        end % if nargin ==
        % check inputs - only type of variable, content is checked in subfunctions
        if ~ischar(jobfn)
            error(err_msg_gen(1)); % bad jobfn
        end % if % ~ischar(jobfn)
        if ~ischar(varx)
            error(err_msg_gen(7)); % bad varx/vary/varz
        end % if % ~ischar(varx)
        if ~ischar(vary)
            error(err_msg_gen(7)); % bad varx/vary/varz
        end % if % ~ischar(vary)
        if ~isstruct(consts)
            error(err_msg_gen(10)); % bad consts
        end % if % ~ischar(vary)
        % get data to plot:
        [X, Y] = get_plotdata(jobfn, varx, vary, '', consts); % XXX consts
        % make plot or return data:
        if nargout == 2
            varargout{1} = X;
            varargout{2} = Y;
        else
            H = plot_2D(jobfn, varx, vary, X, Y, consts); % XXX consts
            varargout{1} = H;
            varargout{2} = X;
            varargout{3} = Y;
        end % if % nargout ==

    % check mode 'plot3D' %<<<2
    elseif strcmpi('plot3D', deblank(varargin{1}))
        % plotting of 3D data
        if nargin == 5
            jobfn = varargin{2};
            varx = varargin{3};
            vary = varargin{4};
            varz = varargin{5};
            consts = struct();
        elseif nargin == 6
            jobfn = varargin{2};
            varx = varargin{3};
            vary = varargin{4};
            varz = varargin{5};
            consts = varargin{6};
        else
            error(err_msg_gen(6)); % bad call
        end % if nargin ==
        % check inputs - only type of variable, content is checked in subfunctions
        if ~ischar(jobfn)
            error(err_msg_gen(1)); % bad jobfn
        end % if % ~ischar(jobfn)
        if ~ischar(varx)
            error(err_msg_gen(7)); % bad varx/vary/varz
        end % if % ~ischar(varx)
        if ~ischar(vary)
            error(err_msg_gen(7)); % bad varx/vary/varz
        end % if % ~ischar(vary)
        if ~ischar(varz)
            error(err_msg_gen(7)); % bad varx/vary/varz
        end % if % ~ischar(varz)
        if ~isstruct(consts)
            error(err_msg_gen(10)); % bad consts
        end % if % ~ischar(vary)
        % get data to plot:
        [X, Y, Z] = get_plotdata(jobfn, varx, vary, varz, consts); % XXX consts
        % make plot or return data:
        if nargout == 3
            varargout{1} = X;
            varargout{2} = Y;
            varargout{3} = Z;
        else
            H = plot_3D(jobfn, varx, vary, varz, X, Y, Z, consts); % XXX consts
            varargout{1} = H;
            varargout{2} = X;
            varargout{3} = Y;
            varargout{4} = Z;
        end % if % nargout == 3

    else %<<<2
        % checking value of mode (first argument) failed
        error(err_msg_gen(9, varargin{1})); % bad mode
    end % if
end % function % qwtbvar

function [Q, f] = parse_Q_f(str) %<<<1
% parse string into quantity Q and field f
% possible strings:
% Q; Q.; Q.f;
% bad strings:
% .; .f; Q.f.X;
    Q = '';
    f = '';
    % find dot:
    id = strfind(str, '.');
    if isempty(id)
        % only quantity in the string
        Q = str;
        return;
    end % if % isempty(id)
    if numel(id) > 1
        error(err_msg_gen(7)); % bad varx/vary/varz
    end % if % numel(id) > 1)
    if id < 2
        % there is missing Q, because '.' is on first place
        error(err_msg_gen(7)); % bad varx/vary/varz
    end % if % id < 2
    % there is quantity in string:
    Q = str(1:id-1);
    % there could be field in the string ('a'(5:4) gives empty string, so no
    % possible error can happen):
    f = str(id+1:end);
end % function % [Q f] = parse_Q_f

% -------------------------------- check input data %<<<1
function check_datainvar(datain, datainvar) %<<<1
% checks input data with variation informations
% does not check if fields of quantities are correct for qwtb

    % get all quantities that will be variated
    Qnamesvar = fieldnames(datainvar);
    for i = 1:length(Qnamesvar)
        if ~isfield(datain, Qnamesvar{i})
            error(err_msg_gen(60, Qnamesvar{i})); % Q in datainvar missing in datain
        end % if
        % get all fields of actual quantity:
        Fnamesvar = fieldnames(datainvar.(Qnamesvar{i}));
        for j = 1:length(Fnamesvar)
            if ~isfield(datain.(Qnamesvar{i}), Fnamesvar{j})
                error(err_msg_gen(61, Fnamesvar{j}, Qnamesvar{i})); % Q.f in datainvar missing in datain
            end % if
            % size of datain Q.f:
            szf   = size(datain.(Qnamesvar{i}).(Fnamesvar{j}));
            % size of datainvar Q.f:
            szfvar = size(datainvar.(Qnamesvar{i}).(Fnamesvar{j}));
            if numel(szf) > numel(szfvar)
                error(err_msg_gen(62, Fnamesvar{j}, Qnamesvar{i})); % more dimensions in datain than in datainvar
            elseif numel(szfvar) > numel(szf)
                % fill in zero dimensions to get same number of dimensions for szf as in szfvar for
                % easy comparison later:
                szf(i) = zeros(numel(szfvar) - numel(szf));
            end % if
            % find out differing dimensions
            id = find(not(szf == szfvar));
            if isempty(id)
                error(err_msg_gen(63, Fnamesvar{j}, Qnamesvar{i})); % same dimensions in datain and datainvar
            end % if
            if numel(id) > 1
                error(err_msg_gen(64, Fnamesvar{j}, Qnamesvar{i})); % too many differing dimensions
            end % if % numel(id) > 1
            if szf(id) ~= 1
                error(err_msg_gen(65, Fnamesvar{j}, Qnamesvar{i})); % differing dimension in datain not one
            end % if
        end % for % j = 1:length(Fnamesvar)
    end % for % i = 1:length(Qnamesvar);
end % function % check_datainvar

function calcset = check_gen_calcset(varargin) %<<<1
% Checks if calculation settings complies to the qwtbvar format.
% Checks only calcset.var part. The rest of the calculation settings used by qwtb
% is not checked.
% If no input, standard calculation settings needed for qwtbvar is generated.
% Boolean values are reformatted to 0/1.

    % check if there is some input %<<<2
    if nargin == 0
        calcset = struct();
    else
        calcset = varargin{1};
    end

    % var %<<<2
    if ~( isfield(calcset, 'var') )
        calcset.var = struct();
    elseif ~isstruct(calcset.var)
        error(err_msg_gen(31));  % calcset.var must be structure
    end
    % var.dir %<<<2
    if ~( isfield(calcset.var, 'dir') )
        calcset.var.dir = 'VAR';
    elseif ~ischar(calcset.var.dir)
        error(err_msg_gen(32)); % var.dir must be string
    end
    % var.fnprefix %<<<2
    if ~( isfield(calcset.var, 'fnprefix') )
        calcset.var.fnprefix = 'var';
    elseif ~ischar(calcset.var.fnprefix)
        error(err_msg_gen(33)); % var.fnprefix must be string
    end
    % var.cleanfiles %<<<2
    if ~( isfield(calcset.var, 'cleanfiles') )
        calcset.var.cleanfiles = 0;
    end
    if calcset.var.cleanfiles
        calcset.var.cleanfiles = 1;
    else 
        calcset.var.cleanfiles = 0;
    end
    % var.smalloutput %<<<2
    if ~( isfield(calcset.var, 'smalloutput') )
        calcset.var.smalloutput = 1;
    end
    if calcset.var.smalloutput
        calcset.var.smalloutput = 1;
    else
        calcset.var.smalloutput = 0;
    end
    % var.method %<<<2
    if ~( isfield(calcset.var, 'method'))
        calcset.var.method = 'singlecore';
    end
    if ~( strcmpi(calcset.var.method, 'singlecore') | strcmpi(calcset.var.method, 'multicore') | strcmpi(calcset.var.method, 'multistaion') )
        calcset.var.method = 'singlecore';
    end
    % var.procno %<<<2
    if ~( isfield(calcset.var, 'procno'))
        calcset.var.procno = 1;
    end
    v = calcset.var.procno;
    if ~(isnumeric(v) & numel(v) == 1 & fix(v) == v & v >= 0)
        calcset.var.procno = 1;
    end
    % var.chunks_per_proc %<<<2
    if ~( isfield(calcset.var, 'chunks_per_proc'))
        calcset.var.chunks_per_proc = 1;
    end
    v = calcset.var.chunks_per_proc;
    if ~(isnumeric(v) & numel(v) == 1 & fix(v) == v & v > 0)
        calcset.var.chunks_per_proc = 1;
    end
end % function % check_gen_calcset

% -------------------------------- variation %<<<1
function job = prepare_var(algid, datain, datainvar, calcset) %<<<1
% default values of variables as DI
% variables to be variated as var with dimension of every variable +1 compared to
% DI. not all .v, .u, only those to be variated
% generate jobs, input data

    check_datainvar(datain, datainvar)
    % initialize variable 'job'
    job = init_job_structure(algid, datain, datainvar, calcset)

    % find out variation parameters and their dimensions
    [job.varlist, job.ndaxes] = get_var_dimensions(datain, datainvar);

    % create calculation plan
    [job.count, job.calcplan] = calculation_plan(job.varlist);
    % display number of variations/calculations:
    disp_msg(2, num2str(job.count));

    % initialize filenames and directory
    job = init_filenames(job, calcset)

    % generate main job file name
    job.jobfn = fullfile(calcset.var.dir, [calcset.var.fnprefix '_QV_job.mat']);
    if exist(job.jobfn, 'file')
        if calcset.var.cleanfiles
            delete(job.jobfn)
            disp_msg(8, job.jobfn); % job deleted
            save('-v7', job.jobfn, 'job');
        else % if calcset.var.cleanfiles
            disp_msg(1, job.jobfn); % jobfn already exist
        end % if % calcset.var.cleanfiles
    else
        save('-v7', job.jobfn, 'job');
    end % if % ~exist(calcset.var.dir, 'dir')
end % function % prepare_var

function [count, plan] = calculation_plan(varlist) %<<<1
% prepare variation informations with plan for calculations

    % total number of calculations
    % (e.g. if dimension sizes of variated Q.f{1}, Q.f{2} are 2,3, than count = 6)
    count = prod(varlist.dimsz(:));
    % number of variated Q.f:
    n = varlist.n;
    
    % prepare empty structure:
    plan.Q = cell(count, n);
    plan.f = cell(count, n);
    plan.dim = zeros(count, n);
    plan.dimsz = zeros(count, n);
    plan.dimidx = zeros(count, n);

    % prepare dimension sizes for multidimensional meshgrid:
    for i = 1:n
        c{i} = [1:varlist.dimsz(i)];
    end % for % i = 1:length(n)
    plan.mg = cell(n,1);
    % multidimensional meshgrid:
    [plan.mg{:}] = ndgrid(c{:});
    % make calcplan structure:
    for i = 1:n
        % fill in collumn for every variated Q.f
        plan.Q(:, i) = repmat(varlist.Q(i), count, 1);
        plan.f(:, i) = repmat(varlist.f(i), count, 1);
        plan.Qf(:, i) = repmat(varlist.Qf(i), count, 1);
        plan.dim(:, i) = repmat(varlist.dim(i), count, 1);
        plan.dimsz(:, i) = repmat(varlist.dimsz(i), count, 1);
        % reshape correctly meshgrid into vector:
        plan.dimidx(:, i) = reshape(plan.mg{i}, count, 1);
    end % for % i = 1:n
    % XXX popis
    plan.job_ids = 1:count;
    if varlist.n > 1
        % reshape got sense only if more than 1 variated quantity
        plan.ndimjobids = reshape(plan.job_ids, varlist.dimsz(:))
    end % if varlist.n > 1
end % function [count, plan] = calculation_plan(varlist)

function [list, ndaxes] = get_var_dimensions(datain, datainvar) %<<<1
% Finds out which Q are to be variated, finds out the dimension of Q.f that has
% to be variated, and number of variations. Put all in list structure (see
% description of varlist.
% It was already checked that all Qs and fields of Qs in datainvar are correct
% with respect to the datain in function check_datainvar.

    list.Q = cell(0);     % quantities to be variated
    list.f = cell(0);     % fields of Q to be variated
    list.Qf = cell(0);    % concatenated string
    list.dim = [];     % dimension of Q.f that should be variated
    list.dimsz = [];   % size of dimension dim of Q.f that should be variated
    ndaxes.values = {}    % cell of values of axes of n-dimensional result matrices
    Qnamesvar = fieldnames(datainvar);  % all quantities that will be variated
    for j = 1:length(Qnamesvar)
        Fnamesvar = fieldnames(datainvar.(Qnamesvar{j})); % fields of quantity that will be variated
        for i = 1:length(Fnamesvar)
            szf   = size(datain.(Qnamesvar{j}).(Fnamesvar{i}));   % size of datain quantity/field
            szfvar = size(datainvar.(Qnamesvar{j}).(Fnamesvar{i})); % size of datainvar quantity/field
            if numel(szfvar) > numel(szf)
                % fill in zero dimensions to get same number of dimensions for
                % szf as in szfvar for easy comparison later
                szf(i) = zeros(numel(szfvar) - numel(szf));
            end % if
            % find out differing dimensions
            id = find(not(szf == szfvar));
            list.Q = [list.Q Qnamesvar(j)]; % actual quantity
            list.f = [list.f Fnamesvar(i)]; % actual field
            list.Qf = [list.Qf [Qnamesvar{j} '.' Fnamesvar{i}]]; % composed quantity.field
            list.dim = [list.dim id(1)]; % actual dimension that contains variated values of the field
            list.dimsz = [list.dimsz szfvar(list.dim(end)) - szf(list.dim(end)) + 1]; % actual number of variations
            ndaxes.values{end+1} = datainvar.(Qnamesvar{j}).(Fnamesvar{i});
        end % for % i = 1:length(Qvarfields)
    end % for % j = 1:length(Qnamesvar);
    % number of parameters for variation:
    list.n = numel(list.Q);
    ndaxes.Q = list.Q;
    ndaxes.f = list.f;
    ndaxes.Qf = list.Qf;
end % function % get_var_dimensions

function datainout = variate_datain(job, calcno) %<<<1
% change datain according calculation plan and calculation number calcno

    datainout = job.datain;
    % for all Q.f that will be variated:
    for i = 1:size(job.calcplan.Q, 2)

        % get variables (only for simplification of code lines):
        Q = job.calcplan.Q{calcno, i};
        f = job.calcplan.f{calcno, i};
        dim = job.calcplan.dim(calcno, i);
        dimidx = job.calcplan.dimidx(calcno, i);
        value = job.datainvar.(Q).(f);

        % general replacement of matrix (of any dimension) by slice of hypermatrix
        % structure for subscript function needed for type struct:
        idx.type = '()';
        % cell with semicolons for every dimension of Q.f:
        idx.subs = repmat({':'}, 1, ndims(value));
        % replace semicolon of variated dimension by calculation number:
        idx.subs{dim} = dimidx;
        % set value of Q.f in datain by value from daitainvar:
        datainout.(Q).(f) = subsref(value, idx);
    end % for
end % function % variate_datain

% function job = run_calculation(job) %<<<1
% XXX ZASTARALE
% % calculate all variations
%     % load data for calculation
%     job = load_job(job);
%
%     alginfo = qwtb();
%     is_qwtb_alg = 1;
%     if ~any(strcmp({alginfo.id}, job.algid))
%         % it is not qwtb algorithm, but function
%         is_qwtb_alg = 0;
%     end
%
%     % make variation calculation %<<<2
%     time_start = tic();
%     for i = 1:job.count
%         % variate quantitites:
%         DI = variate_datain(job, i);
%         disp_msg(3, i, job.count, job.resultfn{i}); % calculating result no
%         if exist(job.resultfn{i}, 'file')
%             disp_msg(4, job.resultfn{i}); %result exist
%         else % if exist(job.resultfn{i})
%             if is_qwtb_alg
%                 % call QWTB:
%                 [DO, DI, CS] = qwtb(job.algid, DI, job.calcset);
%             else
%                 % call user function:
%                 [DO, DI, CS] = feval(job.algid, DI, job.calcset);
%             end
%             % do not check qwtb inputs somewhere?!! XXX
%             if job.calcset.var.smalloutput
%                 % remove large data from quantities (Q.c and Q.r)
%                 DI = remove_c_r_fields(DI);
%                 DO = remove_c_r_fields(DO);
%             end % if % job.calcset.var.smalloutput
%             save('-v7', job.resultfn{i}, 'DO', 'DI', 'CS');
%             disp_msg(5, job.resultfn{i}) % result saved
%         end % if % exist(job.resultfn{i})
%     end % for % i = 1:job.count
%     % display final message
%     disp_msg(6, toc(time_start)); % all calculations finished
% end % function % run_calculation

function job = run_calculation(job) %<<<1
% calculate all variations, singlecore/multicore/multistaion processing
% XXX full description
    % XXX pouzit ! runmulticore, a to same v qwtb!
    time_start = tic();
    % run parallel processing
    % XXX check calculation settings for parallel processing
    % XXX add direct run of job qwtbvar('job', job_ids)
    % XXX divide job_ids into chunks and run parallel calculation of function calculate_job
    % generate ids of jobs:
    job_ids = job.calcplan.job_ids;
    if job.calcset.var.chunks_per_proc == 0
        ch = 1;
    else
        ch = job.calcset.var.chunks_per_proc;
    end % if job.calcset.var.chunks_per_proc == 0
    L = ceil(numel(job_ids)./ch).*ch;
    % pad by zeros. zero means do nothing. XXX check - if zero in variation, do nothing
    job_ids = postpad(job_ids, L, 0);
    job_ids = reshape(job_ids, ch, []);
    job_ids = mat2cell(job_ids, size(job_ids, 1), ones(1, size(job_ids, 2)));
    jobfns = repmat({job.jobfn}, 1, numel(job_ids));
    % start parallel processing
    method = job.calcset.var.method;
    if strcmpi(method, 'singlecore') 
        % for singlecore just simple for cycle is enough
        % (slightly faster than cellfun)
        for j = 1:numel(job_ids)
            % [res] = cellfun(@calculate_job, qwtbvarmode, jobfns, job_ids, 'UniformOutput', true);
            res{j} = calculate_job(job, job_ids{j});
        end % for j = 1:numel(job_ids)
        res = [res{:}];
    elseif strcmpi(method, 'multicore') 
        % multicore - use parcellfun in Octave, and parfor in Matlab
        jobs = repmat({job}, 1, numel(job_ids));
        res = parcellfun(job.calcset.var.procno, @calculate_job, jobs, job_ids, 'UniformOutput', true);
    elseif strcmpi(method, 'multistation') 
        qwtbvarmode = repmat({'job'}, 1, numel(job_ids));
        % XXX this should call @qwtbvar, qwtbvarmode, jobfns, job_ids,...
        error('not implemented')
    end % if strcmpi(method, 'singlecore') 
    % check results:
    if all(res)
        % display final message
        disp_msg(6, toc(time_start)); % all calculations finished
    else
        error('some results failed'); % XXX fix to stdandardized error
    end % if all(res)
    % reshaping results into n-dimensional matrix
    ndres = reshape_results(job);
    % XXXXXXXXXXXX vystup ndres nekam strcit
end % function job = run_calculation(job)

function ndres = reshape_results(job) %<<<1
% load and reshape results into a n-dimensional matrix with marked axes
% this helps for selecting data for plotting and further analysis
    for j = 1:numel(job.resultfn)
        % load data %<<<2
        if exist(job.resultfn{j}, 'file')
            tmp = load(job.resultfn{j});
            resdata{j} = tmp.DO;
            % DI is not saved into results, this could save a lot of space
        else
            error(err_msg_gen(93, job.resultfn{j}, jobfn)); % resultfn does not exist
        end % if
    end % for j = 1:job.resultfn
    % reshape results to ndim matrix:
    % (axes of ndimres are job.varlist.Qf)
    if job.varlist.n > 1
        % reshape got sense only if more than 1 variated quantity
        ndres.DO = reshape(resdata, job.varlist.dimsz(:));
    end % if job.varlist.n > 1
    % process all fields in resdata and make particular ndimensional matrices:
    Qs = fieldnames(resdata{1});
    for j = 1:numel(Qs)
        Q = Qs{j};
        fs = fieldnames(resdata{1}.(Q));
        for k = 1:numel(fs)
            f = fs{k};
            if isscalar(resdata{1}.(Q).(f))
                tmp = [[[resdata{:}].(Q)].(f)];
            else
                tmp = {[[resdata{:}].(Q)].(f)};
            end % if isscalar(resdata{1}.(Q).(f))
            if job.varlist.n > 1
                % reshape got sense only if more than 1 variated quantity
                ndres.(Q).(f) = reshape(tmp, job.varlist.dimsz(:));
            end % if job.varlist.n > 1
        end % for k = 1:numel(fs)
    end % for j = 1:numel(flds)

    % save reshaped results:
    save('-v7', job.fullresultfn, 'ndres');
end % function reshape_results()

function resstat = calculate_job(job, job_ids) %<<<1
% calculate one or more jobs designated by job_ids XXX full description
% job is either job filename or job structure
    % ensure job is loaded:
    job = load_job(job);
    % results status (0 for issues, 1 as ok)
    resstat = 1;
    % go through all designated job ids:
    for j = 1:numel(job_ids)
        job_id = job_ids(j);
        if job_id == 0
            % do nothing, it was only postpadded because of chunks XXX
        else
            if exist(job.resultfn{job_id}, 'file')
                % job result exist, display message and quit
                disp_msg(4, job.resultfn{i}); %result exist
            else
                % calculate
                alginfo = qwtb();
                is_qwtb_alg = 1;
                if ~any(strcmp({alginfo.id}, job.algid))
                    % it is not qwtb algorithm, but function
                    is_qwtb_alg = 0;
                end
                % make variation calculation
                % variate quantitites:
                DI = variate_datain(job, job_id);
                disp_msg(3, job_id, job.count, job.resultfn{job_id}); % calculating result no
                if is_qwtb_alg
                    % call QWTB:
                    [DO, DI, CS] = qwtb(job.algid, DI, job.calcset);
                else
                    % call user function:
                    [DO, DI, CS] = feval(job.algid, DI, job.calcset);
                end
                % do not check qwtb inputs somewhere?!! XXX
                if job.calcset.var.smalloutput
                    % remove large data from quantities (Q.c and Q.r)
                    DI = remove_c_r_fields(DI);
                    DO = remove_c_r_fields(DO);
                end % if % job.calcset.var.smalloutput
                save('-v7', job.resultfn{job_id}, 'DO', 'DI', 'CS');
                disp_msg(5, job.resultfn{job_id}) % result saved
            end % if exist(job.resultfn{job_id}, 'file')
        end % if job_id == 0
    end % for j = 1:numel(job_ids)
end % function resstat = calculate_job(job, job_ids)

function job = init_job_structure(algid, datain, datainvar, calcset) %<<<1
% initiliaze structure job and fill it by input data
    job.algid = algid;
    job.datain = datain;
    job.datainvar = datainvar;
    job.calcset = calcset;
end % function job = init_job_structure()

function job = init_filenames(job, calcset) %<<<1
    % prepare directory for job files and temporary calculation files
    prepare_calculation_directory(calcset)
    % generate filenames of result files
    job = generate_results_filenames(job);
end % function init_filenames(calcset)

function prepare_calculation_directory(calcset) %<<<1
% prepare directory for job files and temporary calculation files
    if ~exist(calcset.var.dir, 'dir')
        mkdir(calcset.var.dir);
    end % if % ~exist(calcset.var.dir)
    if ~exist(calcset.var.dir, 'dir')
        error(err_msg_gen(30, calcset.var.dir)); % not a folder
    end % if % ~exist(calcset.var.dir, 'dir')
end % function prepare_calculation_directory(calcset)

function job = generate_results_filenames(job) %<<<1
% generate filenames of result files
    % final result filename:
    job.fullresultfn = fullfile(job.calcset.var.dir, [job.calcset.var.fnprefix '_QV_final_res.mat']);
    if job.calcset.var.cleanfiles
        delete(job.fullresultfn)
        disp_msg(7, job.fullresultfn); % result deleted
    end % if job.calcset.var.cleanfiles

    % partial result filenames:
    resfnstart = fullfile(job.calcset.var.dir, [job.calcset.var.fnprefix '_QV_res_']);
    resfntemplate = ['%0' num2str(ceil(log10(job.count))+1, '%0d') 'd.mat'];
    for i = 1:job.count
        % whole string is not in sprintf to prevent sprintf to escape path: dir/subdir
        job.resultfn{i} = [resfnstart sprintf(resfntemplate, i)];
        if job.calcset.var.cleanfiles
            if exist(job.resultfn{i}, 'file')
                delete(job.resultfn{i});
                disp_msg(7, job.resultfn{i}); % result deleted
            end % if % exist(job.resultfn{i}, 'file')
        end % if % calcset.var.cleanfiles
    end % for % i = 1:job.count
end % function generate_results_filenames

% -------------------------------- plotting %<<<1
function [X, Y, Z] = get_plotdata(jobfn, varx, vary, varz, consts) %<<<1
% XXX ZASTARALE?!
% loads and extracts all data needed for plotting

        % initialize %<<<2
        % prepare output variables
        X.v = [];
        X.u = [];
        Y.v = [];
        Y.u = [];
        Z.v = [];
        Z.u = [];
        % prepare uncertainty settings:
        xunc = 0; % plot x uncertainties?
        yunc = 0; % plot y uncertainties?
        zunc = 0; % plot z uncertainties?

        % parse input variables %<<<2
        [Qx, fx] = parse_Q_f(varx);
        if isempty(fx)
            % if field was missing, plot .v with .u
            fx = 'v';
            xunc = 1;   % do uncertainties
        end % if % isempty(fx)
        [Qy, fy] = parse_Q_f(vary);
        if isempty(fy)
            % if field was missing, plot .v with .u
            fy = 'v';
            yunc = 1;   % do uncertainties
        end % if % isempty(fy)
        if isempty(varz)
            Qz = []; fz = [];   % only 2D data required
            % (there is [] and not '' because field with empty string is valid
            % and can be constructed: a.('') = 5. However isfield(a,[]) results
            % in 0 and that is ok.
        else
            [Qz, fz] = parse_Q_f(varz);
            if isempty(fz)
                % if field was missing, plot .v with .u
                fz = 'v';
                zunc = 1;   % do uncertainties
            end % if % isempty(fz)
        end % if % isempty(varz)

        % load job file: %<<<2
        job = load_job(jobfn);

        % get results data %<<<2
        % go through all jobs. this is not ideal method! improve! %XXX
        % (because what if some jobs have variated other parameters? but the
        % other outputs can be affected also! and this will now show in the
        % figure as multiple results for single x)
        % it should be done in this way to look at calcplan.Q and load only required values
        for i = 1:length(job.resultfn)
            % load data %<<<2
            if exist(job.resultfn{i}, 'file')
                resdata = load(job.resultfn{i});
            else
                error(err_msg_gen(93, job.resultfn{i}, jobfn)); % resultfn does not exist
            end % if
            % check if values of constants in the result data are the required
            % ones:
            if check_plot_constants(resdata, consts)
                % get variables
                [X, xunc] = get_variable(resdata, Qx, fx, X, xunc, job.resultfn{i});
                [Y, yunc] = get_variable(resdata, Qy, fy, Y, yunc, job.resultfn{i});
                if ~isempty(varz)
                    % varz only if required: %<<<2
                    [Z, zunc] = get_variable(resdata, Qz, fz, Z, zunc, job.resultfn{i});
                end % if % ~isempty(vary)
            end % check_plot_constants(resdat, consts)
        end % for % i = 1:length(job.resultfn)

        % clear possible partial uncertainties %<<<2
        % (if uncertainty was not found in some job result, it was disabled)
        if ~xunc
            X.u = [];
        end % if % ~xunc
        if ~yunc
            Y.u = [];
        end % if % ~yunc
        if ~zunc
            Z.u = [];
        end % if % ~zunc
           
end % function % get_plotdata;

function H = plot_2D(jobfn, varx, vary, X, Y) %<<<1
% plots 2D figure with possible x/y/xy errorbars
% returns handle to the figure
        figure
        hold on
        if isempty(X.u) && isempty(Y.u)
            H = plot(X.v, Y.v, '-xb');
        else
            if isempty(Y.u)
                H = errorbar(X.v, Y.v, X.u, ">rx-");
                set(Hc(1),'color','r'); % change color of data
                set(Hc(2),'color','g'); % change color of errorbars
            elseif isempty(X.u)
                H = errorbar(X.v, Y.v, Y.u, "~rx-");
                Hc = get(H, 'Children');
                set(Hc(1),'color','r'); % change color of data
                set(Hc(2),'color','g'); % change color of errorbars
            else
                % errorbar is making cluttered figures, ellipses are better
                % H = errorbar(X.v, Y.v, X.u, Y.u, "~>rx-");
                drawEllipse(X.v, Y.v, X.u, Y.u, 'g-', 'HandleVisibility', 'off');
                H = plot(X.v, Y.v, 'x-r');
            end % if
            % set blue color of the main line (uncertainties will stay red):
        end % if % isempty(X.u) && isempty(Y.u)
        % add labels
        xlabel(varx, 'interpreter', 'none');
        ylabel(vary, 'interpreter', 'none');
        title(jobfn, 'interpreter', 'none');
        hold off
end % function % plot_2D

function H = plot_3D(jobfn, varx, vary, varz, X, Y, Z) %<<<1
% plots 3D figure with possible x/y/z errorbars % XXX not working yet
% returns handle to the figure
% XXX no idea how to plot 3D surface plots with x uncertainties, only by
% using multilines in single plot
    H = scatter3(X.v, Y.v, Z.v, [], Z.v);
    % add labels
    xlabel(varx, 'interpreter', 'none');
    ylabel(vary, 'interpreter', 'none');
    zlabel(varz, 'interpreter', 'none');
    title(jobfn, 'interpreter', 'none');
end % function % plot_3D

function [Q, unc] = get_variable(data, Qn, fn, Q, unc, resfn) %<<<1
% Finds variable in loaded job result data, checks dimensions and adds them to
% the accumulator
% data - content of job result
% Qn - string with quantitiy name
% fn - string, name of quantity field
% Q - struct, accumulator for quantity values
% unc - numeric, if uncertainty will be displayed or not
% resfn - filename of actual job result
    % find Q in input or output cells: %<<<2
    if isfield(data.DI, Qn)
        tmpQ = data.DI.(Qn);
    elseif isfield(data.DO, Qn)
        tmpQ = data.DO.(Qn);
    else
        error(err_msg_gen(90, [Qn '.' fn], resfn)); % var not found in output data.
    end
    % check size of data to plot:
    if ~isscalar(tmpQ.v)
        error(err_msg_gen(91, [Qn '.' fn])); % var not scalar
    end

    if isfield(tmpQ, fn)
        % get fields
        % XXX this expects correct dimensions of Q, but if user function is
        % failed, this results in incomprehensible error
        Q.v(end+1) = tmpQ.(fn);
        if unc && isfield(tmpQ, 'u')
            % get uncertainty only if exist and is required
            % XXX this expects correct dimensions of Q, but if user
            % function is failed, this results in incomprehensible error
            Q.u(end+1) = tmpQ.u;
        else
            % disable getting of uncertainties:
            unc = 0; % XXX make a message about it to the user!
        end % if % unc
    else
        error(err_msg_gen(92, fn, Qn, resfn)); % var is missing field
    end % if % isfield(tmpQ, f)
end % function [Q, unc] = get_variable(data, Qn, fn, Q, unc, resfn) %<<<1

function valid = check_plot_constants(resdata, consts) %<<<1
% Finds quantities from 'consts' in job results data 'resdata' and finds if
% values are the same. Usefull for selecting data for plotting.
    % suppose job result data are valid:
    valid = 1;
    constnames = fieldnames(consts);
    DInames = fieldnames(resdata.DI);
    % loop through all constants and all result quantities
    for j = 1:numel(constnames)
        for k = 1:numel(DInames)
            % check if consant exist in result quantity
            if strcmp(constnames{j}, DInames{k})
                % check if value should be compared
                if isfield(constnames{j}, 'v')
                    % if constant contains value, but result quantity do not
                    % contains value, result is not valid
                    if ~isfield(DINames{k}, 'v')
                        valid = 0;
                    else
                        % check actual number of value:
                        if ~(constnames{j}.v ~= DInames{k})
                            valid = 0;
                        end
                    end
                end % if isfield(constnames{j}, 'v')
                % check if uncertainty should be compared
                if isfield(constnames{j}, 'u')
                    % if constant contains uncertainty, but result quantity do not
                    % contains uncertainty, result is not valid
                    if ~isfield(DINames{k}, 'u')
                        valid = 0;
                    else
                        % check actual number of uncertainty:
                        if ~(constnames{j}.v ~= DInames{k})
                            valid = 0;
                        end
                    end
                end % if isfield(constnames{j}, 'u')
            end % if strcmp(constnames{j}, DInames{k})
        end % for k = 1:numel(DInames)
    end % for j = 1:numel(constnames)
end % function valid = check_plot_constants(resdat, consts) %<<<1

% -------------------------------- others %<<<1
function job = load_job(job) %<<<1
% if input is string, loads job file. if input is job structure, do nothing.
% this function ensures job structure is loaded
    if ~isstruct(job)
        if ~exist(job, 'file')
            error(err_msg_gen(8, job))% jobfn does not exist
        end % if % ~exist(job)
        load(job);
    end % if % isstruct(job)
end % function % load_job(job)

function D = remove_c_r_fields(D) %<<<1
% removes fields .r and .c from all quantities in D - usefull for spacesaving
    Qnames = fieldnames(D);
    for i = 1:length(Qnames);
        if isfield(D.(Qnames{i}), 'c')
            D.(Qnames{i}) = rmfield(D.(Qnames{i}), 'c');
        end
        if isfield(D.(Qnames{i}), 'r')
            D.(Qnames{i}) = rmfield(D.(Qnames{i}), 'r');
        end
    end % for
end % function % remove_c_r_fields(D)

function disp_msg(varargin) %<<<1
    % generates display message, so all messages are at one place and visually unified

    % escape codes for colours:
    ANSIwhiteonred = [char(27) '[37;41;1m'];
    ANSInormal = [char(27) '[0m'];
    ANSIwhiteongreen = [char(27) '[37;42;1m'];

    try
        switch varargin{1}
            case 1
                msg = ['Job file `' varargin{2} '` already exists. File was not overwritten.'];
            case 2
                msg = ['Number of variation calculations is: ' ANSIwhiteongreen varargin{2} ANSInormal];
            case 3
                msg = ['Now calculating result ' num2str(varargin{2}) '/' num2str(varargin{3}) ' (' ANSIwhiteonred num2str(varargin{2}./varargin{3}.*100, '%.1f'), ' %' ANSInormal '), filename `' varargin{4} '`.'];
            case 4
                msg = ['Result `' varargin{2} '` already exist, skipping calculation.'];
            case 5
                msg = ['Calculation of result `' varargin{2} '` was finished and saved.'];
            case 6
                secs = num2str(varargin{2}, 3);
                mns =  num2str(varargin{2}./60, 3);
                hrs =  num2str(varargin{2}./3600, 3);
                msg = ['All calculations finished. The calculations took ' ANSIwhiteongreen secs ' s (' mns ' m, ' hrs ' h)' ANSInormal '.'];
            case 7
                msg = ['Result file `' varargin{2} '` was deleted.'];
            case 8
                msg = ['Job file `' varargin{2} '` was deleted.'];
            otherwise
                error(err_msg_gen(-5));
        end % switch
    catch ERR
        % try to catch index out of bound error, i.e. not enough input arguments (varargin out of bounds):
        isOctave = exist('OCTAVE_VERSION') ~= 0;
        if isOctave
            if strcmpi(ERR.identifier, 'Octave:index-out-of-bounds')
                % throw internal QWTB error:
                error(err_msg_gen(-5));
            end
        else
            if (strcmpi(ERR.identifier,'MATLAB:badsubscript'))
                % throw internal QWTB error:
                error(err_msg_gen(-5));
            end
        end
    end % try
    % add unified prefix:
    msg = ['### QWTBVAR: ' msg];
    % display message to user:
    disp(msg)
end % function % warn_msg_gen

function msg = err_msg_gen(varargin) %<<<1
    % generates error message, so all errors are at one place. after each
    % message a " QWTBVAR err #X" is added, where X is number of error.
    % 2DO - condider generating an error structure with error ids and message so it can be try-catched.
    % Function copied from QWTB. If something bad is found here, fix it in qwtb.m also.

    % groups of errors:
    % negative - QWTBVAR internal errors, just continued negative integer sequence
    % 0 - empty output (no error)
    % positive - user errors

    % check inputs: %<<<2
    if (nargin < 1)
        errid = -1;
    else
        % error message number:
        errid = varargin{1};
        % check errid is scalar:
        if ~( size(errid, 1) == 1 && size(errid, 2) == 1 )
            errid = -2;
        end
        % check errid is integer number:
        if ~(errid == fix(errid) && isreal(errid))
            errid = -2;
        end
    end
    % common parts of error message: %<<<2
    % beginning of all errors:
    prefix = 'QWTBVAR: ';
    % this is appended in the case of internal error:
    interr = ' This is QWTBVAR internal error. This should not happen. Please report this bug.';
    % this is appended to all errors:
    suffix = [' QWTBVAR error #' num2str(errid, '%03d') '|'];
    % %>>>2

    % select error message:
    msg_generated = 0;
    try
        switch (errid)
            % ------------------- internal errors: %<<<2
            case -1
                msg = 'incorrect call of error handler: missing first argument';
            case -2
                msg = 'incorrect call of error handler: incorrect type of first argument.';
            case -3 % one input - errid - this error is used for recursion from this switch statement otherwise
                msg = ['unknown error number ' num2str(varargin{2}) '.'];
            case -4 % one input - errid - this error is used for recursion from this switch statement otherwise
                msg = ['insufficient number of input arguments for function err_msg_gen and QWTB error ' num2str(varargin{2}) '.'];
            case -5 % one input - errid - this error is used for recursion from this switch statement otherwise
                msg = 'bad use of disp_msg function.';
            % ------------------- input errors 1-29: %<<<2
            case 1
                msg = 'Input `jobfn` must be a string with filename to the existing job file.';
            case 2
                msg = 'Input `algid` must be a string with existing QWTB algorithm. Please read also QWTB documentation.';
            case 3
                msg = 'Input `datain` must be a structure, compatible with QWTB. Please read also QWTB documentation.';
            case 4
                msg = 'Input `datainvar` must be a structure, compatible with QWTB. Please read also QWTB documentation.';
            case 5
                msg = 'Input `calcset` must be a structure, compatible with QWTB. Please read also QWTB documentation.';
            case 6
                msg = 'Invalid call to qwtbvar. Please read QWTBVAR documentation.';
            case 7
                msg = 'Inputs `varx`, `vary` and `varz` must be strings with quantity in format `Q` or `Q.f`. E.g. `x` or `x.v`, but not `x.v.` or `.v`.';
            case 8 % one input - jobfn
                msg = ['Job file `' varargin{2} '` does not exist.'];
            case 9 % one input - mode
                msg = ['Unknown mode (first argument) `' varargin{2} '`. Please read QWTBVAR documentation.'];
            case 10
                msg = 'Input `consts` must be structures of variables.';
            % ------------------- calculation settings errors 30-59: %<<<2
            case 30 % one input - calcset.var.dir
                msg = ['The value of field `var.dir` in calculation settings structure must be a string with folder, but it does not exist and attempt to create it failed. Requested folder is: `' varargin{2} '`.'];
            case 31
                msg = 'Field `var` in calculation settings structure must be a structure. Plese read QWTBVAR documentation.';
            case 32
                msg = 'Field `var.dir` of calculation settings structure must be a string (path to a directory or empty string). Plese read QWTBVAR documentation.';
            case 33
                msg = 'Field `var.fnprefix` of calculation settings structure must be a string. Plese read QWTBVAR documentation.';
            % ------------------- datain errors 60-89: %<<<2
            case 60 % one input - Qname
                msg = ['Quantity `' varargin{2} '` in `datainvar` is not present in `datain`.'];
            case 61 % two inputs - field, Qname
                msg = ['Field `' varargin{2} '` of quantity `' varargin{3} '` in `datainvar` is not present in `datain`.'];
            case 62 % two inputs - field, Qname
                msg = ['Field `' varargin{2} '` of quantity `' varargin{3} '` in `datain` has more dimensions than in `datainvar`.'];
            case 63 % two inputs - field, Qname
                msg = ['Field `' varargin{2} '` of quantity `' varargin{3} '` has same number of dimensions in `datain` as in `datainvar`.'];
            case 64 % two inputs - field, Qname
                msg = ['Field `' varargin{2} '` of quantity `' varargin{3} '` has too many dimensions of different size in `datain` compared to `datainvar`.'];
            case 65 % two inputs - field, Qname
                msg = ['The differing Field `' varargin{2} '` of quantity `' varargin{3} '` has one dimension of different size, but size of this dimension in `datain` is not one.'];
            % ------------------- output data errors 90-119: %<<<2
            case 90 % two inputs - var, resultfn
                msg = ['Quantity `' varargin{2} '` was not found in result file `' varargin{3} '`.'];
            case 91 % one input - algid
                msg = ['Quantity `' varargin{3} '` is not scalar.'];
            case 92 % two inputs - f, Q, resultfn
                msg = ['Requested field `' varargin{2} '` is missing in quantity `' varargin{3} '` in result file `' varargin{3} '`.'];
            case 93 % one input - resultfn
                msg = ['Result file `' varargin{2} '` referenced in job file `' varargin{3} '` does not exist.'];
            otherwise
                msg = err_msg_gen(-3, errid);
                msg_generated = 1;
        end %>>>2
    catch ERR
        % try to catch index out of bound error, i.e. not enough input arguments (varargin out of bounds):
        isOctave = exist('OCTAVE_VERSION') ~= 0;
        if isOctave
            if strcmpi(ERR.identifier, 'Octave:index-out-of-bounds')
                % throw internal QWTB error:
                msg = err_msg_gen(-4, errid);
                msg_generated = 1;
            end
        else
            if (strcmpi(ERR.identifier,'MATLAB:badsubscript'))
                % throw internal QWTB error:
                msg = err_msg_gen(-4, errid);
                msg_generated = 1;
            end
        end
    end % try
    % compose final error message:
    if ~msg_generated
        msg = [prefix msg];
        if (errid < 0)
            msg = [msg interr];
        end
        % print out error message with nice frame. error itself will appear below
        % with this message again
        if errid > 0
            disp( '/============')
            disp( '|')
            disp(['| ' msg])
            disp( '|')
            disp( '\============')
        end % if
        msg = [msg suffix];
        % make empty output for zero errid:
        if errid == 0
            msg = '';
        end
    end % if % msg_generated
end % err_msg_gen

% drawEllipse copied from geometry package from octave forge %<<<1
%% Copyright (C) 2004-2011 David Legland <david.legland@grignon.inra.fr>
%% Copyright (C) 2004-2011 INRA - CEPIA Nantes - MIAJ (Jouy-en-Josas)
%% Copyright (C) 2012 Adapted to Octave by Juan Pablo Carbajal <carbajal@ifi.uzh.ch>
%% All rights reserved.
%% 
%% Redistribution and use in source and binary forms, with or without
%% modification, are permitted provided that the following conditions are met:
%% 
%%     1 Redistributions of source code must retain the above copyright notice,
%%       this list of conditions and the following disclaimer.
%%     2 Redistributions in binary form must reproduce the above copyright
%%       notice, this list of conditions and the following disclaimer in the
%%       documentation and/or other materials provided with the distribution.
%% 
%% THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS ''AS IS''
%% AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
%% IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
%% ARE DISCLAIMED. IN NO EVENT SHALL THE AUTHOR OR CONTRIBUTORS BE LIABLE FOR
%% ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
%% DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
%% SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
%% CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
%% OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
%% OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

%% -*- texinfo -*-
%% @deftypefn {Function File} {@var{h} = } drawEllipse (@var{elli})
%% @deftypefnx {Function File} {@var{h} = } drawEllipse (@var{xc}, @var{yc}, @var{ra}, @var{rb})
%% @deftypefnx {Function File} {@var{h} = } drawEllipse (@var{xc}, @var{yc}, @var{ra}, @var{rb}, @var{theta})
%% @deftypefnx {Function File} {@var{h} = } drawEllipse (@dots{}, @var{param}, @var{value})
%% Draw an ellipse on the current axis.
%%
%%   drawEllipse(ELLI);
%%   Draws the ellipse ELLI in the form [XC YC RA RB THETA], with center
%%   (XC, YC), with main axis of half-length RA and RB, and orientation
%%   THETA in degrees counted counter-clockwise.
%%   Puts all parameters into one single array.
%%
%%   drawEllipse(XC, YC, RA, RB);
%%   drawEllipse(XC, YC, RA, RB, THETA);
%%   Specifies ellipse parameters as separate arguments (old syntax).
%%
%%   drawEllipse(..., NAME, VALUE);
%%   Specifies drawing style of ellipse, see the help of plot function.
%%
%%   H = drawEllipse(...);
%%   Also returns handles to the created line objects.
%%
%%   -> Parameters can also be arrays. In this case, all arrays are supposed 
%%   to have the same size.
%%
%%   Example: 
%%   @example
%%   # Draw an ellipse centered in [50 50], with semi major axis length of
%%   # 40, semi minor axis length of 20, and rotated by 30 degrees.
%%     figure(1); clf; hold on;
%%     drawEllipse([50 50 40 20 30]);
%%     axis equal;
%% @end example
%%
%%   @seealso{ellipses2d, drawCircle, drawEllipseArc, ellipseAsPolygon}
%% @end deftypefn

function varargout = drawEllipse(varargin)

  % extract dawing style strings
  styles = {};
  for i = 1:length(varargin)
      if ischar(varargin{i})
          styles = varargin(i:end);
          varargin(i:end) = [];
          break;
      end
  end

  % extract ellipse parameters
  if length(varargin)==1
      % ellipse is given in a single array
      ellipse = varargin{1};
      x0 = ellipse(:, 1);
      y0 = ellipse(:, 2);
      a  = ellipse(:, 3);
      b  = ellipse(:, 4);
      if length(ellipse)>4
          theta = ellipse(:, 5);
      else
          theta = zeros(size(x0));
      end
      
  elseif length(varargin)>=4
      % ellipse parameters given as separate arrays
      x0 = varargin{1};
      y0 = varargin{2};
      a  = varargin{3};
      b  = varargin{4};
      if length(varargin)>4
          theta = varargin{5};
      else
          theta = zeros(size(x0));
      end
      
  else
      error('drawEllipse: incorrect input arguments');
  end


  %% Process drawing of a set of ellipses

  % angular positions of vertices
  t = linspace(0, 2*pi, 145);

  % compute position of points to draw each ellipse
  h = zeros(length(x0), 1);
  for i = 1:length(x0)
      % pre-compute rotation angles (given in degrees)
      cot = cosd(theta(i));
      sit = sind(theta(i));
      
      % compute position of points used to draw current ellipse
      xt = x0(i) + a(i) * cos(t) * cot - b(i) * sin(t) * sit;
      yt = y0(i) + a(i) * cos(t) * sit + b(i) * sin(t) * cot;
      
      % stores handle to graphic object
      h(i) = plot(xt, yt, styles{:});
  end

  % return handles if required
  if nargout > 0
      varargout = {h};
  end

end

% vim settings modeline: vim: foldmarker=%<<<,%>>> fdm=marker fen ft=matlab textwidth=80 tabstop=4 shiftwidth=4
