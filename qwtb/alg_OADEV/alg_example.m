%% Allan Overlapping Deviation
% Example for algorithm OADEV.
%
% OADEV is an algorithm to compute the overlapping Allan deviation for a set of time-domain frequency data.
%
% See also W. J. Riley, "The Calculation of Time Domain Frequency Stability". Implementation: M. A. Hopcroft, mhopeng@gmail.com, Matlab Central.'

%% Generate sample data
DI = [];
%!demo
%ysin=2.*sin(2.*pi.*1/300.*[1:1:1e3]);
%! [x y s errors]=adev(1, ysin, 1, 'best averaging time is 300 s, i.e. cca one sine period');
% A random numbers with normal probability distribution function will be geneated into data input |DI.y.v|.
DI.y.v = normrnd(1.5,3,1,1e3);
% Next a drift is added:
DI.y.v = DI.y.v + [1:1:1e3]./100;
% Lets suppose a sampling frequency is 1 Hz:
DI.fs.v = 1;
% Let the algorithm generate all possible tau values automatically:
DI.tau.v = [];

%% Call algorithm
% Use QWTB to apply algorithm |OADEV| to data |DI|.
DO = qwtb('OADEV', DI);

%% Display results
% Log log figure is the best to see allan deviation results:
figure; hold on
loglog(DO.tau.v, DO.adev.v, '-b')
loglog(DO.tau.v, DO.adev.v + DO.adev.u, '-k')
loglog(DO.tau.v, DO.adev.v - DO.adev.u, '-k')
xlabel('\tau (sec)');
ylabel('\sigma_y(\tau)');
title(['period = ' num2str(DI.fs.v)]);
grid('on'); hold off
