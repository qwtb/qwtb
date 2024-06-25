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

% Format input data ---------------------------  %<<<1
% Check/generate time series:
if isfield(DI, 't')
    DO.t.v = DI.t.v;
else
    if isfield(DI, 'Ts')
        Ts = DI.Ts.v;
        if CS.verbose
            disp('QWTB: GenNHarm wrapper: time series was calculated from sampling period and number of samples.')
        end
    elseif isfield(DI, 'fs')
        Ts = 1/DI.fs.v;
        if CS.verbose
            disp('QWTB: GenNHarm wrapper: time series was calculated from sampling frequency and number of samples.')
        end
    end
    isfieldL = isfield(DI, 'L');
    if isfieldL
        L = DI.L.v;
    else
        L = NaN;
    end
    isfieldM = isfield(DI, 'M');
    if isfieldM
        M = DI.M.v;
    else
        M = NaN;
    end
    if isfieldL && not(isnan(L)) && not(L < 1) && not(isempty(L))
        % number of samples supplied
        DO.t.v = [0 : Ts : (L - 1).*Ts];
        if CS.verbose
            disp('QWTB: GenNHarm wrapper: time series was calculated from number of samples.')
        end
    elseif isfieldM && not(isnan(M)) && not(M < 0) && not(isempty(M))
        % number of main signal periods supplied
        T = M./DI.f.v(1);
        DO.t.v = [0 : Ts : T - Ts];
        if CS.verbose
            disp('QWTB: GenNHarm wrapper: time series was calculated from number of main signal component periods.')
        end
    else
        error('QWTB: GenNHarm wrapper: if time series t is not supplied, algorithm requires one of these combinations to generate time series: (fs or Ts with L), or (fs or Ts with M), where fs is sampling frequency, Ts is sampling period, L is number of samples, M is number of signal periods.');
    end
end

% Check thd_k1 and nharm
if not(isfield(DI, 'thd_k1'))
    DI.thd_k1.v = 0;
end
if not(isfield(DI, 'nharm'))
    DI.nharm.v = 0;
end
if not(isfield(DI, 'noise'))
    DI.noise.v = 0;
end

% Call algorithm ---------------------------  %<<<1
% algorithm use only .v fields:
[DO.y, DO.thd_k1] = GenNHarm(DO.t, DI.f, DI.A, DI.ph, DI.O, DI.thd_k1, DI.nharm, DI.noise);

% Format output data ---------------------------  %<<<1
% -

% vim settings modeline: vim: foldmarker=%<<<,%>>> fdm=marker fen ft=octave textwidth=80 tabstop=4 shiftwidth=4
