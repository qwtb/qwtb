% Example for qwtbvar with 2 vector inputs and 1 vector output.
% Calculates position and acceleration of an object thrown at t = 0 from
% coordinates (0,0) with velocity (v_x, v_y) in gravitational field of magnitude
% g = (0, 9.8067) +- (0, 0.0001). Position is evaluated for all times specified
% in vector t.
%
% Inputs:
%   'v' is vector of initial velocity of two elements with vector components [v_x, v_y] in in 2D plane.
%   't' is vector of times for which the position will be evaluated [t_1, t_2, ..., t_n].
% Outputs:
%   's' is position vector of size 2*n: [s_x1, s_y1; s_x2, s_y2; ..., s_xn, s_yn];
%   'a' is acceleration vector size 2: [a_x, a_y];
%
% Example of inputs:
%   DI.v.v = [1 20]; % speed 1 m/s in x coordinate, 2 m/s in y coordinate
%   DI.v.u = [0.1 0.2]; % speed uncertainties
%   DI.t.v = [1 2 3 4 5]; % evaluation times 1 s, 2 s, 3 s, 4 s
%   DI.t.u = [0.1 0.2 0.3 0.4 0.5]; % uncertainties of time 0.1 s etc.
%   CS.mcm.repeats = 1e3;
% Run:
%   [DO, DI, CS] = qwtbvar_example_2_process(DI, CS);
% Output:
%   DO.s.v =
%      0.9991   15.0641
%      1.9942   20.1867
%      2.9776   15.5779
%      4.0281    0.5859
%      4.9917  -23.7004
%   DO.s.u =
%      0.1338    0.9857
%      0.2862    0.4841
%      0.4058    2.7508
%      0.5637    7.9105
%      0.7121   14.3013
%   DO.a.v =
%       0   9.8067
%   DO.a.u =
%       0   9.8345e-5

function [DO, DI, CS] = qwtbvar_example_2_process(DI, CS)
    % acceleration vector:
    Gx =  0;
    uGx = 0;
    Gy =  -9.8067; % negative because falling down
    uGy = 0.0001;

    DI.v.v = DI.v.v(:)'; % ensure row vector - is it needed? QWTB does it on its own.
    DI.t.v = DI.t.v(:)';

    % initialize output variables:
    DO.s.v = nan.*zeros(numel(DI.t.v), 2);
    DO.a.v = DO.s.v;

    % with or without uncertainties?
    if isfield(DI.v, 'u') && isfield(DI.t, 'u') && isfield(CS.mcm, 'repeats')
        DI.v.u = DI.v.u(:)'; % ensure row vector - is it needed? QWTB does it on its own.
        DI.t.u = DI.t.u(:)';
        % randomize G, v, t:
        gx = normrnd(Gx, uGx, CS.mcm.repeats, 1);
        gy = normrnd(Gy, uGy, CS.mcm.repeats, 1);
        vx = normrnd(DI.v.v(1), DI.v.u(1), CS.mcm.repeats, 1);
        vy = normrnd(DI.v.v(2), DI.v.u(2), CS.mcm.repeats, 1);
        % using for loop because mvnrnd is not in basic matlab:
        for j = 1:numel(DI.t.v)
            % randomize time vector:
            t = normrnd(DI.t.v(j), DI.t.u(j), CS.mcm.repeats, 1);
            % calculate coordinates:
            sx = vx.*t + 0.5.*gx.*(t.^2);
            sy = vy.*t + 0.5.*gy.*(t.^2);
            DO.s.v(j, 1) = mean(sx);
            DO.s.v(j, 2) = mean(sy);
            % calculate coordinate uncertainties:
            DO.s.u(j, 1) = std(sx);
            DO.s.u(j, 2) = std(sy);
        end % for
        % uncertainty of acceleration
        DO.a.u = [std(gx) std(gy)];
        % uncertainty of final distance from start:
        DO.range.u = sqrt(sum(DO.s.u(end, :).^2, 2));
    else
        gx = Gx;
        gy = Gx;
        t = DI.t.v;
        DO.s.v(:, 1) = DI.v.v(1).*t - 0.5.*gx.*(t.^2);
        DO.s.v(:, 2) = DI.v.v(2).*t - 0.5.*gy.*(t.^2);
        DO.a.v(:, 1) = Gx.*ones(size(DO.s.v(:, 1)));
        DO.a.v(:, 2) = Gy.*ones(size(DO.s.v(:, 2)));
    end
    % value of acceleration
    DO.a.v = [mean(gx) mean(gy)];
    % final distance from start:
    DO.range.v = sqrt(sum(DO.s.v(end, :).^2, 2));
end % function DO = qwtbvar_example_process2(DI)

%!test
%! DI.v.v = [1 20];
%! DI.t.v = [1 2 3 4 5];
%! CS.mcm.repeats = 1000;
%! [DO, DI, CS] = qwtbvar_example_2_process(DI, CS);
%! assert(all(size(DO.s.v) == [5, 2]))
%! assert(all(size(DO.a.v) == [1, 2]))
%! DI.v.u = [0.1 0.2];
%! DI.t.u = [0.1 0.2 0.3 0.4 0.5];
%! [DO, DI, CS] = qwtbvar_example_2_process(DI, CS);
%! assert(all(size(DO.s.u) == [5, 2]))
%! assert(all(size(DO.a.u) == [1, 2]))

% vim settings modeline: vim: foldmarker=%<<<,%>>> fdm=marker fen ft=matlab textwidth=80 tabstop=4 shiftwidth=4

