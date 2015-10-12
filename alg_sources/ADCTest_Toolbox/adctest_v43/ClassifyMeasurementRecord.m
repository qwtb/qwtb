function classresults = ClassifyMeasurementRecord(dsc)
if isfield(dsc,'data') && isfield (dsc,'NoB') %Valid descriptor

    %Setting default values for outputs
    classresults.LS_app = 'OK';
    classresults.LS_warn = {'Warning message';'for LS fit'};
    classresults.LS_error = {'Error message';'for LS fit'};
    
    classresults.FFT_app = 'OK';
    classresults.FFT_warn = {'Warning message';'for FFT test'};
    classresults.FFT_error = {'Error message';'for FFT test'};
    
    classresults.Hist_app = 'OK';
    classresults.Hist_warn = {'Warning message';'for Histogram test'};
    classresults.Hist_error = {'Error message';'for Histogram test'};

    classresults.ML_app = 'OK';
    classresults.ML_warn = {'Warning message';'for ML fit'};
    classresults.ML_error = {'Error message';'for ML fit'};
    
    %Looking for trivial errors
    if (max(dsc.data) > 2^dsc.NoB - 1)... 
            || (min(dsc.data) < 0) % Out of scale        
        classresults.LS_app = 'Error';
        classresults.FFT_app = 'Error';
        classresults.Hist_app = 'Error';
        classresults.ML_app = 'Error';
        classresults.LS_error = {'Invalid measurement record';'mismatch between codes and numer of bits';'Use unsigned code notation: the codes shall be between 0 and 2^b-1'};
        classresults.FFT_error = {'Invalid measurement record';'mismatch between codes and numer of bits';'Use unsigned code notation: the codes shall be between 0 and 2^b-1'};
        classresults.Hist_error = {'Invalid measurement record';'mismatch between codes and numer of bits';'Use unsigned code notation: the codes shall be between 0 and 2^b-1'};
        classresults.ML_error = {'Invalid measurement record';'mismatch between codes and numer of bits';'Use unsigned code notation: the codes shall be between 0 and 2^b-1'};
    elseif ~isempty(find((round(dsc.data) ~= dsc.data),1)) %Not integer code value found
        classresults.LS_app = 'Error';
        classresults.FFT_app = 'Error';
        classresults.Hist_app = 'Error';
        classresults.ML_app = 'Error';
        classresults.LS_error = {'Invalid measurement record';'ADC codes shall be integer values'};
        classresults.FFT_error = {'Invalid measurement record';'ADC codes shall be integer values'};
        classresults.Hist_error = {'Invalid measurement record';'ADC codes shall be integer values'};
        classresults.ML_error = {'Invalid measurement record';'ADC codes shall be integer values'};
    end

    %Setting warnings:
    
    %Estimating frequency for warnings
    NFFT = 1e6;
    source_of_initial_fr = 'ipFFT (Blackman window)';
    f_rel = EstimateFreqBH3Ipfft(dsc.data,NFFT,source_of_initial_fr);
    %calculating numer of periods
    J = length(dsc.data)*f_rel; %Num of periods = num of samples*(periods/samples)
    if (J<5)
        classresults.LS_app = 'Warning';
        classresults.LS_warn = {'Less than 5 full cycles of sine wave';'LS fit can be mislead'};
        classresults.ML_app = 'Warning';
        classresults.ML_warn = {'Less than 5 full cycles of sine wave';'LS fit can be mislead'};
    end
    
    %Examining overdirve:
    D = [cos(2*pi*f_rel*(1:length(dsc.data)).'), sin(2*pi*f_rel*(1:length(dsc.data)).') , ones(length(dsc.data),1)];
    p = inv(D.'*D)*D.'*dsc.data;
    est_amplitude = sqrt((p(1))^2 + p(2)^2);
    if (est_amplitude > (2^dsc.NoB)/2) % amp > FullScale/2 seemingly overdives
        classresults.LS_app = 'Warning';
        classresults.LS_warn = {'The excitation signal seemingly overdrives the ADC under test';'Use amplitude limits to discard overdriven part in LS fit'};
        classresults.FFT_app = 'Warning';
        classresults.FFT_warn = {'The excitation signal seemingly overdrives the ADC under test';'Harmonic distortion can be result of saturation instead of nonlinearity'};
        classresults.ML_app = 'Warning';
        classresults.ML_warn = {'The excitation signal seemingly overdrives the ADC under test';'Use amplitude limits to discard overdriven part in LS fit'};        
    else %Not orverdiven
        classresults.Hist_app = 'Warning';
        classresults.Hist_warning = {'ADC under test is not overiven';'Transition levels outside the excitation range cannot be estimated'};
        classresults.ML_app = 'Warning';
        classresults.ML_warning = {'ADC under test is not overiven';'Transition levels outside the excitation range cannot be estimated'};        
    end    
    
    %Number of samples per code bin:
    if length(dsc.data)/(2^dsc.NoB) < 10 %average number of codes per bins is too low
        classresults.Hist_app = 'Warning';
        classresults.Hist_warn = {'Average number of codes per code bins is low (<10)';'Please consider it when evaluating histogram test'};
    end
    
    %Examining coherence:
    fractional_part = abs(J - round(J));
    rel_fractional_part = fractional_part/J;
    if (rel_fractional_part) > 1e-2
        classresults.Hist_app = 'Warning';
        classresults.Hist_warn = {'Ratio of fractional periods in record is higher than 1%';'Incoherence may mislead histogram test'};
        classresults.ML_app = 'Warning';
        classresults.ML_warn = {'Ratio of fractional periods in record is higher than 1%';'Incoherence may mislead histogram test'};
    end

else %Descriptor is invalid
    classresults.LS_app = 'Error';
    classresults.FFT_app = 'Error';
    classresults.Hist_app = 'Error';
    classresults.ML_app = 'Error';
    classresults.LS_error = {'Invalid measurement descriptor'};
    classresults.FFT_error = {'Invalid measurement descriptor'};    
    classresults.Hist_error = {'Invalid measurement descriptor'};        
    classresults.ML_error = {'Invalid measurement descriptor'};    
end
end
