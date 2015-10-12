function C=cov_bh3(A0,A1,A2,bins,N)
M=length(bins);
% C=zeros(M);
p=[A2/2, A1/2, A0, A1/2, A2/2];
p2=conv(p,p);
% if (~isrow(bins))
%     bins=bins.';
% end
bins = bins(:).';
b1=repmat(bins, M, 1);
b2=repmat(bins.', 1, M);
C=abs(b1-b2);
C(C>N/2)=abs(-N+C(C>N/2));
C(C==0)=p2(5);
C(C==1)=p2(4);
C(C==2)=p2(3);
C(C==3)=p2(2);
C(C==4)=p2(1);
C(C>4)=0;
