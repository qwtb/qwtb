function INL = TransLevels2INL(translevels)
% @fn TransLevels2INL
% @brief Calculates INL vector using the transition levels
% @param translevels Vector of transition levels
% @return INL Vector of the calculated INL
% @author Tamás Virosztek, Budapest University of Technology and Economics,
%         Department of Measurement and Information Systems,
%         Virosztek.Tamas@mit.bme.hu

%Calculates INL vector using the values of the transition levels
INL = zeros(1,length(translevels));
Q = (translevels(end)-translevels(1))/(length(translevels)-1); % Q = V/(2^B-2)
INL(1) = 0; INL(end) = 0;
for k = 2:length(INL)-1
    INL(k) = (translevels(k) - (translevels(1) + (k-1)*Q))/Q;
end
end