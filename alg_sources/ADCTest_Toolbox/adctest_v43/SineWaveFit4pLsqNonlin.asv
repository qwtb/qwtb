function p = SineWaveFit4pLsqNonlin(datavect,timevect,initial_freq,options)
% @fn SineWaveFit4pLsqNonlin
% @brief Fits a sine wave to the recorded data in least squares sense using
%        4 parameters
% @param datavect Vector of the recorded ADC codes
% @param timevect Sampling times of the elements of datavect
% @param initial_freq Initial frequency estimator normalized to the
%                     sampling frequency (f/fs)
% @param options Options of the numerical optimization (the nonlinear LS fit)
% @return p The estimated signal parameters
% @author Tamás Virosztek, Budapest University of Technology and Economics,
%         Department of Measurement and Information Systems,
%         Virosztek.Tamas@mit.bme.hu

% p = [A; B; C; theta]
theta0 = 2*pi*initial_freq; %Initial frequency is given in f/fs;

%Estimating sine wave coefficients using theta0 and 3-parameter fit
D0 = [cos(timevect*theta0) sin(timevect*theta0) ones(length(timevect),1)];
p0 = D0\datavect; %p0 = [A0 B0 C0].';

p0 = [p0; theta0];
options.Display = 'off'; %To suppress display in Command Window
p = lsqnonlin(@(p)CalculateResidualsForLS4pFit(p,datavect,timevect),p0,-Inf,Inf,options);

end
