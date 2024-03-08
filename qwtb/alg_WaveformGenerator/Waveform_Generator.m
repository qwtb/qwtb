% Waveform Generator, version 5 (2024)
%
% Generates waveform with preset properties, its parameters and calculates
% reference values. Reference values are two types: instantaneous, and
% values in frames to simulate Phasor Measurement Unit (PMU) measures.
% Signal can contain harmonics and interharmonics. 
% Harmonics are modulated in the same way as main component.
% Interharmonics are NOT modulated.
% Modulation starts at t=0.
%
% Inputs:
%   acquis: structure with acquisition parameters:
%     .N  - integer number, total number of samples
%     .n  - integer number, number of samples before t=0, must be > 0!
%     .fs - real number, sampling frequency
%     .Fs - real number, PMU frames per second, ratio fs/Fs must be integer!
%   src: structure with basic source signal parameters:
%     .f0 - real number, frequency of main signal component
%     .harm: structure with properties of harmonic components
%        .rank - int vector, multiple(s) of main signal frequency
%        .mag  - real vector, magnitude(s) of harmonic component(s)
%        .pha  - real vector, phase(s) of harmonic component(s) (rad)
%     .inter: structure with properties of interharmonic components
%        .freq - real vector, frequency(ies)of interharmonic component(s)
%        .mag  - real vector, magnitude(s) of interharmonic component(s)
%        .pha  - real vector, phase(s) of interharmonic component(s) (rad)
%     .noise - real number, std of noise in the signal with normal distribution
%     .fMod: structure with frequency modulation parameters (see lower):
%        .type   - string, type of modulation
%        .df     - real number, value of frequency change
%        .f      - real number, speed or frequency of change
%        .ncycle - real number, number of modulation cycles
%     .magMod: structure with magnitude modulation parameters (see lower):
%        .type   - string, type of modulation
%        .dmag   - real number, value of amplitude change
%        .f      - real number, slope of the change
%        .ncycle - real number, number of modulation cycles
%     .phaMod: structure with phase modulation parameters (see lower):
%        .type   - string, type of modulation
%        .dpha   - real number, value of phase change (rad)
%        .f      - real number, speed or frequency of change
%        .ncycle - real number, number of modulation cycles
%   digit - not used
%   infos - string, notes about waveform will be added to this string and put to the output
%
% Modulation structures parameter details:
%   Modulation type can be one of: step, ramp, sinus, square, triangle.
%   step:
%     df/dmag/dpha: change of quantity. f, dt and ncycle are without effect.
%   ramp:
%     df/dmag/dpha: change of quantity. f: slope of ramp. dt and ncycle are without effect.
%     Example: dmag=1, f=0.5: upward ramp for 2 seconds, change by 1 unit.
%     For negative ramp, both dmag and f has to be negative.
%   sinus/square/triangle:
%     df/dmag/dpha: amplitude of sine/square/triangle modulation. f: frequency 
%     of sine/square/triangle modulation. ncycle: number of sine/square/triangle periods 
%     of the modulation. dt: no effect.
%     Example: type=sinus, dmag = 0.1, f=1, ncycle: 3: quantity will be modulated by
%     sine function with amplitude of 0.1, frequency 2, and for 3 periods of the sine function,
%     i.e. modulation will last 1.5 seconds.
%
% Outputs:
%   signal: structure with signal values:
%     .index - integer vector, indexes of PMU frame starts (indexes of signal.time)
%     .time - real vector, time stamps
%     .y - real vector, values of samples
%   srcth: structure with theoretical values for every sample:
%     .time   - real vector, time stamps, same values as signal.time.
%     .freq   - real vector, instantaneous values of frequency
%     .mag    - real vector, instantaneous values of amplitude
%     .pha    - real vector, instantaneous values of phase
%     .ROCOF  - real vector, instantaneous values of rate of change of frequency
%     .thd_k1 - real number, value of total harmonic distortion (without noise), referenced to 1st harmonic
%   ref: structure with reference PMU parameters for every PMU frame:
%     .index     - integer vector, indexes of PMU frame starts (indexes of signal.time)
%     .time      - real vector, time stamps of PMU frame starts (=signal.time(ref.index))
%     .freq      - real vector, frequency of PMU frame starts (=srcth.freq(ref.index))
%     .mag       - real vector, amplitude of PMU frame starts (=srcth.mag(ref.index))
%     .pha       - real vector, phase of PMU frame starts (=srcth.pha(ref.index))
%     .harmmag   - real matrix, amplitudes of harmonic components of PMU frame starts
%     .harmpha   - real matrix, phases of harmonic components of PMU frame starts
%     .ROCOF     - real vector, rate of change of frequency of PMU frame starts
%     .thd_k1    - real number, value of total harmonic distortion (without noise), referenced to 1st harmonic
%   Output string:
%     infos - string, notes about waveform were added to the input infos and put into this string
%
% Authorship:
% Derived  from the function GenerateSignal.m
% Jean-Pierre Brown (March 2011)
% Derived  from the function Waveform_Generator2.m
% Humberto Pogliano, Rado Lapuh (December 2011)
% Work done in the scope of EMRP 2009 ENG04 SmartGrids project.
% Modified by Martin Šíra, 2024. All errors are my fault, all credit is theirs. 

function [signal, srcth, ref, infos] = Waveform_Generator(acquis, src, digit, infos)
% generates signal, its parameters and calculates reference values
% randomization is done inside

% 
%   the phases are in degrees - to be changed!
%
%   3th Hypothesis with computed NW (only as comment) 
%

% --- Check inputs %<<<1
% Only basic sanity check is provided.
% Check if acquis.fs/acquis.Fs is divisible:
if round(acquis.fs/acquis.Fs) ~= acquis.fs/acquis.Fs
    error(sprintf('Waveform_Generator: Ratio acquis.fs/acquis.Fs must be integer! Actual values are: fs=%g, Fs=%g.', acquis.fs, acquis.Fs))
end
% Check if acquis.n is smaller than acquis.N
if acquis.n >= acquis.N
    error(sprintf('Waveform_Generator: acquis.n must be smaller than acquis.N! Actual values are: n=%g, N=%g.', acquis.n, acquis.N))
end
% Check if acquis.n is positive
if acquis.n < 1
    error(sprintf('Waveform_Generator: acquis.n must be larger than 0! Actual value is: n=%g.', acquis.n))
end

% --- Convert inputs from radians to degrees %<<<1
% Because original script works in degrees.
src.harm.pha = src.harm.pha.*180./pi;
src.inter.pha = src.inter.pha.*180./pi;

% --- Time vectors %<<<1
% generate signal indexes: %<<<1
signal.index = 1:1:acquis.N;

signal.time = (-acquis.n:1:acquis.N - acquis.n - 1) * (1/acquis.fs);
% this time vector is also identical to time vector of theoretical values:
srcth.time = signal.time;

% --- Frequency of source %<<<1
% fundamental:
srcth.freq = ones(src.harm.rank, acquis.N) * src.f0;
if ~strcmp(src.fMod.type,'')
        % source waveform frequency is modulated:
        srcth.freq(acquis.n+1:acquis.N) = modulate(...
                src.fMod.type,...
                srcth.freq(acquis.n+1:acquis.N),...
                src.fMod.df,...
                src.fMod.f,...
                signal.time(acquis.n+1:acquis.N),...
                src.fMod.ncycle);
end
% harmonics:
srcth.freq = src.harm.rank'.*srcth.freq;

% --- Phase of source %<<<1
% fundamental:
signalpha = ones(1,acquis.N) * src.harm.pha(1); %corrected sync
if ~strcmp(src.phaMod.type,'')
    signalpha(acquis.n+1:acquis.N) = modulate(...
                src.phaMod.type,...
                signalpha(acquis.n+1:acquis.N),...
                src.phaMod.dpha,...
                src.phaMod.f,...
                signal.time(acquis.n+1:acquis.N),...
                src.phaMod.ncycle);
end
% harmonics:
signalpha = repmat(signalpha, [length(src.harm.rank), 1]);

% --- Magnitude of source %<<<1
% fundamental:
srcth.mag = ones(1,acquis.N) * src.harm.mag(1); %corrected sync
if ~strcmp(src.magMod.type,'')
    srcth.mag(acquis.n+1:acquis.N) = modulate(...
                src.magMod.type,...
                srcth.mag(acquis.n+1:acquis.N),...
                src.magMod.dmag,...
                src.magMod.f,...
                signal.time(acquis.n+1:acquis.N),...
                src.magMod.ncycle);
end
% harmonics:
srcth.mag = src.harm.mag'./src.harm.mag(1).*srcth.mag;

% --- Generation of signal with harmonics %<<<1
% prepare variable:
signal.y = zeros(1, length(signal.time) );
% compose:
for i = 1:length(src.harm.rank)           %corrected sync
        dw = 2*pi*[0 srcth.freq(i,:)/acquis.fs];
        dw = dw(1:length(dw)-1);
        aw = 2*pi*[0 diff(srcth.freq(i,:))] * (1/acquis.fs)^2;
        phase = cumsum(dw+aw);
        signal.y = signal.y + srcth.mag(i,:) .* cos(phase + signalpha(i,:)*pi/180);
        %Instantaneous phase not wrapped        
        srcth.pha(i,:) = phase*180/pi+signalpha(i,:);  
end

% --- Generatation of interharmonics %<<<1
if length(src.inter.freq)>= 1
        for i = 1:length(src.inter.freq)
                signal.y = signal.y + src.inter.mag(i) * cos(...
                        2*pi*src.inter.freq(i) * signal.time...
                        + src.inter.pha(i)*2*pi/360 ...
                        );
        end
end

% --- Generation of white noise %<<<1
signal.y = signal.y + src.noise * randn(1, length(signal.time));

% Evaluation of the waveform stucture %<<<1
% Evaluation of the structure ref

% because of this acquis.n must be smaller than acquis.N,
% and fs/Fs must be divisible:
signal.index = acquis.n:(acquis.fs/acquis.Fs):acquis.N;
ref.index = signal.index;
ref.time = signal.time(1, ref.index);
ref.mag = srcth.mag(1, ref.index);
ref.pha = srcth.pha(1, ref.index);

% references for harmonics
% XXX pridat nuly pro meziharmoniky!
ref.harmmag = zeros(max(src.harm.rank), length(ref.index));
ref.harmpha = zeros(max(src.harm.rank), length(ref.index));
j = 1;
for i = src.harm.rank
        ref.harmmag(i, :) = srcth.mag(j, ref.index);
        ref.harmpha(i, :) = srcth.pha(j, ref.index);
        j = j + 1;
end

% srcth.freq/mag/pha should also contain only main component
% to keep compatibility with previous versions
srcth.freq = srcth.freq(1, :);
srcth.mag = srcth.mag(1, :);
srcth.pha = srcth.pha(1, :);

% The angle is wrapped to the interval between -180 + 180 degrees
%       ref.pha=wrapTo180(ref.pha);

% Second variant for versions lower than 7.6

ref.pha = (180/pi)*angle(cos(ref.pha*pi/180) + 1i*sin(ref.pha*pi/180));

ref.freq = srcth.freq(ref.index);

srcth.ROCOF = (...
        [srcth.freq(2) - srcth.freq(1) diff(srcth.freq)]...
        + [diff(srcth.freq) srcth.freq(acquis.N) - srcth.freq(acquis.N-1)]...
        ) * acquis.fs/2;

% total harmonic distortion cannot be changed by any 
% implemented type of modulation, because harmonic 
% amplitudes are always ratio of first harmonic
srcth.thd_k1 = sqrt(sum(src.harm.mag(2:end).^2))./src.harm.mag(1);
if isempty(srcth.thd_k1)
        % in the case of missing higher harmonics:
        srcth.thd_k1 = 0;
end

ref.thd_k1 = srcth.thd_k1;


% 1st Hypothesis
% ref.ROCOF=srcth.inst_ROCOF(ref.index);  

% 2nd Hypothesis
%  Npnts = length(ref.freq);
%  ref.ROCOF = ([ref.freq(2)-ref.freq(1) diff(ref.freq)]+....
%  [diff(ref.freq) ref.freq(Npnts)-ref.freq(Npnts-1)])*acquis.Fs/2 ;

% 3rd  Hypothesis

% Application of a not casual digital filter

% OPTIONS:
% 1) Windows with a fixed number of elements (10)
NW=10; 
% For a variable NW (side elements of the window) tracked to 
% the frequency the  number can be computed by reference to the signal

% 2) Width of the window = reporting period
% NW=round(acquis.fs/acquis.Fs)-1; % Evaluation of the windows

% 3) Width of the window = period of the signal
% NW=round(acquis.fs/x.f0)-1; % Evaluation of the windows

ref.ROCOF = filterF(NW, srcth.ROCOF, ref.index);

% general text informations --------------------------- %<<<1
infos = sprintf("%s\nWaveform max after t0 (V): %g", infos, max(signal.y(acquis.n:end)));
infos = sprintf("%s\nWaveform min after t0 (V): ", infos, min(signal.y(acquis.n:end)));
infos = sprintf("%s\nWaveform duration (s): ", infos, max(signal.time) - min(signal.time));

% --- Convert outputs from degrees to radians %<<<1
srcth.pha = srcth.pha.*pi./180;
ref.pha = ref.pha.*pi./180;
ref.harmpha = ref.harmpha.*pi./180;

end % function Waveform_Generator5

% --- Demo %<<<1
%!demo
%! src.f0 = 1;
%! acquis.Fs = 10;
%! acquis.fs = 100;
%! acquis.N = 1400;
%! acquis.n = 400;
%! src.harm.rank = [1 3];
%! src.harm.mag = [1 0.15];
%! src.harm.pha = [-pi/2 0];
%! src.noise = 0;
%! src.inter.freq = [];
%! src.inter.mag = [];
%! src.inter.pha = [];
%! src.fMod.type = 'sinus';
%! src.fMod.df = 0.5;
%! src.fMod.f = 0.25;
%! src.fMod.ncycle = 10;
%! src.phaMod.type = 'step';
%! src.phaMod.dpha = 180;
%! src.phaMod.f = 0;
%! src.phaMod.ncycle = 0;
%! src.magMod.type = 'ramp';
%! src.magMod.dmag = 1;
%! src.magMod.f = 0.1;
%! src.magMod.ncycle = 0;
%! [signal, srcth, ref, infos] = Waveform_Generator(acquis, src, [], '');
%!
%! x = srcth.pha; % phase wrap for better plotting
%! xwrap = rem (x, 360);
%! idx = find (abs (xwrap) > 180);
%! xwrap(idx) -= 2*180 * sign (xwrap(idx));
%! srcthphawrap = xwrap;
%! x = ref.pha;
%! xwrap = rem (x, 360); % phase wrap for better plotting
%! idx = find (abs (xwrap) > 180);
%! xwrap(idx) -= 2*180 * sign (xwrap(idx));
%! refphawrap = xwrap;
%
%! plot(signal.time, signal.y, '-+k')
%! hold on;
%! plot(srcth.time, 3 + srcth.freq, '-b')
%! plot(srcth.time, 2 + srcth.mag, '-r')
%! plot(srcth.time, 2 + srcthphawrap./1000, '-g')
%! plot(ref.time, 3 + ref.freq, 'bx')
%! plot(ref.time, 2 + ref.mag, 'rx')
%! plot(ref.time, 2 + refphawrap./1000, 'gx')
%! legend('signal', 'theoretical frequency (offset 3)', 'theoretical magnitude (offset 2)', 'theoretical phase in deg, wrapped to 180 (divided by 1000, offset 2)', 'PMU frame frequency (offset -4)', 'PMU frame magnitude (offset -5)', 'PMU frame phase in deg, wrapped to 180 (divided by 1000, offset -6)', 'location', 'southwest')
%! xlabel('time (s)')
%! ylabel('value')
%! title(sprintf('Generated waveform, 1st and 3rd harmonic, with:\nfrequency modulation (type sinus), amplitude modulation (type ramp)\n and phase modulation (type step).'))
%! hold off

% vim modelin0e: vim: foldmarker=%<<<,%>>> fdm=marker fen ft=octave textwidth=1000
