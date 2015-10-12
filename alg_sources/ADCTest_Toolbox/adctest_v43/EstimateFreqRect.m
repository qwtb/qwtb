function f = EstimateFreqRect(x)
% @fn EstimateFreqRect
% @brief Returns a frequency estimator of the input signal using  sinc fit
%        in the frequency domain
% @param x The vector of the sampled (and quantized) signal
% @return f The estimated frequency normalized to the sampling frequency (f/fs)
% @author Tamás Virosztek, Budapest University of Technology and Economics,
%         Department of Measurement and Information Systems,
%         Virosztek.Tamas@mit.bme.hu

X = fft(x);
Xa = abs(X);
N = length(X);
[val, ind] = max(Xa(2:floor(N/2)+1));
if (ind == 1)
    ii = ind;
    jj = ii + 1;
else
    ii = ind;
    if (Xa(ind-1) < Xa(ind+1))
        jj = ii + 1;
    else
        jj = ii - 1;
    end
end
Ui = real(X(ii+1));
Vi = imag(X(ii+1));
Uj = real(X(jj+1));
Vj = imag(X(jj+1));
n = 2*pi/N;
Kopt = (sin(n*ii*(Vj-Vi)) + cos(n*ii*(Uj-Ui))) / (Uj-Ui);
Z2 = Vj*((Kopt - cos(n*jj))/sin(n*jj)) + Uj;
Z1 = Vi*((Kopt - cos(n*ii))/sin(n*ii)) + Ui;
periods = 1/n*acos((Z2*cos(n*(ii+1)) - Z1*cos(n*ii)) / (Z2-Z1));
if (periods > N/2)
    periods = N - periods;
end
f = periods / N;
end

