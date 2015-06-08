% temporary working test for qwtb
clear all
%% Sine wave:
%%t = [0:1/1e3:20];
%t = [0:1/1e3:1];
%y = sin(2*pi*t);
%% Add noise:
%y = y + normrnd(0,1e-3,size(y));
% create data structure for QWTB.
t = [1:200];
y = [1:200];
datain.t.v = t;
datain.t.u = t.*0 + 1e-3;
datain.t.d = t.*0;
datain.y.v = y;
datain.y.u = y.*0 + 1e-3;
datain.y.d = y.*0;

% Calculation settings structure.
calcset.unc = 'mcm';
calcset.verbose = 1;
calcset.mcm.verbose = 1;
calcset.mcm.tmpdir = '.';
calcset.mcm.procno = 1;
calcset.mcm.method = 'singlecore';
calcset.mcm.repeats = 100;

% -----------------------------------------------------------------------
% Calculate frequency by means of PSFE:
disp('-----')
disp('testG')
dataout = qwtb('testG', datain, calcset);
disp(['calculated frequency is: ' num2str(dataout.max.v, 9) ' Hz'])
disp(['uncertainty is: ' num2str(std(dataout.max.u), 9) ' Hz'])

disp('-----')
disp('testM')
dataout = qwtb('testM', datain, calcset);
disp(['calculated frequency is: ' num2str(dataout.max.v, 9) ' Hz'])
disp(['uncertainty is: ' num2str(std(dataout.max.u), 9) ' Hz'])

disp('------')
disp('testGM')
dataout = qwtb('testGM', datain, calcset);
disp(['calculated frequency is: ' num2str(dataout.max.v, 9) ' Hz'])
disp(['uncertainty is: ' num2str(std(dataout.max.u), 9) ' Hz'])

% vim settings modeline: vim: foldmarker=%<<<,%>>> fdm=marker fen ft=octave textwidth=80 tabstop=4 shiftwidth=4
