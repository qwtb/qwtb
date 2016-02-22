function dataout = alg_wrapper(datain, calcset) %<<<1
% Part of QWTB. Wrapper script for algorithm testQ. Algorithm is usefull only
% for testing QWTB toolbox. It calculates maximal and minimal value of the
% record.
%
% See also qwtb

% Format input data --------------------------- %<<<1
% test(G)(M) definition is: function [maxval, minval] = test(G)(M)(xseries, yseries)
if isfield(datain, 'x')
    in1 = datain.x.v;
else
    in1 = datain.y.v;
end
if isfield(datain, 'u')
    in2 = datain.u.v;
else
    in2 = datain.v.v;
end

% just tap rest of required input quantities to check they are present:
datain.a.v;
datain.c.v;

% Call algorithm --------------------------- %<<<1
[maxval, minval] = testG(in1, in2);

% Format output data:  --------------------------- %<<<1
dataout.max.v = maxval;
dataout.min.v = minval;

end % function

% vim settings modeline: vim: foldmarker=%<<<,%>>> fdm=marker fen ft=octave textwidth=80 tabstop=4 shiftwidth=4
