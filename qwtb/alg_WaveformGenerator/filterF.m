function outputF=filterF(NW,waveformF,indexF)

%   Not causal filter for smoothing a signal and evaluate the values
%   at specific points given by a set of index (indexF)
%   The window is rectangular
%   The program takes into effect the border effect of the windows

%   INPUT:
%   waveformF =  vector of the sample
%   indexF    =  vector of the index where the smothed is evaluated
%   OUTPUT:
%   outputF   =  values of the output of the filter at indexed points

%   Version 2.0
%   6 December 2011

% Triangular window
wind=1-2*(1:NW)/(2+2*NW);

% Rectangular window
%  wind=ones(1,NW);

windin=fliplr(wind);
windt=[windin 1 wind];

% Determination of the Windows
% wind=ones(1,2*NW+1);

Ns=max(size(waveformF));
NF=max(size(indexF));
convol=conv(waveformF,windt);
for nfram=1:NF;
    if indexF(nfram)<=NW
       Den=sum(wind(1:indexF(nfram)-1))+1+sum(wind);
    else
        if indexF(nfram)>Ns-NW
           Den=sum(wind(1:Ns-indexF(nfram)))+1+sum(wind);
        else
            Den=sum(windt);
        end
    end
  outputF(nfram)=convol(indexF(nfram)+NW)/Den;
end
 