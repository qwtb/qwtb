% temporary working test for qwtb
clear all
%% Sine wave:
%%t = [0:1/1e3:20];
%t = [0:1/1e3:1];
%y = sin(2*pi*t);
%% Add noise:
%y = y + normrnd(0,1e-3,size(y));
M = 3;
% create data structure for QWTB.
t = [1:200];
y = [1:200];

datain.t.v = t;
%datain.t.u = t.*0 + 1e-3;
datain.t.u = repmat(datain.t.v,M,1);
datain.t.u = datain.t.u + normrnd(0, 0.01, size(datain.t.u,1), size(datain.t.u,2));
datain.t.d = t.*0;

datain.y.v = y;
%datain.y.u = y.*0 + 1e-3;
datain.y.u = repmat(datain.y.v,M,1);
datain.y.u = datain.y.u + normrnd(0, 0.01, size(datain.y.u,1), size(datain.y.u,2));
datain.y.d = y.*0;

% Calculation settings structure.
calcset.verbose = 0;
calcset.unc = 'mcm';
calcset.unc = 'guf';
calcset.mcm.repeats = M;
calcset.cor.req = 1;
calcset.dof.req = 1;

% -----------------------------------------------------------------------
% Calculate frequency by means of PSFE:
disp('-----')
disp('testG')
[dataout, datain, calcset] = qwtb('testG', datain, calcset);
disp(['calculated frequency is: ' num2str(dataout.max.v, 9) ' Hz'])
disp(['uncertainty is: ' num2str(std(dataout.max.u), 9) ' Hz'])

disp('-----')
disp('testM')
[dataout, datain, calcset] = qwtb('testM', datain, calcset);
disp(['calculated frequency is: ' num2str(dataout.max.v, 9) ' Hz'])
disp(['uncertainty is: ' num2str(std(dataout.max.u), 9) ' Hz'])

disp('------')
disp('testGM')
[dataout, datain, calcset] = qwtb('testGM', datain, calcset);
disp(['calculated frequency is: ' num2str(dataout.max.v, 9) ' Hz'])
disp(['uncertainty is: ' num2str(std(dataout.max.u), 9) ' Hz'])

% vim settings modeline: vim: foldmarker=%<<<,%>>> fdm=marker fen ft=octave textwidth=80 tabstop=4 shiftwidth=4
