function INL = TimeDomain2INL(recorded_data,NoB)
% @fn TimeDomain2INL
% @brief Estimates INL using histogram test form the the time domain representation of the recorded
%        ADC codes (creates histogram itself)
% @param recorded_data Vector of the recorded ADC codes
% @param NoB Number of Bits of the ADC under test
% @return INL The estimated INL of the ADC
% @author Tamás Virosztek, Budapest University of Technology and Economics,
%         Department of Measurement and Information Systems,
%         Virosztek.Tamas@mit.bme.hu


histogram = PosIntHist(recorded_data);
nh = histogram/sum(histogram);
nch = zeros(1,length(nh));
for k = 1:length(nch)
    nch(k) = sum(nh(1:k));
end

%if the ADC is not overdriven, bins with zero value cannot be handled 
min_index = find(nh,1,'first'); %first nonzero bin
max_index = find(nh,1,'last'); %last nonzero bin
nchr = nch(min_index:max_index); %reduced normalized cumulative histogram

INL_reduced = zeros(1,length(nchr)-1);
for k = 1:length(INL_reduced)
    INL_reduced(k) = (length(nchr) - 2) / (cos(pi*nchr(1))-cos(pi*nchr(end-1))) * (cos(pi*nchr(1))-cos(pi*nchr(k))) - (k-1);
end

INL = zeros(1,2^NoB-1);
INL(min_index:max_index-1) = INL_reduced;

end