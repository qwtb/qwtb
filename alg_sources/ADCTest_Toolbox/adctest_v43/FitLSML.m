function result_struct = FitLSML(datavect,timevect,estimated_INL,NoB)
%Default optimization parameters for ML
MAX_ITER_DEFAULT = 30;
MAX_FUN_EVALS_DEFAULT = 60;
TOL_FUN_DEFAULT = 0;

%INL
%estimated_INL = TimeDomain2INL(datavect,NoB);
trans_levels = INL2TransLevels(estimated_INL);

%LS 4p
X = sfit4imp(datavect,timevect);
p_LS = zeros(4,1);
p_LS(1) = X.A*cos(X.phi/180*pi) ;
p_LS(2) = (-1)*X.A*sin(X.phi/180*pi);
p_LS(3) = X.DC - 1; %1..2^NoB - >0..2^NoB-1
p_LS(4) = 2*pi*X.f;

%ML fit
%Getting initial estimators
p = zeros(5,1);
p(1:2) = p_LS(1:2)/(2^NoB-2);
p(3) = (p_LS(3) - 0.5)*1/(2^NoB - 2); %0.5->0 2^NoB-1.5-> 1
p(4) = p_LS(4);
M = length(datavect);
%pure_sinewave = p(1)*cos(((1:M).')*p(4)) + p(2)*sin(((1:M).')*p(4)) + p(3);
%quantized_sinewave = QuantizeSignal(pure_sinewave,trans_levels) + 1;
p(5) = 0.2; %rms(quantized_sinewave - datavect)/(2^NoB-2);

%Nelder-Mead method: (fminsearch)
p0 = p;
fminsearch(@(p) EvaluateCF(datavect,p,NoB,estimated_INL),p0);
p_ML_NM = p;
CF_NM = EvaluateCF(datavect,p_ML_NM,NoB,estimated_INL);

p_ML_NM(1:2) = p_ML_NM(1:2)*(2^NoB-2);
p_ML_NM(3) = p_ML_NM(3)*(2^NoB-2) + 0.5;
p_ML_NM(4) = p_ML_NM(4);
p_ML_NM(5) = p_ML_NM(5)*(2^NoB-2);


%Gradient method:
p = p0;
%Initializing iteration
evaluation_counter = 0;
[PML,CF,grad,hess] = EvaluateCF(datavect,p,NoB,estimated_INL);
evaluation_counter = evaluation_counter + 1;
l = max(max(hess));
index = 0;
optim_status = 'Running';
termination_reason = 'None';
while strcmpi(optim_status,'Running')
    p_next = p - inv(hess + l*eye(5))*grad;
    while (p_next(5) < 0)
        l  = l*10;
        p_next = p - inv(hess + l *eye(5))*grad;
    end
    [PML_next,CF_next] = EvaluateCF(datavect,p_next,NoB,estimated_INL);
    evaluation_counter = evaluation_counter + 1;
    while (CF_next > CF)
        l = l*10;
        p_next = p - inv(hess + l*eye(5))*grad;
        while (p_next(5) < 0)
            l  = l*10;
            p_next = p - inv(hess + l *eye(5))*grad;
        end
        [PML_next,CF_next] = EvaluateCF(datavect,p_next,NoB,estimated_INL);
        evaluation_counter = evaluation_counter + 1;        
    end
    [PML_next,CF_next,grad_next,hess_next] = EvaluateCF(datavect,p_next,NoB,estimated_INL);
    evaluation_counter = evaluation_counter + 1;    
    l = l*0.1;
    %Checking termination conditions
    if (index == MAX_ITER_DEFAULT - 1)
        termination_reason = 'MaxIter';
        optim_status = 'Terminated';
    elseif (evaluation_counter > MAX_FUN_EVALS_DEFAULT)
        termination_reason = 'MaxFunEvals';
        optim_status = 'Terminated';
    elseif (abs(CF - CF_next) < TOL_FUN_DEFAULT)
        termination_reason = 'TolFun';
        optim_status = 'Terminated';
    end
    p = p_next;
    CF = CF_next;
    PML = PML_next;
    grad = grad_next;
    hess = hess_next;
    index = index + 1;
end

%Converting estimators to the same scale;
p_ML = zeros(5,1);
p_ML(1:2) = p(1:2)*(2^NoB - 2);
p_ML(3) = p(3)*(2^NoB - 2) + 0.5; %0->0.5 1->2^NoB-1.5
p_ML(4) = p(4);
p_ML(5) = p(5)*(2^NoB - 2);

result_struct.LS = p_LS;
result_struct.ML = p_ML;
result_struct.p_ML_MN = p_ML_NM;
result_struct.INL = estimated_INL;
result_struct.termination_resaon = termination_reason;
result_struct.CF = CF;
result_struct.CF_NM = CF_NM;
end
