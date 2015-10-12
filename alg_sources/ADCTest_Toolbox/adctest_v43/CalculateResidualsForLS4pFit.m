function residuals = CalculateResidualsForLS4pFit(p,datavect,timevect)
% p = [A B C theta].'
sinewave = (p(1)*cos((timevect)*p(4)) + p(2)*sin((timevect)*p(4)) + p(3));
residuals = sinewave - datavect;
end
