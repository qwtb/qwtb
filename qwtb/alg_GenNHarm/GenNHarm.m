% Generate steady sampled waveform with multiple harmonic or interharmonic
% components, noise level.
% All inputs and outputs are structures with value .v and uncertainty .u fields

function [y, thd_k1] = GenNHarm(t, f, A, ph, O, thd_k1, nharm, noise)
    % Check inputs
    if not( all(length(f.v) == [length(A.v) length(ph.v) length(O.v)]) )
        error('GenNHarm: lengths of f.v, A.v, ph.v and O.v are not same! All harmonics must be represented in all f,A,ph,O quantities!')
    end

    % Make amplitudes:
    % check if user set THD or actual harmonics:
    if not(isscalar(f.v))
        % f, A, ph, O quantities are vectors, thd_k1 and nharm is not relevant:
        Hi.v = f.v./f.v(1);
    elseif (isscalar(f.v) && thd_k1.v > 0 && nharm.v > 1)
        % THD is some value and actual values of harmonics are not set, and
        % number of harmonics should be more than 1, so amplitudes of harmonics
        % has to be calculated here:
        % Amplitude of one higher harmonic if all higher harmonics got the same
        % amplitude:
        % $$ THD = \sqrt(\Sigma_2^N(V_i)^2)/V_1 => V_i = \sqrt(THD*V_1)^2/(N-1) $$
        Ai = sqrt(1/(nharm.v-1).*(A.v .* thd_k1.v)^2);
        A.v = [A.v repmat(Ai, 1, nharm.v - 1)];
        % harm indexes:
        Hi.v = [1:1:nharm.v];
        % phases
        ph.v = repmat(ph.v, 1, nharm.v);
        O.v = repmat(O.v, 1, nharm.v);
    else
        % scalars, but thd_k1 or nharm is not set, generate only single
        % harmonic:
        Hi.v = [1];
    end
    % sampled values:
    y.v = A.v(:).*sin(2.*pi .* f.v(:) .* Hi.v(:) .* t.v + ph.v(:)) + O.v(:);
    y.v = sum(y.v, 1);
    % add noise to the data:
    y.v = y.v + normrnd(0, noise.v, size(y.v));
    % return also THD value, k1:
    thd_k1.v = sqrt(sum(A.v(2:end).^2))./A.v(1);
end % function

%!test
%! % Test input with f,A,ph,O as vectors
%! t.v = [0:1/1e3:1-1/1e3];
%! f.v = [1 2 3];
%! A.v = [1 0.1 0.1];
%! ph.v = [0 pi/4 pi*2/4];
%! O.v = [0 0.1 0.2];
%! thd_k1.v = 0.01;
%! nharm.v = 10;
%! noise.v = 0;
%! [y, thd_k1_o] = GenNHarm(t, f, A, ph, O, thd_k1, nharm, noise);
%! assert(numel(y.v), numel(t.v))
%! assert(thd_k1_o.v, sqrt(0.02), 1e-15)
%!test
%! % Test input with f,A,ph,O as scalar and defined THD value
%! t.v = [0:1/1e3:1-1/1e3];
%! f.v = [1];
%! A.v = [1];
%! ph.v = [0];
%! O.v = [0];
%! thd_k1.v = 0.01;
%! nharm.v = 10;
%! noise.v = 0;
%! [y, thd_k1_o] = GenNHarm(t, f, A, ph, O, thd_k1, nharm, noise);
%! assert(numel(y.v), numel(t.v))
%! assert(thd_k1_o.v, thd_k1.v, 1e-15)
%!test
%! % Numerical test with very simple values for fft 
%! t.v = [0 0.25 0.5 0.75];
%! f.v = [1];
%! A.v = [1];
%! ph.v = [0];
%! O.v = [0];
%! thd_k1.v = 0;
%! nharm.v = 0;
%! noise.v = 0;
%! y = GenNHarm(t, f, A, ph, O, thd_k1, nharm, noise);
%! assert(y.v, [0 1 0 -1], 1e-15)

% vim settings modeline: vim: foldmarker=%<<<,%>>> fdm=marker fen ft=octave textwidth=80 tabstop=4 shiftwidth=4
