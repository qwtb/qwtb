function [A,B,C,f,D]=ng_bh3(X,J_init)
% Négyparaméteres frekvenciatartománybeli LS szinuszbecslés
% [P, D]=ng_bh3(X,J_init)
% X: szinuszjel Fourier transzformáltjának vektora
% J_init: periódusok számának kezdeti becslõje
% P: a szinuszjel paramétereit tartalmazó struktúra, mezõk: A, B, C, f
% Az illesztett N pontos szinuszjel:
% Fi=2*pi*P.f*(0:N-1)/N; x=P.C+P.A*cos(Fi)+P.B*sin(Fi);
% D: A Jacobi mátrix inverze (kovarianciaszámításhoz)
% time: illesztési idõ

% A bemenõ jel legyen oszlopvektor
X = X(:);
% A bemenõ jel hossza
Nx=length(X);

% A 3 tagú Blackman-Harris ablak együtthatói
A0=+4.243800934609435e-001;
A1=-4.973406350967378e-001;
A2=+7.827927144231873e-002;

% A paraméterek kezdõértéke a becslésnél
A=0;
B=0;
C=0;
f=J_init;
k=round(f);

% A konvolválóvektor
cv=0.5*[A2 A1 2*A0 A1 A2];

% Az illesztésnél használt binek kiválasztása
bins=([-2:2, k-2:k+2, Nx-k-2:Nx-k+2]).';
inds0=(bins<0); % Azon elemek indexe, amelyek nullánál kisebbek
bins(inds0)=Nx+bins(inds0);
indsN=(bins>Nx-1); % Azon elemek indexe, amelyek N-1-nél nagyobbak
bins(indsN)=-Nx+bins(indsN);
bins=unique(bins); % Sorba van rendezve a 0:N-1 között, nincs 2 azonos elem.

% Az illesztéshez használt mért jel elõállítása
Xbh3_ref=zeros(length(bins),1);
for ii=1:length(bins)
    ind=bins(ii)+1; % Matlab indexelés
    indices=(ind-2:ind+2);
    indices(indices<1)=Nx+indices(indices<1);
    indices(indices>Nx)=-Nx+indices(indices>Nx);
    Xbh3_ref(ii)=cv*X(indices);
end


% % A mért jel ablakozása, elõállítása
% xbh3=x.*wbh3;
% Xbh3=fft(xbh3);
% 

% 

% 
% % Az illesztéshez használt mért jel elõállítása
% inds=ismember(0:Nx-1,bins);
% Xbh3_ref=Xbh3(inds); % Referenciajel, a hibát ebbõl számoljuk

% Kovarianciamátrix meghatározása
W=cov_bh3(A0,A1,A2,bins,Nx);
O=zeros(size(W));
K=[...
    W, O;
    O, W;
    ];
invK=pinv(K,0);

% Segédpolinom elõállítása
[limit, sf, p]=poli_bh3(Nx);

% Gauss-Newton
It_szam=10;
for ii=1:It_szam
    [Xbh3_calc, dA, dB, dC, df]=g2_bh3(A,B,C,f,Nx,bins,A0,A1,A2,limit,sf,p); % Számolt érték és a deriváltak
    e=[real(Xbh3_ref-Xbh3_calc); imag(Xbh3_ref-Xbh3_calc)];
    J=[...
        real(dA), real(dB), real(dC), real(df);
        imag(dA), imag(dB), imag(dC), imag(df);
        ];
    H=J.'*invK;
    D=pinv(H*J,0);
    dP=D*H*e;
    A=A+dP(1);
    B=B+dP(2);
    C=C+dP(3);
    f=f+dP(4);
end
end









