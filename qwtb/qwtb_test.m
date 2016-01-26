% test of qwtb functions
% XXX missing tests for matrix input quantities
clear all
tg = 1;

disp(['------ TEST GROUP ' num2str(tg) ': qwtb without arguments ------------']) % ------------------ %<<<1
tg = tg + 1;
algs = qwtb();

% test for existing algorithm testM: %<<<2
algsids = {algs.id};
assert(any(ismember(algsids, 'testM')))
% test for existing algorithm testG: %<<<2
assert(any(ismember(algsids, 'testG')))
% test for existing algorithm testGM: %<<<2
assert(any(ismember(algsids, 'testGM')))

disp(['------ TEST GROUP ' num2str(tg) ': error for incorrect numer of input arguments ------------']) % ------------------ %<<<1
tg = tg + 1;
try
    qwtb('a')
catch it
    disp(it.message)
end
assert(strcmpi(it.message(1:5), 'QWTB:'))
clear it

disp(['------ TEST GROUP ' num2str(tg) ': qwtb with two input arguments (no CS) ------------']) % ------------------ %<<<1
tg = tg + 1;
% prepare data: %<<<2
x = [1:20];
y = [1:20];
u = 0.1;

DI.x.v = x;
DI.x.u = x.*0 + u;
% XXX normrnd must be removed in future if these lines will be used:
%DI.t.r = normrnd( repmat(t, M, 1), repmat(u, size(repmat(t, M, 1))) );

DI.y.v = y;
DI.y.u = y.*0 + u;
% XXX normrnd must be removed in future if these lines will be used:
%DI.y.r = normrnd( repmat(y, M, 1), repmat(u, size(repmat(y, M, 1))) );

% test for results for algorithm testGM: %<<<2
[DO, DIout, CSout] = qwtb('testM', DI);
assert(DO.max.v == 20);
assert(DO.min.v == 1);

disp(['------ TEST GROUP ' num2str(tg) ': qwtb with three input arguments ------------']) % ------------------ %<<<1
tg = tg + 1;

% partial calculation settings structure: %<<<2
CS.verbose = 1;
[DO, DIout, CSout] = qwtb('testM', DI, CS);
assert(DO.max.v == 20);

disp(['------ TEST GROUP ' num2str(tg) ': guf by wrapper ------------']) % ------------------ %<<<1
tg = tg + 1;

CS.unc = 'guf';
[DO, DIout, CSout] = qwtb('testG', DI, CS);
assert(DO.max.v == 20);
assert(DO.max.u == 0.1);

disp(['------ TEST GROUP ' num2str(tg) ': for error guf unknown by wrapper ------------']) % ------------------ %<<<1
tg = tg + 1;
try
    [DO, DIout, CSout] = qwtb('testM', DI, CS);
catch it
    disp(it.message)
end
assert(strcmpi(it.message(1:5), 'QWTB:'))
clear it


disp(['------ TEST GROUP ' num2str(tg) ': mcm by wrapper - random test! ------------']) % ------------------ %<<<1
tg = tg + 1;

CS.unc = 'mcm';
CS.mcm.verbose = 1;
CS.mcm.repeats = 1e3;
[DO, DIout, CSout] = qwtb('testGM', DI, CS);
assert(DO.max.v > 19.9 && DO.max.v < 20.1);
assert(DO.max.u > 0.05 && DO.max.u < 0.15);

disp(['------ TEST GROUP ' num2str(tg) ': general mcm - random test! ------------']) % ------------------ %<<<1
tg = tg + 1;

CS.mcm.randomize = 1;
[DO, DIout, CSout] = qwtb('testG', DI, CS);
assert(DO.max.v > 19.9 && DO.max.v < 20.1);
assert(DO.max.u > 0.05 && DO.max.u < 0.15);

disp(['------ TEST GROUP ' num2str(tg) ': for error dof required but missing ------------']) % ------------------ %<<<1
tg = tg + 1;
CS.unc = 'guf';
CS.dof.req = 1;
CS.dof.gen = 0;
CS.cor.req = 1;
CS.cor.gen = 1;
try
    [DO, DIout, CSout] = qwtb('testG', DI, CS);
catch it
    disp(it.message)
end
assert(strcmpi(it.message(1:5), 'QWTB:'))
clear it

disp(['------ TEST GROUP ' num2str(tg) ': for error cor required but missing ------------']) % ------------------ %<<<1
tg = tg + 1;
CS.unc = 'guf';
CS.dof.req = 1;
CS.dof.gen = 1;
CS.cor.req = 1;
CS.cor.gen = 0;
try
    [DO, DIout, CSout] = qwtb('testG', DI, CS);
catch it
    disp(it.message)
end
assert(strcmpi(it.message(1:5), 'QWTB:'))
clear it

disp(['------ TEST GROUP ' num2str(tg) ': guf dof ------------']) % ------------------ %<<<1
tg = tg + 1;
CS.unc = 'guf';
CS.dof.req = 1;
CS.dof.gen = 0;
CS.cor.req = 0;
CS.cor.gen = 0;
DI.x.d = zeros(size(x)) + 123;
DI.y.d = zeros(size(y)) + 123;

[DO, DIout, CSout] = qwtb('testG', DI, CS);
assert(DO.max.d(1) == 123);
assert(DO.min.d(1) == 123);

% 2DO XXX  test calculation with cor

disp(['------ TEST GROUP ' num2str(tg) ': for error when CS is not correct but strict set ------------']) % ------------------ %<<<1
tg = tg + 1;
CS.strict = 1;
try
    [DO, DIout, CSout] = qwtb('testG', DI, CS);
catch it
    disp(it.message)
end
assert(strcmpi(it.message(1:5), 'QWTB:'))
clear it

disp(['------ TEST GROUP ' num2str(tg) ': test algorithms one by one ------------']) % ------------------ %<<<1
tg = tg + 1;

for i = 1:length(algsids)
    disp(['test of algorithm: ' algsids{i}]);
    qwtb(algsids{i}, 'test');
end % for all algorithms

disp(['------ TEST GROUP ' num2str(tg) ': test getting algorithm info one by one ------------']) % ------------------ %<<<1
tg = tg + 1;

for i = 1:length(algsids)
    disp(['test of algorithm: ' algsids{i}]);
    qwtb(algsids{i}, 'info');
end % for all algorithms


disp(['------ TEST GROUP ' num2str(tg) ': test for existence of algorithms licenses ------------']) % ------------------ %<<<1
tg = tg + 1;

for i = 1:length(algsids)
    disp(['test of algorithm: ' algsids{i}]);
    qwtb(algsids{i}, 'license');
end % for all algorithms
disp(['------ ALL ' num2str(tg) ' GROUPS OF TESTS OK! ------------']) %<<<1
% vim settings modeline: vim: foldmarker=%<<<,%>>> fdm=marker fen ft=octave textwidth=80 tabstop=4 shiftwidth=4
