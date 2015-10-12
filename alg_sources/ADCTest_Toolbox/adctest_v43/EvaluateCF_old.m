function varargout = EvaluateCF(y,p0,NoB,INL)
% @fn EvaluateCF
% @brief Evaluates the Maximum likelihood cost function using the actual
%        parameters
% @param y The measurement record (in ADC codes)
% @param p0 The parameters of the sine wave
% @param NoB Number of bits of the ADC under test
% @param INL The estimated INL of the ADC using histogram test
% @return PML The value of the likelihood function
% @return CF The value of the cost function: CF = -log(PML)
% @return grad The gradient of the Cost Function
% @return hess The Hesse-matrix of the Cost Function
% @return probVect The probabilities of each recorded sample in a vector
% @retunr probMTRX The probability of the ADC codes at each element of the
%                  record, collected in a matrix
% @author Tamás Virosztek, Budapest University of Technology and Economics,
%         Department of Measurement and Infromation Systems,
%         Virosztek.Tamas@mit.bme.hu


%function [PML,CF,grad,hess,probVect,probMTRX] = evaluateCF(y,p0,NoB,INL);

% x(k) = A*cos(2*pi*f*t(k)) + B*sin(2*pi*f*t(k) + C)
% t(k) = k*T; 2*pi*f*t(k) = 2*pi*f*k*T = k * 2*pi*f/fs = k*theta
% x (k) = A*cos(k*theta) + B*sin(k*theta) + C
% P(Y(k) == 0) = 1/2*(1 + erf((T(1)-x(k))/(sqrt(2)*sigma)))
% P(Y(k) == 2^B-1) = 1/2*(1 - erf((T(2^B-1)-x(k))/(sqrt(2)*sigma)))
% T(0):= -Inf; T(2^B) := +Inf
% P(Y(k) == l) = 1/2*(erf((T(l+1)-x(k))/(sqrt(2)*sigma)) - erf((T(l)-x(k))/(sqrt(2)*sigma)))
% P(Y(k) == y[k]) = 1/2*(erf((T(y(k)+1)-x(k))/(sqrt(2)*sigma)) - erf((T(y(k))-x(k))/(sqrt(2)*sigma)))

% PML = PROD(P(Y(k) == y(k)));
% CF = -ln(PML) = - SUM(ln(P(Y(k)==y(k))))
% CF = - SUM (-ln(2) + ln (erf((T(y(k)+1)-x(k))/(sqrt(2)*sigma)) - erf ((T(y(k))-x(k))/(sqrt(2)*sigma))))
% CF = M*ln(2) - SUM (ln(arg))
% arg = erf((T(y(k)+1)-x(k))/(sqrt(2)*sigma)) - erf
% ((T(y(k))-x(k))/(sqrt(2)*sigma))


T = zeros (1,2^NoB + 1);
T(1) = -700; T(2^NoB + 1) = +700; %exp(-700) ~=0 exp(700) ~= Inf
T(2:2^NoB) = INL2TransLevels(INL);
%Adding +1 offset to ADC codes: ADC codes between 1 and 2^NoB
%Compatible with transition levels between 2 and 2^NoB
%Equivalent with ADC codes between 0 and 2^NoB-1
%and transition levels between 1 and 2^NoB-1
y = y + 1;
%Initialize parameters
A = p0(1); B = p0(2); C = p0(3); theta = p0(4); sigma = p0(5);

if (nargout>=1)
    %Computing overall probaility
    M = length(y);
    x = zeros(1,M);
    probVect = zeros (1,M);
    for k = 1:M
        x(k) = A*cos(k*theta) + B*sin(k*theta) + C;
        probVect(k) = 1/2*(erf((T(y(k)+1)-x(k))/(sqrt(2)*sigma)) - erf((T(y(k))-x(k))/(sqrt(2)*sigma)));
    end
    PML = prod(probVect);
    varargout{1} = PML;
end

if (nargout>=2)
    %Computing ML Cost function
    arg = zeros(1,M);
    for k = 1:M
        arg(k) = erf((T(y(k)+1)-x(k))/(sqrt(2)*sigma)) - erf((T(y(k))-x(k))/(sqrt(2)*sigma));
    end
    CF = M*log(2) - sum(log(arg)); %exactly the same as CF == -log(PML)
    varargout{2} = CF;

end

if (nargout>=3) %gradient vector shall be calculated
    % Computing first order partial derivatives
    
    %Computing dCF(A,B,C,theta,sigma)/dA
    %dCF/dA = -SUM(1/arg(k)*darg(k)/dA)
    %darg(k)/dA = 2/sqrt(pi)*exp(-((T(y(k)+1)-A*cos(k*theta)-B*sin(k*theta)-C)/(sqrt(2)*sigma))^2) * (-1)*cos(k*theta)/(sqrt(2)*sigma)) -
    %		   	  2/sqrt(pi)*exp(-((T(y(k))-A*cos(k*theta)-B*sin(k*theta)-C)/(sqrt(2)*sigma))^2) * (-1)*cos(k*theta)/(sqrt(2)*sigma))
    dCF_dA = 0;
    darg_dA = zeros(1,M);
    for k = 1:M
        darg_dA(k) = 2/sqrt(pi)*exp(-((T(y(k)+1)-A*cos(k*theta)-B*sin(k*theta)-C)/(sqrt(2)*sigma))^2) * (-1)*cos(k*theta)/(sqrt(2)*sigma) - ...
            2/sqrt(pi)*exp(-((T(y(k))-A*cos(k*theta)-B*sin(k*theta)-C)/(sqrt(2)*sigma))^2) * (-1)*cos(k*theta)/(sqrt(2)*sigma);
        dCF_dA = dCF_dA - 1/arg(k)*darg_dA(k);
    end

    %Computing dCF(A,B,C,theta,sigma)/dB
    %dCF/dB = -SUM(1/arg(k)*darg(k)/dB)
    %darg(k)/dB = 2/sqrt(pi)*exp(-(T((y(k)+1)-A*cos(k*theta)-B*sin(k*theta)-C)/(sqrt(2)*sigma))^2) * (-1)*sin(k*theta)/(sqrt(2)*sigma)) -
    %		      2/sqrt(pi)*exp(-(T((y(k))-A*cos(k*theta)-B*sin(k*theta)-C)/(sqrt(2)*sigma))^2) * (-1)*sin(k*theta)/(sqrt(2)*sigma))
    dCF_dB = 0;
    darg_dB = zeros(1,M);
    for k = 1:M
        darg_dB(k) = 2/sqrt(pi)*exp(-((T(y(k)+1)-A*cos(k*theta)-B*sin(k*theta)-C)/(sqrt(2)*sigma))^2) * (-1)*sin(k*theta)/(sqrt(2)*sigma) - ...
            2/sqrt(pi)*exp(-((T(y(k))-A*cos(k*theta)-B*sin(k*theta)-C)/(sqrt(2)*sigma))^2) * (-1)*sin(k*theta)/(sqrt(2)*sigma);
        dCF_dB = dCF_dB - 1/arg(k)*darg_dB(k);
    end

    %Computing dCF(A,B,C,theta,sigma)/dC
    %dCF/dC = -SUM(1/arg(k)*darg(k)/dC)
    %darg(k)/dC = 2/sqrt(pi)*exp(-((T(y(k)+1)-A*cos(k*theta)-B*sin(k*theta)-C)/(sqrt(2)*sigma))^2) * (-1)/(sqrt(2)*sigma)) -
    %		      2/sqrt(pi)*exp(-((T(y(k))-A*cos(k*theta)-B*sin(k*theta)-C)/(sqrt(2)*sigma))^2) * (-1)/(sqrt(2)*sigma))
    dCF_dC = 0;
    darg_dC = zeros(1,M);
    for k = 1:M
        darg_dC(k) = 2/sqrt(pi)*exp(-((T(y(k)+1)-A*cos(k*theta)-B*sin(k*theta)-C)/(sqrt(2)*sigma))^2) * (-1)/(sqrt(2)*sigma) - ...
            2/sqrt(pi)*exp(-((T(y(k))-A*cos(k*theta)-B*sin(k*theta)-C)/(sqrt(2)*sigma))^2) * (-1)/(sqrt(2)*sigma);
        dCF_dC = dCF_dC - 1/arg(k)*darg_dC(k);
    end

    %Computing dCF(A,B,C,theta,sigma)/dtheta
    %dCF/dC = -SUM(1/arg(k)*darg(k)/dtheta)
    %darg(k)/dtheta = 2/sqrt(pi)*exp(-((T(y(k)+1)-A*cos(k*theta)-B*sin(k*theta)-C)/(sqrt(2)*sigma))^2) * (A/(sqrt(2)*sigma)*sin(k*theta)*k - B/(sqrt(2)*sigma)*cos(k*theta)*k) -
    %		      	  2/sqrt(pi)*exp(-((T(y(k))-A*cos(k*theta)-B*sin(k*theta)-C)/(sqrt(2)*sigma))^2) * (A/(sqrt(2)*sigma)*sin(k*theta)*k - B/(sqrt(2)*sigma)*cos(k*theta)*k)
    dCF_dtheta = 0;
    darg_dtheta = zeros(1,M);
    for k = 1:M
        darg_dtheta(k) = 2/sqrt(pi)*exp(-((T(y(k)+1)-A*cos(k*theta)-B*sin(k*theta)-C)/(sqrt(2)*sigma))^2) * (A/(sqrt(2)*sigma)*sin(k*theta)*k - B/(sqrt(2)*sigma)*cos(k*theta)*k) - ...
            2/sqrt(pi)*exp(-((T(y(k))-A*cos(k*theta)-B*sin(k*theta)-C)/(sqrt(2)*sigma))^2) * (A/(sqrt(2)*sigma)*sin(k*theta)*k - B/(sqrt(2)*sigma)*cos(k*theta)*k);
        dCF_dtheta = dCF_dtheta - 1/arg(k)*darg_dtheta(k);
    end

    %Computing dCF(A,B,C,theta,sigma)/dsigma
    %dCF/dC = -SUM(1/arg(k)*darg(k)/dsigma)
    %darg(k)/dsigma = 2/sqrt(pi)*exp(-((T(y(k)+1)-A*cos(k*theta)-B*sin(k*theta)-C)/(sqrt(2)*sigma))^2) * (-1)/sigma^2*(T(y(k)+1)-A*cos(k*theta)-B*sin(k*theta)-C)/sqrt(2)) -
    %		      	  2/sqrt(pi)*exp(-((T(y(k))-A*cos(k*theta)-B*sin(k*theta)-C)/(sqrt(2)*sigma))^2) * (-1)/sigma^2*(T(y(k))-A*cos(k*theta)-B*sin(k*theta)-C)/sqrt(2)
    dCF_dsigma = 0;
    darg_dsigma = zeros(1,M);

    for k = 1:M
        darg_dsigma(k) = 2/sqrt(pi)*exp(-((T(y(k)+1)-A*cos(k*theta)-B*sin(k*theta)-C)/(sqrt(2)*sigma))^2) * (-1)/sigma^2*(T(y(k)+1)-A*cos(k*theta)-B*sin(k*theta)-C)/sqrt(2) - ...
            2/sqrt(pi)*exp(-((T(y(k))-A*cos(k*theta)-B*sin(k*theta)-C)/(sqrt(2)*sigma))^2) * (-1)/sigma^2*(T(y(k))-A*cos(k*theta)-B*sin(k*theta)-C)/sqrt(2);
        dCF_dsigma = dCF_dsigma - 1/arg(k)*darg_dsigma(k);
    end

    %Assembling the gradient vector:
    grad = [dCF_dA; dCF_dB; dCF_dC; dCF_dtheta; dCF_dsigma];
    %returning the gardient in varargout
    varargout{3} = grad;
end

if (nargout>=4) %Hess matrix shall be calculated
    %d2CF_dA2
    d2CF_dA2 = 0;
    d2arg_dA2 = zeros(1,M);
    for k = 1:M
        bracketplus = (T(y(k)+1)-A*cos(k*theta)-B*sin(k*theta)-C)/(sqrt(2)*sigma);
        bracketnull = (T(y(k))-A*cos(k*theta)-B*sin(k*theta)-C)/(sqrt(2)*sigma);
        d2arg_dA2(k) = 2/sqrt(pi)*exp(-bracketplus^2)*(-2)*(bracketplus)*(-1)*cos(k*theta)/(sqrt(2)*sigma)*(-1)*cos(k*theta)/(sqrt(2)*sigma) - ...
                       2/sqrt(pi)*exp(-bracketnull^2)*(-2)*(bracketnull)*(-1)*cos(k*theta)/(sqrt(2)*sigma)*(-1)*cos(k*theta)/(sqrt(2)*sigma);
        d2CF_dA2 = d2CF_dA2 + 1/arg(k)^2*darg_dA(k)*darg_dA(k) - 1/arg(k)*d2arg_dA2(k);
    end

    %d2CF_dAdB
    d2CF_dAdB = 0;
    d2arg_dAdB = zeros(1,M);
    for k = 1:M
        bracketplus = (T(y(k)+1)-A*cos(k*theta)-B*sin(k*theta)-C)/(sqrt(2)*sigma);
        bracketnull = (T(y(k))-A*cos(k*theta)-B*sin(k*theta)-C)/(sqrt(2)*sigma);
        d2arg_dAdB(k) = 2/sqrt(pi)*exp(-bracketplus^2)*(-2)*(bracketplus)*(-1)*sin(k*theta)/(sqrt(2)*sigma)*(-1)*cos(k*theta)/(sqrt(2)*sigma) - ...
                        2/sqrt(pi)*exp(-bracketnull^2)*(-2)*(bracketnull)*(-1)*sin(k*theta)/(sqrt(2)*sigma)*(-1)*cos(k*theta)/(sqrt(2)*sigma);
        d2CF_dAdB = d2CF_dAdB + 1/arg(k)^2*darg_dB(k)*darg_dA(k) - 1/arg(k)*d2arg_dAdB(k);
    end
    
    %d2CF_dAdC
    d2CF_dAdC = 0;
    d2arg_dAdC = zeros(1,M);
    for k = 1:M
        bracketplus = (T(y(k)+1)-A*cos(k*theta)-B*sin(k*theta)-C)/(sqrt(2)*sigma);
        bracketnull = (T(y(k))-A*cos(k*theta)-B*sin(k*theta)-C)/(sqrt(2)*sigma);
        d2arg_dAdC(k) = 2/sqrt(pi)*exp(-bracketplus^2)*(-2)*(bracketplus)*(-1)/(sqrt(2)*sigma)*(-1)*cos(k*theta)/(sqrt(2)*sigma) - ...
                        2/sqrt(pi)*exp(-bracketnull^2)*(-2)*(bracketnull)*(-1)/(sqrt(2)*sigma)*(-1)*cos(k*theta)/(sqrt(2)*sigma);
        d2CF_dAdC = d2CF_dAdC + 1/arg(k)^2*darg_dC(k)*darg_dA(k) - 1/arg(k)*d2arg_dAdC(k);
    end
    
    %d2CFdAdtheta
    d2CF_dAdtheta = 0;
    d2arg_dAdtheta = zeros(1,M);
    for k = 1:M
        bracketplus = (T(y(k)+1)-A*cos(k*theta)-B*sin(k*theta)-C)/(sqrt(2)*sigma);
        bracketnull = (T(y(k))-A*cos(k*theta)-B*sin(k*theta)-C)/(sqrt(2)*sigma);
        d2arg_dAdtheta(k) = 2/sqrt(pi)*exp(-bracketplus^2)*(-2)*(bracketplus)*((A*sin(k*theta)*k-B*cos(k*theta)*k)/(sqrt(2)*sigma))*(-1)*cos(k*theta)/(sqrt(2)*sigma) + 2/sqrt(pi)*exp(-bracketplus^2)*(sin(k*theta)*k/(sqrt(2)*sigma)) - ...
                            2/sqrt(pi)*exp(-bracketnull^2)*(-2)*(bracketnull)*((A*sin(k*theta)*k-B*cos(k*theta)*k)/(sqrt(2)*sigma))*(-1)*cos(k*theta)/(sqrt(2)*sigma) + 2/sqrt(pi)*exp(-bracketnull^2)*(sin(k*theta)*k/(sqrt(2)*sigma));
        d2CF_dAdtheta = d2CF_dAdtheta + 1/arg(k)^2*darg_dtheta(k)*darg_dA(k) - 1/arg(k)*d2arg_dAdtheta(k);
    end
    
    %d2CF_dAdsigma
    d2CF_dAdsigma = 0;
    d2arg_dAdsigma = zeros(1,M);
    for k = 1:M
        bracketplus = (T(y(k)+1)-A*cos(k*theta)-B*sin(k*theta)-C)/(sqrt(2)*sigma);
        bracketnull = (T(y(k))-A*cos(k*theta)-B*sin(k*theta)-C)/(sqrt(2)*sigma);
        d2arg_dAdsigma(k) = 2/sqrt(pi)*exp(-bracketplus^2)*(-2)*(bracketplus)*(-1)*(bracketplus/sigma)*(-1)*cos(k*theta)/(sqrt(2)*sigma) + 2/sqrt(pi)*exp(-bracketplus^2)*(cos(k*theta)/(sqrt(2)*sigma^2)) - ...
                            2/sqrt(pi)*exp(-bracketnull^2)*(-2)*(bracketnull)*(-1)*(bracketnull/sigma)*(-1)*cos(k*theta)/(sqrt(2)*sigma) + 2/sqrt(pi)*exp(-bracketnull^2)*(cos(k*theta)/(sqrt(2)*sigma^2));
        d2CF_dAdsigma = d2CF_dAdsigma + 1/arg(k)^2*darg_dsigma(k)*darg_dA(k) - 1/arg(k)*d2arg_dAdsigma(k);
    end

    %d2CF_dB2
    d2CF_dB2 = 0;
    d2arg_dB2 = zeros(1,M);
    for k = 1:M
        bracketplus = (T(y(k)+1)-A*cos(k*theta)-B*sin(k*theta)-C)/(sqrt(2)*sigma);
        bracketnull = (T(y(k))-A*cos(k*theta)-B*sin(k*theta)-C)/(sqrt(2)*sigma);
        d2arg_dB2(k) = 2/sqrt(pi)*exp(-bracketplus^2)*(-2)*(bracketplus)*(-1)*sin(k*theta)/(sqrt(2)*sigma)*(-1)*sin(k*theta)/(sqrt(2)*sigma) - ...
                       2/sqrt(pi)*exp(-bracketnull^2)*(-2)*(bracketnull)*(-1)*sin(k*theta)/(sqrt(2)*sigma)*(-1)*sin(k*theta)/(sqrt(2)*sigma);
        d2CF_dB2 = d2CF_dB2 + 1/arg(k)^2*darg_dB(k)*darg_dB(k) - 1/arg(k)*d2arg_dB2(k);
    end
    
    %d2CF_dBdC
    d2CF_dBdC = 0;
    d2arg_dBdC = zeros(1,M);
    for k = 1:M
        bracketplus = (T(y(k)+1)-A*cos(k*theta)-B*sin(k*theta)-C)/(sqrt(2)*sigma);
        bracketnull = (T(y(k))-A*cos(k*theta)-B*sin(k*theta)-C)/(sqrt(2)*sigma);
        d2arg_dBdC(k) = 2/sqrt(pi)*exp(-bracketplus^2)*(-2)*(bracketplus)*(-1)/(sqrt(2)*sigma)*(-1)*sin(k*theta)/(sqrt(2)*sigma) - ...
                        2/sqrt(pi)*exp(-bracketnull^2)*(-2)*(bracketnull)*(-1)/(sqrt(2)*sigma)*(-1)*sin(k*theta)/(sqrt(2)*sigma);
        d2CF_dBdC = d2CF_dBdC + 1/arg(k)^2*darg_dC(k)*darg_dB(k) - 1/arg(k)*d2arg_dBdC(k);
    end

    %d2CF_dBdtheta
    d2CF_dBdtheta = 0;
    d2arg_dBdtheta = zeros(1,M);
    for k = 1:M
        bracketplus = (T(y(k)+1)-A*cos(k*theta)-B*sin(k*theta)-C)/(sqrt(2)*sigma);
        bracketnull = (T(y(k))-A*cos(k*theta)-B*sin(k*theta)-C)/(sqrt(2)*sigma);
        d2arg_dBdtheta(k) = 2/sqrt(pi)*exp(-bracketplus^2)*(-2)*(bracketplus)*((A*sin(k*theta)*k-B*cos(k*theta)*k)/(sqrt(2)*sigma))*(-1)*sin(k*theta)/(sqrt(2)*sigma) + 2/sqrt(pi)*exp(-bracketplus^2)*(-1)*(cos(k*theta)*k/(sqrt(2)*sigma)) - ...
                            2/sqrt(pi)*exp(-bracketnull^2)*(-2)*(bracketnull)*((A*sin(k*theta)*k-B*cos(k*theta)*k)/(sqrt(2)*sigma))*(-1)*sin(k*theta)/(sqrt(2)*sigma) + 2/sqrt(pi)*exp(-bracketnull^2)*(-1)*(cos(k*theta)*k/(sqrt(2)*sigma));
        d2CF_dBdtheta = d2CF_dBdtheta + 1/arg(k)^2*darg_dtheta(k)*darg_dB(k) - 1/arg(k)*d2arg_dBdtheta(k);
    end
    
    %d2CF_dBdsigma
    d2CF_dBdsigma = 0;
    d2arg_dBdsigma = zeros(1,M);
    for k = 1:M
        bracketplus = (T(y(k)+1)-A*cos(k*theta)-B*sin(k*theta)-C)/(sqrt(2)*sigma);
        bracketnull = (T(y(k))-A*cos(k*theta)-B*sin(k*theta)-C)/(sqrt(2)*sigma);
        d2arg_dBdsigma(k) = 2/sqrt(pi)*exp(-bracketplus^2)*(-2)*(bracketplus)*(-1)*(bracketplus/sigma)*(-1)*sin(k*theta)/(sqrt(2)*sigma) + 2/sqrt(pi)*exp(-bracketplus^2)*(sin(k*theta)/(sqrt(2)*sigma^2)) - ...
                            2/sqrt(pi)*exp(-bracketnull^2)*(-2)*(bracketnull)*(-1)*(bracketnull/sigma)*(-1)*sin(k*theta)/(sqrt(2)*sigma) + 2/sqrt(pi)*exp(-bracketplus^2)*(sin(k*theta)/(sqrt(2)*sigma^2));
        d2CF_dBdsigma = d2CF_dBdsigma + 1/arg(k)^2*darg_dsigma(k)*darg_dB(k) - 1/arg(k)*d2arg_dBdsigma(k);
    end

    %d2CF_dC2
    d2CF_dC2 = 0;
    d2arg_dC2 = zeros(1,M);
    for k = 1:M
        bracketplus = (T(y(k)+1)-A*cos(k*theta)-B*sin(k*theta)-C)/(sqrt(2)*sigma);
        bracketnull = (T(y(k))-A*cos(k*theta)-B*sin(k*theta)-C)/(sqrt(2)*sigma);
        d2arg_dC2(k) = 2/sqrt(pi)*exp(-bracketplus^2)*(-2)*(bracketplus)*(-1)/(sqrt(2)*sigma)*(-1)/(sqrt(2)*sigma) - ...
                       2/sqrt(pi)*exp(-bracketnull^2)*(-2)*(bracketnull)*(-1)/(sqrt(2)*sigma)*(-1)/(sqrt(2)*sigma);
            
        d2CF_dC2 = d2CF_dC2 + 1/arg(k)^2*darg_dC(k)*darg_dC(k) - 1/arg(k)*d2arg_dC2(k);
    end

    %d2CF_dCdtheta
    d2CF_dCdtheta = 0;
    d2arg_dCdtheta = zeros(1,M);
    for k = 1:M
        bracketplus = (T(y(k)+1)-A*cos(k*theta)-B*sin(k*theta)-C)/(sqrt(2)*sigma);
        bracketnull = (T(y(k))-A*cos(k*theta)-B*sin(k*theta)-C)/(sqrt(2)*sigma);
        d2arg_dCdtheta(k) = 2/sqrt(pi)*exp(-bracketplus^2)*(-2)*(bracketplus)*((A*sin(k*theta)*k-B*cos(k*theta)*k)/(sqrt(2)*sigma))*(-1)/(sqrt(2)*sigma) - ...
                            2/sqrt(pi)*exp(-bracketnull^2)*(-2)*(bracketnull)*((A*sin(k*theta)*k-B*cos(k*theta)*k)/(sqrt(2)*sigma))*(-1)/(sqrt(2)*sigma);
        d2CF_dCdtheta = d2CF_dCdtheta + 1/arg(k)^2*darg_dtheta(k)*darg_dC(k) - 1/arg(k)*d2arg_dCdtheta(k);
    end

    %d2CF_dCdsigma
    d2CF_dCdsigma = 0;
    d2arg_dCdsigma = zeros(1,M);
    for k = 1:M
        bracketplus = (T(y(k)+1)-A*cos(k*theta)-B*sin(k*theta)-C)/(sqrt(2)*sigma);
        bracketnull = (T(y(k))-A*cos(k*theta)-B*sin(k*theta)-C)/(sqrt(2)*sigma);
        d2arg_dCdsigma(k) = 2/sqrt(pi)*exp(-bracketplus^2)*(-2)*(bracketplus)*(-1)*(bracketplus/sigma)*(-1)/(sqrt(2)*sigma) + 2/sqrt(pi)*exp(-bracketplus^2)*(1)/(sqrt(2*sigma)) - ...
                            2/sqrt(pi)*exp(-bracketnull^2)*(-2)*(bracketnull)*(-1)*(bracketnull/sigma)*(-1)/(sqrt(2)*sigma) + 2/sqrt(pi)*exp(-bracketnull^2)*(1)/(sqrt(2*sigma));
        d2CF_dCdsigma = d2CF_dCdsigma + 1/arg(k)^2*darg_dsigma(k)*darg_dC(k) - 1/arg(k)*d2arg_dCdsigma(k);
    end
    
    %d2CF_dtheta2
    d2CF_dtheta2 = 0;
    d2arg_dtheta2 = zeros(1,M);
    for k = 1:M
        bracketplus = (T(y(k)+1)-A*cos(k*theta)-B*sin(k*theta)-C)/(sqrt(2)*sigma);
        bracketnull = (T(y(k))-A*cos(k*theta)-B*sin(k*theta)-C)/(sqrt(2)*sigma);
        d2arg_dtheta2(k) = 2/sqrt(pi)*exp(-bracketplus^2)*(-2)*(bracketplus)*((A*sin(k*theta)*k-B*cos(k*theta)*k)/(sqrt(2)*sigma))*((A*sin(k*theta)*k-B*cos(k*theta)*k)/(sqrt(2)*sigma)) + 2/sqrt(pi)*exp(-bracketplus^2)*((A*cos(k*theta)*k^2+B*sin(k*theta)*k^2)/(sqrt(2)*sigma)) - ...
                           2/sqrt(pi)*exp(-bracketnull^2)*(-2)*(bracketnull)*((A*sin(k*theta)*k-B*cos(k*theta)*k)/(sqrt(2)*sigma))*((A*sin(k*theta)*k-B*cos(k*theta)*k)/(sqrt(2)*sigma)) + 2/sqrt(pi)*exp(-bracketnull^2)*((A*cos(k*theta)*k^2+B*sin(k*theta)*k^2)/(sqrt(2)*sigma));
        d2CF_dtheta2 = d2CF_dtheta2 + 1/arg(k)^2*darg_dtheta(k)*darg_dtheta(k) - 1/arg(k)*d2arg_dtheta2(k);
    end

    %d2CF_dthetadsigma
    d2CF_dthetadsigma = 0;
    d2arg_dthetadsigma = zeros(1,M);
    for k = 1:M
        bracketplus = (T(y(k)+1)-A*cos(k*theta)-B*sin(k*theta)-C)/(sqrt(2)*sigma);
        bracketnull = (T(y(k))-A*cos(k*theta)-B*sin(k*theta)-C)/(sqrt(2)*sigma);
        d2arg_dthetadsigma(k) = 2/sqrt(pi)*exp(-bracketplus^2)*(-2)*(bracketplus)*(-1)*(bracketplus/sigma)*((A*sin(k*theta)*k-B*cos(k*theta)*k)/(sqrt(2)*sigma)) + 2/sqrt(pi)*exp(-bracketplus^2)*(-1)*((A*sin(k*theta)*k-B*cos(k*theta)*k)/(sqrt(2)*sigma^2)) - ...
                                2/sqrt(pi)*exp(-bracketnull^2)*(-2)*(bracketnull)*(-1)*(bracketnull/sigma)*((A*sin(k*theta)*k-B*cos(k*theta)*k)/(sqrt(2)*sigma)) + 2/sqrt(pi)*exp(-bracketnull^2)*(-1)*((A*sin(k*theta)*k-B*cos(k*theta)*k)/(sqrt(2)*sigma^2));
        d2CF_dthetadsigma = d2CF_dthetadsigma + 1/arg(k)^2*darg_dsigma(k)*darg_dtheta(k) - 1/arg(k)*d2arg_dthetadsigma(k);
    end

    %d2CF_dsigma2
    d2CF_dsigma2 = 0;
    d2arg_dsigma2 = zeros(1,M);
    for k = 1:M
        bracketplus = (T(y(k)+1)-A*cos(k*theta)-B*sin(k*theta)-C)/(sqrt(2)*sigma);
        bracketnull = (T(y(k))-A*cos(k*theta)-B*sin(k*theta)-C)/(sqrt(2)*sigma);
        d2arg_dsigma2(k) = 2/sqrt(pi)*exp(-bracketplus^2)*(-2)*(bracketplus)*(-1)*(bracketplus/sigma)*(-1)*(bracketplus/sigma) + 2/sqrt(pi)*exp(-bracketplus^2)*(2*bracketplus/sigma^2) - ...
                           2/sqrt(pi)*exp(-bracketnull^2)*(-2)*(bracketnull)*(-1)*(bracketnull/sigma)*(-1)*(bracketnull/sigma) + 2/sqrt(pi)*exp(-bracketnull^2)*(2*bracketnull/sigma^2);
        d2CF_dsigma2 = d2CF_dsigma2 + 1/arg(k)^2*darg_dsigma(k)*darg_dsigma(k) - 1/arg(k)*d2arg_dsigma2(k);
    end

    hess = [d2CF_dA2        d2CF_dAdB       d2CF_dAdB       d2CF_dAdtheta       d2CF_dAdsigma; ...
            d2CF_dAdB       d2CF_dB2        d2CF_dBdC       d2CF_dBdtheta       d2CF_dBdsigma; ...
            d2CF_dAdC       d2CF_dBdC       d2CF_dC2        d2CF_dCdtheta       d2CF_dCdsigma; ...
            d2CF_dAdtheta   d2CF_dBdtheta   d2CF_dCdtheta   d2CF_dtheta2        d2CF_dthetadsigma;...
            d2CF_dAdsigma   d2CF_dBdsigma   d2CF_dCdsigma   d2CF_dthetadsigma   d2CF_dsigma2];

    varargout{4} = hess;
end

if (nargout>=5) %probVect shall be returned
    varargout{5} = probVect;
end

if (nargout>=6) %probMTRX shall be calculated
   probMTRX = zeros(2^NoB,M);
    for k = 1:M
        for l = 1:2^NoB
            probMTRX(l,k) = 1/2*(erf((T(l+1)-x(k))/(sqrt(2)*sigma)) - erf((T(l)-x(k))/(sqrt(2)*sigma)));%!! (l,k)
        end
    end
    %returning probMTRX in varargout
    varargout{6} = probMTRX;
end

end