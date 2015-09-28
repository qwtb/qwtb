function dataout = general_mcm2(alginfo, datain, calcset) %<<<1
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
        % if isOctave
        %     % XXX where is rand and call?
            % how to tell parcellfun which calcluation id it is?
        %     f = @(in) alg_wrapper(in, calcset);
        %     tmp = {datain};
        %     tmp = repmat(datain, 1, M);
        %     res = parcellfun(f, tmp);
        % else
        %     parfor i = 1:M
        %         res(i) = rand_and_call(datain, calcset, i);
        %     end
        % end
    % multi station code --------------------------- %<<<2
    elseif strcmpi(method, 'multistation') 
        % 2DO
    else
        error(['QWTB: unknown settings of calcset.mcm.method: `' method '` '])
    end
        
    % concatenate data into output structure --------------------------- %<<<2
    % .v is created by mean of outputs
    % .u is all outputs
    for i = 1:size(alginfo.returns, 1)
        % through all quantities:
        Qname = alginfo.returns{i};
        rescell = {[res.(Qname)].v};

        % check all outputs has the same dimensions:
        tst = cellfun('ndims', rescell);
        if ~all(tst == tst(1))
            error(['QWTB: some outputs `' Qname '.v` of general mcm has different numbers of dimensions'])
        end  % if not all tst
        for i = 1:tst(1)
            % for all dimensions
            tst2 = cellfun('size', rescell, i);
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
        endif
    end % for concatenate
end % function

function dataout = call_alg(alginfo, datain, calcset, MCind) %<<<1
% set quantity values and call algorithm

    % copy uncertainty to values for all required quantities:
    for i = 1:length(alginfo.requires)
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
    endif
%    % tohle by jenom melo presunout .u(i) do .v
%    if length(Qin.v) == 1
%        % randomizovat jen kdyz neni randomizovane, a to by mel
%        % resit nejaky kontrolor nejistot v datain
%        % XXX
%        Qout.v = normrnd(Qin.v, Qin.u, [M 1]);
%    else
%        for i = 1:length(Qin.v)
%            % 2DO too slow, mvnrnd has to be used
%            % 2DO, other distributions
%            % 2DO, paralelize if no other possibility?
%            Qout.v(:,i) = normrnd(Qin.v(i), Qin.u(i), [1 1]);
%        end
%    end
end % function

% vim settings modeline: vim: foldmarker=%<<<,%>>> fdm=marker fen ft=octave textwidth=80 tabstop=4 shiftwidth=4
