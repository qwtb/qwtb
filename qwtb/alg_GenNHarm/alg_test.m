function alg_test(calcset) %<<<1
% Part of QWTB. Test script for algorithm GenNHarm
%
% See also qwtb

CS.verbose = 0;

% Generate sample data --------------------------- %<<<1
DI = [];
% Numerical test with very simple values for fft 
DI.t.v = [0 0.25 0.5 0.75];
DI.f.v = [1];
DI.A.v = [1];
DI.ph.v = [0];
DI.O.v = [0];
% DI.thd_k1.v = 0;
% DI.nharm.v = 0;
% DI.noise.v = 0;

% Test algorithm --------------------------- %<<<1
DO = qwtb('GenNHarm', DI, CS);
% Check results
assert(DO.y.v, [0 1 0 -1], 1e-15);

% Check alternative inputs t/Ts/fs --------------------------- %<<<1
DI = rmfield(DI, 't');
DI.fs.v = 4;
DI.L.v = 4;
DO = qwtb('GenNHarm', DI, CS);
assert(DO.y.v, [0 1 0 -1], 1e-15);

DI = rmfield(DI, 'fs');
DI.Ts.v = 1/4;
DO = qwtb('GenNHarm', DI, CS);
assert(DO.y.v, [0 1 0 -1], 1e-15);

% Check alternative inputs thd_kt/nharm --------------------------- %<<<1
DI = [];
DI.fs.v = 1e3;
DI.L.v = 1e3;
DI.f.v = [1 2];
DI.A.v = [1 0.1];
DI.ph.v = [0 0];
DI.O.v = [0 0];
DI.thd_k1.v = 0;
DI.nharm.v = 0;
DI.noise.v = 0;
DO = qwtb('GenNHarm', DI, CS);
assert(DO.thd_k1.v, 0.1, 1e-15);

DI = [];
DI.fs.v = 1e3;
DI.L.v = 1e3;
DI.f.v = [1];
DI.A.v = [1];
DI.ph.v = [0];
DI.O.v = [0];
DI.thd_k1.v = 0.1;
DI.nharm.v = 2;
DI.noise.v = 0;
DO = qwtb('GenNHarm', DI, CS);
assert(DO.thd_k1.v, 0.1, 1e-15);

end % function

% vim settings modeline: vim: foldmarker=%<<<,%>>> fdm=marker fen ft=octave textwidth=80 tabstop=4 shiftwidth=4
