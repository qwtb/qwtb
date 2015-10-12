function [X, Rn, Q]=sfit4imp(data, varargin)
%SFIT4IMP  Improved four parameter fit of a sine wave to measured data
%
%       [X, Rn, Q]=sfit4(data,time,sample_rate,start_fr,use_ipfft,dfmin,maxCyc,verbose)
%
%       Input arguments:
%         data: vector of measured samples
%       
%       Optional parameters (some optional parameters can be either numeric or character string):
%         time: vector of time spacing (numeric)
%         sample_rate: sampling rate   (numeric)
%         start_fr - starting frequency in Hz (numeric or char string) (Default is determined by DFT or IpFFT)
%         use_ipfft - 'Yes' or 'No'. If 'Yes', interpolated FFT is used for
%                 setting the initial value. (character string)
%         dfmin - maximum change in frequency during last iteration step (numeric or character string)
%         maxCyc - the maximum number of iterating cycle (default=30) (numeric or character string)
%         verbose - 'Yes' or 'No'. If 'Yes', iteration details are displayed  (character string)
%
%       Output arguments:
%       X: structure of  DC + A * cos(w*tvect + phi)
%         DC   - DC level
%         A    - amplitude of the fitted cosine
%         f    - frequency of the fitted cosine
%         phi  - phase of the fitted cosine
%         erms - RMS error
%       Rn: the residual vector, the difference between the data and the fitted sine-wave
%       Q: structure array of iteration steps
%
% See also SFIT3, SFIT4


% Written by Zoltán Tamás Bilau, modified by Janos Markus
% $Id: sfit4imp.m,v 3.0 2004/04/19 11:20:09 markus Exp $
% Copyright (c) 2001-2004 by Istvan Kollar and Janos Markus
% All rights reserved.

if ~isnumeric(data), error('Sample vector is not numeric'); end
if length(size(data))>2, error('Dimension of the data vector is more than 2');	end
if min(size(data))>1, error('The data array is not a vector'); end

N=length(data);
if ~all(isfinite(data)), error('Not all samples are finite'); end
if any(imag(data))~=0, error('Not all samples are real');end
if N<4, error('Less than four samples'); end
mode='';

if nargin>1, time=varargin{1}; end
if nargin>2, sample_rate=varargin{2}; end
if nargin>3, start_fr=varargin{3}; end
if nargin>4, use_ipfft=varargin{4}; end
if nargin>5, dfmin=varargin{5}; end
if nargin>6, maxCyc=varargin{6}; end
if nargin>7, verbose=varargin{7}; end


if exist('maxCyc','var')
    %evaluate parameter
    if isstr(maxCyc)
        if isempty(maxCyc) | all(isspace(maxCyc))
            maxCyc=30;
        else
            try
                maxCyc=eval(maxCyc);
            catch
                warning('Cannot evaluate maxCyc, default (30) is used')
                maxCyc=30;
            end
        end
    elseif ~isnumeric(maxCyc) 
        warning('Cannot interpret maxCyc, default (30) is used')
        maxCyc=30;
    end
%     
    if isnan(maxCyc) | ~isfinite(maxCyc) | maxCyc<1
        warning('maxCyc is non-positive, default (30) is used')
        maxCyc=30;
    end
    maxCycN=fix(maxCyc);
else
    maxCycN=30; %maxCycN default
end


mode='dft';
if exist('use_ipfft','var')
    if isstr(use_ipfft)
        if strncmpi(use_ipfft,'Yes',3)
            mode='ipfft';
        end
    end
end

showiter=0;
if exist('verbose','var')
    if isstr(verbose)
        if strncmpi(verbose,'Yes',3)
            showiter=1;
        end
    end
end


if exist('dfmin','var')
    %evaluate parameter
    if isstr(dfmin)
        if isempty(dfmin) | all(isspace(dfmin))
            dfmin=1e-6;
        else
            try
                dfmin=eval(dfmin);
            catch
                warning('Cannot evaluate dfmin, default (1e-6) is used')
                dfmin=1e-6;
            end
        end
    elseif ~isnumeric(maxCyc) 
        warning('Cannot interpret dfmin, default (1e-6) is used')
        dfmin=1e-6;
    end
    
    if ~isequal(size(dfmin),[1,1]), 
        warning('dfmin is not a scalar, default is used'); 
        dfmin=1e-6;
    end
    
    if isnan(dfmin) | ~isfinite(dfmin) | dfmin>1 | dfmin<=0
        warning('dfmin<=0 or dfmin>1, default (1e-6) is used')
        dfmin=1e-6;
    end
    ferror=dfmin;
else
    ferror=1e-6; %dWmin default
end

werror=2*pi*ferror;


unisamp=0; %uniform sampling
if exist('sample_rate','var') 
    if ~isnumeric(sample_rate), 
        warning('sample_rate is not numeric'); 
    end
    if ~isequal(size(sample_rate),[1,1]), 
        warning('sample_rate is not a scalar'); 
    end
    if sample_rate<=0, 
        warning('sample_rate is not positive'); 
    end
end


if exist('time','var')
    if isempty(time)
        if ~exist('Ts'), Ts=1; sample_rate=1; end
        time=[0:N-1]*Ts; % Ts default
        unisamp=1;
    end
    if ~isnumeric(time), error('time is not numeric'); end
    if ~isequal(size(data),size(time)), error('sizes of data and time differ'), end
    time=time(:)';
    
    %Unisamp is 0 even if time is in almost equal distances
    unisamp=all(diff(diff(time))<max(diff(time))*100*eps);
    if ~exist('Ts','var')
        Ts=median(diff(time));
        sample_rate=1/Ts;
    end
else
    if ~exist('Ts'), Ts=1; sample_rate=1; end
    time=[0:N-1]*Ts; % Ts default
    unisamp=1;
end

data=data(:); %Force column vector

%If startW is given
w=0;
if exist('start_fr','var')
    %evaluate parameter
    if isstr(start_fr)
        if isempty(start_fr) | all(isspace(start_fr))
            start_fr=0;
        else
            try
                start_fr=eval(start_fr);
            catch
                warning('Cannot evaluate start_fr, initial frequency is determined by DFT')
                start_fr=0;
            end
        end
    elseif ~isnumeric(start_fr) 
        warning('Cannot interpret start_fr, initial frequency is determined by DFT')
        start_fr=0;        
    end
    
    if ~isequal(size(start_fr),[1,1]), 
        warning('start_fr is not a scalar, initial frequency is determined by DFT'); 
        start_fr=0;
    end
    
    if isnan(start_fr) | ~isfinite(start_fr) | start_fr<0
        warning('start_fr<0, initial frequency is determined by DFT')
        start_fr=0;
    end
    w=2*pi*start_fr;
end

if ~w %w is 0, no initial frequency is given
    %Initial radian frequency: look at maximum of PSD
    
    if ~unisamp
        Nt=round((max(time)-min(time)+Ts)/Ts);
        tvecti=round(time/Ts);
        
        %interpolation should be preferred if there are missing data
        tvecti=tvecti-min(tvecti)+1; 
        
        ym=zeros(Nt,1);
        ym(tvecti)=data;
        F=abs(fft(ym));
        [Mfft,w]=max(F(2:round(Nt/2)));
        w=2*pi*w/Nt/Ts;
    else
        Fc=fft(data);
        F=abs(Fc);
        [Mfft,w]=max(F(2:round(N/2)));
        
        if strcmpi(mode,'ipfft')
            if w>1
                %calculating the 2 points, between them the estimated frequency is
                if F(w-1)>F(w+1) w=w-1; end
            end
            
            n=2*pi/N;
            U=real(Fc(w+1));    V=imag(Fc(w+1));
            U1=real(Fc(w+2));  V1=imag(Fc(w+2));
            Kopt=(sin(n*w)*(V1-V)+cos(n*w)*(U1-U))/(U1-U);
            Z1=V*(Kopt-cos(n*w))/sin(n*w)+U;
            Z2=V1*(Kopt-cos(n*(w+1)))/sin(n*(w+1))+U1;
            
            lambda=acos((Z2*cos(n*(w+1))-Z1*cos(n*w))/(Z2-Z1))/n;
            w=lambda;
        end
        w=2*pi*w/N/Ts;
    end
end


% three parameters (step 0):
D0=[cos(w*time);sin(w*time);ones(1,N)]';
x0=D0\data;
x0(4)=0;

iQ=0; icyc=0;
while 1
    icyc=icyc+1;
    if nargout>2 
        iQ=iQ+1;
        Q(iQ).A=x0(1);
        Q(iQ).B=x0(2);
        Q(iQ).C=x0(3);
        Q(iQ).w=w;
    end
    
    D0=[cos(w*time);sin(w*time);ones(1,N);-x0(1)*time.*sin(w*time)+x0(2)*time.*cos(w*time)]';
    
    x0=pinv(D0,0)*data;
    w=w+x0(4); %adjust w
    
    if showiter
        if icyc==1
            disp(' ');
            disp('   Cyc#   frequency in Hz   Change of frequency              A           B');
            disp('   ----   ---------------   ----------------------------------------------');
        end
        fprintf('   %02d     %1.12g  %+1.25g             %+1.10g  %+1.10g\n',icyc,w/2/pi,Ts*x0(4)/2/pi,x0(1),x0(2));
    end
    
    if abs(x0(4))<werror/Ts break; end
    if icyc>=maxCycN break; end
end

if nargout<2
    iQ=iQ+1;
    Q(iQ).A=x0(1);
    Q(iQ).B=x0(2);
    Q(iQ).C=x0(3);
    Q(iQ).w=w;
end

Rn=data-[x0(1)*cos(w*time)+x0(2)*sin(w*time)+x0(3)]';

%Compose output:
X.DC=x0(3);
X.A=sqrt(x0(1)^2+x0(2)^2);
X.f=w/2/pi;
if      x0(1)>0
    X.phi=atan(-x0(2)/x0(1));
elseif x0(1)<0
    X.phi=atan(-x0(2)/x0(1))+pi;
else %x0(1)==0
    if x0(2)<0, X.phi=pi/2;
    else X.phi=3*pi/2;
    end
end
X.phi=X.phi*(180/pi);
X.erms=sqrt(1/N*Rn'*Rn);

%
%End of sfit4
