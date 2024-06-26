% Example for algorithm ISOTS28037

%% Generate sample data
% Set independent and dependent variables.
DI.x.v = [1 2 3 4 5];
DI.x.u = [0.1 0.1 0.1 0.1 0.1];
DI.y.v = [1.1 1.9 3.1 3.9 5.1];
DI.y.u = [0.1 0.1 0.1 0.1 0.1];

% Set values for interpolation:
DI.xhat.v = [0:0.1:6];
DI.xhat.u = 0.1 + zeros(size(DI.xhat.v));

%% Call algorithm
% Use QWTB to apply algorithm |ISOTS28037| to data |DI|.
DO = qwtb('ISOTS28037', DI);

%% Display results
% Results is
disp(['offset          : ' num2str(DO.coefs.v(1)) ' +- ' num2str(DO.coefs.u(1))])
disp(['linear coeff.   : ' num2str(DO.coefs.v(2)) ' +- ' num2str(DO.coefs.u(2))])

%% Plot results
figure
hold on
errorbar(DI.x.v, DI.y.v, DI.x.u, DI.x.u, DI.y.u, DI.y.u, '~>xb')
plot(DI.xhat.v, DO.yhat.v, 'r-')
plot(DI.xhat.v, DO.yhat.v + DI.xhat.u, 'k-')
plot(DI.xhat.v, DO.yhat.v - DI.xhat.u, 'k-')
xlabel('independent variable')
ylabel('dependent variable')
legend('original data','fit', 'interpolated values', 'uncer. of int. val.','location','southeast')
hold off
