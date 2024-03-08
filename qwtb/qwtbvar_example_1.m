clear all

% === Inputs
DI.x.v = 0;
DI.y.v = 0;
DI.a.v = 1;
DI.a.u = 0;
DI.b.v = 2;
DIvar.a.v = [1 2];
DIvar.a.u = [0 0.25 0.5];
DIvar.x.v = [-5  -2   0   2   5];
DIvar.y.v = [-5; -3; -1;  1;  3;  5];

CS.verbose = 1;
%variationsettings:
CS.mcm.repeats = 1e3;
CS.var.dir = 'qwtbvarexample';
CS.var.cleanfiles = 1;
% CS.var.method = 'multicore';
CS.var.method = 'singlecore';
CS.var.procno = 4;

% === Calculation
[jobfn] = qwtbvar('calc', 'qwtbvar_example_process', DI, DIvar, CS);

% === Plotting
consts.a.v = 1;
% 3 dimensional plot:
% qwtbvar('plot3D', jobfn, 'x', 'y', 'z', consts);
% [H x y]=qwtbvar('plot2D', jobfn, 'x', 'y'); % , consts);

% === Look Up Table
axset.a.v.min_ovr = min(DIvar.a.v)-0.1;
axset.a.v.max_ovr = max(DIvar.a.v)+0.1;
axset.a.v.min_lim = 'error';
axset.a.v.max_lim = 'error';
axset.a.v.scale = 'lin';
axset.a.u.min_ovr = min(DIvar.a.u);
axset.a.u.max_ovr = max(DIvar.a.u);
axset.a.u.min_lim = 'error';
axset.a.u.max_lim = 'error';
axset.a.u.scale = 'lin';
axset.x.v.min_ovr = min(DIvar.x.v)-3;
axset.x.v.max_ovr = max(DIvar.x.v)+3;
axset.x.v.min_lim = 'const';
axset.x.v.max_lim = 'const';
axset.x.v.scale = 'lin';
axset.y.v.min_ovr = min(DIvar.y.v)-3;
axset.y.v.max_ovr = max(DIvar.y.v)+3;
axset.y.v.min_lim = 'const';
axset.y.v.max_lim = 'const';
axset.y.v.scale = 'lin';

rqset.z.v.scale = 'lin';

lut = qwtbvar('lut', jobfn, axset, rqset);

% === Interpolation
ipoint.a.v = 1.5;
ipoint.a.u = 0;
ipoint.x.v = 0;
ipoint.y.v = 0;

x = -7:0.5:7;
y = -7:0.5:7;
for j = 1:numel(x)
    ipoint.x.v = x(j);
    for k = 1:numel(y)
        ipoint.y.v = y(k);
        tmp = qwtbvar('interp', lut, ipoint);
        ival(j, k) = tmp.z.v;
    end
end
mesh(ival)

% vim settings modeline: vim: foldmarker=%<<<,%>>> fdm=marker fen ft=matlab textwidth=80 tabstop=4 shiftwidth=4
