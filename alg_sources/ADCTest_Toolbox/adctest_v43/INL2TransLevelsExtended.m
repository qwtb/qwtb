function translevels = INL2TransLevelsExtended(INL,T_first,T_last)
% @fn INL2TransLevelsExtended
% @brief Calculates transition levels using INL values. The full scale is
%        given with T_first and T_last
% @param INL The INL vector
% @param T_first The lowest transition level
% @param T_last The highest transition level
% @return translevels The transition levels in a vector
% @author Tamás Virosztek, Budapest University of Technology and Economics,
%         Department of Measurement and Infromation Systems,
%         Virosztek.Tamas@mit.bme.hu

translevels = zeros(1,length(INL));
translevels(1) = T_first;
translevels(end) = T_last;
Q = (T_last-T_first)/(length(translevels)-1); %V/(2^B-2)
for k = 2:length(translevels)-1
    translevels(k) = translevels(1) + (k-1)*Q + INL(k)*Q;
end
end