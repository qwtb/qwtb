function varargout = qwtb(varargin) %<<<1
% QWTB: Q-Wave Toolbox
%   1 input argument: 
%     'get_algs' - finds all available algorithms and returns information
%   3 input argument: 
%     algname - short name of algorithm to use
%     datain - data structure
%     calcset - calculation settings structure

        % start of function %<<<1
        % check empty inputs:
        if nargin == 0
                error('qwtb: missing input arguments')
        end


        if strcmp(varargin{1}, 'get_algs')  % one parameter input %<<<1
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
        else   % three parameter input %<<<1
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
                if ( strcmpi(calcset.unc, 'guf') && not(info.providesGUF) )
                        % raise error, GUF required and cannot calculate GUF %<<<2
                        error('qwtb: uncertainty calculation by GUF method required, but algorithm does not provide GUF uncertainty calculation')
                elseif isempty(calcset.unc)
                        % no uncertainty, just calculate value: %<<<2
                        % calculate with specified algorithm
                        dataout = alg_wrapper(varargin{2}, calcset);
                elseif ( strcmpi(calcset.unc, 'guf') && info.providesGUF ) || ( strcmpi(calcset.unc, 'mmc') && info.providesMMC )
                        % uncertainty is calculated by algorithm/wrapper: %<<<2
                        dataout = alg_wrapper(varargin{2}, calcset);
                elseif strcmpi(calcset.unc, 'mmc')
                        % MMC is calculated here: %<<<2
                        % if no vector, do randomization
                        % if vector, check all u vectors are equal length
                        % call in multiple processing the algorithm
                        % multiple processing must copy u->v and calculate
                        % XXX
                else
                        % unknown settings of calcset.unc or algorithm: %<<<2
                        error(['qwtb: unknown settings of calcset.unc: `' calcset.unc '` or algorithm info structure concerning uncertainty calculation'])
                end
                % remove algorithm path from path:
                rmpath(algdir);
                varargout{1} = dataout;
        end

% end function
end

function res = isalgdir(algpath) %<<<1
% checks if directory in algpath is directory with algorithm, i.e. path exists
% and contains scripts alg_info and alg_wrapper
% returns boolean

        res = exist(algpath,'dir') == 7;
        res = res && (exist([algpath '/alg_info.m'], 'file') == 2);
        res = res && (exist([algpath '/alg_wrapper.m'], 'file') == 2);

end

function checkdatain(datain, alginfo, mustunc) %<<<1
% checks if input data complies to the QWTB data format and has all variables
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
                evres = eval(['isfield(datain.' quants{i} ', ' char(39) 'v' char(39) ')'], 0);
                if ~(evres)
                        error(['qwtb: field `v` missing in quantity `' quants{i} ])
                end
                evres = eval(['isfield(datain.' quants{i} ', ' char(39) 'u' char(39) ')'], 0);
                if (~(evres) && mustunc)
                        error(['qwtb: field `u` missing in quantity `' quants{i} ])
                end
                evres = eval(['isfield(datain.' quants{i} ', ' char(39) 'd' char(39) ')'], 0);
                if (~(evres) && mustunc)
                        error(['qwtb: field `d` missing in quantity `' quants{i} ])
                end
        end

end

function checkcalcset(calcset) %<<<1
% checks if calculation settings complies to the QWTB format
        if ~( isfield(calcset, 'unc') )
                error('qwtb: field `unc` is missing in calculation settings')
        end
        if ~( strcmpi(calcset.unc, '') || strcmpi(calcset.unc, 'guf') || strcmpi(calcset.unc, 'mmc') )
                error('qwtb: field `unc` has unknown value')
        end

end

function datain2 = randomize(datain, alginfo, calcset) %<<<1
% randomizes datain structure for MMC

        % get quantities required by algorithm:
        quants = alginfo.requires;
        M = calcset.mmcrepeats;

        for i = 1:length(quants)
                % randomize:
                eval(['tmp = datain.' quants{i}]);
                if length(tmp.v) == 1
                        % randomizovat jen kdyz neni randomizovane, a to by mel
                        % resit nejaky kontrolor nejistot v datain
                        % XXX
                        tmp.u = normrnd(tmp.v, tmp.u, [M 1]);
                else
                        tmpu = tmp.u;
                        tmp.u = zeros(M, length(tmp.v));
                        for j = 1:length(tmp.v)
                                tmp.u(:,j) = normrnd(tmp.v(j), tmpu(j), [M 1]);
                        end
                end
        end % for i
end


% vim settings modeline: vim: foldmarker=%<<<,%>>> fdm=marker fen ft=octave textwidth=80
