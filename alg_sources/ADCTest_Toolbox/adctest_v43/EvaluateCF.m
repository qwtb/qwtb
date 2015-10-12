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
    fi = (1:M)*theta;
    x = A*cos(fi) + B*sin(fi) + C;
    T1 = T(y+1);
    T2 = T(y);
        
    probVect = 1/2*(erf((T1-x)/(sqrt(2)*sigma)) - erf((T2-x)/(sqrt(2)*sigma)));
               
    
    PML = prod(probVect);
    varargout{1} = PML;
end

if (nargout>=2)
    %Computing ML Cost function
    arg = 2 * probVect;
    %CF = M*log(2) - sum(log(arg)); %exactly the same as CF == -log(PML)
    CF = -sum(log(probVect));
    varargout{2} = CF;

end

if (nargout>=3) %gradient vector shall be calculated
    % Computing first order partial derivatives    
    L = (1:M);

    %Computing dCF(A,B,C,theta,sigma)/dA     
        darg_dA = (2/sqrt(pi)*exp(-((T1-A*cos(fi)-B*sin(fi)-C)/(sqrt(2)*sigma)).^2)).* ((-1)*cos(fi)/(sqrt(2)*sigma)) - ...
                  (2/sqrt(pi)*exp(-((T2-A*cos(fi)-B*sin(fi)-C)/(sqrt(2)*sigma)).^2)).* ((-1)*cos(fi)/(sqrt(2)*sigma));
              
        dCF_dA = -1./arg*darg_dA';

    %Computing dCF(A,B,C,theta,sigma)/dB
        darg_dB = (2/sqrt(pi)*exp(-((T1-A*cos(fi)-B*sin(fi)-C)/(sqrt(2)*sigma)).^2)).* ((-1)*sin(fi)/(sqrt(2)*sigma)) - ...
            (2/sqrt(pi)*exp(-((T2-A*cos(fi)-B*sin(fi)-C)/(sqrt(2)*sigma)).^2)).* ((-1)*sin(fi)/(sqrt(2)*sigma));  

        dCF_dB = -1./arg*darg_dB';
   
    %Computing dCF(A,B,C,theta,sigma)/dC
        darg_dC = (2/sqrt(pi)*exp(-((T1-A*cos(fi)-B*sin(fi)-C)/(sqrt(2)*sigma)).^2)).* ((-1)/(sqrt(2)*sigma)) - ...
                  (2/sqrt(pi)*exp(-((T2-A*cos(fi)-B*sin(fi)-C)/(sqrt(2)*sigma)).^2)).* ((-1)/(sqrt(2)*sigma));
            
        dCF_dC = -1./arg*darg_dC';

    %Computing dCF(A,B,C,theta,sigma)/dtheta
        darg_dtheta =   (2/sqrt(pi)*exp(-((T1-A*cos(fi)-B*sin(fi)-C)/(sqrt(2)*sigma)).^2)).* (A/(sqrt(2)*sigma)*sin(fi).*L - B/(sqrt(2)*sigma)*cos(fi).*L) - ...
                        (2/sqrt(pi)*exp(-((T2-A*cos(fi)-B*sin(fi)-C)/(sqrt(2)*sigma)).^2)).* (A/(sqrt(2)*sigma)*sin(fi).*L - B/(sqrt(2)*sigma)*cos(fi).*L);
            
        dCF_dtheta = -1./arg*darg_dtheta';

    %Computing dCF(A,B,C,theta,sigma)/dsigma
        darg_dsigma = (2/sqrt(pi)*exp(-((T1-A*cos(fi)-B*sin(fi)-C)/(sqrt(2)*sigma)).^2)).* ((-1)/sigma^2*(T1-A*cos(fi)-B*sin(fi)-C)/sqrt(2)) - ...
                      (2/sqrt(pi)*exp(-((T2-A*cos(fi)-B*sin(fi)-C)/(sqrt(2)*sigma)).^2)).* ((-1)/sigma^2*(T2-A*cos(fi)-B*sin(fi)-C)/sqrt(2));
            
        dCF_dsigma = -1./arg*darg_dsigma';

    %Assembling the gradient vector:
    grad = [dCF_dA; dCF_dB; dCF_dC; dCF_dtheta; dCF_dsigma];
    %Returning the gardient in varargout
    varargout{3} = grad;
end

if (nargout>=4) %Hess matrix shall be calculated

    bracketplus = (T1-A*cos(fi)-B*sin(fi)-C)/(sqrt(2)*sigma);
    bracketnull = (T2-A*cos(fi)-B*sin(fi)-C)/(sqrt(2)*sigma);
    
    %d2CF_dA2
    d2arg_dA2 =  2/sqrt(pi)*exp(-bracketplus.^2).*(-2).*(bracketplus).*(-1).*cos(fi)./(sqrt(2)*sigma)*(-1).*cos(fi)./(sqrt(2)*sigma) - ...
                 2/sqrt(pi)*exp(-bracketnull.^2).*(-2).*(bracketnull).*(-1).*cos(fi)./(sqrt(2)*sigma)*(-1).*cos(fi)./(sqrt(2)*sigma);
        
    d2CF_dA2 = 1./(arg.^2)*(darg_dA.*darg_dA)' - 1./arg*d2arg_dA2';


    %d2CF_dAdB
    d2arg_dAdB = 2/sqrt(pi)*exp(-bracketplus.^2).*(-2).*(bracketplus).*(-1).*sin(fi)./(sqrt(2)*sigma)*(-1).*cos(fi)./(sqrt(2)*sigma) - ...
                 2/sqrt(pi)*exp(-bracketnull.^2).*(-2).*(bracketnull).*(-1).*sin(fi)./(sqrt(2)*sigma)*(-1).*cos(fi)./(sqrt(2)*sigma);
       
    d2CF_dAdB = 1./arg.^2*(darg_dB.*darg_dA)' - 1./arg*d2arg_dAdB';

    
    %d2CF_dAdC
    d2arg_dAdC = 2/sqrt(pi)*exp(-bracketplus.^2).*(-2).*(bracketplus).*(-1)./(sqrt(2)*sigma)*(-1).*cos(fi)./(sqrt(2)*sigma) - ...
                 2/sqrt(pi)*exp(-bracketnull.^2).*(-2).*(bracketnull).*(-1)./(sqrt(2)*sigma)*(-1).*cos(fi)./(sqrt(2)*sigma);
        
    d2CF_dAdC = 1./arg.^2*(darg_dC.*darg_dA)' - 1./arg*d2arg_dAdC';

    
    %d2CFdAdtheta
    d2arg_dAdtheta =  2/sqrt(pi)*exp(-bracketplus.^2).*(-2).*(bracketplus).*((A*sin(fi).*L-B*cos(fi).*L)./(sqrt(2)*sigma)).*(-1).*cos(fi)./(sqrt(2)*sigma) + 2/sqrt(pi)*exp(-bracketplus.^2).*(sin(fi).*L./(sqrt(2)*sigma)) - ...
                     (2/sqrt(pi)*exp(-bracketnull.^2).*(-2).*(bracketnull).*((A*sin(fi).*L-B*cos(fi).*L)./(sqrt(2)*sigma)).*(-1).*cos(fi)./(sqrt(2)*sigma) + 2/sqrt(pi)*exp(-bracketnull.^2).*(sin(fi).*L./(sqrt(2)*sigma)));

    d2CF_dAdtheta = 1./arg.^2*(darg_dtheta.*darg_dA)' - 1./arg*d2arg_dAdtheta';

    
    %d2CF_dAdsigma
    d2arg_dAdsigma = 2/sqrt(pi)*exp(-bracketplus.^2).*(-2).*(bracketplus).*(-1).*(bracketplus./sigma).*(-1).*cos(fi)./(sqrt(2)*sigma) + 2/sqrt(pi)*exp(-bracketplus.^2).*(cos(fi)./(sqrt(2)*sigma^2)) - ...
                    (2/sqrt(pi)*exp(-bracketnull.^2).*(-2).*(bracketnull).*(-1).*(bracketnull./sigma).*(-1).*cos(fi)./(sqrt(2)*sigma) + 2/sqrt(pi)*exp(-bracketnull.^2).*(cos(fi)./(sqrt(2)*sigma^2)));

    d2CF_dAdsigma = 1./arg.^2*(darg_dsigma.*darg_dA)' - 1./arg*d2arg_dAdsigma';


    %d2CF_dB2
    d2arg_dB2 = 2/sqrt(pi)*exp(-bracketplus.^2).*(-2).*(bracketplus).*(-1).*sin(fi)./(sqrt(2)*sigma).*(-1).*sin(fi)./(sqrt(2)*sigma) - ...
                2/sqrt(pi)*exp(-bracketnull.^2).*(-2).*(bracketnull).*(-1).*sin(fi)./(sqrt(2)*sigma).*(-1).*sin(fi)./(sqrt(2)*sigma);
        
    d2CF_dB2 = 1./arg.^2*(darg_dB.*darg_dB)' - 1./arg*d2arg_dB2';

    
    %d2CF_dBdC
    d2arg_dBdC =  2/sqrt(pi)*exp(-bracketplus.^2).*(-2).*(bracketplus).*(-1)./(sqrt(2)*sigma).*(-1).*sin(fi)./(sqrt(2)*sigma) - ...
                  2/sqrt(pi)*exp(-bracketnull.^2).*(-2).*(bracketnull).*(-1)./(sqrt(2)*sigma).*(-1).*sin(fi)./(sqrt(2)*sigma);
        
    d2CF_dBdC = 1./arg.^2*(darg_dC.*darg_dB)' - 1./arg*d2arg_dBdC';

    %d2CF_dBdtheta
    d2arg_dBdtheta = 2/sqrt(pi)*exp(-bracketplus.^2).*(-2).*(bracketplus).*((A*sin(fi).*L-B*cos(fi).*L)./(sqrt(2)*sigma)).*(-1).*sin(fi)./(sqrt(2)*sigma) + 2/sqrt(pi)*exp(-bracketplus.^2).*(-1).*(cos(fi).*L/(sqrt(2)*sigma)) - ...
                    (2/sqrt(pi)*exp(-bracketnull.^2).*(-2).*(bracketnull).*((A*sin(fi).*L-B*cos(fi).*L)./(sqrt(2)*sigma)).*(-1).*sin(fi)./(sqrt(2)*sigma) + 2/sqrt(pi)*exp(-bracketnull.^2).*(-1).*(cos(fi).*L/(sqrt(2)*sigma)));
        
    d2CF_dBdtheta = 1./arg.^2*(darg_dtheta.*darg_dB)' - 1./arg*d2arg_dBdtheta';

    
    %d2CF_dBdsigma
    d2arg_dBdsigma = 2/sqrt(pi)*exp(-bracketplus.^2).*(-2).*(bracketplus).*(-1).*(bracketplus./sigma).*(-1).*sin(fi)./(sqrt(2)*sigma) + 2/sqrt(pi)*exp(-bracketplus.^2).*(sin(fi)./(sqrt(2)*sigma^2)) - ...
                    (2/sqrt(pi)*exp(-bracketnull.^2).*(-2).*(bracketnull).*(-1).*(bracketnull./sigma).*(-1).*sin(fi)./(sqrt(2)*sigma) + 2/sqrt(pi)*exp(-bracketnull.^2).*(sin(fi)./(sqrt(2)*sigma^2)));

    d2CF_dBdsigma = 1./arg.^2*(darg_dsigma.*darg_dB)' - 1./arg*d2arg_dBdsigma';


    %d2CF_dC2
    d2arg_dC2 =  2/sqrt(pi)*exp(-bracketplus.^2).*(-2).*(bracketplus).*(-1)./(sqrt(2)*sigma).*(-1)./(sqrt(2)*sigma) - ...
                 2/sqrt(pi)*exp(-bracketnull.^2).*(-2).*(bracketnull).*(-1)./(sqrt(2)*sigma).*(-1)./(sqrt(2)*sigma);

    d2CF_dC2 = 1./arg.^2*(darg_dC.*darg_dC)' - 1./arg*d2arg_dC2';


    %d2CF_dCdtheta
    d2arg_dCdtheta = 2/sqrt(pi)*exp(-bracketplus.^2).*(-2).*(bracketplus).*((A*sin(fi).*L-B*cos(fi).*L)./(sqrt(2)*sigma)).*(-1)./(sqrt(2)*sigma) - ...
                     2/sqrt(pi)*exp(-bracketnull.^2).*(-2).*(bracketnull).*((A*sin(fi).*L-B*cos(fi).*L)./(sqrt(2)*sigma)).*(-1)./(sqrt(2)*sigma);

    d2CF_dCdtheta = 1./arg.^2*(darg_dtheta.*darg_dC)' - 1./arg*d2arg_dCdtheta';


    %d2CF_dCdsigma
    d2arg_dCdsigma = 2/sqrt(pi)*exp(-bracketplus.^2).*(-2).*(bracketplus).*(-1).*(bracketplus./sigma).*(-1)./(sqrt(2)*sigma) + 2/sqrt(pi)*exp(-bracketplus.^2).*(1)./(sqrt(2)*sigma^2) - ...
                    (2/sqrt(pi)*exp(-bracketnull.^2).*(-2).*(bracketnull).*(-1).*(bracketnull./sigma).*(-1)./(sqrt(2)*sigma) + 2/sqrt(pi)*exp(-bracketnull.^2).*(1)./(sqrt(2)*sigma^2));

    d2CF_dCdsigma = 1./arg.^2*(darg_dsigma.*darg_dC)' - 1./arg*d2arg_dCdsigma';

    
    %d2CF_dtheta2
    d2arg_dtheta2 = 2/sqrt(pi)*exp(-bracketplus.^2).*(-2).*(bracketplus).*((A*sin(fi).*L-B*cos(fi).*L)./(sqrt(2)*sigma)).*((A*sin(fi).*L-B*cos(fi).*L)./(sqrt(2)*sigma)) + 2/sqrt(pi)*exp(-bracketplus.^2).*((A*cos(fi).*L.^2+B*sin(fi).*L.^2)./(sqrt(2)*sigma)) - ...
                   (2/sqrt(pi)*exp(-bracketnull.^2).*(-2).*(bracketnull).*((A*sin(fi).*L-B*cos(fi).*L)./(sqrt(2)*sigma)).*((A*sin(fi).*L-B*cos(fi).*L)./(sqrt(2)*sigma)) + 2/sqrt(pi)*exp(-bracketnull.^2).*((A*cos(fi).*L.^2+B*sin(fi).*L.^2)./(sqrt(2)*sigma)));
     
    d2CF_dtheta2 = 1./arg.^2*(darg_dtheta.*darg_dtheta)' - 1./arg*d2arg_dtheta2';


    %d2CF_dthetadsigma
    d2arg_dthetadsigma = 2/sqrt(pi)*exp(-bracketplus.^2).*(-2).*(bracketplus).*(-1).*(bracketplus./sigma).*((A*sin(fi).*L-B*cos(fi).*L)./(sqrt(2)*sigma)) + 2/sqrt(pi)*exp(-bracketplus.^2).*(-1).*((A*sin(fi).*L-B*cos(fi).*L)./(sqrt(2)*sigma^2)) - ...
        (2/sqrt(pi)*exp(-bracketnull.^2).*(-2).*(bracketnull).*(-1).*(bracketnull./sigma).*((A*sin(fi).*L-B*cos(fi).*L)./(sqrt(2)*sigma)) + 2/sqrt(pi)*exp(-bracketnull.^2).*(-1).*((A*sin(fi).*L-B*cos(fi).*L)./(sqrt(2)*sigma^2)));
        
    d2CF_dthetadsigma = 1./arg.^2*(darg_dsigma.*darg_dtheta)' - 1./arg*d2arg_dthetadsigma';


    %d2CF_dsigma2
    d2arg_dsigma2 = 2/sqrt(pi)*exp(-bracketplus.^2).*(-2).*(bracketplus).*(-1).*(bracketplus./sigma).*(-1).*(bracketplus./sigma) + 2/sqrt(pi)*exp(-bracketplus.^2).*(2*bracketplus./sigma^2) - ...
        (2/sqrt(pi)*exp(-bracketnull.^2).*(-2).*(bracketnull).*(-1).*(bracketnull./sigma).*(-1).*(bracketnull./sigma) + 2/sqrt(pi)*exp(-bracketnull.^2).*(2*bracketnull./sigma^2));
        
    d2CF_dsigma2 = 1./arg.^2*(darg_dsigma.*darg_dsigma)' - 1./arg*d2arg_dsigma2';


    hess = [d2CF_dA2        d2CF_dAdB       d2CF_dAdC       d2CF_dAdtheta       d2CF_dAdsigma; ...
            d2CF_dAdB       d2CF_dB2        d2CF_dBdC       d2CF_dBdtheta       d2CF_dBdsigma; ...
            d2CF_dAdC       d2CF_dBdC       d2CF_dC2        d2CF_dCdtheta       d2CF_dCdsigma; ...
            d2CF_dAdtheta   d2CF_dBdtheta   d2CF_dCdtheta   d2CF_dtheta2        d2CF_dthetadsigma;...
            d2CF_dAdsigma   d2CF_dBdsigma   d2CF_dCdsigma   d2CF_dthetadsigma   d2CF_dsigma2];

    varargout{4} = hess;
end

if (nargout>=5) %probVect shall be returned
    varargout{5} = probVect;
end

% if (nargout>=6) %probMTRX shall be calculated
%    probMTRX = zeros(2^NoB,M);
%     for k = 1:M
%         for l = 1:2^NoB
%            probMTRX(l,k) = 1/2*(erf((T(l+1)-x(k))/(sqrt(2)*sigma)) - erf((T(l)-x(k))/(sqrt(2)*sigma)));%!! (l,k)
%         end
%     end
%     %returning probMTRX in varargout
%     varargout{6} = probMTRX;
% end

if (nargout>=6) %probMTRX shall be calculated
   probMTRX = zeros(2^NoB,M);
   tempT1 = T(2:2^NoB+1)'*ones(1,M);
   tempT  = T(1:2^NoB)'*ones(1,M);

   tempx = ones(2^NoB,1)*x;
   
   probMTRX = 1/2*(erf((tempT1-tempx)/(sqrt(2)*sigma)) - erf((tempT-tempx)/(sqrt(2)*sigma)));

    %returning probMTRX in varargout
    varargout{6} = probMTRX;
end

end