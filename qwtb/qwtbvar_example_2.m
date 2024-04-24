clear all

% The example shows how nonscalar quantities can be used in variations and
% plotting.

% === Inputs
% All input quantities are vectors:
DI.v.v = [1 2];
DI.v.u = [0.1 0.2];
DI.t.v = [1 2 3 4];
DI.t.u = [0.1 0.2 0.3 0.4 0.5];
% Varied input quantities:
DIvar.v.v = [    1 2;     2 3;       4 4];
DIvar.v.u = [0.1 0.2; 0.2 0.3;   0.4 0.4];
DIvar.t.v = [1 2 3 4; 2 4 6 8; 4 8 12 16];

% Some optional settings: 
CS.verbose = 1;
CS.mcm.repeats = 1e3;
CS.var.dir = 'qwtbvar_example_2_calculation_data';
CS.var.cleanfiles = 1;
CS.var.method = 'singlecore';
CS.var.procno = 1;

% === Calculation
% Run whole calculation. Input quantities in DI will be varied according DIvar:
[jobfn] = qwtbvar('calc', 'qwtbvar_example_2_process', DI, DIvar, CS);

% === Results
% Get results as multidimensional arrays, where every dimension represents one
% varied quantity. The result will be for selected settings of consts.
% consts.v.v = [1 2];
consts.v.u = [0.1 0.2];
[ndres, ndresc, ndaxes] = qwtbvar('result', jobfn, consts);
% ndres is a structure with results as matrices. Although, because results are not scalars,
% it contains cells.
% ndresc is a cell with structures of results.
% ndaxes is description of which quantity was varied in which dimension.

% vim settings modeline: vim: foldmarker=%<<<,%>>> fdm=marker fen ft=matlab textwidth=80 tabstop=4 shiftwidth=4
