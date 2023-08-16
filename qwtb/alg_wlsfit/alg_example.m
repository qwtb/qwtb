close all
%% Weighted Least Square Fitting Algortihm
% Example for algorithm wlsfit
%

%% Obtain example data
% load ws_lsfit_0308.mat

% Set independent and dependent variables for |wlsfit| algorithm, OLS method.
% Lets operate in semi logarithm space for easy plotting.
DIols = [];
DIols.x.v = log10([10 1e2 1e3 1e4 1e5]);
DIols.x.u = [];
DIols.y.v = [19.700 32.700 69.700 90.700 148.700];
% polynomial order:
DIols.n.v = 2;

% Create data for WLS method (add uncertainties of y):
DIwls = DIols;
DIwls.y.u = [4 10 13 20 33];

%% Call algorithm
% Use QWTB to apply algorithm |wlsfit| to data |DIwls|.
DOols = qwtb('wlsfit', DIols);
DOwls = qwtb('wlsfit', DIwls);

%% Display results
% Results is 
disp('')
disp([DOols.model.v ':'])
disp(['offset          : ' num2str(DOols.coefs.v(1)) ' +- ' num2str(DOols.coefs.u(1))])
disp(['linear coeff.   : ' num2str(DOols.coefs.v(2)) ' +- ' num2str(DOols.coefs.u(2))])
disp(['quadratic coeff.: ' num2str(DOols.coefs.v(3)) ' +- ' num2str(DOols.coefs.u(3))])
disp([DOwls.model.v ':'])
disp(['offset          : ' num2str(DOwls.coefs.v(1)) ' +- ' num2str(DOwls.coefs.u(1))])
disp(['linear coeff.   : ' num2str(DOwls.coefs.v(2)) ' +- ' num2str(DOwls.coefs.u(2))])
disp(['quadratic coeff.: ' num2str(DOwls.coefs.v(3)) ' +- ' num2str(DOwls.coefs.u(3))])

%% Interpolate values
% Interpolate fitted polynom at values |t|.
t = [0:0.1:6];
tyols = DOols.func.v(t, DOols.coefs.v);
tywls = DOwls.func.v(t, DOwls.coefs.v);
%%
% Calculate uncertainties of interpolated values (|S| is sensitivity matrix, |CC| is covariance
% matrix of coefficients, |CT| is covariance matrix of interpolated values, |uty| is uncertainty of
% interpolated values).
for i = 1:length(t);
        S = t(i).^[0:DIols.n.v];
        CC = diag(DOols.coefs.u,0)*DOols.coefs.c*diag(DOols.coefs.u,0);
        CT(i)=S*CC*S';
end
utyols=CT.^0.5;

for i = 1:length(t);
        S = t(i).^[0:DIwls.n.v];
        CC = diag(DOwls.coefs.u,0)*DOwls.coefs.c*diag(DOwls.coefs.u,0);
        CT(i)=S*CC*S';
end
utywls=CT.^0.5;

%% Plot results
hold on
% input data:
errorbar(DIwls.x.v, DIwls.y.v, DIwls.y.u, 'xb')
% outputs:
plot(DIols.x.v, DOols.yhat.v, 'or')
errorbar(DIwls.x.v, DOwls.yhat.v, DOwls.yhat.u, 'og')
plot(t, tyols, '--r');
plot(t, tywls, '-g');
plot(t, tyols + utyols, '--r');
plot(t, tywls + utywls, '-g');
plot(t, tyols - utyols, '--r');
plot(t, tywls - utywls, '-g');
xlabel('log(f)')
ylabel('error of amplitude')
legend('original data','fitted values, OLS', 'fitted values, WLS','interpolated values, OLS', 'interpolated values, WLS', 'uncer. of int. val., OLS', 'uncert. of int. val., WLS','location','southeast')
hold off
