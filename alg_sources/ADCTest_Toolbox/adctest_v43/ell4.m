function [N_t, G_t, P_t]=ell4(J0,N0,s0)
N_t=zeros(1,5);
G_t=N_t;
P_t=N_t;
if (round(J0)<5)
    error('Túl kevés periódus! Legalább 5 periódusból álló mérés szükséges!');
end
d=J0/N0;
N=round(1/d*(round(J0):-1:1));
J=N*d;
if (J0<round(J0))
    N(1)=N0;
end
P=0;
G=0;
for ii=1:length(J);
    s=N(ii)/N0*s0;
    CC=1/2/N(ii);
    x=1/s*(round(J(ii))+CC-J(ii));
    y=1/s*(J(ii)-round(J(ii))+CC);
    P(ii)=normcdf(y)-normcdf(-x);
    G(ii)=gcd(N(ii), round(J(ii)));
end
[dummy,ind]=sort(P.*N./G, 'descend');
for ii=1:5
    N_t(ii)=N(ind(ii));
    G_t(ii)=G(ind(ii));
    P_t(ii)=P(ind(ii));
    % fprintf('N=%d, G=%d, P=%.3f\n', N(ind(ii)), G(ind(ii)), P(ind(ii)));
end



% J0(1)=round(J);
% CC(1)=1/2/N;
% x=(J0+CC-J)/s;
% y=(J-J0+CC)/s;
% P(1)=normcdf(y)-normcdf(-x);
% G(1)=gcd(N,J0);