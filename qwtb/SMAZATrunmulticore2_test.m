% preparation: --------------------------- %<<<1 
% shared res, result, method, functionhandle, parametercell, procno, tmpdir, verbose
for i = 1:100000
     parametercell{i} = 10;
end
functionhandle = @factorial;
procno = 0;
tmpdir = '~';
verbose = 0;
result = {};

% tests: --------------------------- %<<<1 
disp('testing runmulticore2, for')
result = {};
tic
result = runmulticore2('for', functionhandle, parametercell, procno, tmpdir, verbose);
toc
res = 0;
cell2mat(result
for i = 1:10
     res = res + result{i};
end
assert(res == 4037913)

disp('testing runmulticore2, cellfun')
result = {};
tic
result = runmulticore2('cellfun', functionhandle, parametercell, procno, tmpdir, verbose);
toc
res = 0;
for i = 1:10
     res = res + result{i};
end
assert(res == 4037913)

disp('testing runmulticore2, parcellfun')
result = {};
tic
result = runmulticore2('parcellfun', functionhandle, parametercell, procno, tmpdir, verbose);
toc
res = 0;
for i = 1:10
     res = res + result{i};
end
assert(res == 4037913)

% 2DO finish this test when runmulticore is completed:
% disp('testing runmulticore2, multicore')
% result = {};
% tic
% result = runmulticore2('multicore', functionhandle, parametercell, procno, tmpdir, verbose);
% toc
% res = 0;
% for i = 1:10
%      res = res + result{i};
% end
% assert(res == 4037913)

% vim settings modeline: vim: foldmarker = %<<<,%>>> fdm = marker fen ft = octave textwidth = 80 tabstop = 4 shiftwidth = 4
