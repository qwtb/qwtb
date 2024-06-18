function [DO, DI, CS] = qwtbvar_example_1_process(DI, CS)
% Calculates hyperparaboloid.
% Input quantities: x, y, a, b
% Output quantities: z

    if isfield(DI.x, 'u') && isfield(DI.y, 'u') && isfield(DI.a, 'u') && isfield(DI.b, 'u') && isfield(CS.mcm, 'repeats')
        x = normrnd(DI.x.v, DI.x.u, CS.mcm.repeats, 1);
        y = normrnd(DI.y.v, DI.y.u, CS.mcm.repeats, 1);
        a = normrnd(DI.a.v, DI.a.u, CS.mcm.repeats, 1);
        b = normrnd(DI.b.v, DI.b.u, CS.mcm.repeats, 1);
        z = y.^2./b.^2 - x.^2./a.^2;
        DO.z.v = mean(z);
        DO.z.u = std(z);
        DO.z.r = z;
    else
        x = DI.x.v;
        y = DI.y.v;
        a = DI.a.v;
        b = DI.b.v;
        DO.z.v = y.^2./b.^2 - x.^2./a.^2;
    end
end % function
