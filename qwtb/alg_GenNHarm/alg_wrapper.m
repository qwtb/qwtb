function DO = alg_wrapper(DI, CS) %<<<1
% Part of QWTB. Wrapper script for algorithm GenNHarm
%
% See also qwtb

% required quantities:
% fs - scalar
% L - scalar
% f - main signal frequency
% A - main signal amplitude
% ph - main signal phase
% O - main signal offset
% THD - scalar
% nharm - max number of harms
% noise,...

if isfield(DI, 't')
    DO.t.v = DI.t.v;
else
    if isfield(DI, 'Ts')
        Ts = DI.Ts.v;
    elseif isfield(DI, 'fs')
        Ts = 1/DI.fs.v;
        if CS.verbose
            disp('QWTB: GenNHarm wrapper: sampling time was calculated from sampling frequency')
        end
    end
    DO.t.v = [0 : Ts : DI.L.v.*Ts];
end

% make waveform ---------------------------  %<<<1
    % time series:
    DO.t.u = ones(size(DO.t.v)).*1e-10;
    % amplitudes:
    A = (DI.A.v .* DI.THD.v)^(1/DI.nharm.v);
    A = [DI.A.v repmat(A, 1, DI.nharm.v - 1)];
    % harm indexes:
    Hi = [1:1:DI.nharm.v];
    % phases
    ph = repmat(DI.ph.v, 1, DI.nharm.v);
    O = repmat(DI.O.v, 1, DI.nharm.v);
    % sampled values:
    DO.y.v = A'.*sin(2.*pi.*DI.f.v.*Hi'.*DO.t.v + DI.ph.v') + DI.O.v';
    DO.y.v = sum(DO.y.v, 1);
    % add noise to the data:
    DO.y.v = DO.y.v + normrnd(0,DI.noise.v,size(DO.y.v));
    % uncertainties of every sample:
    DO.y.u = ones(size(DO.y.v)).*1e-5;
end % function

% vim settings modeline: vim: foldmarker=%<<<,%>>> fdm=marker fen ft=octave textwidth=80 tabstop=4 shiftwidth=4
