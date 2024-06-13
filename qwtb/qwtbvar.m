function varargout = qwtbvar(varargin)
% NOT FINISHED, IN DEVELOPEMENT PHASE - XXX fix for new possibilities
% QWTBVAR: Variator for  Q-Wave Toolbox
%   [jobfn] = QWTBVAR(algid, datain, datainvar, [calcset])
%       Variates inputs 'datain' according 'datainvar' and applies them one
%       by one into QWTB with settings 'calcset'. Returns path to the
%       calculation plan 'jobfn'.
%   [jobfn] = QWTBVAR('cont', jobfn)
%       Continues interrupted calculation according calculation plan 'jobfn'.
%   [jobfn] = QWTBVAR('job', jobfn, jobids)
%       Calculate particular jobs defined in 'jobids' according to the
%       calculation plan 'jobfn'.
%   [ndres, ndresc, ndaxes, consts] = QWTBVAR('result', jobfn, [consts])
%       Returns calculated results, sliced according to 'consts', as
%       n-dimensional matrices 'ndres', or n-dimensional cell of results
%       'ndresc', with description of dimensions in 'ndaxes'.
%   [H, x, y] = QWTBVAR('plot2D', jobfn, varx, vary, [consts])
%       Plots 'vary' vs 'varx' from results of calculation described in 'jobfn',
%       and sliced according to the 'consts'.
%   [H, x, y, z] = QWTBVAR('plot3D', jobfn, varx, vary, varz, [consts])
%       Plots 'varz' vs 'vary' and 'varx' from results of calculation described
%       in 'jobfn', and sliced according to the 'consts'.
%   [lut] = QWTBVAR('lut', jobfn, axset, rqset)
%       Creates a look-up table from results 'jobfn', according to axes settings
%       in 'axset' and 'rqset'.
%   [ival] = QWTBVAR('interp', lut, ipoint)
%       Interpolate look-up table at point 'ipoint' and returns value 'ival'.
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
%   'x', 'y', 'z' - values used for plot. Structures with values, error bars,
%   labels etc.
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
%   The script tries to plot requested data. Using QWTBVAR('plot2D', 'somepath',
%   'x','y') will plot 2D figure with uncertainties for both x and y axes, if
%   results file contained it. Using QWTBVAR('plot2D', 'somepath', 'x.v','y.u')
%   will plot 2D figure with dependence of uncertainty of y on value of x. The
%   same apply to the 3D plotting.
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
%   mode        |o|i|   out1  | out2  | out3  | out4  ||  in1     | in2   | in3   | in4      | in5    | in6   |
%   ------------|-|-|---------|-------|-------|-------||----------|-------|-------|----------|--------|-------|
%   continue    |1|2|   jobfn |       |       |       || 'cont'   | jobfn |       |          |        |       |
%   do job      |1|3|   jobfn |       |       |       || 'job'    | jobfn | jobids|          |        |       |
%   calculate   |1|4|   jobfn |       |       |       || 'calc'   | algid | datain| datainvar|        |       |
%   calculate   |1|5|   jobfn |       |       |       || 'calc'   | algid | datain| datainvar| calcset|       |
%   get result  |4|2|   ndres | ndresc| ndaxes| consts|| 'result' | jobfn |       |          |        |       |
%   get result  |4|3|   ndres | ndresc| ndaxes| consts|| 'result' | jobfn | consts|          |        |       |
%   2D plot     |3|4|   H     | x     | y     |       || 'plot2D' | jobfn | varx  | vary     |        |       |
%   2D plot     |3|5|   H     | x     | y     |       || 'plot2D' | jobfn | varx  | vary     | consts |       |
%   3D plot     |4|5|   H     | x     | y     | z     || 'plot3D' | jobfn | varx  | vary     | varz   |       |
%   3D plot     |4|6|   H     | x     | y     | z     || 'plot3D' | jobfn | varx  | vary     | varz   | consts|
%   make LUT    |1|4|   lut   |       |       |       || 'lut'    | jobfn | axset | rqset    |        |       |
%   interp LUT  |1|3|   ival  |       |       |       || 'interp' | lut   | ipoint|          |        |       |
%   interp LUT  |1|3|   ival  |       |       |       || 'interp' | lutfn | ipoint|          |        |       |
%
%   (o|i - number of output|input arguments, outX - output arguments, inX -
%   input arguments, H - handle to output figure)

% Description of the calculation job %<<<2
% main job structure %<<<3
% job.id            - id of variation combination id - XXX REVIEW is it used?
% job.jobfn         - filename of the main job file with calculation description
%                     (where this structure is stored)
% job.count         - total number of variation calculations
% job.resultfns     - cell of strings, full paths with the partial result files
% job.fullresultfn  - string of filename with final total result
% job.algid         - string with algorithm (input of qwtbvar)
% job.datain        - datain, has values of all nonvariated variables and standard
%                     values of variated variables (input of qwtbvar)
% job.datainvar     - datain with variated variables (input of qwtbvar)
% job.calcset       - calculation settings (input of qwtbvar)
% job.varlist       - structure with list of variated quantities, see lower
% job.calcplan      - structure with calculation plan, see lower

% job.varlist - list of variated quantities %<<<3
%  Needed to create job.calcplan.
%   List of variated quantities:
% .varlist.Q{}      - list of quantity names to be variated
%                       Example: 'a','a','x','y'
% .varlist.f{}      - list of field names to be variated (e.g. 'v', 'u', 'v')
%                       Example: 'v', 'u', 'v', 'v'
% .varlist.names{}  - composed quantity and field names 'Q.f' (e.g. 'x.v')
%                       Example: 'a.v', 'a.u', 'x.v', 'y.v'
% .varlist.dim()    - array of dimension of Q{i}.f{i} to be variated. E.g.
%                     index of the dimension of DIvar.Q.f that is missing in
%                     DI.Q.f.
%                       Example: [2 2 2 1]
% .varlist.dimsz()  - array of size of dimension Q{i}.f{i} to be variated
%                    (e.g. both quantities to be variated are scalars, so
%                    variations are vectors, but 1st variation vector got 2
%                    elements, and 2nd got 3 elments, so
%                    dimsz = [2 3]; prod() of this denotes number of
%                    variations)
%                       Example: [2 3 5 6]
% .varlist.n        - number of parameters to variate (numel(job.varlist.Q), that is
%                     the same as numel(job.varlist.f) or numel(job.varlist.names))
%                       Example: 4

% job.calcplan - calculation plan %<<<3
% (values for particular calculation jobs)
% .calcplan.count        - number of calculations
%                           Example: 180 (=2*3*5*6)
% .calcplan.Q{}          - cell of names of quantity to be changed from default
%                          (datain) value to one variated (datainvar) value in
%                          particular job. Number of cells is equal to jobs
%                          (variations).
%                           Example: size(.Q) = [180, 4]
%                           .Q = ['a', 'x', 'x', 'y';
%                                 ...
%                                 'a', 'x', 'x', 'y']
% .calcplan.f{}          - cell of names of fields of Q{i} to be variated.
%                           Example: size(.f) = [180, 4]
%                           .f = ['v', 'u', 'v', 'v';
%                                 ...
%                                 'v', 'u', 'v', 'v']
% .calcplan.names{}       - cell of names of fields of Q{i} to be variated.
%                           Example: size(.names) = [180, 4]
%                           .f = ['a.v', 'a.u', 'x.v', 'y.v';
%                                 ...
%                                 'a.v', 'a.u', 'x.v', 'y.v']
% .calcplan.dim()        - actual dimension of DIvar.Q.f that contains variated
%                          values of the field. i.e. dimension, through which
%                          values are changing for variation of DI.Q.f (variated
%                          parameter). Dimension of Q.f. that should be variated.
%                          e.g. [2 2; 2 2; ...; 2 2]; (change DIvar.x.v
%                          dimension 2 and DIvar.y.v dimension 2; ... )
%                           Example: size(.dim) = [180, 4]
%                           .dim = [2 2 2 1;
%                                   ...
%                                   2 2 2 1]
% .calcplan.dimidx()     - index of the variated value (value goes through
%                          1:dimsz(i) for actual Q{i}.f{i}) (e.g. for datain
%                          x.v=[1], and datainvar x.v=[4 5 6], if dimidx=2 than
%                          at 2nd calculation x.v=2)
%                          (rows are jobs, columns are Q.f)
%                          it is 'linearizzation' of meshgrid
%                           Example: size(.dimidx) = [180, 4]
%                           .dimidx = [1   1   1   1
%                                      2   1   1   1
%                                      1   2   1   1
%                                      2   2   1   1
%                                      1   3   1   1
%                                      2   3   1   1
%                                      1   1   2   1
%                                      ...
%                                      1   2   5   6
%                                      2   2   5   6
%                                      1   3   5   6
%                                      2   3   5   6]
% .calcplan.job_ids      - indexes of jobs for all variations (1:job.count)
%                           Example: [1, 2, ..., 180];
% .calcplan.ndimjobids   - n-dimensional matrix with jobids, for recreation of
%                          ndimensional matrix of results
%                           Example: size(.ndimjobids) = [2 3 5 6];
%                           .ndimjobids = (:,:,1,1) =
%                                           [1   3   5
%                                            2   4   6]
%                                         (:,:,2,1) =
%                                           [7    9   11
%                                            8   10   12]
%                                         ...
%                                         (:,:,5,6) =
%                                           [175   177   179
%                                            176   178   180]

% Description of the result structure %<<<2
% .calcplan.axes.Q       - axes of meshgrid (same as varlist.Q)
% .calcplan.XXXaxes.f    - axes of meshgrid
% .calcplan.XXXaxes.names   - axes of meshgrid
% Description of the resulting n-dimensional matrices
% ndres.Q.f             - n-dimensional matrix, not only if output quantity Q.f was scalar
% % XXX add:
% ndres.<Q>
% ndres.<f>
% ndres.<names>
%       
% ndresc                - n-dimensional cell with result structures
%   ndresc{x,y,...}.Q.f - result structure for dimension values x,y,...

% res.ndaxes        - axes values of ndim result

% Description of the axset structure %<<<2
%   same as lut.ax structure without .val and .def

% Description of the rqset structure %<<<2
%   same as lut.rq structure, only .val is added by QWTBVAR by loading
%   job result

% Description of the lut structure %<<<2
%   .ax         - axis of the LUT
%       .<Q>    - LUT axis quantity name, variated quantity
%               (char, e.g. 'x', 'y')
%           .<f>- field name
%               (char, e.g. 'v' as value, 'u' as uncertainty)
%               .val        - values of the axis Q.f
%                   (numeric, vector of variated values)
%               .def        - default value of the axis Q.f, based on DI input during variations
%                   % XXX 2DO, reserved for future
%                   (numeric, scalar of variated values)
%               .scale      - scale of the axis, this helps for interpolation
%                   (char, 'lin', 'log')
%               .max_ovr    - maximum over range, absolute value
%                   (numeric, scalar)
%               .min_ovr    - minimum over range
%                   (numeric, scalar)
%               .max_lim    - what to do if max_ovr is exceeded
%               .min_lim    - what to do if min_ovr is exceeded
%                   (char, 'error', 'const')
%                       'error' - do error,
%                       'const' - constant value equal to edge value of axis
%   .ax_names   - quantity-field names of LUT axes
%                   (cell of chars, e.g. 'x.v', 'y.u')
%   .ax_Q       - quantities of LUT axes
%                   (cell of chars, e.g. {'x', 'y'})
%   .ax_f       - fields of LUT axes
%                   (cell of chars, e.g. {'v', 'v'})
%   .rq         - resulting quantities of the LUT
%       .<Q>    - result quantity name (e.g. 'z')
%           .<f>- field name (e.g. 'v' as value, 'u' as uncertainty)
%               .val        - values
%                   (numeric, matrix)
%               .scale      -
%                   (char, 'lin','log')
%   .rq_names   - quantity-field names of LUT results
%               (cell of chars, e.g. 'z.v')
%   .rq_Q       - quantities of LUT results
%               (cell of chars, e.g. {'z'})
%   .rq_f       - fields of LUT results
%               (cell of chars, e.g. {'v'})

% Description of the ipoint structure %<<<2
% ipoint contains .Q.f for every axis of LUT
%   .Q      - axis quantity name (e.g. 'x', 'y'), variated value
%       .f  - field name (e.g. 'v' as value, 'u' as uncertainty)
%           (value for which interpolation will be done)

% -------------------------------- main function %<<<1
% main qwtbvar function %<<<1
% parse input parameters, make basic type checks of inputs and run sub function
% called main_something.
    % check basic things %<<<2
    if nargin < 2
        % always at least 2 input arguments are required
        error(err_msg_gen(6)); % bad call
    end
    if ~ischar(varargin{1})
        % if first argument is not char, mode is unknown
        error(err_msg_gen(9, char(varargin{1}))); % bad mode
    end

    % check mode 'continue' %<<<2
    if strcmpi('cont', deblank(varargin{1}))
        % continuation of unfinished calculation
        if nargin > 2
            error(err_msg_gen(6)); % bad call
        end
        % check rest:
        if ~ischar(varargin{2})
            error(err_msg_gen(1)); % bad jobfn
        end
        % return job filename:
        varargout{1} = main_cont(varargin{2});

    % check mode 'job' %<<<2
    elseif strcmpi('job', deblank(varargin{1}))
        % calculating one or more particualr jobs, for internal use mainly
        if nargin ~= 3
            error(err_msg_gen(6)); % bad call
        end
        if ~ischar(jobfn) % XXX where comes jobfn from?! THIS IS ERROR
            error(err_msg_gen(1)); % bad jobfn
        end
        % return job filename:
        varargout{1} = main_job(varargin{2}, varargin{3});

    % check mode 'calc' %<<<2
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
            calcset = check_gen_calcset(varargin{5});
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
        % check datain and datainvar
        check_datainvar(datain, datainvar);
        % return job filename:
        varargout{1} = main_calc(algid, datain, datainvar, calcset);

    % check mode 'lut' %<<<2
    elseif strcmpi('lut', deblank(varargin{1}))
        % setting up and starting lut compilation
        if nargin == 2
            jobfn = varargin{2};
            axset = check_gen_axset(struct());
            rqset = check_gen_rqset(struct());
        elseif nargin == 3
            jobfn = varargin{2};
            axset = check_gen_axset(varargin{3});
            rqset = check_gen_rqset(struct());
        elseif nargin == 4
            jobfn = varargin{2};
            axset = check_gen_axset(varargin{3});
            rqset = check_gen_rqset(varargin{4});
        else
            error(err_msg_gen(6)); % bad call
        end % if nargin ==
        % check inputs - only type of variable, content is checked in subfunctions
        if ~ischar(jobfn)
            error(err_msg_gen(1)); % bad jobfn
        end
        if ~isstruct(axset)
            error(err_msg_gen(11)); % bad axset
        end
        if ~isstruct(rqset)
            error(err_msg_gen(12)); % bad rqset
        end
        % return lut:
        varargout{1} = main_lut(jobfn, axset, rqset);

    elseif strcmpi('interp', deblank(varargin{1})) %<<<2
        % interpolation of lut
        if nargin == 3
            lut = varargin{2};
            ipoint = varargin{3}; % ipoint is checked later
        else
            error(err_msg_gen(6)); % bad call
        end
        % return interpolated value(s):
        varargout{1} = main_interp(lut, ipoint);

    % check mode 'result' %<<<2
    elseif strcmpi('result', deblank(varargin{1}))
        % returns ndres, ndresc, ndaxes
        if nargin == 2
            % return all results
            jobfn = varargin{2};
            [varargout{1}, varargout{2}, varargout{3}, varargout{4}] = main_result(jobfn, []);
        elseif nargin == 3
            % return results sliced according consts
            jobfn = varargin{2};
            consts = varargin{3};
            [varargout{1}, varargout{2}, varargout{3}, varargout{4}] = main_result(jobfn, consts);
        else
            error(err_msg_gen(6)); % bad call
        end

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
        end
        % check inputs - only type of variable, content is checked in subfunctions
        if ~ischar(jobfn)
            error(err_msg_gen(1)); % bad jobfn
        end
        if ~ischar(varx)
            error(err_msg_gen(7)); % bad varx/vary/varz
        end
        if ~ischar(vary)
            error(err_msg_gen(7)); % bad varx/vary/varz
        end
        if ~isstruct(consts)
            error(err_msg_gen(10)); % bad consts
        end
        if nargout == 2
            makeplot = 0;
        else
            makeplot = 1;
        end
        [varargout{1}, varargout{2}, varargout{3}] = main_plot(makeplot, jobfn, varx, vary, [], consts);

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
        end
        % check inputs - only type of variable, content is checked in subfunctions
        if ~ischar(jobfn)
            error(err_msg_gen(1)); % bad jobfn
        end
        if ~ischar(varx)
            error(err_msg_gen(7)); % bad varx/vary/varz
        end
        if ~ischar(vary)
            error(err_msg_gen(7)); % bad varx/vary/varz
        end
        if ~ischar(varz)
            error(err_msg_gen(7)); % bad varx/vary/varz
        end
        if ~isstruct(consts)
            error(err_msg_gen(10)); % bad consts
        end
        if nargout == 3
            makeplot = 0;
        else
            makeplot = 1;
        end
        [varargout{1}, varargout{2}, varargout{3}, varargout{4}] = main_plot(makeplot, jobfn, varx, vary, varz, consts);
    else % unknown mode %<<<2
        % checking value of mode (first argument) failed
        error(err_msg_gen(9, varargin{1})); % bad mode
    end % if
end % function % qwtbvar

function jobfn = main_cont(jobfn) %<<<1
    % continuation of unfinished calculation
    job = load_job(jobfn)
    job = run_calculations(job);
    % finalize
    job = finish_calculations(job);
    jobfn = job.jobfn;
end

function jobfn = main_job(jobfn, job_ids) %<<<1
    % calculating one or more particular jobs, for internal use mainly
    jobfn = calculate_job(jobfn, job_ids);
end

function jobfn = main_calc(algid, datain, datainvar, calcset) %<<<1
    % setting up and starting calculation
    job = prepare_calculations(algid, datain, datainvar, calcset);
    % do calculation
    job = run_calculations(job);
    % finalize
    job = finish_calculations(job);
    jobfn = job.jobfn;
end

function lut = main_lut(jobfn, axset, rqset) %<<<1
% setting up and starting lut compilation
    % load calculation settings:
    job = load_job(jobfn);
    % load final result
    job = load_final_result(job);
    % make lut
    lut = make_lut(job.ndres, job.ndresc, job.ndaxes, job.varlist, axset, rqset);
end % main_lut

function ival = main_interp(lutfn, ipoint) %<<<1
% interpolate value based on lut and ax values
    % ensure lut is loaded
    lut = load_lut(lutfn);
    % check ipoint
    ipoint = check_gen_ipoint(lut, ipoint);
    % calculate interpolation weight matrix
    w = interp_weights(lut, ipoint);
    % interpolate values
    ival = interp_val(lut, w);
end % function main_interp

function [ndres, ndresc, ndaxes, consts] = main_result(jobfn, consts) %<<<1
    % Squeezing of the data is not performed to keep values of all axes.

    % load calculation settings:
    job = load_job(jobfn);
    % load final result
    job = load_final_result(job);

    % Make slice based on consts:
    [ndresc, ndaxes] = slice_ndresc_and_ndaxes(job.ndresc, job.ndaxes, consts);
    % clean out singleton dimensions and relevant axes
    [ndresc, ndaxes, consts] = simplify_ndresc_and_ndaxes(ndresc, ndaxes);
    % create structure of cells also:
    ndres = CoS_to_SoC(ndresc);
end % function main_result

function [H, X, Y, Z] = main_plot(do_plot, jobfn, varx, vary, varz, consts) %<<<1
% getting data for 2/3D plot and/or plotting of 2/3D data
    % load job file:
    job = load_job(jobfn);
    % load final job file with results:
    job = load_final_result(job);
    % Remove varx/vary from consts:
    % (E.g. user supply varx in consts, but he wants dependence on varx so it
    % has to be removed from consts otherwise the slicing would do too much work)
    to_remove = {varx};
    if not(isempty(varz))
        to_remove{end+1} = vary;
    end
    % XXX description
    consts_fixed = remove_Q_f(consts, to_remove);
    % slice out matrices:
    [ndresc_sliced, ndaxes_sliced] = slice_ndresc_and_ndaxes(job.ndresc, job.ndaxes, consts_fixed);
    % XXX warning if consts does contain value of Q.f not found in axes.v.f, so
    % the user knows about strange input
    % XXX warning if constst do not slice fully for 2D/3D, warning here or
    % somewhere else
    [ndres_sliced] = CoS_to_SoC(ndresc_sliced);
    % Get constant names:
    [~, ~, constnames] = get_Qs_fs_names(consts_fixed);
    % Check that consts covers all remaining axes
    [d] = setdiff(job.varlist.names, constnames);
    if not(isempty(d))
        % XXX add PROPER warning that data will be concatenated!
        % XXX Does not trigger properly. even if data should be concatenated, the
        % message is not shown. or if all axes are covered, the message is
        % shown.
        % warning('CONCATENATION of the data')
    end % if

    % Get plot data:
    [X, Y, Z] = get_plot_data(job, ndres_sliced, ndresc_sliced, ndaxes_sliced, varx, vary, varz, job.fullresultfn);

    % Create string for title
    plottitle = sprintf('%s\n%s', jobfn, consts_to_string(consts_fixed));

    % Make plot or return data:
    if do_plot
        if isempty(varz)
            H = plot_2D(jobfn, X, Y, plottitle);
        else
            H = plot_3D(jobfn, X, Y, Z, plottitle);
        end % if isempty(varz)
    else
        H = [];
    end
end

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

function axset = check_gen_axset(axset) %<<<1
% check input structure axset - lut axis settings
    if isempty(axset)
        axset = struct();
    end
    % for all quantities and fields of quantities, check existence and values of
    % subfields, add default values for missing subfields
    [Qs, fs, names] = get_Qs_fs_names(axset);
    for j = 1:numel(names)
            f = axset.(Qs{j}).(fs{j});

            if isfield(f, 'scale') %<<<2
                if ischar(f.scale)
                    if not(strcmpi(f.scale, 'lin') || strcmpi(f.scale, 'log'))
                        error(err_msg_gen(124, 'axset', [names{j} '.scale'], f.scale, '`lin` or `log`')) % bad value
                    end
                else
                    error(err_msg_gen(123, 'axset', [names{j} '.scale'], class(f.scale), 'char')) % bad type
                end % ischar
            else
                % set default value of axis scale:
                axset.(Qs{j}).(fs{j}).scale = 'lin';
            end % if isfield scale

            if isfield(f, 'max_lim') %<<<2
                if ischar(f.max_lim)
                    if not(strcmpi(f.max_lim, 'error') || strcmpi(f.max_lim, 'const'))
                        error(err_msg_gen(124, 'axset', [names{j} '.max_lim'], f.max_lim, '`error` or `const`')) % bad value
                    end
                else
                    error(err_msg_gen(123, 'axset', [names{j} '.max_lim'], class(f.max_lim), 'char')) % bad type
                end % ischar
            else
                % set default value of axis scale:
                axset.(Qs{j}).(fs{j}).max_lim = 'error';
            end % if isfield max_lim

            if isfield(f, 'min_lim') %<<<2
                if ischar(f.min_lim)
                    if not(strcmpi(f.min_lim, 'error') || strcmpi(f.min_lim, 'const'))
                        error(err_msg_gen(124, 'axset', [names{j} '.min_lim'], f.min_lim, '`error` or `const`')) % bad value
                    end
                else
                    error(err_msg_gen(123, 'axset', [names{j} '.min_lim'], class(f.min_lim), 'char')) % bad type
                end % ischar
            else
                % set default value of axis scale:
                axset.(Qs{j}).(fs{j}).min_lim = 'error';
            end % if isfield min_lim

            if isfield(f, 'min_ovr') %<<<2
                if isnumeric(f.min_ovr)
                    if not(isscalar(f.min_ovr))
                        error(err_msg_gen(125, 'axset', [names{j} '.min_ovr'])) % bad size
                    end
                else
                    error(err_msg_gen(123, 'axset', [names{j} '.min_ovr'], class(f.min_ovr), 'numeric')) % bad type
                end % ischar
            else
                % set default value of axis scale
                % becaues job result is not yet fully loaded, set it to NaN and
                % funcion make_lut will fill it to proper value
                axset.(Qs{j}).(fs{j}).min_ovr = NaN;
            end % if isfield min_lim

            if isfield(f, 'max_ovr') %<<<2
                if isnumeric(f.max_ovr)
                    if not(isscalar(f.max_ovr))
                        error(err_msg_gen(125, 'axset', [names{j} '.max_ovr'])) % bad size
                    end
                else
                    error(err_msg_gen(123, 'axset', [names{j} '.max_ovr'], class(f.max_ovr), 'numeric')) % bad type
                end % ischar
            else
                % set default value of axis scale
                % becaues job result is not yet fully loaded, set it to NaN and
                % funcion make_lut will fill it to proper value
                axset.(Qs{j}).(fs{j}).max_ovr = NaN;
            end % if isfield max_lim
    end % for j 1..names
end % function check_gen_axset

function rqset = check_gen_rqset(rqset) %<<<1
% check input structure rqset - result quantity settings 
    if isempty(rqset)
        rqset = struct();
    end
    [Qs, fs, names] = get_Qs_fs_names(rqset);
    % for all quantities and fields of quantities, check existence and values of
    % fields, add default values for missing field
    for j = 1:numel(names)
        f = rqset.(Qs{j}).(fs{j});

        if isfield(f, 'scale') %<<<2
            if ischar(f.scale)
                if not(strcmpi(f.scale, 'lin') || strcmpi(f.scale, 'log'))
                    error(err_msg_gen(124, 'rqset', [names{j} '.scale'], f.scale, '`lin` or `log`')) % bad value
                end
            else
                error(err_msg_gen(123, 'rqset', [names{j} '.scale'], class(f.scale), 'char')) % bad type
            end % ischar
        else
            % set default value of axis scale:
            axset.(Qs{j}).(fs{j}).scale = 'lin';
        end % if isfield scale

    end % for j 1..names
end % function check_gen_rqset

function ipoint = check_gen_ipoint(lut, ipoint) %<<<1
% check input structure ipoint - interpolation point
% checks if ipoint defines values for all LUT axes
 % XXX 2DO in future - generate values of missing ipoint axes from lut.ax.Q.f.def
    if isempty(ipoint)
        error(err_msg_gen(16)) % ipoint must be struct
    end
    for j = 1:numel(lut.ax_Q)
        ok = 0;
        if isfield(ipoint, lut.ax_Q{j})
            if isfield(ipoint.(lut.ax_Q{j}), lut.ax_f{j})
                ok = 1;
                if ~isscalar(ipoint.(lut.ax_Q{j}).(lut.ax_f{j}))
                    error(err_msg_gen(141, lut.ax_names{j})) % ipoint not scalar
                end
            end
        end
        if not(ok)
            error(err_msg_gen(140, lut.ax_names{j})) % missing Q.f in ipoint
        end
    end % for j
end % function check_gen_ipoint

% -------------------------------- variation %<<<1
function [varlist] = make_varlist(datain, datainvar) %<<<1
% Finds out which Q are to be variated, finds out the dimension of Q.f that has
% to be variated, and number of variations. Put all in varlist structure (see
% description of varlist.
% It was already checked that all Qs and fields of Qs in datainvar are correct
% with respect to the datain in function check_datainvar.

    varlist.Q = cell(0);     % quantities to be variated
    varlist.f = cell(0);     % fields of Q to be variated
    varlist.names = cell(0);    % concatenated string
    varlist.dim = [];     % dimension of Q.f that should be variated
    varlist.dimsz = [];   % size of dimension dim of Q.f that should be variated
    Qnamesvar = fieldnames(datainvar);  % all quantities that will be variated
    for j = 1:length(Qnamesvar)
        Fnamesvar = fieldnames(datainvar.(Qnamesvar{j})); % fields of quantity that will be variated
        for k = 1:length(Fnamesvar)
            szf   = size(datain.(Qnamesvar{j}).(Fnamesvar{k}));   % size of datain quantity/field
            szfvar = size(datainvar.(Qnamesvar{j}).(Fnamesvar{k})); % size of datainvar quantity/field
            if numel(szfvar) > numel(szf)
                % fill in zero dimensions to get same number of dimensions for
                % szf as in szfvar for easy comparison later
                szf(k) = zeros(numel(szfvar) - numel(szf));
            end % if
            % find out differing dimensions
            id = find(not(szf == szfvar));
            varlist.Q = [varlist.Q Qnamesvar(j)]; % actual quantity
            varlist.f = [varlist.f Fnamesvar(k)]; % actual field
            varlist.names = [varlist.names [Qnamesvar{j} '.' Fnamesvar{k}]]; % composed quantity.field
            varlist.dim = [varlist.dim id(1)]; % actual dimension that contains variated values of the field
            varlist.dimsz = [varlist.dimsz szfvar(varlist.dim(end)) - szf(varlist.dim(end)) + 1]; % actual number of variations
            % XXX remove after making lone function XXX ndaxes{end+1} = datainvar.(Qnamesvar{j}).(Fnamesvar{k});
        end % for % k = 1:length(Qvarfields)
    end % for % j = 1:length(Qnamesvar);
    % number of parameters for variation:
    varlist.n = numel(varlist.Q);
end % function % make_varlist

function [calcplan] = make_calculation_plan(varlist) %<<<1
% prepare variation informations with plan for calculations

    % total number of calculations
    % (e.g. if dimension sizes of variated Q.f{1}, Q.f{2} are 2,3, than count = 6)
    % (matlab must obtain *row* vector in second argument
    calcplan.count = prod(varlist.dimsz(:)');
    % this is for simplification of lines in this function:
    C = calcplan.count;
    % number of variated Q.f:
    n = varlist.n;
    
    % prepare empty structure:
    calcplan.Q = cell(C, n);
    calcplan.f = cell(C, n);
    calcplan.dim = zeros(C, n);
        % XXX smazat neni pouzite calcplan.dimsz = zeros(C, n);
    calcplan.dimidx = zeros(C, n);

    % XXX co to je? variace s opakovanim. proc na tohle neni funkce v matlabu
    % neetusim. pridat pekne vysvetleni by to chtelo
    % prepare dimension sizes for multidimensional meshgrid:
    for i = 1:n
        c{i} = [1:varlist.dimsz(i)];
    end % for i
    % multidimensional meshgrid, one cell for every Q.f:
    MG = cell(n,1);
    [MG{:}] = ndgrid(c{:});
    % make calcplan structure:
    for i = 1:n
        % fill in collumn for every variated Q.f
        calcplan.Q(:, i) = repmat(varlist.Q(i), C, 1);
        calcplan.f(:, i) = repmat(varlist.f(i), C, 1);
        calcplan.names(:, i) = repmat(varlist.names(i), C, 1);
        calcplan.dim(:, i) = repmat(varlist.dim(i), C, 1);
        % reshape correctly meshgrid into vector:
        calcplan.dimidx(:, i) = reshape(MG{i}, C, 1);
    end % for % i = 1:n
    % generate job indexes, as vector:
    calcplan.job_ids = 1:C;
    if varlist.n > 1
        % reshape got sense only if more than 1 variated quantity
        % (matlab must obtain *row* vector in second argument
        calcplan.ndimjobids = reshape(calcplan.job_ids, varlist.dimsz(:)');
    end % if varlist.n > 1
end % function [calcplan] = make_calculation_plan(varlist)

function datainout = variate_datain(job, calcno) %<<<1
% change datain according calculation plan and calculation index calcno

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

function job = prepare_calculations(algid, datain, datainvar, calcset) %<<<1
% prepare all needed for new calculation
    % initialize variable 'job'
    job = init_job_structure(algid, datain, datainvar, calcset);
    % find out variation parameters and their dimensions
    [job.varlist] = make_varlist(datain, datainvar);
    % create calculation plan
    [job.calcplan] = make_calculation_plan(job.varlist);
    job.count = job.calcplan.count; % XXX casem zrusit job.count, neni potreba
    % display number of variations/calculations:
    disp_msg(2, num2str(job.count));

    % initialize filenames and directory
    job = init_filenames(job, calcset);

    % ensure job main file exists
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
end % function prepare_calculations

function job = run_calculations(job) %<<<1
% calculate all variations, singlecore/multicore/multistaion processing
% XXX full description
    % XXX use ! runmulticore from package multicore, the same in qwtb!
    time_start = tic();
    % run parallel processing
    % XXX check calculation settings for parallel processing
    % XXX add direct run of job qwtbvar('job', job_ids)
    % XXX divide job_ids into chunks and run parallel calculation of function calculate_job - just use multicore
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
end % function job = run_calculations(job)

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
            if exist(job.resultfns{job_id}, 'file')
                % job result exist, display message and quit
                disp_msg(4, job.resultfns{j}); %result exist
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
                disp_msg(3, job_id, job.count, job.resultfns{job_id}); % calculating result no
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
                save('-v7', job.resultfns{job_id}, 'DO', 'DI', 'CS');
                disp_msg(5, job.resultfns{job_id}) % result saved
            end % if exist(job.resultfns{job_id}, 'file')
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

function job = finish_calculations(job) %<<<1
    % load results
    resdata = load_result_files(job);
    % reshape results into n-dimensional matrix and create axes:
    [job.ndres, job.ndresc, job.ndaxes] = reshape_results_create_ndaxes(job, resdata);
    % save final reshaped results:
    save('-v7', job.fullresultfn, 'job');
end % function finish_calculations

% -------------------------------- plotting %<<<1
function H = plot_2D(jobfn, X, Y, plottitle) %<<<1
% plots 2D figure with possible x/y/xy errorbars
% returns handle to the figure
% Inputs: filename of the job
%         plot quantity X (independent)
%         plot quantity Y (dependent)
%         plot title
% Outputs: handle to the plot

    % Plotting
    figure
    hold on
    if isempty(X.bars) && isempty(Y.bars)
        H = plot(X.data, Y.data, '-x');
    else
        if isempty(Y.bars)
            % because errorbar input cannot be multiple lines at once (contrary
            % to plot()):
            for j = 1:size(Y.data, 2)
                H = errorbar(X.data, Y.data(:, j), X.bars, ">x-");
            end % for
        elseif isempty(X.bars)
            % because errorbar input cannot be multiple lines at once (contrary
            % to plot()):
            for j = 1:size(Y.data, 2)
                H = errorbar(X.data, Y.data(:, j), Y.bars(:, j), "~x-");
            end % for
        else
            % errorbar is making cluttered figures, ellipses are better
            % H = errorbar(X.data, Y.data, X.bars, Y.bars, "~>rx-");
            drawEllipse(X.data, Y.data, X.bars, Y.bars, 'g-', 'HandleVisibility', 'off');
            H = plot(X.data, Y.data, 'x-r');
        end % if
    end % if % isempty(X.bars) && isempty(Y.bars)
    % create legend if needed:
    if not(isempty(Y.leg))
        legend(Y.leg)
    end
    % Add plot labels
    xlabel(X.lbl, 'interpreter', 'none');
    ylabel(Y.lbl, 'interpreter', 'none');
    % Make ticklabels
    if not(isempty(X.ticklbl))
        % Set x tick labels, because x data values are arbitrary:
        xticks(X.data);
        xticklabels(X.ticklbl);
    end
    if not(isempty(Y.ticklbl))
        % Set y tick labels, because y data values are arbitrary:
        yticks(Y.data);
        yticklabels(Y.ticklbl);
    end
    % Title and finish
    title(plottitle, 'interpreter', 'none');
    hold off
end % function % plot_2D

function H = plot_3D(jobfn, X, Y, Z, plottitle) %<<<1
% plots 3D figure with possible x/y/z errorbars % XXX not working yet
% returns handle to the figure
% Inputs: filename of the job
%         plot quantity X (independent)
%         plot quantity Y (independent)
%         plot quantity Z (dependent)
%         plot title
% Outputs: handle to the plot
%
% XXX no idea how to plot 3D surface plots with x uncertainties, only by
% using multilines in single plot

    % number of surfaces to plot:
    surfaces = size(Z.data, 2)./numel(X.data);
    % check if Z.data contains exactly integer number of surfaces to plot:
    if not(surfaces == round(surfaces))
        error('internal error, mixed rows/collumns') %XXX
    end % if
    % Make surface plot
    figure
    hold on
    % go through collumns and plot surface by surface:
    for j = 1:surfaces
        ids = 1 + (j-1).*numel(X.data);
        ide = j.*numel(X.data);
        H = surf(X.data, Y.data, Z.data(:, ids:ide));
    end
    view(45,45);
    % create legend if needed:
    if not(isempty(Z.leg))
        legend(Z.leg)
    end
    % Add plot labels
    xlabel(X.lbl, 'interpreter', 'none');
    ylabel(Y.lbl, 'interpreter', 'none');
    zlabel(Z.lbl, 'interpreter', 'none');
    if not(isempty(X.ticklbl))
        % Set x tick labels, because x data values are arbitrary:
        xticks(X.data);
        xticklabels(X.ticklbl);
    end
    if not(isempty(Y.ticklbl))
        % Set x tick labels, because y data values are arbitrary:
        yticks(Y.data);
        yticklabels(Y.ticklbl);
    end
    title(plottitle, 'interpreter', 'none');
    hold off
end % function % plot_3D

function [X, Y, Z] = get_plot_data(job, ndres_sliced, ndresc_sliced, ndaxes_sliced, varx, vary, varz, fullresultfn) %<<<1
% Obtains data for plotting from defined ndres, ndaxes and
% job.datain/job.datainvar.
% Outputs data in plotting form, i.e. shape of data is in vectors.
% Outputs also neded labels if variables were not scalar.

    % initialize %<<<2
    % Prepare output variables - plot quantities
    % .name - name of variable in datain/dataout
    % .Q - quantity part of .name
    % .f - field part of .name
    % .uncbar - 0/1 if uncertainties are to be plotted or not
    % (uncertainty bars is not the same as uncertainty! user could ask for
    % plotting uncertainty as the main value! - i.e. dependence of y.u on x.u)
    % .data - value to plot (can be anything, e.g. .v, .u, as user asks)
    % .bars - value for plot error bars, should be only .u if .u is not already in .plot.
    % .lbl - axis labels
    % .ticklbl - tick labels in the case of arbitrary axis values.
    % .leg - legend values for multiplots (not in X)
    X.name = varx;
    X.Q = '';
    X.f = '';
    X.uncbar = 1;
    X.data = [];
    X.bars = [];
    X.lbl = [];
    X.ticklbl = [];
    Y.name = vary;
    Y.Q = '';
    Y.f = '';
    Y.uncbar = 1;
    Y.data = [];
    Y.bars = [];
    Y.lbl = [];
    Y.ticklbl = [];
    Y.leg = {};
    Z.name = varz;
    Z.Q = '';
    Z.f = '';
    Z.uncbar = 1;
    Z.data = [];
    Z.bars = [];
    Z.lbl = [];
    Z.ticklbl = [];
    Z.leg = {};
    % prepare uncertainty settings:
    yuncbar = 0; % plot uncertainty bars for y? XXX delete?
    zuncbar = 0; % plot uncertainty bars for z? XXX delete?

    % Parse input variables %<<<2
    % User input can be defined as only 'Q', then 'Q.v' will be plotted.
    [X.Q, X.f] = parse_Q_f(X.name);
    % If .f not supplied, select value ('.v'):
    if isempty(X.f)
        % if field was missing, plot '.v' with '.u'
        X.f = 'v';
        X.name = [X.Q '.v'];
        X.uncbar = 1;   % do uncertainty bars
    end % if
    if strcmp(X.f, 'u')
        X.uncbar = 0;
    end

    [Y.Q, Y.f] = parse_Q_f(Y.name);
    if isempty(Y.f)
        % if field was missing, plot .v with .u
        Y.f = 'v';
        Y.name = [Y.Q '.v'];
        Y.uncbar = 1;   % do uncertainty bars
    end % if % isempty(Y.f)
    if strcmp(Y.f, 'u')
        Y.uncbar = 0;
    end

    if isempty(varz)
        Qz = []; fz = [];   % only 2D data required
        % (there is [] and not '' because field with empty string is valid
        % and can be constructed: a.('') = 5. However isfield(a,[]) results
        % in 0 and that is ok.
        zuncbar = 0;
    else
        [Z.Q, Z.f] = parse_Q_f(varz);
        if isempty(Z.f)
            % if field was missing, plot .v with .u
            Z.f = 'v';
            Z.name = [Z.Q '.v'];
            Z.uncbar = 1;   % do uncertainty bars
        end % if % isempty(Z.Q)
        if strcmp(Z.f, 'u')
            Z.uncbar = 0;
        end
    end % if % isempty(varz)

    % Get plot quantities %<<<2
    % This permutes ndresc in such way to move xvar as first axis
    [X, ndres_sliced, ndresc_sliced, ndaxes_sliced] = get_independent_variable(X, ndresc_sliced, ndaxes_sliced, fullresultfn);
    % Get vary/z
    if isempty(varz)
        % Preparing for a 2D plot
        [Y] = get_dependent_variable(Y, ndresc_sliced, ndaxes_sliced, 1, fullresultfn);
    else % if isempty(varz)
        % Preparing for a 3D plot
        [Y, ndres_sliced, ndresc_sliced, ndaxes_sliced] = get_independent_variable(Y, ndresc_sliced, ndaxes_sliced, fullresultfn);
        [Z] = get_dependent_variable(Z, ndresc_sliced, ndaxes_sliced, 2, fullresultfn);
    end % if isempty(varz)
    % Add labels %<<<2
    Y.lbl = vary;
    Z.lbl = varz;
end % function ndresc_to_variables()

function constsstr = consts_to_string(consts) %<<<1
% Creates string with consts values to be used in a plot title.
% Input: consts structure with constant quantities and its values
% Ouput: string for plot title.
    constsstr = '';
    Qs = fieldnames(consts);
    for j = 1:numel(Qs)
        Q = Qs{j};
        fs = fieldnames(consts.(Q));
        for k = 1:numel(fs)
            f = fs{k};
            if isscalar(consts.(Q).(f))
                valuestr = sprintf('%g', consts.(Q).(f));
            else
                valuestr = sprintf('[%g, %g', consts.(Q).(f)(1), consts.(Q).(f)(2));
                if numel(consts.(Q).(f)) > 2
                    valuestr = [valuestr '...'];
                else
                    valuestr = [valuestr ']'];
                end % if
            end % if isscalar
            constsstr = sprintf('%s\n%s.%s=%s', constsstr, Q, f, valuestr);
        end % for k
    end % for j
end % function constsstr = consts_to_string(consts)

function PQ = make_axis_and_ticklabels(PQ) %<<<1
% If variable for figure is made of nonscalar values, create fake values and
% nice ticklabels for figure.
% Input: plot quantity
% Output: plot quantity
    if iscell(PQ.data)
        % If values is a cell, either convert it to simple scalar values, or
        % create fake values and nice ticklabels.
        % Find out if all cell content are scalars:
        scalars = cellfun(@isscalar, PQ.data, 'UniformOutput', true);
        if all(scalars)
            % Just convert cell to simple scalar values.
            PQ.data = [PQ.data{:}];
            % Ticklabels are not needed:
            PQ.ticklbl = [];
        else
            % Values are nonscalars. Create fake values and ticklabels for axis
            % from content of cells:
            for j = 1:numel(PQ.data);
                if numel(PQ.data{j}) == 2
                    PQ.ticklbl{j} = sprintf('[%.3g, %.3g]', PQ.data{j}(1), PQ.data{j}(2));
                else
                    PQ.ticklbl{j} = sprintf('[%.3g, %.3g...', PQ.data{j}(1), PQ.data{j}(2));
                end
            end % for
            PQ.data = 1:numel(PQ.data);
        end % if all(scalars)
    end % if iscell(PQ.data)
end % function make_axis_and_ticklabels

function [PQ, ndres, ndresc, ndaxes] = get_independent_variable(PQ, ndresc, ndaxes, fullresultfn) %<<<1
% Gets data for independent variable PQ for plotting - i.e. input variable that
% was varied. Moves independent variable axis to be the first dimension of
% results (ndres, ndresc).
% Inputs: plot quantity PQ
%         n-dimensional cell matrix with results
%         n-dimensional axes
%         name of the job file
% Outputs: plot quantity PQ
%          n-dimensional cell matrix with results
%          n-dimensional axes, name of the job file
%   Outputs ndresc and ndaxes are permuted and changed so the independent
%   variable is at first axis.

    % Check if PQ.name is in varied data, i.e. ndaxes:
    % (find the axis)
    varaxisindex = find(strcmp(ndaxes.names, PQ.name));
    if not(isempty(varaxisindex))
        % PQ.name is in ndaxes:
        % permute to get PQ.name as the  first dimension:
        % (that will be usefull for reshaping the data for yvar)
        [ndresc ndaxes] = general_permute(ndresc, ndaxes, {PQ.name});
        % Remove singleton dimensions - what if this will remove xvar?!!! XXX
        [ndresc ndaxes consts_out] = simplify_ndresc_and_ndaxes(ndresc, ndaxes);
        [ndres] = CoS_to_SoC(ndresc);
        PQ.data = ndaxes.valuesc{1}; % cell axis will be converted in next line
        % create fake values and ticklabels if PQ does not conain scalar data:
        PQ = make_axis_and_ticklabels(PQ);
        % Take uncertainties from datainvar
        % What if uncertainties are varied? how to find proper value? XXX
        % if uncertainty is in ndaxes, take proper value from sliced. if not, it
        % is constant and take from datain
        if PQ.uncbar
            % if uncertainties in ndaxes, than it has to be taken during
            % dependent_variable.
            % if uncertainties fixed, take from job
            % 2DO XXX FINISH ME! missing X.uncbar!
            PQ.uncbar = 0;
            PQ.bars = [];
        end % if
    else
        % if xvar is not in ndaxes, but only in DI, the plot would be a single
        % point, or multiple points over each other, because all values on x
        % axis (or x&y axis) will be on the same value. There is no sense to
        % plot it.
        % Variable not found in ndaxes:
        error(err_msg_gen(90, PQ.name, fullresultfn)); % var not found in input data.
    end % if

    PQ.lbl = PQ.name;
end % function get_independent_variable

function [PQ] = get_dependent_variable(PQ, ndresc, ndaxes, independent_dimensions, fullresultfn) %<<<1
% Gets data for depenednt variable PQ for plotting - i.e. output variable.
% Inputs: plot quantity PQ
%         n-dimensional cell matrix with results
%         n-dimensional axes
%         number of independent dimensions (2D figure -> 1, 3D figure -> 2)
%         name of the job file
% Outputs: plot quantity PQ

    % vary should be in the output data:
    if not(isfield(ndresc{1}, PQ.Q))
        error(err_msg_gen(90, [PQ.Q '.' PQ.f], fullresultfn)); % var not found in output data.
    end % if
    if not(isfield(ndresc{1}.(PQ.Q), PQ.f))
        error(err_msg_gen(90, [PQ.Q '.' PQ.f], fullresultfn)); % var not found in output data. - the message is "in result file", has to be changed to "result data" XXX
    end % if
    % Hard check if uncertainties also will be obtained:
    if PQ.uncbar
        if not(isfield(ndresc{1}.(PQ.Q), 'u'));
            PQ.bars = [];
            PQ.uncbar = 0;
        end
    end
    % Go through all remaining axes and create matrix of Y.data and
    % Y.bars values. Also make a proper label based on constants needed to
    % generate curves for Y.data.
    if not(numel(ndaxes.names) > independent_dimensions)
        % Simple case - right number of axes as needed, no redundant axes
        ndres = CoS_to_SoC(ndresc);
        PQ.data = ndres.(PQ.Q).(PQ.f);
        if PQ.uncbar
            PQ.bars = ndres.(PQ.Q).('u');
        end % if
        PQ.leg = {};
    else % case for numel(ndaxes.names) > independent_dimensions
        % More axes than needed for simple 2D plotting with one plot line.
        % n will be the number of redundant axes. -1 is because first axis
        % is the one that user wants to plot against. We did general permute
        % when X data were obtained. All other axes are redundant and cause
        % multiple lines in the plot:
        n = numel(ndaxes.names) - independent_dimensions;
        % Get dimensions of redundant axes:
        for i = 1:n % for number of redundant axes
            c{i} = [1:numel(ndaxes.valuesc{independent_dimensions + i})];
        end % for i
        % Multidimensional meshgrid, one cell for every axis:
        MG = cell(n, 1);
        [MG{:}] = ndgrid(c{:});
        resMG = [];
        % Create variations for all values of all redundant axes:
        for j = 1:numel(MG)
            resMG = [resMG MG{j}(:)]; 
        end
        % Now resMG contains indexes of values of redundant axes. Every row
        % is one variation.
        for j = 1:size(resMG, 1) % for all values/variations of redundant axes
            % Generate intermediate consts structure that will define values
            % of redundant axes for slicing to get actual line for plot.
            consts_redundant = struct();
            for k = 1:size(resMG, 2) % for all axes but independent ones (first ones)
                axid = independent_dimensions + k;
                consts_redundant.(ndaxes.Q{axid}).(ndaxes.f{axid}) = ...
                    squeeze(ndaxes.valuesc{axid}{resMG(j, k)});
            end % for j
            % Make slice
            [ndresc_slice_redundant, ndaxes_redundant] = slice_ndresc_and_ndaxes(ndresc, ndaxes, consts_redundant);
            [ndres_slice_redundant] = CoS_to_SoC(ndresc_slice_redundant);
            % Now ndres_slice2 should contains only single vector that is
            % possible to plot in 2D:
            PQ.data = [PQ.data ndres_slice_redundant.(PQ.Q).(PQ.f)];
            if PQ.uncbar
                PQ.bars = [PQ.bars ndres_slice_redundant.(PQ.Q).('u')];
            end % if
            % Create legend based on constant values of redundant axes:
            PQ.leg = [PQ.leg consts_to_string(consts_redundant)];
        end % for k
    end % if Y.data
    % Although it does not make sense for 2D plots, create fake values and
    % ticklabels if Y does not contain scalar data:
    % XXX add warning this does not make sense
    PQ = make_axis_and_ticklabels(PQ);
end % function get_dependent_variable
 
% -------------------------------- LUT %<<<1
function [lut] = make_lut(ndres, ndresc, ndaxes, varlist, axset, rqset) %<<<1
% Simple generator of multidim lookup table (LUT)
    lut = struct();

    % check axes %<<<2
    % get axes in the user ax parameter, i.e. find axes of the LUT:
    [axset_Qs, axset_fs, axset_names] = get_Qs_fs_names(axset);
    % check if all axes in ndaxes are defined in user axset
    for j = 1:numel(ndaxes.names)
        tmp = strcmpi(ndaxes.names{j}, axset_names);
        if ~any(tmp)
            err_msg_gen(120, ndaxes.names{j}); % Q not defined in axset
        end
    end % for j
    % make axes %<<<2
    % pair quantities of axset and quantities of ndaxes
    for j = 1:numel(axset_names)
        for k = 1:numel(ndaxes.names)
            if strcmp(axset_names{j}, ndaxes.names{k})
                axset.(axset_Qs{j}).(axset_fs{j}).val = ndaxes.values{k};
                % check and fill NaNs in .max_ovr and .min_ovr when
                % check_gen_axset was run, the job was not yet loaded so it
                % couldn't be filled
                if isnan(axset.(axset_Qs{j}).(axset_fs{j}).min_ovr)
                    axset.(axset_Qs{j}).(axset_fs{j}).min_ovr = min(axset.(axset_Qs{j}).(axset_fs{j}).val);
                end
                if isnan(axset.(axset_Qs{j}).(axset_fs{j}).max_ovr)
                    axset.(axset_Qs{j}).(axset_fs{j}).max_ovr = max(axset.(axset_Qs{j}).(axset_fs{j}).val);
                end
            end
        end % for
    end % for
    % add axes to lut %<<<2
    % add axis info into lut structure:
    lut.ax = axset;
    lut.ax_names = axset_names;
    lut.ax_Q = axset_Qs;
    lut.ax_f = axset_fs;
        
    % check results %<<<2
    % get quantities in rq parameter, i.e. results of the LUT:
    [rqset_Qs, rqset_fs, rqset_names] = get_Qs_fs_names(rqset);
    % Qs and fs are taken from ndres (not ndresc) because QWTBVAR can
    % interpolate only scalars
    [ndres_Qs, ndres_fs, ndres_names] = get_Qs_fs_names(ndres);
    % check if quantities in rqset are in results:
    for j = 1:numel(rqset_names)
        tmp = strcmpi(rqset_names{j}, ndres_names);
        if ~any(tmp)
            err_msg_gen(121, rqset_names{j}); % Q in rq not in results
        end
    end % for j

    % make results %<<<2
    % add definition of quantities
    lut.rq = rqset;
    % add N-dimensional matrices (variation results)
    for j = 1:numel(rqset_names)
        % result (data) matrix:
        lut.rq.(rqset_Qs{j}).(rqset_fs{j}).val = ndres.(rqset_Qs{j}).(rqset_fs{j});
    end % for j = 1:numel(qu_names)

    % add results to lut %<<<2
    lut.rq_names = rqset_names;
    lut.rq_Q = rqset_Qs;
    lut.rq_f = rqset_fs;
end % function make_lut

function [ndres, ndresc, ndaxes] = reshape_results_create_ndaxes(job, resdata) %<<<1
% Reshape results into a n-dimensional matrices and create axes of the matrices.
% This helps for selecting data for plotting and further analysis
%
% ndres is structure with Q.f, where .f is matrix for scalar outputs or cell for nonscalar outputs)
%
% ndresc is cell with structures Q.f, where .f is scalar/matrix according to the
% output

    % create n-dimensional cell %<<<2
    % Get only output data:
    for j = 1:numel(resdata)
        ndresc{j} = resdata{j}.DO;
    end
    % Reshape results to proper size
    % If only 1 variated quantity, no reshaping needed.
    % (axes of ndimres are job.varlist.names)
    if job.varlist.n > 1
        % reshape got sense only if more than 1 variated quantity
        % (matlab must obtain *row* vector in second argument
        % XXX what if reshape do not reshape according ndaxis created elsewhere?
        % dimsz should ensure it!? or not?
        ndresc = reshape(ndresc, job.varlist.dimsz(:)');
    end % if job.varlist.n > 1
    % convert ndresc to structure of cells:
    ndres = CoS_to_SoC(ndresc);

    % Create ndaxes %<<<2
    % Structure ndaxes holds information on axes of n-dimensional matrices.
    % Add names, Q, f (copy of job.varlist):
    ndaxes.names = job.varlist.names;
    ndaxes.Q = job.varlist.Q;
    ndaxes.f = job.varlist.f;
    % Suppose all axes are scalar:
    allaxesscalar = 1;
    % Go trhough all variated quantities:
    for j = 1:numel(job.varlist.dimsz)
        % Actual variated quantity:
        Q = ndaxes.Q{j};
        f = ndaxes.f{j};
        % Prepare slice according dimension of actual variated quantity:
        C = repmat({1},1,ndims(job.calcplan.ndimjobids));
        C{j} = ':';
        % Make slice. idxs contains indexes of results where ony one quantity
        % was varied. This will be used to copy values of variated quantities.
        % (ndaxes could have been created during calculate_job subfunction, but
        % this way is more safe because it takes actual results)
        idxs = job.calcplan.ndimjobids(C{:});
        % Suppose actual axis is scalar:
        isscalaraxis = 1;
        % Go through all values of actually variated quantity/axis
        for k = 1:numel(idxs)
            % Assign value of axis:
            ndaxes.valuesc{j}{k} = resdata{idxs(k)}.DI.(Q).(f);
            % Check if axis is still purely scalar:
            if not(all(size(ndaxes.valuesc{j}{k}) == 1))
                isscalaraxis = 0;
            end % if
        end % for k = 1:numel(idx)
        % Resize axis into proper dimension (first axis to first dimension
        % etc.):
        C = repmat({1}, 1, ndims(job.calcplan.ndimjobids));
        C{j} = job.varlist.dimsz(j);
        ndaxes.valuesc{j} = reshape(ndaxes.valuesc{j}, C{:});
        % If actual axis is not scalar, than all axes are not scalar:
        if not(isscalaraxis)
            allaxesscalar = 0;
        else
            % If scalar axis, convert cell to simple matrix:
            % (this keep dimensions)
            ndaxes.values{j} = cell2mat(ndaxes.valuesc{j});
        end % if
    end % for j = 1:numel(job.varlist.dimsz)

    % XXX Create n-dimensional matrices %<<<2
    % CoS_to_SoC(ndaxes.valuesc); XXX tohle nefunguje protoze ta funkce je jen
    % pro Q.f strukturu!

end % function reshape_results()

% -------------------------------- interpolation %<<<1
function w = interp_weights(lut, ipoint) %<<<1
% calculate weights matrix for interpolation based on interpolation point

    % dimensions of the results (use first result quantity from LUT):
    adims = size(lut.rq.(lut.rq_Q{1}).(lut.rq_f{1}).val);

    % create interpolation weigth matrix:
    %  note: at this point same weight for all axes
    w = ones(adims);

    % for each LUT axis:
    for a = 1:numel(lut.ax_names);
        % actual LUT axis setup:
        cax = lut.ax.(lut.ax_Q{a}).(lut.ax_f{a});
        % actual LUT axis values:
        vax = cax.val(:);
        % get interpolation value for the actual LUT axis from ipoint (interpolation point):
        ai = ipoint.(lut.ax_Q{a}).(lut.ax_f{a});

        % check axis limits, coerce interp. point to valid range
        if ai < cax.min_ovr
            % required axis value too low:
            if strcmpi(cax.min_lim, 'error')
                error(err_msg_gen(142, num2str(ai), lut.ax_names{a}, num2str(cax.min_ovr), num2str(cax.max_ovr)))
            elseif strcmpi(cax.min_lim, 'const')
                % limit interpolation value 'ai' to the nearest axis spot:
                ai = min(vax);
            else
                % unknown min_lim value
                error(err_msg_gen(122, ['ax.' lut.ax_names{a} '.min_lim'], cax.min_lim))
            end
        elseif ai > cax.max_ovr
            % required axis value too high:
            if strcmpi(cax.max_lim, 'error')
                error(err_msg_gen(142, num2str(ai), lut.ax_names{a}, num2str(min(cax.val)), num2str(max(cax.values))))
            elseif strcmpi(cax.max_lim,'const')
                % limit interpolation value 'ai' to the nearest axis spot:
                ai = max(vax);
            else
                % unknown max_lim value
                error(err_msg_gen(122, ['ax.' lut.ax_names{a} '.min_lim'], cax.max_lim))
            end            
        end

        % select mode of interpolation:
        if strcmpi(cax.scale,'log')
            % log-scale interpolation:
            vax = log10(vax);
            ai = log10(ai);
        elseif ~strcmpi(cax.scale,'lin')
            % unknown scale value
            error(err_msg_gen(122, ['ax.' lut.ax_names{a} '.scale'], cax.scale))
        end

        % create axis interpolation mask:
        wa = zeros(size(vax));
        
        % descending axis values?
        is_descend = any(diff(vax) < 0);
                
        % if at limit of axis, set weight at limits to 1
        % i.e. if value of axis is at upper max of lut axis, the weight vector is 0;0;...;0;1
        % i.e. if value of axis is at lower min of lut axis, the weight vector is 1;0;...;0;0
        % i.e. if value of axis is somewhere in the middle, the weight vector is 0;0;...;1;...;0;0
        % or                                                                    0;0;...;0.5;0.5;...;0;0
        if ai <= min(vax)
            % left limit:
            if is_descend
                wa(end) = 1;
            else
                wa(1) = 1;
            end                
        elseif ai >= max(vax)
            % right limit:
            if is_descend
                wa(1) = 1;
            else
                wa(end) = 1;
            end
        else
            % interpolate the axis:
            if is_descend
                % descending axis order:
                id = find(vax > ai,1,'last');               
                ws = (vax(id) - ai)/(vax(id) - vax(id+1));                
                wa(id+0) = 1 - ws;
                wa(id+1) = ws;
            else
                % ascending axis order:
                id = find(ai > vax,1,'last');               
                ws = (ai - vax(id))/(vax(id+1) - vax(id));                
                wa(id+0) = 1 - ws;
                wa(id+1) = ws;
            end                
        end

        % expand the axis interpolation mask to all dimensions:
        wdim = ones(size(adims));
        wdim(a) = adims(a);
        wa = reshape(wa,wdim);                                                 
        rdim = adims;
        rdim(a) = 1;
        wa = repmat(wa,rdim);
        
        % combine the mask with previous axes:
        w = bsxfun(@times,w,wa);            
    end
end % function interp_weight

function val = interp_val(lut, w) %<<<1
    % init result struct (interpolated values):
    val = struct();
    for k = 1:numel(lut.rq_names);
        % quantity name:
        q_name = lut.rq_names{k};
        
        % get quantity and its value:
        rq = lut.rq.(lut.rq_Q{k}).(lut.rq_f{k});
        value = rq.val;

        % linearize logarithmic quantity before interpolation for better results:
        is_log = 0;
        if strcmpi(rq.scale, 'log')
            is_log = 1;
            value = log10(value);
        elseif ~strcmpi(rq.scale, 'lin')
            % bad value of rq.scale
            error(err_msg_gen(122, ['rq.' lut.rq_names{k} '.scale'], rq.scale))
        end

        value = value.*w;
        value = sum(value(:))/sum(w(:));

        % return back to unlog value
        if is_log
            value = 10^value;
        end

        % store interpolated quantity:
        val.(lut.rq_Q{k}).(lut.rq_f{k}) = value;
    end
end % function interp_val

% -------------------------------- unified message/error functions %<<<1
function disp_msg(varargin) %<<<1
    persistent isOctave
    if isempty(isOctave)
        isOctave = exist('OCTAVE_VERSION') ~= 0;
    end
    % generates display message, so all messages are at one place and visually unified

    % escape codes for colours:
    if isOctave
        ANSIwhiteonred = [char(27) '[37;41;1m'];
        ANSInormal = [char(27) '[0m'];
        ANSIwhiteongreen = [char(27) '[37;42;1m'];
    else
        ANSIwhiteongreen = '<strong>';
        ANSIwhiteonred = '<strong>';
        ANSInormal = '</strong>';
    end

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
                msg = ['Old job file `' varargin{2} '` was deleted.'];
            otherwise
                error(err_msg_gen(-5));
        end % switch
    catch ERR
        % try to catch index out of bound error, i.e. not enough input arguments (varargin out of bounds):
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

    persistent isOctave
    if isempty(isOctave)
        isOctave = exist('OCTAVE_VERSION') ~= 0;
    end

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
                msg = 'Input `consts` must be a valid structure. PLease read QWTBVAR documentation.';
            case 11
                msg = 'Input `axset` must be a valid structure. Please read QWTBVAR documentation.';
            case 12
                msg = 'Input `rqset` must be a valid structure. Please read QWTBVAR documentation.';
            case 13 % one input - lutfn
                msg = ['LUT file `' varargin{2} '` does not exist.'];
            case 14 % one input - jobfn
                msg = ['Job file `' varargin{2} '` does not contain variable `job`.'];
            case 15 % one input - lutfn
                msg = ['LUT file `' varargin{2} '` does not contain variable `lut`.'];
            case 16
                msg = ['Input `ipoint` must be a valied structure. Please read QWTBVAR documentation.'];
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
            case 90 % two inputs - var, resultfns
                msg = ['Quantity `' varargin{2} '` was not found in result file `' varargin{3} '`.'];
            case 91 % one input - algid
                msg = ['Quantity `' varargin{3} '` is not scalar.'];
            case 92 % two inputs - f, Q, resultfns
                % This number is empty
            case 93 % two inputs - resultfns, jobfile
                msg = ['Result file `' varargin{2} '` referenced in job file `' varargin{3} '` does not exist. Maybe calculations have not finished yet. Try running `qwtbvar(' char(39) 'cont' char(39) ', ' char(39) varargin{3} char(39) ')` to finish calculations.'];
            % ------------------- lut errors 120-139: %<<<2
            case 120 % one input - undefined Q
                msg = ['Quantity `' varargin{2} '` is missing in definition of LUT axes in `axset` parameter).'];
            case 121 % one input - missing Q in results 
                msg = ['Quantity `' varargin{2} '` in `rqset` parameter was not found in the results.'];
            case 122 % two inputs - bad lut parameter, parameter value
                msg = ['LUT parameter `' varargin{2} '` has incorrect value `' varargin{3} '`. Probably corrupted LUT data.'];
            case 123 % 4 inputs - axset/rqset, parameter name, actual type, correct type
                msg = ['Input `' varargin{2} '`, parameter `' varargin{3} '` has incorrect class `' varargin{4} '`, expected class is `' varargin{5} '`.'];
            case 124 % 4 inputs - axset/rqset, parameter name, actual value, correct value
                msg = ['Input `' varargin{2} '`, parameter `' varargin{3} '` has incorrect value `' varargin{4} '`, expected value(s) are: ' varargin{5} '.'];
            case 125 % 2 inputs - axset/rqset, parameter name
                msg = ['Input `' varargin{2} '`, parameter `' varargin{3} '` must be a scalar, vector LUT axes are not supported.'];
            % ------------------- interpolation errors 140-159: %<<<2
            case 140 % one input - lut axis name
                msg = ['Interpolation point does not contain value for LUT axis `' varargin{2} '`.'];
            case 141 % one input - lut axis name
                msg = ['Value of interpolation point at axis `' varargin{2} '` must be a scalar, vector LUT axes are not supported.'];
            case 142 % four inputs - ipoint value, lut axis name, lut axis low/high value
                msg = ['Value `' varargin{2} '` of interpolation point `' varargin{3} '` is exceeding span of LUT axis with overrange (' varargin{4} ' to ' varargin{5} ').'];
            otherwise
                msg = err_msg_gen(-3, errid);
                msg_generated = 1;
        end %>>>2
    catch ERR
        % try to catch index out of bound error, i.e. not enough input arguments (varargin out of bounds):
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

% -------------------------------- utilities %<<<1
function [Qs, fs, names] = get_Qs_fs_names(stru) %<<<1
% finds all fields and subfields of supposedly Quantities and fields (x.v, y.u, etc.)
% create a list of Qs, fs and names:
%   Qs = {'x','x','y'}
%   fs = {'v','u','v'}
%   names = {'x.v','x.u','y.v'}
    Qs = {};
    fs = {};
    names = {};

    if not(isempty(stru))
        fQ = fieldnames(stru);
        for j = 1:numel(fQ)
            ff = fieldnames(stru.(fQ{j}));
            for k = 1:numel(ff)
                Qs{end+1} = fQ{j};
                fs{end+1} = ff{k};
                names{end+1} = [fQ{j} '.' ff{k}];
            end
        end
    end % if not(isempty(stru))
end % function get_Qs_fs_names

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

function job = load_job(job) %<<<1
% if input is string, loads job file. if input is job structure, do nothing.
% this function ensures job structure is loaded
    if ~isstruct(job)
        if ~exist(job, 'file')
            error(err_msg_gen(8, job))% job does not exist
        end
        jobstr = job;
        load(job);
        if ~exist('job', 'var')
            err_msg_gen(14, jobstr) % file does not contain job variable
        end
    end % if % isstruct(job)
    % XXX what if job is not struct nor string. where is job checked?
end % function % load_job(job)

function job = load_final_result(job) %<<<1
% loads data from file with final result
    if not(exist(job.fullresultfn, 'file'))
        error(err_msg_gen(93, jobfn, jobfn)); % resultfns does not exist
    end % if
    % load result
    load(job.fullresultfn);
end % function resdata = load_final_result(job)

function resdata = load_result_files(job) %<<<1
% loads all particular results into resdata cell of structures
    for j = 1:numel(job.resultfns)
        % load data
        if exist(job.resultfns{j}, 'file')
            resdata{j} = load(job.resultfns{j});
        else
            error(err_msg_gen(93, job.resultfns{j}, jobfn)); % resultfns does not exist
        end % if
    end % for j = 1:job.resultfns
end % function resdata = load_result_files(job)

function lut = load_lut(lut) %<<<1
% if input is string, loads lut file. if input is lut structure, do nothing.
% this function ensures lut structure is loaded
    if ~isstruct(lut)
        if ~exist(lut, 'file')
            error(err_msg_gen(13, lut)) % lut does not exist
        end % if % ~exist(lut)
        lutstr = lut;
        load(lut);
        if ~exist(lut, 'lut')
            err_msg_gen(15, lutstr) % file does not contain job variable
        end
    end % if % isstruct(lut)
    % XXX what if lut is not struct nor string. where is lut checked?
end % function % load_lut(lut)

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

function job = generate_results_filenames(job) %<<<1
% generate filenames of result files
    % final result filename:
    job.fullresultfn = fullfile(job.calcset.var.dir, [job.calcset.var.fnprefix '_QV_final_res.mat']);
    if job.calcset.var.cleanfiles
        if exist(job.fullresultfn, 'file')
            delete(job.fullresultfn)
            disp_msg(7, job.fullresultfn); % result deleted
        end
    end % if job.calcset.var.cleanfiles

    % partial result filenames:
    resfnstart = fullfile(job.calcset.var.dir, [job.calcset.var.fnprefix '_QV_res_']);
    resfntemplate = ['%0' num2str(ceil(log10(job.count))+1, '%0d') 'd.mat'];
    for i = 1:job.count
        % whole string is not in sprintf to prevent sprintf to escape path: dir/subdir
        job.resultfns{i} = [resfnstart sprintf(resfntemplate, i)];
        if job.calcset.var.cleanfiles
            if exist(job.resultfns{i}, 'file')
                delete(job.resultfns{i});
                disp_msg(7, job.resultfns{i}); % result deleted
            end % if % exist(job.resultfns{i}, 'file')
        end % if % calcset.var.cleanfiles
    end % for % i = 1:job.count
end % function generate_results_filenames

function prepare_calculation_directory(calcset) %<<<1
% prepare directory for job files and temporary calculation files
    if ~exist(calcset.var.dir, 'dir')
        mkdir(calcset.var.dir);
    end % if % ~exist(calcset.var.dir)
    if ~exist(calcset.var.dir, 'dir')
        error(err_msg_gen(30, calcset.var.dir)); % not a folder
    end % if % ~exist(calcset.var.dir, 'dir')
end % function prepare_calculation_directory(calcset)

function job = init_filenames(job, calcset) %<<<1
    % prepare directory for job files and temporary calculation files
    prepare_calculation_directory(calcset);
    % generate filenames of result files
    job = generate_results_filenames(job);
    % generate main job file name
    job.jobfn = fullfile(calcset.var.dir, [calcset.var.fnprefix '_QV_job.mat']);
end % function init_filenames(calcset)

function [ndresc_slice, ndaxes_out] = slice_ndresc_and_ndaxes(ndresc, ndaxes, consts) %<<<1
    % make slice of a n-dimensional cell of results according constants in the
    % consts structure.
    % axes in ndaxes_out are set to values to which the axes were sliced

    % const.names must exist, be correct, nonrepeating
    % const.values must be one value of actual axis

    % trivial case:
    if isempty(consts)
        ndresc_slice = ndresc;
        ndaxes_out = ndaxes;
    else
        % Convert consts Q and f into strings with relevant values.
        constsnames = {};
        constsvalues = {};
        constsQs = fieldnames(consts);
        for j = 1:numel(constsQs)
            constsfs = fieldnames(consts.(constsQs{j}));
            for k = 1:numel(constsfs)
                constsnames{end+1} = [constsQs{j} '.' constsfs{k}]; % composed quantity.field
                constsvalues{end+1} = consts.(constsQs{j}).(constsfs{k});
            end % for k
        end % for j
        % Now constsnames contains Q.fs as strings, and constsvalues contains
        % relevant values.

        % Create intial structure with dimension indexes and parameters for the
        % subsref function:
        idx.type = "()";
        idx.subs = repmat({":"}, 1, ndims(ndresc));

        % Prepare output axes that will match sliced matrix:
        ndaxes_out = ndaxes;

        % Go through Q.f in consts and try to find matching axis and related
        % axis value to fill out idx structure for subsref slicing function.
        [axname, constindex, axisindex] = intersect(constsnames, ndaxes.names);
        % For all axes that are same for const and axis:
        for j = 1:numel(axisindex) % axisindex and constindex got same sizes
            % Index of actual axis:
            actual_axis_id = axisindex(j);
            % Get actual axis:
            actual_axis = squeeze(ndaxes.valuesc{actual_axis_id});
            % Actual value of actual axis where slice will be taken from constants:
            slice_at_axis_value = constsvalues{constindex(j)};
            % Now find value for actual axis equal to value in consts:
            for actual_axis_value_id = 1:numel(actual_axis)
                % Get actual value of actual axis:
                actual_axis_value = actual_axis{actual_axis_value_id};
                % For all values in axis
                % check if sizes match:
                if all( size(actual_axis_value) == size(slice_at_axis_value) )
                    % check if values match:
                    % This compares double to double!
                    if all(all( actual_axis_value == slice_at_axis_value ))
                        % Set index of actual axis(dimension) to proper value of
                        % actual axis to make a slice at:
                        idx.subs{actual_axis_id} = actual_axis_value_id;
                        % Set new values of axes for output:
                        ndaxes_out.valuesc{actual_axis_id} = ndaxes_out.valuesc{actual_axis_id}(actual_axis_value_id);
                    end % if
                end % if
            end % for actual_axis_value_id = 1:numel(actual_axis)
        end % for j = 1:numel(IB)

        % Now make slice of the n-dimensional matrix
        ndresc_slice = subsref(ndresc, idx);

        % convert ndaxes.valuesc to ndaxes.values:
        ndaxes_out = ndaxes_valuesc_to_values(ndaxes_out);

    end % if isempty(consts)
end % function slice_ndresc_and_ndaxes

function [ndresc ndaxes consts_out] = simplify_ndresc_and_ndaxes(ndresc, ndaxes) %<<<1
    % Remove axes that contain only single point (result ndresc was sliced at
    % this axis). Also remove relevant dimension from ndresc. Removed axis
    % values are set into consts_out.

    % initialize
    consts_out = struct();
    sz = size(ndresc);
    dimensions_to_remove = [];
    sizes_for_reshape = zeros(1, numel(sz));
    % find out dimensions that will be removed. Simple squeeze is not enough,
    % because we need to properly set also ndaxes and generate consts_out.
    for j = 1:numel(ndaxes.names)
        % is actual axis singleton?
        if numel(ndaxes.valuesc{j}) == 1
            if not(size(ndresc, j) == 1)
                error('self check failed, internal error') % XXX internal error
            end
            % Singleton axis, will be marked to be removed.
            dimensions_to_remove(end+1) = j;
            sizes_for_reshape(j) = 1;
            % {1} at the end of the line is possible because the matrix was
            % sliced at this value, so there is only one element of the
            % cell.
            consts_out.(ndaxes.Q{j}).(ndaxes.f{j}) = ndaxes.valuesc{j}{1};
        end % if numel
    end % for j = 1:numel(ndaxes.names)

    % clean up ndaxes
    ndaxes.valuesc(dimensions_to_remove) = [];
    ndaxes.names  (dimensions_to_remove) = [];
    ndaxes.Q      (dimensions_to_remove) = [];
    ndaxes.f      (dimensions_to_remove) = [];

    % Remove notwanted dimensions by reshaping:
    dims = sz(not(sizes_for_reshape));
    % because reshape MUST obtain at least two dimensions:
    if numel(dims) < 2
        dims = [dims 1]; % add singleton dimension to the end if needed
    end
    ndresc = reshape(ndresc, dims);

    % Particular axes in ndaxes.valuesc must be also properly transposed. (So
    % the axes are varied in the same dimension as the dimension it describes,
    % e.g. if axis describes 3rd axis, than it is not row, not collumn but page
    % vector)
    % Create vector of singular dimensions for reshape
    dims = ones(1, numel(ndaxes.valuesc));
    for j = 1:numel(ndaxes.valuesc)
        tmp = dims;
        % Replace j-th dimension by length of the axis so reshape does the
        % proper thing:
        tmp(j) = numel(ndaxes.valuesc{j});
        % because reshape MUST obtain at least two dimensions:
        if numel(tmp) < 2
            tmp = [tmp 1]; % add singleton dimension to the end if needed
        end
        ndaxes.valuesc{j} = reshape(ndaxes.valuesc{j}, tmp);
    end % for j
    % convert ndaxes.valuesc to ndaxes.values:
    ndaxes = ndaxes_valuesc_to_values(ndaxes);
end % function simplify_ndresc_and_ndaxes

function [ndresc ndaxes] = general_permute(ndresc, ndaxes, Qfnames)
% permutes dimensions (generalized trasnpose) of ndresc in such a way that
% Qfnames{1} is at first dimension, Qfnames{2} is second dimension (if
% supplied), Qfnames{3} is third dimension etc.

    dimensions = 1:numel(size(ndresc));

    idx = zeros(1, numel(ndaxes.names));
    dim = [];
    for j = 1:numel(Qfnames)
        tmp = strcmp(ndaxes.names, Qfnames{j});
        if not(isempty(tmp))
            tmp = strcmp(ndaxes.names, Qfnames{j});
            dim(end + 1) = dimensions(tmp);
            idx = or(idx, tmp);
        end % if
    end % for
    dimensions(idx) = [];
    dimensions = [dim dimensions];

    if numel(dimensions) ~= numel(size(ndresc))
        % XXX add errror! internal
        error('internal')
    end % if

    ndresc = permute(ndresc, dimensions);
    ndaxes.names   = ndaxes.names(dimensions);
    ndaxes.Q       = ndaxes.Q(dimensions);
    ndaxes.f       = ndaxes.f(dimensions);
    % Order of ndaxes.valuesc to match .names, .Q, and .f:
    ndaxes.valuesc = ndaxes.valuesc(dimensions);
    % Particular axes in ndaxes.valuesc must be also properly transposed. (So
    % the axes are varied in the same dimension as the dimension it describes,
    % e.g. if axis describes 3rd axis, than it is not row, not collumn but page
    % vector)
    for j = 1:numel(ndaxes.valuesc)
        ndaxes.valuesc{j} = permute(ndaxes.valuesc{j}, dimensions);
    end % for j
    % convert ndaxes.valuesc to ndaxes.values:
    ndaxes = ndaxes_valuesc_to_values(ndaxes);
end % function [ndresc ndaxes] = general_permute(ndresc, ndaxes, varA, varB, varC)

function [stru_out] = remove_Q_f(stru, Qfcell) %<<<1
% remove Q.f from structure. Q.f is in input Qfcell, that is cell of
% strings.
    stru_out = stru;
    if not(isempty(stru))
        Qs = fieldnames(stru);
        for j = 1:numel(Qs)
            Q = Qs{j};
            fs = fieldnames(stru.(Qs{j}));
            for k = 1:numel(fs)
                f = fs{k};
                if any(strcmp([Q '.' f], Qfcell))
                    stru_out.(Q) = rmfield(stru_out.(Q), f);
                end % if
            end % for k
            % Check if some fields are left in current Q, if not, remove
            % whole Q:
            if isempty( fieldnames(stru_out.(Q)) )
                stru_out = rmfield(stru_out, Q);
            end % if
        end % for j
    end % if not(isempty(stru))
end % function remove_Q_f

function [SoC] = CoS_to_SoC(CoS); %<<<1
% converts cell of structures CoS (e.g. job.ndresc) with quantities and fields
% to a structure of quantities and fields with values/cells SoC (e.g.
% job.ndres). If structure in SoC is scalar, than cell is converted to matrix of
% appropriate size.
    % sizes of cells:
    sz = size(CoS);
    Qs = fieldnames(CoS{1});
    for j = 1:numel(Qs)
        Q = Qs{j};
        fs = fieldnames(CoS{1}.(Q));
        for k = 1:numel(fs)
            f = fs{k};
            % (in two lines because of matlab:)
            tmp = [CoS{:}];
            tmp = [tmp.(Q)];
            tmp = {tmp.(f)};
            SoC.(Q).(f) = reshape(tmp, sz);
            if isscalar(SoC.(Q).(f){1})
                % Scalar Q.f
                SoC.(Q).(f) = cell2mat(SoC.(Q).(f));
            end % if
        end % for k = 1:numel(fs)
    end % for j = 1:numel(Qs)
end % function [SoC] = ndres_to_ndresc(CoS);

function [ndaxes] = ndaxes_valuesc_to_values(ndaxes) %<<<1
% Converts ndaxes.valuesc to ndaxes.values
% (that is cell representation of values of axes of n-dimensional result matrix
% is converted to a vector representation)
% If axis values are not possible to convert to a vector, cell representation is
% used.
    ndaxes.values = {};
    for j = 1:numel(ndaxes.valuesc)
        % Check if axis is still purely scalar:
        if all(cellfun(@isvector, ndaxes.valuesc{j}))
            % If scalar is purely axis, convert cell to simple matrix:
            % (this keeps dimensions)
            ndaxes.values{j} = cell2mat(ndaxes.valuesc{j});
        end % if
    end % for j
end % function ndaxes_valuesc_to_values

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


% function  postpad copied from from octave and matlabified %<<<1
% ########################################################################
% ##
% ## Copyright (C) 1994-2022 The Octave Project Developers
% ##
% ## See the file COPYRIGHT.md in the top-level directory of this
% ## distribution or <https://octave.org/copyright/>.
% ##
% ## This file is part of Octave.
% ##
% ## Octave is free software: you can redistribute it and/or modify it
% ## under the terms of the GNU General Public License as published by
% ## the Free Software Foundation, either version 3 of the License, or
% ## (at your option) any later version.
% ##
% ## Octave is distributed in the hope that it will be useful, but
% ## WITHOUT ANY WARRANTY; without even the implied warranty of
% ## MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
% ## GNU General Public License for more details.
% ##
% ## You should have received a copy of the GNU General Public License
% ## along with Octave; see the file COPYING.  If not, see
% ## <https://www.gnu.org/licenses/>.
% ##
% ########################################################################
% 
% ## -*- texinfo -*-
% ## @deftypefn  {} {} postpad (@var{x}, @var{l})
% ## @deftypefnx {} {} postpad (@var{x}, @var{l}, @var{c})
% ## @deftypefnx {} {} postpad (@var{x}, @var{l}, @var{c}, @var{dim})
% ## Append the scalar value @var{c} to the vector @var{x} until it is of length
% ## @var{l}.  If @var{c} is not given, a value of 0 is used.
% ##
% ## If @code{length (@var{x}) > @var{l}}, elements from the end of @var{x} are
% ## removed until a vector of length @var{l} is obtained.
% ##
% ## If @var{x} is a matrix, elements are appended or removed from each row.
% ##
% ## If the optional argument @var{dim} is given, operate along this dimension.
% ##
% ## If @var{dim} is larger than the dimensions of @var{x}, the result will have
% ## @var{dim} dimensions.
% ## @seealso{prepad, cat, resize}
% ## @end deftypefn

function y = postpad (x, l, c, dim)

  if (nargin < 2)
    print_usage ();
  end

  if (nargin < 3 || isempty (c))
    c = 0;
  else
    if (not(isscalar (c)))
      error ("postpad: third argument must be empty or a scalar");
    end
  end

  nd = ndims (x);
  sz = size (x);
  if (nargin < 4)
    % ## Find the first non-singleton dimension.
    % octave version:
    % (dim = find (sz > 1, 1)) || (dim = 1);
    % matlabified version:
    dim = find (sz > 1, 1);
    if isempty(dim)
        dim = 1;
    end
  else
    if (not(isscalar (dim) && dim == fix (dim) && dim >= 1))
      error ("postpad: DIM must be an integer and a valid dimension");
    end
  end

  if (not(isscalar (l)) || l < 0)
    error ("postpad: second argument must be a positive scaler");
  end

  if (dim > nd)
    sz(nd+1:dim) = 1;
  end

  d = sz(dim);

  if (d == l)
    % ## This optimization makes sense because the function is used to match
    % ## the length between two vectors not knowing a priori is larger, and
    % ## allow for:
    % ##    ml = max (numel (v1), numel (v2));
    % ##    v1 = postpad (v1, ml);
    % ##    v2 = postpad (v2, ml);
    y = x;
  elseif (d >= l)
    idx = repmat ({':'}, nd, 1);
    idx{dim} = 1:l;
    y = x(idx{:});
  else
    sz(dim) = l - d;
    y = cat (dim, x, c(ones (sz)));
  end

end

%% Testing
% XXX test with all inputs/outputs, all types of plotting with/out constants

%% Demo
% XXX demo runs qwtbvar_example_1?

% vim settings modeline: vim: foldmarker=%<<<,%>>> fdm=marker fen ft=matlab textwidth=80 tabstop=4 shiftwidth=4
