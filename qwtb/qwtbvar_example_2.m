%% Complex example of the QWTBvar use

%% Overview
% The example shows how non-scalar quantities can be used in variations and
% plotting.

%% Inputs
% All input quantities are vectors. First value is x component, second value is
% y component. Gravity acceleration is approx. [0, -9.81].
% Starting velocity (m/s):
DI.v.v = [0 0];
DI.v.u = [0 0];
%%
% Evaluation will be conducted at times (s):
DI.t.v = [0 1 2 3];
DI.t.u = [0.1 0.2 0.3 0.4 0.5].*0.0001;
%%
% Varied input quantities:
% Starting velocity is for 3 cases:
%  1, still object,
%  2, object thrown upward,
%  3, object thrown forward,
%  4, object thrown backward:
DIvar.v.v = [0 0; 0 10; 10 0; -10 0];
%%
% Variation for velocity uncertainties: none, small, large:
DIvar.v.u = [0 0; 0.2 0.2; 10 100];
%%
% Variation: Results calculated for short range of times and distant times:
DIvar.t.v = [0 1 2 3; 4 5 6 7];
%% 
% Some optional settings: 
CS.verbose = 1;
CS.mcm.repeats = 10;
CS.var.dir = 'qwtbvar_example_2_calculation_data';
CS.var.cleanfiles = 1;
CS.var.method = 'singlecore';
CS.var.procno = 1;

%% Calculation
% Run whole calculation. Input quantities in DI will be varied according DIvar:
[jobfn] = qwtbvar('calc', 'qwtbvar_example_2_process', DI, DIvar, CS);

%% Results
% Get results as multidimensional arrays, where every dimension represents one
% varied quantity. The result will be for selected settings of consts.
qwtbvar('plot2D', jobfn, 'v.v', 'range.v');
consts.v.v = [0   0];
consts.v.u = [0   0];
qwtbvar('result', jobfn, consts);
qwtbvar('plot2D', jobfn, 'v.v', 'range.v', consts);
qwtbvar('plot3D', jobfn, 'v.v', 'v.u', 'range.v', consts);



% % consts.v.v = [1 2];
% consts.v.u = [0.1 0.2];
% [ndres, ndresc, ndaxes] = qwtbvar('result', jobfn, consts);
% % ndres is a structure with results as matrices. Although, because results are not scalars,
% % it contains cells.
% % ndresc is a cell with structures of results.
% % ndaxes is description of which quantity was varied in which dimension.
