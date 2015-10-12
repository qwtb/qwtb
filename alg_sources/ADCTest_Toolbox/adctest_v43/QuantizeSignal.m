function y = QuantizeSignal(x,trans_levels)
% @fn QuantizeSignal
% @brief Quantizes a sampled, unquantized signal: a vector of "real"
%        numbers to a vector of integers
% @param x The unquantized signal
% @param trans_levels The transition levels used in quantization
% @return y The quantized signal
% @author Tamás Virosztek, Budapest University of Technology and Economics,
%         Department of Measurement and Infromation Systems,
%         Virosztek.Tamas@mit.bme.hu


y = zeros(length(x),1);

for k = 1:length(x)
    if (x(k) <= trans_levels(1))
        y(k) = 0;
    elseif (x(k) > trans_levels(end))
        y(k) = length(trans_levels);
    else
        for l = 1:length(trans_levels) - 1
            if (x(k) >  trans_levels(l)) && (x(k) <= trans_levels(l+1))
                y(k) = l;
                break;
            end
        end
    end
end

end
