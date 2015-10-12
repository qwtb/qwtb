%Script to evaluate ML cost function
clc;

building = 0;
scan = 0;
plotting = 1;

if (building)
    %Building a simulated measurement descriptor
    NoB = 8;
    INL = 5*sin(2*pi*1/254*(0:254)); 
    INL(1) = 0; INL(255) = 0;
    NoS = 1e4;
    amp = 0.52;
    phase = 78/180*pi;
    A = amp*cos(phase);
    B = -amp*sin(phase);
    C = 0.497;
    freq = 13;
    fs = 1e4;
    theta = 2*pi*freq/fs;
    phi = (1:NoS).'*theta;
    sw = A*cos(phi) + B*sin(phi) + C;
    T = INL2TransLevels(INL);
    y = QuantizeSignal(sw,T);

    %Evaluating Cost Function using the simulated parameters
    q = 1/(2^NoB-2);
    p0 = [A;B;C;2*pi*freq/fs;0];
    [L_0,CF_0] = EvaluateCF(y,p0,NoB,INL);

end

if (scan)
    %Scanning the parameter space
    sigmas = [0;q*1e-3;q*1e-2;q*1e-1;q];
    A_res = 81;
    B_res = 81;
    C_res = 1;
    theta_res = 81;

    A_range = [-5e-4;5e-4];
    B_range = [-5e-5;5e-5];
    C_range = [-1e-4;1e-4];
    theta_range = [-1e-6;1e-6];

    A_axis = linspace(A*(1+A_range(1)),A*(1+A_range(2)),A_res);
    B_axis = linspace(B*(1+B_range(1)),B*(1+B_range(2)),B_res);
    C_axis = linspace(C*(1+C_range(1)),C*(1+C_range(2)),C_res);
    theta_axis = linspace(theta*(1+theta_range(1)),theta*(1+theta_range(2)),theta_res);

    if (A_res == 1)
        A_axis = A;
    end
    if (B_res == 1)
        B_axis = B;
    end
    if (C_res == 1)
        C_axis = C;
    end
    if (theta_res == 1)
        theta_axis = theta;
    end

    L = zeros(A_res, B_res, C_res, theta_res);
    CF = zeros(A_res, B_res, C_res, theta_res);

    for i1 = 1:A_res;
        for i2 = 1:B_res
            for i3 = 1:C_res;
                for i4 = 1:theta_res;
                    p = [A_axis(i1); B_axis(i2); C_axis(i3); theta_axis(i4); sigmas(2)];
                    [L(i1,i2,i3,i4),CF(i1,i2,i3,i4)] = EvaluateCF(y,p,NoB,INL);
                end
            end
        end
    end
end

if (plotting)
    L_red = zeros(A_res, B_res, theta_res);
    CF_red = zeros(A_res, B_res, theta_res);
    for k1 = 1:A_res
        for k2 = 1:B_res
            for k4 = 1:theta_res
                L_red(k1,k2,k4) = L(k1,k2,1,k4);
                CF_red(k1,k2,k4) = CF(k1,k2,1,k4);
            end
        end
    end
    X1 = 0;
    Y1 = 0;
    Z1 = 0;
    plot_index = ones(4,1);
    L_limit = [1e-13;1e-10;1e-8;1e-6;Inf];
    for k1 = 1:A_res
        for k2 = 1:B_res
            for k4 = 1:theta_res
                for level = 1:4
                    if (L_red(k1,k2,k4) >= L_limit(level)) && (L_red(k1,k2,k4) < L_limit(level+1))
                        X1(plot_index(level),level) = (A_axis(k1) - A)/A;
                        Y1(plot_index(level),level) = (B_axis(k2) - B)/B;
                        Z1(plot_index(level),level) = (theta_axis(k4) - theta)/theta;
                        plot_index(level) = plot_index(level) + 1;
                end
                end
            end
        end
    end

    Xlev1 = X1(1:plot_index(1)-1,1);
    Xlev2 = X1(1:plot_index(2)-1,2);
    Xlev3 = X1(1:plot_index(3)-1,3);
    Xlev4 = X1(1:plot_index(4)-1,4);
    
    Ylev1 = Y1(1:plot_index(1)-1,1);
    Ylev2 = Y1(1:plot_index(2)-1,2);
    Ylev3 = Y1(1:plot_index(3)-1,3);
    Ylev4 = Y1(1:plot_index(4)-1,4);

    Zlev1 = Z1(1:plot_index(1)-1,1);
    Zlev2 = Z1(1:plot_index(2)-1,2);
    Zlev3 = Z1(1:plot_index(3)-1,3);
    Zlev4 = Z1(1:plot_index(4)-1,4);
    
    
    figure(1);
    plot3(Xlev1,Ylev1,Zlev1,'b.');
    hold on;
    plot3(Xlev2,Ylev2, Zlev2,'g.');
    hold on;
    plot3(Xlev3, Ylev3, Zlev3,'y.');
    hold on
    plot3(Xlev4, Ylev4, Zlev4, 'r.');
    shg;
    

end