% Generator for SFDR algorithm
function [DO, DI] = alg_generator(DI)
% generates signal based on input quantities. if none given, basic signal is constructed.
%
% used quantities:
% f - main signal frequency, list of spurious/harmonics frequencies
% A - main signal amplitude, list of spurious/harmonics amplitudes
% ph - main signal phase, list of spurious/harmonics phases
% O - main signal offset, list of spurious/harmonics offsets
% dc - dc component
% Np - scalar real, number of main signal periods in the record ( Ns/fs = Np/f(1) )
% ssr - ratio of sampling to signal frequency, ssr = fs/f(1).
% SFDR - scalar, spurious free dynamic ratio
% jitter - standard deviation of jitter [s]
% noise - standard deviation of noise [V]
% smr - spurious to main signal frequency multiple
%
% calculated quantities:
% fs - scalar integer, sampling frequency
% Ns - scalar integer, record length (samples count)

    if ~exist('DI', 'var')
        DI = struct();
    end

    % set initial values and randomize input quantities %<<<1
    [DI, f]      = setQ(DI, 'f',      1e3,      0);
    [DI, A]      = setQ(DI, 'A',        1,      0);
    [DI, ph]     = setQ(DI, 'ph',       0,      0);
    [DI, O]      = setQ(DI, 'O',        0,      0);
    [DI, dc]     = setQ(DI, 'dc',       0,      0);
    [DI, Np]     = setQ(DI, 'Np',      10,      0);
    [DI, ssr]    = setQ(DI, 'ssr',    100,      0);
    [DI, SFDR]   = setQ(DI, 'SFDR',   120,      0);
    [DI, jitter] = setQ(DI, 'jitter',1e-12,     0);
    [DI, noise]  = setQ(DI, 'noise',    0,      0);
    [DI, smr]    = setQ(DI, 'smr',      5,      0);

    % calculate and set other needed quantities %<<<1
    % sampling frequency
    fs = ssr.*f(1);
    [DI, fs]     = setQ(DI, 'fs',      fs,      0);

    % samples count:
    Ns = fix(Np.*fs./f(1));
    [DI, Ns]     = setQ(DI, 'Ns',      Ns,      0);

    % add one single spurious based on SFDR and smr:
    % A = [A 10^(-1.*SFDR/20)];
    A = [A A./SFDR];
    f = [f smr.*f];
    O = [O 0];
    ph = [ph 0];
    DI.A.v = A;
    DI.f.v = f;
    DI.O.v = O;
    DI.ph.v = ph;

    % generate the signal %<<<1
    % time series:
    t = [0 : Ns-1]./fs;
    % set t uncertainty as jitter:
    ut = jitter.*ones(size(t));
    % sampled values:
    % (to save memory, use for cycle instead of matrix multiplication)
    y = dc + zeros(size(t));
    for j = 1:numel(A)
        y = y + A(j).*sin(2.*pi.*f(j).*t + ph(j)) + O(j);
    end
    % add noise to the data:
    uy = noise.*ones(size(y));

    % make output %<<<1
    DO.t.v = t;
    DO.t.u = ut;
    DO.y.v = y;
    DO.y.u = uy;

    DO.fs.v = fs;
    DO.fs.u = 0;
end

function [DI, val] = setQ(DI, Qn, v, u) %<<<1
% ensure the quantity is set in DI,
% set default values for .v and .u if missing,
% randomize quantity.
    % if quantitiy missing
    if ~isfield(DI, Qn)
        DI.(Qn).v = v;
        DI.(Qn).u = u;
    end
    % if uncertainty missing 
    if ~isfield(DI.(Qn), 'u')
        DI.(Qn).u = u;
    end
    % randomize
    DI.(Qn).v = normrnd(DI.(Qn).v, DI.(Qn).u, size(DI.(Qn).v));
    val = DI.(Qn).v;
end % function setQ

% function A = harmonic_series(THD, N) %<<<1
% % Spectrum made using geometric series
% % N is number of harmonics
% % A_1 is given (value is 1)
% % A_2 is calculated from THD value in a such way that:
% % A_3..A_N is function of A_2: A_i = A_2/(i-1) for i=2..N
% % so:
% % harmonic id:      A_1     A_2     A_3     A_4     A_5     A_N
% % harmonic number:  given   calc    A_2/2   A_2/3   A_2/4   A_2/(N-1)
%
%     A(1) = 1;
%
%     if N > 1
%         S = sum(1./[1:N-1].^2);
%         A(2) = THD.*A(1)./sqrt(S);
%         A(2:N) = A(2)./[2-1:N-1];
%     else
%         A = 1;
%     end
%
% % selfcheck:
% % error = sum(A(2:end).^2)^0.5/A(1) - THD:
%
% end % function harmonic_series
