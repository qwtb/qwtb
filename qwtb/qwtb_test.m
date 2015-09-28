% test of qwtb functions
clear all
tg = 1;

disp(['------ TEST GROUP ' num2str(tg) ': qwtb without arguments ------------']) % ------------------ %<<<1
tg++;
algs = qwtb();

% test for existing algorithm testM: %<<<2
assert(any(ismember({[algs.info].shortname},'testM')))
% test for existing algorithm testG: %<<<2
assert(any(ismember({[algs.info].shortname},'testG')))
% test for existing algorithm testGM: %<<<2
assert(any(ismember({[algs.info].shortname},'testGM')))

disp(['------ TEST GROUP ' num2str(tg) ': error for incorrect numer of input arguments ------------']) % ------------------ %<<<1
tg++;
try
    qwtb('a')
catch it
    disp(it.message)
end
assert(it.message(1:5) == 'QWTB:')
clear it

disp(['------ TEST GROUP ' num2str(tg) ': qwtb with two input arguments (no calcset) ------------']) % ------------------ %<<<1
tg++;
% prepare data: %<<<2
t = [1:20];
y = [1:20];
u = 0.1;

datain.t.v = t;
datain.t.u = t.*0 + u;
%datain.t.r = normrnd( repmat(t, M, 1), repmat(u, size(repmat(t, M, 1))) );

datain.y.v = y;
datain.y.u = y.*0 + u;
%datain.y.r = normrnd( repmat(y, M, 1), repmat(u, size(repmat(y, M, 1))) );

% test for results for algorithm testGM: %<<<2
[dataout, datainout, calcsetout] = qwtb('testM', datain);
assert(dataout.max.v == 20);
assert(dataout.min.v == 1);

disp(['------ TEST GROUP ' num2str(tg) ': qwtb with three input arguments ------------']) % ------------------ %<<<1
tg++;

% partial calculation settings structure: %<<<2
calcset.verbose = 1;
[dataout, datainout, calcsetout] = qwtb('testM', datain, calcset);
assert(dataout.max.v == 20);

disp(['------ TEST GROUP ' num2str(tg) ': guf by wrapper ------------']) % ------------------ %<<<1
tg++;

calcset.unc = 'guf';
[dataout, datainout, calcsetout] = qwtb('testG', datain, calcset);
assert(dataout.max.v == 20);
assert(dataout.max.u == 0.1);

disp(['------ TEST GROUP ' num2str(tg) ': for error guf unknown by wrapper ------------']) % ------------------ %<<<1
tg++;
try
    [dataout, datainout, calcsetout] = qwtb('testM', datain, calcset);
catch it
    disp(it.message)
end
assert(it.message(1:5) == 'QWTB:')
clear it


disp(['------ TEST GROUP ' num2str(tg) ': mcm by wrapper - random test! ------------']) % ------------------ %<<<1
tg++;

calcset.unc = 'mcm';
calcset.mcm.verbose = 1;
calcset.mcm.repeats = 1e3;
[dataout, datainout, calcsetout] = qwtb('testGM', datain, calcset);
assert(dataout.max.v > 19.9 && dataout.max.v < 20.1);
assert(dataout.max.u > 0.05 && dataout.max.u < 0.15);

disp(['------ TEST GROUP ' num2str(tg) ': general mcm - random test! ------------']) % ------------------ %<<<1
tg++;

calcset.mcm.randomize = 1;
[dataout, datainout, calcsetout] = qwtb('testG', datain, calcset);
assert(dataout.max.v > 19.9 && dataout.max.v < 20.1);
assert(dataout.max.u > 0.05 && dataout.max.u < 0.15);

disp(['------ TEST GROUP ' num2str(tg) ': for error dof required but missing ------------']) % ------------------ %<<<1
tg++;
calcset.unc = 'guf';
calcset.dof.req = 1;
calcset.dof.gen = 0;
calcset.cor.req = 1;
calcset.cor.gen = 1;
try
    [dataout, datainout, calcsetout] = qwtb('testG', datain, calcset);
catch it
    disp(it.message)
end
assert(it.message(1:5) == 'QWTB:')
clear it

disp(['------ TEST GROUP ' num2str(tg) ': for error cor required but missing ------------']) % ------------------ %<<<1
tg++;
calcset.unc = 'guf';
calcset.dof.req = 1;
calcset.dof.gen = 1;
calcset.cor.req = 1;
calcset.cor.gen = 0;
try
    [dataout, datainout, calcsetout] = qwtb('testG', datain, calcset);
catch it
    disp(it.message)
end
assert(it.message(1:5) == 'QWTB:')
clear it

disp(['------ TEST GROUP ' num2str(tg) ': guf dof ------------']) % ------------------ %<<<1
tg++;
calcset.unc = 'guf';
calcset.dof.req = 1;
calcset.dof.gen = 0;
calcset.cor.req = 0;
calcset.cor.gen = 0;
datain.t.d = zeros(size(t)) + 123;
datain.y.d = zeros(size(y)) + 123;

[dataout, datainout, calcsetout] = qwtb('testG', datain, calcset);
assert(dataout.max.d(1) == 123);
assert(dataout.min.d(1) == 123);

% 2DO XXX  test calculation with cor

disp(['------ TEST GROUP ' num2str(tg) ': for error when calcset is not correct but strict set ------------']) % ------------------ %<<<1
tg++;
calcset.strict = 1;
try
    [dataout, datainout, calcsetout] = qwtb('testG', datain, calcset);
catch it
    disp(it.message)
end
assert(it.message(1:5) == 'QWTB:')
clear it

disp(['------ ALL ' num2str(tg) ' TESTS OK! ------------']) %<<<1
% vim settings modeline: vim: foldmarker=%<<<,%>>> fdm=marker fen ft=octave textwidth=80 tabstop=4 shiftwidth=4
