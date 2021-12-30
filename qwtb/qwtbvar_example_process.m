function [DO, DI, CS] = hyper_paraboloid(DI, CS)
    % paraboloid euqation
    DO.z.v = DI.y.v.^2./DI.b.v.^2 - DI.x.v.^2./DI.a.v.^2;
end % function DO = hyper_paraboloid(DI)

% vim settings modeline: vim: foldmarker=%<<<,%>>> fdm=marker fen ft=matlab textwidth=80 tabstop=4 shiftwidth=4

