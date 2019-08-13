function varargout = qwtbvar(varargin)
% NOT FINISHED, IN DEVELOPEMENT PHASE
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
%   '.prod/simple' - XXX meshgrid or nomeshgrid %XXX
%
%   Plotting
%   The script tries to plot requested data. Using QWTBVAR('somepath',
%   'x','y') will plot 2D figure with uncertainties for both x and y axes,
%   if results file contained it. Using QWTBVAR('somepath', 'x.v','y.u')
%   will plot 2D figure with dependence of uncertainty of y on value of x.
%   The same apply to the 3D plotting.

% Copyright (c) 2019 by Martin ≈†√≠ra

% Internal documentation:  %<<<1

% Inputs/outputs scheme: %<<<2
%   mode        |o|i|   out1  | out2  | out3  | out4  | in1   | in2   | in3       | in4
%   ------------|-|-|---------|-------|-------|-------|-------|-------|-----------|----------
%   continue    |1|1|   jobfn |       |       |       | jobfn |       |           |
%   2D plot     |1|3|   H     |       |       |       | jobfn | varx  | vary      |
%   2D plot     |2|3|   x     | y     |       |       | jobfn | varx  | vary      |
%   2D plot     |3|3|   H     | x     | y     |       | jobfn | varx  | vary      |
%   3D plot     |1|4|   H     |       |       |       | jobfn | varx  | vary      | varz
%   3D plot     |3|4|   x     | y     | z     |       | jobfn | varx  | vary      | varz
%   3D plot     |4|4|   H     | x     | y     | z     | jobfn | varx  | vary      | varz
%   calculate   |1|3|   jobfn |       |       |       | algid | datain| datainvar |             %XXX add this possibility
%   calculate   |1|4|   jobfn |       |       |       | algid | datain| datainvar | calcset


% Description of the calculation job %<<<2
% job.jobfn         - filename of the main job file with calculation description
%                   (where this structure is stored)
% job.count         - total number of variation calculations
% job.resultfn      - cell of strings, full paths with the result files
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
% varlist.dim()         - array of dimension of Q{i}.f{i} to be variated
% varlist.dimsz()       - array of size of dimension Q{i}.f{i} (number of
%                       variations)
%   Calculation plan:
% calcplan.Q{}          - cell of names of quantity to be variated
% calcplan.f{}          - cell of names of fields of Q{i} to be variated
% calcplan.dim()        - array of dimensions of Q{i}.f{i} to be variated
% calcplan.dimsz()      - array of size of dimension Q{i}.f{i} (number of
%                           variations)
% calcplan.dimidx()     - index of the variated value (value goes through
%                           1:dimsz(i) for actual Q{i}.f{i})
%                           (e.g. for datain x.v=[1], and datainvar x.v=[4 5 6],
%                           if dimidx=2 than at 2nd calculation x.v=2)
% calcplan.mg           - meshgrid of the plan (if any)

    % main qwtbvar function %<<<1
    % determine inputs:
    if nargin == 1 %<<<2
        % continuation of unfinished calculation
        jobfn = varargin{1};
        % check inputs - only type of variable, content is checked in subfunctions
        if ~ischar(jobfn)
            error(err_msg_gen(1)); % bad jobfn
        end % if % ~ischar(jobfn)
        % continue calculation
        job = make_var(jobfn);
        % return actual job filename:
        varargout{1} = job.jobfn;
    elseif nargin == 3 %<<<2
        % plotting of 2D data
        jobfn = varargin{1};
        varx = varargin{2};
        vary = varargin{3};
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
        % get data to plot:
        [X, Y] = get_plotdata(jobfn, varx, vary, '');
        % make plot or return data:
        if nargout == 2
            varargout{1} = X;
            varargout{2} = Y;
        else
            H = plot_2D(jobfn, varx, vary, X, Y);
            varargout{1} = H;
            varargout{2} = X;
            varargout{3} = Y;
        end % if % nargout == 2
    elseif nargin == 4 %<<<2
        if ischar(varargin{2})
            % plotting of 3D data
            jobfn = varargin{1};
            varx = varargin{2};
            vary = varargin{3};
            varz = varargin{4};
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
            % get data to plot:
            [X, Y, Z] = get_plotdata(jobfn, varx, vary, varz);
            % make plot or return data:
            if nargout == 3
                varargout{1} = X;
                varargout{2} = Y;
                varargout{3} = Z;
            else
                H = plot_3D(jobfn, varx, vary, varz, X, Y, Z);
                varargout{1} = H;
                varargout{2} = X;
                varargout{3} = Y;
                varargout{4} = Z;
            end % if % nargout == 3
        else nargin == 4
            algid = varargin{1};
            datain = varargin{2};
            datainvar = varargin{3};
            calcset = varargin{4};
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
            job = make_var(job);
            varargout{1} = job.jobfn;
        end % if % ischar(varagin{2})
    else %<<<2
        error(err_msg_gen(6)); % bad inputs number
    end % if
end % function % qwtbvar

function [Q, f] = parse_Q_f(str)
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
        calcset.var.dir = '.';
    elseif ~ischar(calcset.var.dir)
        error(err_msg_gen(32)); % var.dir must be string
    end
    % var.fnprefix %<<<2
    if ~( isfield(calcset.var, 'fnprefix') )
        calcset.var.fnprefix = '';
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
end % function % check_gen_calcset

% -------------------------------- variation %<<<1
function job = prepare_var(algid, datain, datainvar, calcset) %<<<1
% default values of variables as DI
% variables to be variated as var with dimension of every variable +1 compared to
% DI. not all .v, .u, only those to be variated
% generate jobs, input data

    check_datainvar(datain, datainvar)
    % for every Q in datainvar do get_var_dimension
    job.varlist = get_var_dimensions(datain, datainvar);
    % varQ is actual quantity, varf is actual field, dim is actual dimension that contains
    % variated values of the field, dimsz is actual number of variations

    % XXX prod or sum? permutations or not?
    % construct DI cells - move it into calculation itself? cdatain can be very large... XXX
    % generate_datain_cells_independent(varQ, varf, dim, dimsz, datain, datainvar);
    [job.count, job.calcplan] = generate_datain_cells_dependent(job.varlist, datain, datainvar);
    % disp(['number of variation calculations, independent, by size: ' num2str(job.count)]);
    % XXX display method of variations generation: dependent/independent
    % display number of calculations
    disp_msg(2, num2str(job.count));
    % XXX cdatain = generate_datain_cells_dependent  (varQ, varf, dim, dimsz, datain, datainvar);
    % d XXXisp(['number of variation calculations, dependent: ' num2str(prod([dimsz{:}]))]);
    % %XXX disp(['number of variation calculations, dependent, by size: ' num2str(numel(cdatain))]);

    if ~exist(calcset.var.dir, 'dir')
        mkdir(calcset.var.dir);
    end % if % ~exist(calcset.var.dir)
    if ~exist(calcset.var.dir, 'dir')
        error(err_msg_gen(30, calcset.var.dir)); % not a folder
    end % if % ~exist(calcset.var.dir, 'dir')

    job.algid = algid;
    job.datain = datain;
    job.datainvar = datainvar;
    job.calcset = calcset;

    % generate filenames of result files
    resfnstart = fullfile(calcset.var.dir, [calcset.var.fnprefix '_QV_res_']);
    resfntemplate = ['%0' num2str(ceil(log10(job.count))+1, '%d') 'd.mat'];
    for i = 1:job.count
        % whole string is not in sprintf to prevent sprintf to escape path: dir/subdir
        job.resultfn{i} = [resfnstart sprintf(resfntemplate, i)];
        if calcset.var.cleanfiles
            if exist(job.resultfn{i}, 'file')
                delete(job.resultfn{i});
                disp_msg(7, job.resultfn{i}); % result deleted
            end % if % exist(job.resultfn{i}, 'file')
        end % if % calcset.var.cleanfiles
    end % for % i = 1:job.count

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

% function [cdatain varinfo] = generate_datain_cells_independent(varQ, varf, dim, dimsz, datain, datainvar); %<<<1
% % XXX zastarale
% % XXX description
%     % goes through all outputs from get_var_dimensions:
%     for i = 1:length(varQ)
%         % generate data for needed number of variations for this Q
%         for j = 1:dimsz{i}
%             cdatain{end+1} = datain; % prepare datain to be variated
%             tmp = datainvar.(varQ{i}).(varf{i});
%             idx.type = '()';    % structure for subscript function - type struct
%             idx.subs = repmat({':'}, 1, ndims(tmp)); % cell with semicolons for every dimension of Q.f
%             idx.subs{dim{i}} = j; % replace semicolon of variated dimension by index
%             cdatain{end}.(varQ{i}).(varf{i}) = subsref(tmp, idx); % generate variated datain
%             varinfo.Q{end+1} = varQ{i}; % save information
%             varinfo.f{end+1} = varf{i};   % save information
%             varinfo.dim{end+1} = dim{i};  % save information
%             varinfo.dimsz{end+1} = dimsz{i};  % save information
%             varinfo.dimidx{end+1} = j;  % save information
%         endfor % j = 1:dimsz{i}
%     endfor % i = 1:length(varQ)
% 
%     % XXX
%     % This can generate some cells with same values (e.g. x goes 1:5 and normally is 3, y goes 10:15
%     % and normally is 13, so point x=3,y=13 will be calculated twice!
%     % Would be good to find duplicates, but quite hard for cell of structures...? Almost impossible,
%     % user could have put there anything and one would need to compare floats etc.
%     % XXX
% 
% end % function % generate_datain_cells_independent

function [count, plan] = generate_datain_cells_dependent(list, datain, datainvar) %<<<1
% prepare variation info with plan for calculations

    % total number of calculations
    % (e.g. if dimension sizes of variated Q.f{1}, Q.f{2} are 2,3, than count = 6)
    count = prod(list.dimsz(:));
    % number of variated Q.f:
    Qfno = length(list.Q);
    
    % prepare empty structure:
    plan.Q = cell(count, Qfno);
    plan.f = cell(count, Qfno);
    plan.dim = zeros(count, Qfno);
    plan.dimsz = zeros(count, Qfno);
    plan.dimidx = zeros(count, Qfno);

    % prepare dimension sizes for multidimensional meshgrid:
    for i = 1:Qfno
        c{i} = [1:list.dimsz(i)];
    end % for % i = 1:length(Qfno)
    plan.mg = cell(Qfno,1);
    % multidimensional meshgrid:
    [plan.mg{:}] = ndgrid(c{:});
    % make calcplan structure:
    for i = 1:Qfno
        % fill in collumn for every variated Q.f
        plan.Q(:, i) = repmat(list.Q(i), count, 1);
        plan.f(:, i) = repmat(list.f(i), count, 1);
        plan.dim(:, i) = repmat(list.dim(i), count, 1);
        plan.dimsz(:, i) = repmat(list.dimsz(i), count, 1);
        % reshape correctly shape meshgrid into vector:
        plan.dimidx(:, i) = reshape(plan.mg{i}, count, 1);
    end % for % i = 1:Qfno
end % function % generate_datain_cells_dependent

function [list] = get_var_dimensions(datain, datainvar) %<<<1
% Finds out which Q are to be variated, finds out the dimension of Q.f that has
% to be variated, and number of variations. Put all in list structure (see
% description of varlist.
% It was already checked that all Qs and fields of Qs in datainvar are correct
% with respect to the datain in function check_datainvar.

    list.Q = cell(0);      % quantities to be variated
    list.f = cell(0);     % fields of Q to be variated
    list.dim = [];     % dimension of Q.f that should be variated
    list.dimsz = [];   % size of dimension dim of Q.f that should be variated
    Qnamesvar = fieldnames(datainvar);  % all quantities that will be variated
    for j = 1:length(Qnamesvar)
        Fnamesvar = fieldnames(datainvar.(Qnamesvar{j})); % fields of quantity that will be variated
        for i = 1:length(Fnamesvar)
            szf   = size(datain  .(Qnamesvar{j}).(Fnamesvar{i}));   % size of datain quantity/field
            szfvar = size(datainvar.(Qnamesvar{j}).(Fnamesvar{i})); % size of datainvar quantity/field
            if numel(szfvar) > numel(szf)
                % fill in zero dimensions to get same number of dimensions for szf as in szfvar for easy comparison later
                szf(i) = zeros(numel(szfvar) - numel(szf));
            end % if
            % find out differing dimensions
            id = find(not(szf == szfvar));
            list.Q = [list.Q Qnamesvar(j)]; % actual quantity
            list.f = [list.f Fnamesvar(i)]; % actual field
            list.dim = [list.dim id(1)]; % actual dimension that contains variated values of the field
            list.dimsz = [list.dimsz szfvar(list.dim(end)) - szf(list.dim(end)) + 1]; % actual number of variations
        end % for % i = 1:length(Qvarfields)
    end % for % j = 1:length(Qnamesvar);
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

function job = make_var(job) %<<<1
    % load data for calculation
    job = load_job(job);

    % make variation calculation %<<<2
    id = tic();
    for i = 1:job.count
        % variate quantitites:
        DI = variate_datain(job, i);
        disp_msg(3, i, job.count, job.resultfn{i}); % calculating result no
        if exist(job.resultfn{i}, 'file')
            disp_msg(4, job.resultfn{i}); %result exist
        else % if exist(job.resultfn{i})
            [DO, DI, CS] = qwtb(job.algid, DI, job.calcset);
            % do not check qwtb inputs somewhere?!! XXX
            if job.calcset.var.smalloutput
                % remove large data from quantities (Q.c and Q.r)
                DI = remove_c_r_fields(DI);
                DO = remove_c_r_fields(DO);
            end % if % job.calcset.var.smalloutput
            save('-v7', job.resultfn{i}, 'DO', 'DI', 'CS');
            disp_msg(5, job.resultfn{i}) % result saved
        end % if % exist(job.resultfn{i})
    end % for % i = 1:job.count
    % display final message
    disp_msg(6, toc(id)); % all calculations finished
end % function % make_var

% -------------------------------- plotting %<<<1
function [X, Y, Z] = get_plotdata(jobfn, varx, vary, varz) %<<<1
% XXX ZASTARALE?!
% loads and extracts all data needed for plotting

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

        % load job file: %<<<2
        job = load_job(jobfn);
        % parse variables:
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

        % go through all jobs. this is not ideal method! improve! %XXX
        % (because what if some jobs have variated other parameters? but the
        % other outputs can be affected also! and this will now show in the
        % figure as multiple results for single x)
        % it should be done in this way to look at calcplan.Q and load only required values
        for i = 1:length(job.resultfn)

            % load data %<<<2
            if exist(job.resultfn{i}, 'file')
                tmp = load(job.resultfn{i});
            else
                error(err_msg_gen(93, job.resultfn{i}, jobfn)); % resultfn does not exist
            end % if
            % find varx in input or output cells: %<<<2
            if isfield(tmp.DI, Qx)
                tmpQx = tmp.DI.(Qx);
            elseif isfield(tmp.DO, Qx)
                tmpQx = tmp.DO.(Qx);
            else
                error(err_msg_gen(90, varx, job.resultfn{i})); % var not found in output data.
            end % if % isfield(tmp.DI, Qx)
            % check size of data to plot:
            if ~isscalar(tmpQx.v)
                error(err_msg_gen(91, varx)); % var not scalar
            end % if % ~isscalar(tmpQx.v)
            % find vary in input or output cells: %<<<2
            if isfield(tmp.DI, Qy)
                tmpQy = tmp.DI.(Qy);
            elseif isfield(tmp.DO, Qy)
                tmpQy = tmp.DO.(Qy);
            else
                error(err_msg_gen(90, vary, job.resultfn{i})); % var not found in output data.
            end % if % isfield(tmp.DI, Qy)
            % check size of data to plot:
            if ~isscalar(tmpQy.v)
                error(err_msg_gen(91, vary)); % var not scalar
            end % if % ~isscalar(tmpQy.v)
            % find varz in input or output cells only if varz required: %<<<2
            if ~isempty(varz)
                if isfield(tmp.DI, Qz)
                    tmpQz = tmp.DI.(Qz);
                elseif isfield(tmp.DO, Qz)
                    tmpQz = tmp.DO.(Qz);
                else
                    error(err_msg_gen(90, varz, job.resultfn{i})); % var not found in output data.
                end % if % isfield(tmp.DI, Qz)
                % check size of data to plot:
                if ~isscalar(tmpQz.v)
                    error(err_msg_gen(91, varz)); % var not scalar
                end % if % ~isscalar(tmpQz.v)
            end % if % ~isempty(vary)

            % get fields %<<<2
            % find field
            if isfield(tmpQx, fx)
                X.v(end+1) = tmpQx.(fx);
                if xunc && isfield(tmpQx, 'u')
                    % get uncertainty only if exist and is required
                    X.u(end+1) = tmpQx.u;
                else
                    % disable getting of uncertainties:
                    xunc = 0; % XXX make a message about it to the user!
                end % if % xunc
            else
                error(err_msg_gen(92, fx, tmpQx, job.resultfn{i})); % var is missing field
            end % if % isfield(tmpQx, fx)
            if isfield(tmpQy, fy)
                Y.v(end+1) = tmpQy.(fy);
                if yunc && isfield(tmpQy, 'u')
                    % get uncertainty only if exist and is required
                    Y.u(end+1) = tmpQy.u;
                else
                    % disable getting of uncertainties:
                    yunc = 0; % XXX make a message about it to the user!
                end % if % yunc
            else
                error(err_msg_gen(92, fy, tmpQy, job.resultfn{i})); % var is missing field
            end % if % isfield(tmpQy, fy)
            if ~isempty(varz)
                if isfield(tmpQz, fz)
                    Z.v(end+1) = tmpQz.(fz);
                    if zunc && isfield(tmpQz, 'u')
                        % get uncertainty only if exist and is required
                        Z.u(end+1) = tmpQz.u;
                    else
                        % disable getting of uncertainties:
                        zunc = 0; % XXX make a message about it to the user!
                    end % if % zunc
                else
                    error(err_msg_gen(92, fz, tmpQz, job.resultfn{i})); % var is missing field
                end % if % isfield(tmpQz, fz)
            end % if % ~isempty(varz)
        end % for % i = 1:length(job.resultfn)

        % clear possible partial uncertainties %<<<2
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
        if isempty(X.u) && isempty(Y.u)
            H = plot(X.v, Y.v, '-xb');
        else
            if isempty(Y.u)
                H = errorbar(X.v, Y.v, X.u, ">rx-");
            elseif isempty(X.u)
                H = errorbar(X.v, Y.v, Y.u, "~rx-");
            else
                H = errorbar(X.v, Y.v, X.u, Y.u, "~>rx-");
            end % if
            % set blue color of the main line (uncertainties will stay red):
            Hc = get(H, 'Children');
            set(Hc(1),'color','b'); % data, Hc(2) are errorbars
        end % if % isempty(X.u) && isempty(Y.u)
        % add labels
        xlabel(varx, 'interpreter', 'none');
        ylabel(vary, 'interpreter', 'none');
        title(jobfn, 'interpreter', 'none');
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

% -------------------------------- others %<<<1
function job = load_job(job) %<<<1
% if input is string, loads job file. if input is job structure, do nothing.
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
                msg = 'Incorrect number of input arguments. Please read QWTBVAR documentation.';
            case 7
                msg = 'Inputs `varx`, `vary` and `varz` must be strings with quantity in format `Q` or `Q.f`. E.g. `x` or `x.v`, but not `x.v.` or `.v`.';
            case 8 % one input - jobfn
                msg = ['Job file `' varargin{2} '` does not exist.'];
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
            disp( '‚îè‚î?‚î?‚î?‚î?‚î?‚î?‚î?‚î?‚î?‚î?‚î?‚î?')
            disp( '‚î?')
            disp(['‚î? ' msg])
            disp( '‚î?')
            disp( '‚îó‚î?‚î?‚î?‚î?‚î?‚î?‚î?‚î?‚î?‚î?‚î?‚î?')
        end % if
        msg = [msg suffix];
        % make empty output for zero errid:
        if errid == 0
            msg = '';
        end
    end % if % msg_generated
end % err_msg_gen

% vim settings modeline: vim: foldmarker=%<<<,%>>> fdm=marker fen ft=octave textwidth=80 tabstop=4 shiftwidth=4
