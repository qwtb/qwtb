 function [A phi O] = ThreePSF(Record,f,Ts)
 % Three Parameter Sine Fit (3PSF)
 %
 %  [A phi O] = ThreePSF(Record,f,Ts)
 %  Input arguments
 %    Record     - sampled input signal
 %    f          - signal frequency
 %    Ts         - sampling time (in s)
 %  Output arguments
 %    A          - estimated signal's amplitude
 %    phi        - estimated signal's phase
 %    O          - estimated signal's offset
 %
 % Reference: IEEE Standard for Digitizing Waveform Recorders 
 % IEEE Instrumentation and Measurement Society,  
 % IEEE Std 1057TM-2007 (Revision of IEEE 1057-1994)
 % (c) Rado Lapuh, 2016

 N = length(Record);             % determine the number of samples
 Record = Record(:);             % force column vector

 vct = 2*pi*f*Ts*(0:N-1);
 D0 = [cos(vct);sin(vct);ones(1,N)]'; % (Eq. A.3)
 x1 = D0\Record;                 % solve system of linear equations 
                                 % (Eq. A.7)
 phi =atan(-x1(2)/x1(1))-pi/2;   % phase estimation (Eq. A.10)
 if x1(1) >= 0                   % wrap phase within <-pi,pi>
   phi = phi + pi; 
 end
 A = sqrt(x1(1)^2+x1(2)^2);      % amplitude estimation (Eq. A.9)
 O = x1(3);                      % offset estimation
