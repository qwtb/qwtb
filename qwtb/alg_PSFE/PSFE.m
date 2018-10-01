 function [fa A ph,O] = PSFE(Record,Ts)
 % PSFE (Phase Sensitive Frequency Estimator)
 %  [fa, A, ph, O] = PSFE(Record,Ts)
 %
 %  Input arguments
 %    Record     - sampled input signal
 %    Ts         - sampling time (in s)
 %  Output arguments
 %    fa         - estimated signal's frequency
 %    A          - estimated signal's amplitude
 %    ph         - estimated signal's phase
 %    O          - estimated signal's offset
 %
 % PSFE requires more than two periods of sampled signal and 
 % at least 6 samples in the Record

 N = length(Record);
 Record = reshape(Record,1,N);   % force the row vector
 cost_error = 2.4e-12;           % the cost function threshold error
 max_iter = 20;             % maximum number of algorithm iterations
 NFFT = 2^nextpow2(N);         % Find the initial frequency estimate
 t = fft(Record,NFFT);             
 tr = abs(t(1:NFFT/2));            
% line in original source code:
% [~,I]=max(tr);          % find the index of the maximum value bin
% modified line so it works in older versions of Matlab (tmp variable is not used):
% (changed by M. Sira, 2018-10-01)
 [tmp,I]=max(tr);          % find the index of the maximum value bin
 fa = (I-1)/(Ts*NFFT);   % and calculate the corresponding frequency
 if fa == 0            % in case the peak frequency is not found
   A  = NaN; ph = NaN; O  = NaN;
   return 
 end
 for iter = 1:max_iter            % the algorithm loop
   dm = fix(N/2);
   if dm < fix(1/(fa*Ts)) 
     d0 = dm;                     % the optimum window separation d0
   else
     dc = round((round(floor(dm*fa*Ts)/(fa*Ts)):-(1/(fa*Ts)):dm/2));   
     dd = dc*fa*Ts;                 % possible candidates for d0
     % line in original source code:
     % [~,I] = min(abs(round(dd)./dd-1));
     % modified line so it works in older versions of Matlab (tmp variable is not used):
     % (changed by M. Sira, 2018-10-01)
     [tmp,I] = min(abs(round(dd)./dd-1));
     if I                           % if I is not zero
       d0 = dc(I);
     else
       d0 = dm;
     end
   end
   w0 = N - d0;        % use remaining samples for the window width
   fTs = 2*pi*fa*Ts;
   vct = fTs*(0:w0-1);
   D0 = [cos(vct);sin(vct);ones(1,w0)];
   D0T = D0 * D0';
   D0R = D0 * Record(1:w0)';
   x1 = D0T\D0R;
   ph1=atan(-x1(2)/x1(1));            % W1 phase
   if x1(1) >= 0 
     ph1=ph1+pi; 
   end
   D0R = D0 * Record(d0+1:d0+w0)';
   x2 = D0T\D0R;
   ph2=atan(-x2(2)/x2(1));            % W2 phase
   if x2(1) >= 0 
     ph2=ph2+pi; 
   end
   c1 = 2*pi*Ts*d0;
   Dph_a = c1*fa;
   dph_c = ph2 - ph1;
   P = round((Dph_a-dph_c)/(2*pi));  % number of full periods 
                                     % between W1 and W2 (Eq. 5)
   Dph_c = dph_c+2*pi*P;             % estimated phase diff. (Eq. 4)
   eps = abs(Dph_a - Dph_c)/c1/fa/N; % cost function result (Eq. 3)
   fa = fa - (Dph_a - Dph_c)/c1;     % new freq. estimate (Eq. 2)
   if eps == 0 || eps < cost_error || iter >= max_iter 
     [A,ph,O] = ThreePSF(Record,fa,Ts);
     return
   end
end
