function alg_test(calcset) %<<<1
% Part of QWTB. Test script for algorithm ISOTS28037
% disable any warnings:
CS.verbose = 0;

%% WLS1 %<<<1
% This test based on file TS28037_WLS1.m
% no x uncertainty, so wrapper must select WLS1
clear DI
DI.x.v = [1.0 2.0 3.0 4.0 5.0 6.0];
DI.y.v = [3.3 5.6 7.1 9.3 10.7 12.1];
DI.y.u = [0.5 0.5 0.5 0.5 0.5 0.5];
DI.xhat.v = [3.5 4.5];
DI.xhat.u = [0.2 0.4];

DO = qwtb('ISOTS28037', DI, CS);

assert(all(abs(DO.coefs.v(:)' - [1.757 1.867]) < 1e-3));
assert(all(abs(DO.coefs.u(:)' - [0.120 0.465]) < 1e-3));
% XXX 2DO covariance! % Covariance associated with estimates of intercept and slope -0.050
assert(all(abs(DO.exponents.v(:)' - [0 1]) < 1e-3));
assert(all(abs(DO.yhat.v(:)' - [8.017 9.774]) < 1e-3));
assert(all(abs(DO.yhat.u(:)' - [0.406 0.742]) < 1e-3));
assert(DO.model.v == 'ISO/TS 28037:2010(E) WLS');
assert(all(abs(DO.chisq_obs.v - 1.665) < 1e-3));
assert(all(abs(DO.chisq.v - 9.488) < 1e-3));
assert(DO.model_rejected.v == false);

%% WLS3 %<<<1
% This test based on file TS28037_WLS3.m
% no x nor y uncertainty, so wrapper must select WLS with posterior uncertainty
% estimates
clear DI
DI.x.v = [1.000 2.000 3.000 4.000 5.000 6.000]; 
DI.y.v = [3.014 5.225 7.004 9.061 11.201 12.762]; 
DI.xhat.v = [3.5 4.5];
DI.xhat.u = [0.2 0.4];

DO = qwtb('ISOTS28037', DI, CS);

assert(all(abs(DO.coefs.v(:)' - [1.964 1.172]) < 1e-3));
assert(all(abs(DO.exponents.v(:)' - [0 1]) < 1e-3));
assert(all(abs(DO.yhat.v(:)' - [8.044 10.008]) < 1e-3));
assert(all(abs(DO.yhat.u(:)' - [1.280 1.592]) < 1e-3));
assert(DO.model.v == 'ISO/TS 28037:2010(E) WLS, posterior uncertainty estimates');
assert(all(abs(DO.chisq_obs.v - 0.116) < 1e-3));
assert(all(abs(DO.chisq.v - 9.488) < 1e-3));
assert(DO.model_rejected.v == false);

%% GDR1 %<<<1
% This test based on file TS28037_GDR1.m
% x uncertainty, so wrapper must select GDR
clear DI
DI.x.v = [1.2 1.9 2.9 4.0 4.7 5.9]';
DI.y.v = [3.4 4.4 7.2 8.5 10.8 13.5]';
DI.x.u = [0.2 0.2 0.2 0.2 0.2 0.2]';
DI.y.u = [0.2 0.2 0.2 0.4 0.4 0.4]';
DI.xhat.v = [3.5 4.5];
DI.xhat.u = [0.2 0.4];

DO = qwtb('ISOTS28037', DI, CS);

assert(all(abs(DO.coefs.v(:)' - [2.1597 0.5788]) < 1e-4));
assert(all(abs(DO.coefs.u(:)' - [0.1355 0.4764]) < 1e-4));
% XXX 2DO covariance! Covariance associated with estimates of intercept and slope -0.0577
assert(all(abs(DO.exponents.v(:)' - [0 1]) < 1e-3));
assert(all(abs(DO.yhat.v(:)' - [8.138 10.297]) < 1e-3));
assert(all(abs(DO.yhat.u(:)' - [0.484 0.909]) < 1e-3));
assert(DO.model.v == 'ISO/TS 28037:2010(E) GDR');
assert(all(abs(DO.chisq_obs.v - 2.743) < 1e-3));
assert(all(abs(DO.chisq.v - 9.488) < 1e-3));
assert(DO.model_rejected.v == false);

end
