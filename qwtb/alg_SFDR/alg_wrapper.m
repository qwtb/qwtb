function dataout = alg_wrapper(datain, calcset)
% Part of QWTB. Wrapper script for algorithm SFDR.
%
% See also qwtb

% Format input data --------------------------- %<<<1
if ~isfield(datain, 'A')
    % spectrum is missing, lets call algorithm SP-WFFT to calculate it
    if ~isfield(datain, 'fs') || ~isfield(datain, 'Ts') || ~isfield(datain, 't')
        % timing data is missing but required by SP-WFFT algorithm, so add
        % something, because the actual value is irrelevant:
        datain.fs.v = 1;
        datain.window.v = 'blackman';
    end
    specDO = qwtb('SP-WFFT',datain, calcset);
    dataout.A = specDO.A;
end

% Call algorithm ---------------------------  %<<<1
dataout.SFDR.v = spec_to_SFDR(dataout.A.v);
dataout.SFDRdBc.v = 20*log10(dataout.SFDR.v);

% Format output data:  --------------------------- %<<<1

end % function

% vim settings modeline: vim: foldmarker=%<<<,%>>> fdm=marker fen ft=octave textwidth=80 tabstop=4 shiftwidth=4
