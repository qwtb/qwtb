function alg_test(calcset) %<<<1
% Part of QWTB. Test script for algorithm SP-WFFT.
%
% See also qwtb

CS.verbose = 0;

% Test proper results for odd and even samples --------------------------- %<<<1
DI.t.v = [0:1/3:1];
DI.t.v = DI.t.v(1:end-1);
DI.y.v = sin(2*pi*1*DI.t.v+1);
DO = qwtb('SP-WFFT', DI, CS);
assert(all(abs(DO.f.v - [0 1]) < 1e-14));
assert(all(abs(DO.A.v - [0 1]) < 1e-14));
assert(all(abs(DO.ph.v(2) - 1) < 1e-14));

clear DI
DI.t.v=[0:1/4:1];
DI.t.v = DI.t.v(1:end-1);
DI.y.v=sin(2*pi*1*DI.t.v+1);
DO = qwtb('SP-WFFT', DI, CS);
assert(all(abs(DO.f.v - [0 1 2]) < 1e-14));
assert(all(abs(DO.A.v - [0 1 0]) < 1e-14));
assert(all(abs(DO.ph.v(2)   - 1) < 1e-14));

% Test proper results for complex signal with offset --------------------------- %<<<1
clear DI
DI.fs.v = 50;
DI.t.v = [0 : 1/DI.fs.v : 1];
DI.t.v = DI.t.v(1:end-1);
fnom = [1; 8; 15];
Anom = [1; 0.5; 0.3];
pnom = [0; 1; 2];
DI.y.v = zeros(size(DI.t.v));
for i = 1:length(fnom)
    DI.y.v = DI.y.v + Anom(i).*sin(2.*pi.*fnom(i).*DI.t.v + pnom(i));
end
DI.y.v = DI.y.v + 2;
DO = qwtb('SP-WFFT', DI, CS);
assert(all(abs(DO.A.v(1)  -   2) < 1e-14));
assert(all(abs(DO.A.v(2)  -   1) < 1e-14));
assert(all(abs(DO.A.v(9)  - 0.5) < 1e-14));
assert(all(abs(DO.A.v(16) - 0.3) < 1e-14));

% Test windowing - all possible windows --------------------------- %<<<1
available_windows = {
    'barthann', ...
    'bartlett', ...
    'blackman', ...
    'blackmanharris', ...
    'blackmannuttall', ...
    'bohman', ...
    'cheb', ...
    'flattop_matlab', ...
    'flattop_SFT3F', ...
    'flattop_SFT4F', ...
    'flattop_SFT5F', ...
    'flattop_SFT3M', ...
    'flattop_SFT4M', ...
    'flattop_SFT5M', ...
    'flattop_248D', ...
    'flattop_248D', ...
    'gaussian', ...
    'hamming', ...
    'hanning', ...
    'kaiser', ...
    'nuttall', ...
    'parzen', ...
    'rect', ...
    'triang', ...
    'tukey', ...
    'welch', ...
};

DI.cheb_att.v = 200;
DI.gaussian_width.v = 2;
DI.kaiser_att.v = 1e2;
DI.tukey_ratio.v = 1;
for current_window = available_windows
    DI.window.v = current_window{1};
    DO = qwtb('SP-WFFT', DI, CS);
    % Very crude test just to know that applied window have not generated error.
    % Some windows (gaussian) generate large errors with nominal settings.
    assert(DO.A.v(16) > 0.25);
end

% Test windowing - cheb window --------------------------- %<<<1
clear DI
DI.fs.v = 50;
DI.t.v = [0 : 1/DI.fs.v : 1];
DI.t.v = DI.t.v(1:end-1);
DI.y.v = sin(2.*pi.*10.*DI.t.v);
DI.window.v = 'cheb';
DO = qwtb('SP-WFFT', DI, CS);
assert (abs(DO.A.v(11)   - 1) < 1e-4);
DI.cheb_att.v = 200;
DO = qwtb('SP-WFFT', DI, CS);
assert (abs(DO.A.v(11)   - 1) < 1e-7);

% Test windowing - gaussian window --------------------------- %<<<1
clear DI
DI.fs.v = 50;
DI.t.v = [0 : 1/DI.fs.v : 1];
DI.t.v = DI.t.v(1:end-1);
DI.y.v = sin(2.*pi.*10.*DI.t.v);
DI.window.v = 'gaussian';
DO = qwtb('SP-WFFT', DI, CS);
assert (abs(DO.A.v(11) - 0.956) < 1e-3)
DI.gaussian_width.v = 2;
DO = qwtb('SP-WFFT', DI, CS);
assert (abs(DO.A.v(11) - 0.385) < 1e-3)

% Test windowing - kaiser window --------------------------- %<<<1
clear DI
DI.fs.v = 50;
DI.t.v = [0 : 1/DI.fs.v : 1];
DI.t.v = DI.t.v(1:end-1);
DI.y.v = sin(2.*pi.*10.*DI.t.v);
DI.window.v = 'kaiser';
DO = qwtb('SP-WFFT', DI, CS);
assert (abs(DO.A.v(12) - 0.012) < 1e-3)
DI.kaiser_att.v = 1e2;
DO = qwtb('SP-WFFT', DI, CS);
assert (abs(DO.A.v(12) - 0.952) < 1e-3)

% Test windowing - tukey window --------------------------- %<<<1
clear DI
DI.fs.v = 50;
DI.t.v = [0 : 1/DI.fs.v : 1];
DI.t.v = DI.t.v(1:end-1);
DI.y.v = sin(2.*pi.*10.*DI.t.v);
DI.window.v = 'tukey';
DO = qwtb('SP-WFFT', DI, CS);
assert (abs(DO.A.v(12) - 0.283) < 1e-3)
DI.tukey_ratio.v = 1;
DO = qwtb('SP-WFFT', DI, CS);
assert (abs(DO.A.v(12)  - 0.5) < 1e-3)

% Test windowing and zero padding --------------------------- %<<<1
clear DI
DI.fs.v = 50;
DI.t.v = [0 : 1/DI.fs.v : 1];
DI.t.v = DI.t.v(1:end-1);
DI.y.v = sin(2.*pi.*10.*DI.t.v);
DI.window.v = 'cheb';
DI.fft_padding.v = 10.*length(DI.y.v);
DO = qwtb('SP-WFFT', DI, CS);
assert (abs(DO.A.v(101) -  1) < 1e-4)
DI.cheb_att.v = 200;
DO = qwtb('SP-WFFT', DI, CS);
assert (abs(DO.A.v(101) -  1) < 1e-7)

% Test all other outputs using bartlett window --------------------------- %<<<1
clear DI
DI.fs.v = 1e6;
DI.t.v = [0 : 1/DI.fs.v : 10];
DI.t.v = DI.t.v(1:end-1);
DI.y.v = normrnd(0, 1e-6, size(DI.t.v)) + sin(2.*pi.*10.*DI.t.v);
DI.window.v = 'bartlett';
DO = qwtb('SP-WFFT', DI, CS);
assert (DO.noise_rms.v < 1e-6);
assert (DO.SNR.v > 10^(115/20));
assert (DO.SNR.v < 10^(125/20));
assert (abs(DO.SNRdB.v - 120) < 5);
assert (abs(DO.NL.v - 6.0e-10) < 0.5e-10);
assert (abs(DO.NLD.v - 1.17e-9) <  0.01e-9);
assert (numel(DO.A.v) == numel(DO.SD.v));
assert (numel(DO.w.v) == numel(DI.y.v));
assert (abs(DO.NENBW.v - 1.333333) < 1e-5);
assert (abs(DO.ENBW.v - 0.1333333) < 1e-5);

% Check alternative inputs --------------------------- %<<<1
clear DI
fs = 4;
t=[0:1/fs:1];
t = t(1:end-1);
DI.y.v=sin(2*pi*1*t+1);
DI.fs.v = fs;
DO = qwtb('SP-WFFT', DI, CS);
assert(all(abs(DO.A.v - [0 1 0]) < 1e-14));

DI = rmfield(DI, 'fs');
DI.Ts.v = 1/fs;
DO = qwtb('SP-WFFT', DI, CS);
assert(all(abs(DO.A.v - [0 1 0]) < 1e-14));

DI = rmfield(DI, 'Ts');
DI.t.v = t;
DO = qwtb('SP-WFFT', DI, CS);
assert(all(abs(DO.A.v - [0 1 0]) < 1e-14));
% 
end % function

% vim settings modeline: vim: foldmarker=%<<<,%>>> fdm=marker fen ft=octave textwidth=80 tabstop=4 shiftwidth=4
