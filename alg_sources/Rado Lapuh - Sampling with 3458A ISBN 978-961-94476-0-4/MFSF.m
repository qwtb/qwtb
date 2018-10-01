 function [f0, A, phase, O, THD] = MFSF(Record, Ts, Har,ig)
 % MLESinFit fits a signal model of the form
 %
 %  s(t) = A0 + sum_{k in [-Har, Har]} (Ak cos(2 pi k f0 t) + 
 %                                      Ak sin(2 pi k f0 t))
 %         k in [-Har, Har]
 %  to N measured samples sm(nTs) (n=0, 1, ..., N-1).
 %
 %  Input arguments
 %    Record  - sampled input signal
 %    Ts      - sampling time (in s)
 %    Har     - index signal harmonics to be estimated
 %              default: 1:3
 %    ig      -  0: FFT max bin is initial frequency estimate)
 %              >0: forced frequency estimate
 %  Output arguments
 %    f0      - estimated fundamental frequency
 %    A       - estimated signal's amplitude (record for more harm.)
 %    phase   - estimated signal's phase (record for more harmonics)
 %    O       - estimated signal's offset
 %    THD     - Total harmonic distortion for specified nr. of harm.
 %
 % Reference: J. Schoukens, R. Pintelon, and G. Vandersteen, 
 % "A sinewave fitting procedure for characterizing data acquisition 
 % channels in the presence of time base distortion and time jitter"
 % IEEE Trans. Instrum. Meas., Vol. 46, No. 4, Aug. 1997, 1005-1010
 % (c) Vrije Universiteit Brussel / ELEC, Gerd Vandersteen, 2010
 % adopted: Rado Lapuh, 2014

 if (nargin<4)
   ig = 0;
 end
 if (nargin<3)
   Har = 1:3;
 end
 RelErr = 1e-14;         % cost function treshold
 NofHarm = length(Har);
 fs = 1/Ts;
 itt = 7;
 h = length(Har);        % number of harmonics to be estimated
 Har = reshape(Har,1,h); % ensure that Har is a row vector
 N = length(Record);
 Record = reshape(Record,N,1);	% ensure that Record is 
                                % a column vector
 if ig == 0
   NFFT = 2^nextpow2(N); % Next power of 2 from length of y
   t = fft(Record,NFFT);
   tr = abs(t(1:NFFT/2));
   [~,I]=max(tr);
   f0start = (I-1)/(Ts*NFFT);
 elseif ig > 0
   f0start = ig;
 end
 counter = 0;           % dummy counter of the number of iterations
 rdf0 = inf;
 oldcost = inf;
 Mat = 2*pi/fs*kron((0:N-1)',Har);
 % Perform a linear least squares with f0 by Grandke
 C=cos(f0start*Mat);
 S=sin(f0start*Mat);
 P=[f0start; [ones(N,1), C, S]\Record];
 Error = (P(2)+[C, S]*P(3:end) - Record);
 cost = Error.' * Error;
 Jacob = [[-Mat.*S, Mat.*C]*P(3:end), ones(N,1), C, S];
 % Optimise amplitudes and frequency f0 ...
 while ((counter < itt) && (rdf0 > RelErr) && (cost < oldcost))
   counter = counter + 1;
   oldcost = cost;
   oldP = P;
   oldJacob = Jacob;
   oldError = Error;
   dP = -Jacob\Error;
   P=P+dP;
   f0=P(1);
   C=cos(f0*Mat);
   S=sin(f0*Mat);
   Error = (P(2)+[C, S]*P(3:end) - Record);
   cost = Error.' * Error;
   Jacob = [[-Mat.*S, Mat.*C]*P(3:end), ones(N,1), C, S];
   rdf0 = abs(dP(1)/P(1));
   if (cost > oldcost)
     cost=oldcost;
     P=oldP;
     Jacob=oldJacob;
     Error=oldError;
   end
 end         % end Newton-Gauss iteration loop
 f0 = P(1);
 Ac = P(2:end);
 A = sqrt(Ac(2)^2+Ac(2+NofHarm)^2);
 phase = atan2(Ac(2),Ac(2+NofHarm));
 O = Ac(1);
 for k = 2:length(Har)
   A(k) = sqrt(Ac(1+k)^2+Ac(1+k+NofHarm)^2);
   phase(k) = atan2(Ac(1+k),Ac(1+k+NofHarm));
 end
 if (NofHarm > 1)
   THD = sqrt(sum(A(2:NofHarm).^2))/A(1);
 else
   THD = 0;
 end
 