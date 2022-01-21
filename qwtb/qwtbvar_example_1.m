clear all

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
CS.unc = 'mcm';
CS.loc = 0.6827;
CS.cor.req = 0;
CS.cor.gen = 0;
CS.dof.req = 0;
CS.dof.gen = 0;
CS.mcm.repeats = 1e3;
CS.mcm.verbose = 1;
CS.mcm.method = 'singlecore';
CS.mcm.procno = 6;
CS.mcm.tmpdir = '.';
CS.mcm.randomize = 1;
CS.checkinputs = 1;
%variationsettings:
CS.var.dir = 'qwtbvarexample';
CS.var.cleanfiles = 1;
CS.var.method = 'multicore';
CS.var.procno = 4;

[jobfn] = qwtbvar('calc', 'qwtbvar_example_process', DI, DIvar, CS);
keyboard

consts.a.v = 1;
% 3 dimensional plot:
qwtbvar('plot3D', jobfn, 'x', 'y', 'z', consts);
% [H x y]=qwtbvar('plot2D', jobfn, 'x', 'y'); % , consts);

% Look Up Table
ax.a.v.min_ovr = 0.95;
ax.a.v.max_ovr = 1.05;
ax.a.v.min_lim = 'error';
ax.a.v.max_lim = 'error';
ax.a.v.scale = 'lin';
ax.a.u.min_ovr = 0.95;
ax.a.u.max_ovr = 1.05;
ax.a.u.min_lim = 'error';
ax.a.u.max_lim = 'error';
ax.a.u.scale = 'lin';
ax.x.v.min_ovr = 0.95;
ax.x.v.max_ovr = 1.05;
ax.x.v.min_lim = 'error';
ax.x.v.max_lim = 'error';
ax.x.v.scale = 'lin';
ax.y.v.min_ovr = 0.95;
ax.y.v.max_ovr = 1.05;
ax.y.v.min_lim = 'error';
ax.y.v.max_lim = 'error';
ax.y.v.scale = 'lin';

qu.z.v.scale = 'lin';
qu.z.v.mult = 1;

lut = qwtbvar('lut', jobfn, ax, qu);

% vim settings modeline: vim: foldmarker=%<<<,%>>> fdm=marker fen ft=matlab textwidth=80 tabstop=4 shiftwidth=4
