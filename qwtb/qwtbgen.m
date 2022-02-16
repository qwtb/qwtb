function varargout = qwtbgen(varargin) 
% QWTBGEN: part of Q-Wave Toolbox for data processing algorithms
%   [alginfo, calcset] = qwtbgen()
%       Gives informations on available algorithms and standard calculation
%       settings.
%   [dataout, datain, calcset] = qwtbgen('algid', datain, [calcset])
%       Apply algorithm with id `algid` to input data `datain` with calculation
%       settings `calcset`.

% Copyright (c) 2022 by Martin Šíra

% Internal documentaion %<<<1
% Inputs/outputs scheme: %<<<2
%   mode        ||o|i  ||   out1  | out2 | out3 || in1 | in2       | in3  |
%   ------------||-|---||---------|------|------||-----|-----------|------|
%   generate    ||3|2/3|| DO      | DI   | CS   || ID  | DI        | [CS] |
%
%   (o|i - number of output|input arguments, outX - output arguments, inX -
%   input arguments, DO - dataout, DI - datain, CS - calculation settings)

    % start of qwtbgen function --------------------------- %<<<1

    % check inputs:
    if nargin < 2 || nargin > 3
        error(err_msg_gen(1)) % incorrect number of inputs!
    else
        algid = varargin{1};
        % second argument is considered as input data:
        datain = varargin{2};
        if nargin == 2
            % calculation settings is missing
            calcset = [];
        else
            calcset = varargin{3};
        end
        % process data:
        [dataout, datain, calcset, paths] = run_generator(algid, datain, calcset);
        varargout{1} = dataout;
        varargout{2} = datain;
        varargout{3} = calcset;
    end % if nargin

end % end qwtbgen function

function [dataout, datain, calcset] = run_generator(algid, datain, calcset);
    alginfo = qwtb(algid, 'info');
    % check if generator informations are found in algorithm info:
    if isfield(alginfo, 'generator')
        generatorid = alginfo.generator;
        allai = qwtb();
        % check if generator algorithm exists:
        if ~any(strcmp('SFDR',{allai.id}))
            error(err_msg_gen(3, alginfo.id, generatorid)) % missing generator alg
        end
    else
        error(err_msg_gen(2, alginfo.id)) % alg is missing generator info
    end % isfield

    % success, generator information found and algorithm exist,
    % run a generator algorithm
    [dataout, datain, calcset] = qwtb(generatorid, datain, calcset);

end % function [dataout, datain, calcset] = run_generator(algid, datain, calcset, paths);

function msg = err_msg_gen(varargin) %<<<1
    % generates error message, so all errors are at one place. after each
    % message a " QWTB err #X" is added, where X is number of error.
    % 2DO - condider generating an error structure with error ids and message so it can be try-catched.

    % groups of errors:
    % negative - QWTB internal errors:
    % just continued negative integer sequence
    % 0 - empty output (no error)
    % positive - user errors:
    %  1  -  29  various

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
        if ~(errid == fix(errid) && isreal(errid));
            errid = -2;
        end
    end
    % common parts of error message: %<<<2
    % beginning of all errors:
    prefix = 'QWTBGEN: ';
    % this is appended in the case of internal error:
    interr = ' This is QWTBGEN internal error. This should not happen. Please report this bug.';
    % this is appended to all errors:
    suffix = [' QWTBGEN error #' num2str(errid, '%03d') '|'];
    % %>>>2

    % select error message:
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
                msg = ['insufficient number of input arguments for function err_msg_gen and QWTBGEN error ' num2str(varargin{2}) '.'];
            % ------------------- basic errors 1-29: %<<<2
            case 1
                msg = ['Incorrect number of input arguments. Please read QWTBGEN documentation.'];
            case 2 % one input - algid
                msg = ['Algorithm `' varargin{2} '` does not contain information which algorithm should be used to generate input quantities.'];
            case 3 % two inputs - algid, generatorid
                msg = ['The generator algorithm `' varargin{3} '` specified in algorithm `' varargin{2} '` does not exist'];
            otherwise
                msg = err_msg_gen(-3, errid);
        end %>>>2
    catch ERR
        % try to catch index out of bound error, i.e. not enough input arguments (varargin out of bounds):
        isOctave = exist('OCTAVE_VERSION') ~= 0;
        if isOctave
            if strcmpi(ERR.identifier, 'Octave:index-out-of-bounds')
                % throw internal QWTBGEN error:
                msg = err_msg_gen(-4, errid);
            end
        else
            if (strcmpi(ERR.identifier,'MATLAB:badsubscript'))
                % throw internal QWTBGEN error:
                msg = err_msg_gen(-4, errid);
            end
        end
    end
    % compose final error message:
    msg = [prefix msg];
    if (errid < 0)
        msg = [msg interr];
    end
    msg = [msg suffix];
    % make empty output for zero errid:
    if errid == 0
        msg = '';
    end
end % err_msg_gen
    
% vim settings modeline: vim: foldmarker=%<<<,%>>> fdm=marker fen ft=octave textwidth=80 tabstop=4 shiftwidth=4
