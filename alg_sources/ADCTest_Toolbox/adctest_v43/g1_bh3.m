function [X,dA,dB,dC,df]=g1_bh3(A,B,C,f,N,m,limit,sf,p)
% teszt jelleggel
% [limit, sf, p]=poli(N);
f1=round(f); % skalár
f2=f-f1; % skalár
d1=1/N*(-f+m); % vektor
d2=1/N*(f+m); % vektor
e1=((-1).^(f1+m)).*exp(1i*(f2+d1)*pi); % vektor
e2=((-1).^(f1+m)).*exp(1i*(-f2+d2)*pi); % vektor
de1_df=(1i)*pi*(N-1)/N*e1; % vektor
de2_df=(-1i)*pi*(N-1)/N*e2; % vektor
b1=(A+1i*B)/2; % skalár 
b2=(A-1i*B)/2; % skalár

n1=sin(pi*d1); % vektor
sz1=sin(-pi*f2)*((-1).^(f1+m)); % vektor
dsz1_df=-pi*cos(f2*pi)*((-1).^(f1+m)); % vektor
dn1_df=-pi/N*cos(pi*d1); % vektor
sqr_n1=1/2*(1-cos(2*pi*d1)); % vektor
r1=sz1./n1; % vektor
dr1_df=(dsz1_df.*n1-dn1_df.*sz1)./sqr_n1; % vektor
w01=pi*(d1-round(d1)); % vektor
w1=sf*w01; % vektor
ind1=(abs(n1)<limit);
r1(ind1)=polyval(p,w1(ind1));
q=polyder(p);
dr1_df(ind1)=polyval(q,w1(ind1));
% if (rem(N,2)==0)
%     ind11=((rem(round(d1),2)~=0)&ind1);
%     r1(ind11)=-r1(ind11);
%     dr1_df(ind11)=-dr1_df(ind11);
% end
ind11=(mod((m-f1),2)==1)... % pluszból tart minuszba
    &(mod(round((m-f1)/N),2)==0); % minuszból tart pluszba
ind12=(mod((m-f1),2)==0)... % minuszból tart pluszba
    &(mod(round((m-f1)/N),2)==1); % pluszból tart minuszba
ind13=ind1&(ind11|ind12);
r1(ind13)=-r1(ind13);
dr1_df(ind13)=-dr1_df(ind13);

n2=sin(pi*d2);
sz2=sin(f2*pi)*((-1).^(f1+m));
dsz2_df=pi*cos(f2*pi)*((-1).^(f1+m));
dn2_df=pi/N*cos(pi*d2);
sqr_n2=1/2*(1-cos(2*pi*d2));
r2=sz2./n2;
dr2_df=(dsz2_df.*n2-dn2_df.*sz2)./sqr_n2;

w02=pi*(d2-round(d2));
w2=sf*w02;
ind2=(abs(n2)<limit);
r2(ind2)=polyval(p, w2(ind2));
q=polyder(p);
dr2_df(ind2)=polyval(q, w2(ind2));
% if (rem(N,2)==0)
%     ind22=((rem(round(d2),2)~=0)&ind2);
%     r2(ind22)=-r2(ind22);
%     dr2_df(ind22)=-dr2_df(ind22);
% end
ind21=(mod(m+f1,2)==1)... % pluszból tart minuszba
    &(mod(round((m+f1)/N),2)==0); % minuszból tart pluszba
ind22=(mod(m+f1,2)==0)... % minuszból tart pluszba
    &(mod(round((m+f1)/N),2)==1);
ind23=ind2&(ind21|ind22);
r2(ind23)=-r2(ind23);
dr2_df(ind23)=-dr2_df(ind23);


X_sin=b1*e1.*r1+b2*e2.*r2;
X_dc=zeros(length(m),1);
X_dc(rem(m,N)==0)=C*N;
X=X_sin+X_dc;
dA=1/2*e1.*r1+1/2*e2.*r2;
dB=1i/2*e1.*r1-1i/2*e2.*r2;
dC=zeros(length(m),1);
dC(rem(m,N)==0)=N;
df=b1*de1_df.*r1+b1*e1.*dr1_df+b2*de2_df.*r2+b2*e2.*dr2_df;


