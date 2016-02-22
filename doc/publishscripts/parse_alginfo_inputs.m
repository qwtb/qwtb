% This is copy of inner function of qwtb. Do not edit, only copy past from qwtb.m!

function [reqQ, reqQdesc, optQ, optQdesc, reqQG, reqQGdesc, optQG, optQGdesc, parQ, Qlist] = parse_alginfo_inputs(alginfo) %<<<1
% parse requirements of the algorithm as stated in algorithm info structure
% returns:
% reqQ - cell of strings of names of required quantities
% reqQdesc - cell of strings of descriptions of reqQ
% optQ - cell of strings of names of optional quantities
% optQdesc - cell of strings of descriptions of optQ
% reqQG - cell of cell of strings of names of grouped quantities (one array
%       element is one group) in which at least one quantity is required, therefore
%       whole group is required
% reqQGdesc - cell of cell of strings of descriptions of reqQG
% optQG - cell of cell of strings of names of grouped quantities (one array
%       element is one group) in which all quantities are optional, therefore whole
%       group is optional
% optQGdesc - cell of cell of strings of descriptions of optQG
% parQ - cell of strings of names of parameter quantities (parameters)
% Qlist - cell with {x,1} names and {x,2} descriptions of all input quantities of algorithm, sorted by names of quantities

    reqQ = {};
    reqQdesc = {};
    optQ = {};
    optQdesc = {};
    tmpQG = {};
    tmpQGdesc = {};
    tmpQGopt = {};
    parQ = {};
    Qlist = {};

    for i = 1:length(alginfo.inputs)
        % for every input quantity
        Q = alginfo.inputs(i);
        % prepare list of Quantities:
        Qlist{i, 1} = Q.name;
        Qlist{i, 2} = Q.desc;
        if Q.alternative > 0
            % grouped quantity -> store name, description and optionality:
            tmpQG{Q.alternative}{end+1} = Q.name;
            tmpQGdesc{Q.alternative}{end+1} = Q.desc;
            tmpQGopt{Q.alternative}{end+1} = Q.optional;
        else
            % not-grouped quantity:
            if Q.optional
                % optional not-grouped quantity -> store name and description:
                optQ{end+1} = Q.name;
                optQdesc{end+1} = Q.desc;
            else
                % not-optional not-grouped quantity -> store name and
                % description:
                reqQ{end+1} = Q.name;
                reqQdesc{end+1} = Q.desc;
            end
        end % if Q.alternative > 0
        % check for parameter settings
        if Q.parameter
            parQ{end+1} = Q.name;
        end
    end % for every required quantity

    % check that no empty elements are in reqQG (Q.alternative is incremental by
    % one and e.g. 2, 5, 10). separate required and optional groups.
    reqQG = {};
    reqQGdesc = {};
    optQG = {};
    optQGdesc = {};
    for i = 1:length(tmpQG)
        if ~isempty(tmpQG{i}) % some groups numbers maybe do not exist
            % check optionality of group. if all required quantities in this
            % group are NOT optional -> group is NOT optional (and one of
            % quantities in group must be in input data)
            if all([tmpQGopt{i}{:}])
                optQG{end+1} = tmpQG{i};
                optQGdesc{end+1} = tmpQGdesc{i};
            else
                reqQG{end+1} = tmpQG{i};
                reqQGdesc{end+1} = tmpQGdesc{i};
            end % if all
        end % if isempty
    end % for i

    % sort list of Quantities by name:
    [tmp, ind] = sort(Qlist(:,1));
    ind = ind(:,1);
    Qlist = {Qlist{ind,1}; Qlist{ind,2}}';

end % function parse_alginfo_inputs(alginfo)

% vim settings modeline: vim: foldmarker=%<<<,%>>> fdm=marker fen ft=octave textwidth=80 tabstop=4 shiftwidth=4
