function [A,B,C,f,COV,time] = fdsfit4_bh3(xq)
%FDSFIT4_BH3 Summary of this function goes here
%   Detailed explanation goes here

N=length(xq);

% MSD ablakos IpFFT
Fc=fft(xq);
F=abs(Fc);
[dummy,w]=max(F(2:round(N/2)));
% w tehát a 2. indextõl induló tömb maximuma, azaz F-ben a tényleges
% maximum a w+1 helyen van.
J0=w; % periódusok számának kezdeti becslése 
% 3 tényezõs MSD ablak az idõtartományban:
a0=3/8;
a1=-1/2;
a2=1/8;
L=[...
    0, a2/2, a1/2, a0, a1/2, a2/2, 0, 0, 0;... % Xmsd(w-1)
    0, 0, a2/2, a1/2, a0, a1/2, a2/2, 0, 0;... % Xmsd(w)
    0, 0, 0, a2/2, a1/2, a0, a1/2, a2/2, 0;... % Xmsd(w+1)
    ];
v=[...
    Fc(w-3);...
    Fc(w-2);...
    Fc(w-1);...
    Fc(w);...
    Fc(w+1);...
    Fc(w+2);...
    Fc(w+3);...
    Fc(w+4);...
    Fc(w+5);...
    ];
Xmsd3=L*v;
dJ=3*(abs(Xmsd3(3))-abs(Xmsd3(1)))/(abs(Xmsd3(1))+2*abs(Xmsd3(2))+abs(Xmsd3(3)));
J_init=J0+dJ; 
% MSD ablakos IpFFT vége

% Túlvezérlés detektálás
k=(0:N-1).';
Cmax=max(xq); % legnagyobb kód
Cmin=min(xq); % legkisebb kód
ind=((xq<Cmax)&(xq>Cmin));
Fi=2*pi*J_init/N*k(ind); % oszlopvektor
Fi = Fi(:);
D=[cos(Fi), sin(Fi), ones(nnz(ind),1)];
xq = xq(:);
s=pinv(D,0)*xq(ind);
A_init=s(1);
B_init=s(2);
C_init=s(3);
% túlvezérlés detektálása, majd a szinuszjel kiegészítése ahol szükséges
Fi=2*pi*J_init/N*k;
x2=xq;
xf=A_init*cos(Fi)+B_init*sin(Fi)+C_init; % illesztett szinusz
th1=Cmax+1/2;
ind1=(xf>th1); % a felfelé túlvezérelt minták indexe
if (nnz(ind1)>0)
    x2(ind1)=xf(ind1);
end;
th2=Cmin-1/2;
ind2=(xf<th2);
if (nnz(ind2)>0)
    x2(ind2)=xf(ind2);
end
X2=fft(x2);
% Túlvezérlés detektálás vége

% Szinuszillesztés
tic;
[A,B,C,f,M]=ng_bh3(X2, J_init);
time=toc;
N=length(x2);
t=(0:N-1)';
fi=2*pi*f/N*t;
xfit=C+A*cos(fi)-B*sin(fi);
if (size(x2)~=size(xfit))
    xfit=xfit.';
end;
ind12=~(ind1|ind2);
r=xfit(ind12)-x2(ind12);
v=var(r);
% Eredeti
V=N*v; % Mert ha v=var(x), akkor V=var(fft(x))=N*v. 
COV=V*M;
% Módosított
% D2=[cos(fi), -sin(fi), ones(size(fi)), -1/f*fi.*(A*sin(fi)+B*cos(fi))];
% COV=v*pinv(D2.'*D2,0);


