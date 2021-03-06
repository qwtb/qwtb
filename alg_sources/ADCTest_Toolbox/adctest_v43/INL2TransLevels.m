function translevels = INL2TransLevels(INL)
% @fn INL2TransLevels
% @brief Calculates transition levels using INL values. Transition levels are
%        normalized: T(1) = 0, T(2^B-1) = 1
% @param INL The INL vector
% @return translevels The transition levels in a vector
% @author Tam�s Virosztek, Budapest University of Technology and Economics,
%         Department of Measurement and Infromation Systems,
%         Virosztek.Tamas@mit.bme.hu

translevels = zeros(length(INL),1);
translevels(1) = 0;
translevels(end) = 1;
Q = (translevels(end)-translevels(1))/(length(translevels)-1); %V/(2^B-2)
for k = 2:length(translevels)-1
    translevels(k) = translevels(1) + (k-1)*Q + INL(k)*Q;
end
end