function [X,dA,dB,dC,df]=g2_bh3(A,B,C,f,N,bins,w0,w1,w2,limit,sf,p)
s=size(bins);
if (s(2)>s(1))
    bins=bins.';
end
w=[
    w2/2;
    w1/2;
    w0;
    w1/2;
    w2/2;
    ];
D=[-2+bins, -1+bins, bins, 1+bins, 2+bins];
rect_bins=unique(D);
[X_rect,dA_rect,dB_rect,dC_rect,df_rect]=g1_bh3(A,B,C,f,N,rect_bins,limit,sf,p);
ind1=(ismember(rect_bins, -2+bins));
ind2=(ismember(rect_bins, -1+bins));
ind3=(ismember(rect_bins, bins));
ind4=(ismember(rect_bins, 1+bins));
ind5=(ismember(rect_bins, 2+bins));
X_rect_m=[X_rect(ind1), X_rect(ind2), X_rect(ind3), X_rect(ind4), X_rect(ind5)];
X=X_rect_m*w;
dA_rect_m=[dA_rect(ind1), dA_rect(ind2), dA_rect(ind3), dA_rect(ind4), dA_rect(ind5)];
dA=dA_rect_m*w;
dB_rect_m=[dB_rect(ind1), dB_rect(ind2), dB_rect(ind3), dB_rect(ind4), dB_rect(ind5)];
dB=dB_rect_m*w;
dC_rect_m=[dC_rect(ind1), dC_rect(ind2), dC_rect(ind3), dC_rect(ind4), dC_rect(ind5)];
dC=dC_rect_m*w;
df_rect_m=[df_rect(ind1), df_rect(ind2), df_rect(ind3), df_rect(ind4), df_rect(ind5)];
df=df_rect_m*w;



