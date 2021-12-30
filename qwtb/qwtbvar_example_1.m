clear all

DI.x.v = 0;
DI.y.v = 0;
DI.a.v = 1;
DI.b.v = 2;
% DIvar.x.v = [-5 0 5];
% DIvar.x.v = [-5 -3 -2 0 2 3 5];
DIvar.x.v = [-5:5];
% DIvar.y.v = [-5 -2 0 2 5]; % [-5:5];
DIvar.y.v = [-5:5]; % [-5:5];
% DIvar.a.v = [1 2]; % [1 2 3];
% DIvar.b.v = [4 5 6 7];

CS.verbose = 1;
CS.unc = 'none';
CS.loc = 0.6827;
CS.cor.req = 0;
CS.cor.gen = 0;
CS.dof.req = 0;
CS.dof.gen = 0;
CS.mcm.repeats = 1e3;
CS.mcm.verbose = 1;
% CS.mcm.method = ’multicore’;
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

consts.a.v = 1;
% 3 dimensional plot:
qwtbvar('plot3D', jobfn, 'x', 'y', 'z', consts);
% [H x y]=qwtbvar('plot2D', jobfn, 'x', 'y'); % , consts);
% vim settings modeline: vim: foldmarker=%<<<,%>>> fdm=marker fen ft=matlab textwidth=80 tabstop=4 shiftwidth=4
