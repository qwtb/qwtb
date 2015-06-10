function dataout = general_mcm2(alginfo, datain, calcset) %<<<1
method = calcset.mcm.method;
M = calcset.mcm.repeats;
isOctave = exist('OCTAVE_VERSION') ~= 0;

if strcmpi(method, 'singlecore') % single core code --------------------------- %<<<2
    for i = 1:calcset.mcm.repeats
        % call wrapper --------------------------- %<<<1
        a = rand_and_call(alginfo, datain, calcset);
        dataout{i} = a;
    end
elseif strcmpi(method, 'singlestation')
    if isOctave
        f = @(in) alg_wrapper(in, calcset);
        tmp = {datain};
        tmp = repmat(datain, 1, M);
        res = parcellfun(f, tmp);
    else
        parfor i = 1:M
            res(i) = rand_and_call(datain, calcset);
        end
    end
elseif strcmpi(method, 'multistation')
    % 2DO
else
    %2DO error
end
    
for 

    % concatenate data into output structure:
end % function

function dataout = rand_and_call(alginfo, datain, calcset) %<<<1
% Rand and call

% list of quantities required by algorithm:
quants = alginfo.requires;
M = calcset.mcm.repeats;

for i = 1:length(quants)
    % randomize values of all required quantities:
    datain.(quants{i}) = rand_quant(datain.(quants{i}), M);
end % for i
calcset.unc = 'none';
dataout = alg_wrapper(datain, calcset);

end % function

function Qout = rand_quant(Qin, M) %<<<1
    if length(Qin.v) == 1
        % randomizovat jen kdyz neni randomizovane, a to by mel
        % resit nejaky kontrolor nejistot v datain
        % XXX
        Qout.v = normrnd(Qin.v, Qin.u, [M 1]);
    else
        for i = 1:length(Qin.v)
            % 2DO too slow, mvnrnd has to be used
            % 2DO, other distributions
            % 2DO, paralelize if no other possibility?
            Qout.v(:,i) = normrnd(Qin.v(i), Qin.u(i), [1 1]);
        end
    end
end % function

% vim settings modeline: vim: foldmarker=%<<<,%>>> fdm=marker fen ft=octave textwidth=80 tabstop=4 shiftwidth=4
