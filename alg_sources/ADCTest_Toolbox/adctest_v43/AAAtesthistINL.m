clear all
fs=1e3;
t=[0:1/fs:5];
bits = 4;
rmax = 1;
rmin = -1;

x = 1.*sin(2.*pi.*t.*1 + 1) + 0;
%quantize:
x = (x >= rmin).*x + (x < rmin).*rmin;
x = (x <= rmax).*x + (x > rmax).*rmax;
% calculate number of quantization levels - 1:
levels = 2^bits-1;
% get total range:
xrange=(rmax-rmin);
% quantize values:
res = round(x./xrange.*levels).*xrange./levels;

dsc.data = round(res.*2.^bits);
dsc.NoB = bits;

dsc.name = 'test'
dsc.comment = {['comment']}
dsc.model = 'MatlabSim'
dsc.serial = 'N/A'
dsc.channel = 1
dsc.simulation = 1
%%%%dsc.parameters: [1x1 struct]


display_settings.results_win = 1;
display_settings.summary_win = 1;
display_settings.warning_dialog = 1;

INL = ProcessHistogramTest(dsc,display_settings)

%co to vlastne dela?:
%[PML,CF,grad,hess] = EvaluateCF(reduced_data,p,dsc.NoB,INL);
