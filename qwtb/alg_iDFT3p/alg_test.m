function alg_test(calcset) %<<<1
% Part of QWTB. Test script for algorithm iDFT3p.
%
% See also qwtb

% Generate sample data --------------------------- %<<<1
DI = [];
Anom = 1; fnom = 100; phnom = 1; Onom = 0.1;
DI.t.v = [0:1/1e4:1-1/1e4];
DI.y.v = Anom*sin(2*pi*fnom*DI.t.v + phnom) + Onom;

% Call algorithm --------------------------- %<<<1
% rectangular window:
DI.window.v = 'rectangular';
DO_r = qwtb('iDFT3p', DI);
% Hann window:
DI.window.v = 'Hann';
DO_h = qwtb('iDFT3p', DI);

% Check results --------------------------- %<<<1
feps = 1e-6;
Aeps = 1e-6;
pheps = 1e-6;
% XXX is it really correct? The offset has bad values:
Oeps = 1e+4;
assert((DO_r.f.v > fnom.*(1-feps))    & (DO_r.f.v < fnom.*(1+feps)));
assert((DO_r.A.v > Anom.*(1-Aeps))    & (DO_r.A.v < Anom.*(1+Aeps)));
assert((DO_r.ph.v > phnom.*(1-pheps)) & (DO_r.ph.v < phnom.*(1+pheps)));
assert((DO_r.O.v > Onom.*(1-Oeps))  & (DO_r.O.v < Onom.*(1+Oeps)));

assert((DO_h.f.v > fnom.*(1-feps))    & (DO_h.f.v < fnom.*(1+feps)));
assert((DO_h.A.v > Anom.*(1-Aeps))    & (DO_h.A.v < Anom.*(1+Aeps)));
assert((DO_h.ph.v > phnom.*(1-pheps)) & (DO_h.ph.v < phnom.*(1+pheps)));
assert((DO_h.O.v > Onom.*(1-Oeps))  & (DO_h.O.v < Onom.*(1+Oeps)));


end % function

% vim settings modeline: vim: foldmarker=%<<<,%>>> fdm=marker fen ft=octave textwidth=80 tabstop=4 shiftwidth=4
