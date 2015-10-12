elements = 8;
NoSs = [1000;2000;4000;8000;16000;32000;64000;128000];
INL = 1.5*hann(255) + 4*sin(2*pi*1/254*(0:254).') + 0.5*rand(255,1)- 0.25;
T = INL2TransLevels(INL);
A = 0.52*cos(78);
B = 0.52*sin(78);
C = 0.497;
thetas = 2*pi*1./NoSs;

sinewaves = zeros(max(NoSs),elements);
for k = 1:elements
    sinewaves(1:NoSs(k),k) = A*cos(thetas(k)*(1:NoSs(k)).') + B*sin(thetas(k)*(1:NoSs(k)).') + C*ones(NoSs(k),1);
end

quantized_sinewaves = cell(elements,1);
timevects = cell(elements,1);

for k = 1:elements
    quantized_sinewaves{k,1} = QuantizeSignal(sinewaves(1:NoSs(k),k),T);
end

for k = 1:elements
    ti = 1;
    for l = 1:NoSs(k)
        if (quantized_sinewaves{k,1}(l) > 0) && (quantized_sinewaves{k,1}(l) < 255)
            timevects{k,1}(ti) = l;
            ti = ti + 1;
        end
    end
end

datavects = cell(elements,1);
for k = 1:elements
    timevects{k,1} = timevects{k,1}.';
    datavects{k,1} = quantized_sinewaves{k,1}(timevects{k,1});
end

descriptors = cell(elements,1);
for k = 1:elements
    descriptors{k,1}.data = quantized_sinewaves{k,1};
    descriptors{k,1}.NoB = 8;
    descriptors{k,1}.name = sprintf('s%d_meas',NoSs(k));
    descriptors{k,1}.comment = {'';''};
    descriptors{k,1}.model = 'R2007b';
    descriptors{k,1}.serial = 'N/A';
    descriptors{k,1}.channel = 1;
end