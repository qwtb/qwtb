function [f, amp, ph, noise_rms, SNR, SNRdB, NL, NLD, SD, w, NENBW, ENBW] = ampphspectrum(y, fs, verbose, plottype, win, winparam, padding)
% [f, amp, ph, noise_rms, SNR, SNRdB, NL, NLD, SD, w, NENBW, ENBW] = ampphspectrum(y, fs, verbose, plottype, win, winparam, padding)
%
% Calcualtes amplitude and phase spectrum by means of discrete fourier
% transformation of vector of sampled values |y| with sampling
% frequency |fs|. Function returns frequency vector |f|, amplitudes
% |amp| and phases |ph|. Used window coefficients are returned in |w|,
% this can be usefull for further processing.
% 
% If |verbose| is set, two figures with amplitude and phase will be
% plotted. Plot properties can be modified by string |plottype|
% containing keywords, see lower.
%
% Window function will be used if |win| contains name of
% window function. Some window functions are parametric, its value can
% be set in |winparam|.
%
% If |padding| is set, signal will be zero
% padded at right side to the total length of |padding|.
%
% |plottype| is searched for following keywords. Keywords can be
% written in any case, keywords do not have to be separated in any
% way, any other content is ignored.
% line - plots are line types
% stem - (nominal) plots are stem types
% log - y-axis of amplitude spectrum is logarithmic
% dBm - y-axis of amplitude spectrum is in decibels relative to 1e-3
% dBu - y-axis of amplitude spectrum is in decibels relative to 1e-6
% dB - y-axis of amplitude spectrum is in decibels relative to 1
% Np - y-axis of amplitude spectrum is in Neppers relative to 1
% abs - (nominal) y-axis of amplitude spectrum is in absolute values
% deg - y-axis of phase spectrum is in degrees
% rad - (nominal) y-axis of phase spectrum is in radians.
%
% Outputs:
% f - vector of spectrum frequencies
% amp - vector of spectrum amplitudes
% ph - vector of spectrum phases
% noise_rms = RMS noise amplitude
% SNR - signal to noise ratio
% SNRdB - signal to noise ratio in decibels
% NL - average spectral noise level
% NLD - average spectral denstity noise level
% SD - spectral density, to get power spectral density: PSD = SD.^2;
% w - vector of window coefficients
% NENBW - Normalized Equivalent Noise BandWidth
% ENBW - Effective Noise BandWidth
%
% Example with signal of frequency 1 Hz, sampled by 50 Hz 
% frequency, two harmonic components at 1 and 8 Hz and one
% interharmonic component at 15.5 Hz with various
% amplitudes and phases:
% 
% fr=1; fs=50;
% x=[0:1/fs:1/fr];
% x = x(1:end-1);
% y=sin(2*pi*fr*x+1)+0.5*sin(2*pi*8*fr*x+2)+0.3*sin(2*pi*15.5*fr*x+3);
% [f,amp,ph]=ampphspectrum(y,fs,1, 'log deg');
% 

% Copyright (C) 2023 Martin Šíra
%
% This program is free software; you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation; either version 2 of the License, or
% (at your option) any later version.
%
% This program is distributed in the hope that it will be useful,
% but WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
% GNU General Public License for more details.
%
% You should have received a copy of the GNU General Public License
% along with this program; If not, see <http://www.gnu.org/licenses/>.

% Author: Martin Šíra <msira@cmi.cz>
% Created: 2013-02-27
% Modified: 2021-10-24
% Version: 1.5

% texinfo for octave:
% ## -*- texinfo -*-
% ## @deftypefn {Function File} {[@var{f}, @var{amp}, @var{ph}, @var{w}] = ampphspectrum (@var{y}, @var{fs}, [@var{verbose}, @var{plottype}, @var{win}, @var{winparam}, @var{padding}]) }
% ##  
% ## Calcualtes amplitude and phase spectrum by means of discrete fourier transformation of vector of sampled values @var{y} with sampling
% ## frequency @var{fs}. Function returns frequency vector @var{f}, amplitudes @var{amp} and
% ## phases @var{ph}. Used window coefficients are returned in @var{w}, this can be usefull for further
% ## processing.
% ## 
% ## If @var{verbose} is set, two figures with amplitude and phase will be plotted. 
% ## Plot properties can be modified by string @var{plottype} containing
% ## keywords, see lower.
% ## 
% ## Window function will be used if @var{win} contains name of window function. Some window
% ## functions are parametric, its value can be set in @var{winparam}.
% ## 
% ## If @var{padding} is set, signal will be zero padded at right side to the total length of
% ## @var{padding}.
% ##
% ## @var{plottype} is searched for following keywords. Keywords can be
% ## written in any case, keywords do not have to be separated in any
% ## way, any other content is ignored.
% ## @table @keywords
% ## @item line - plots are line types,
% ## @item stem - (nominal) plots are stem types,
% ## @item log - y-axis of amplitude spectrum is logarithmic,
% ## @item dBm - y-axis of amplitude spectrum is in decibels relative to 1e-3,
% ## @item dBu - y-axis of amplitude spectrum is in decibels relative to 1e-6,
% ## @item dB - y-axis of amplitude spectrum is in decibels relative to 1,
% ## @item Np - y-axis of amplitude spectrum is in Neppers relative to 1,
% ## @item abs - (nominal) y-axis of amplitude spectrum is in absolute values,
% ## @item deg - y-axis of phase spectrum is in degrees,
% ## @item rad - (nominal) y-axis of phase spectrum is in radians.
% ## @end table
% ##
% ## Outputs:
% ## @table @keywords
% ## @item f - vector of spectrum frequencies
% ## @item amp - vector of spectrum amplitudes. To get log scale: =20*log10(amp);
% ## @item ph - vector of spectrum phases
% ## @item noise_rms = RMS noise amplitude
% ## @item SNR - signal to noise ratio
% ## @item SNRdB - signal to noise ratio in decibels
% ## @item NL - average spectral noise level
% ## @item NLD - average spectral denstity noise level
% ## @item SD - spectral density, to get power spectral density: PSD = SD.^2;
% ## @item w - vector of window coefficients
% ## @item NENBW - Normalized Equivalent Noise BandWidth
% ## @item ENBW - Effective Noise BandWidth
% ## @end table
% ##
% ## Example with signal of frequency 1 Hz, sampled by frequency 50 samples/s. Two harmonic components at 1 and 8 Hz and one
% ## interharmonic component at 15.5 Hz with various amplitudes and phases:
% ## 
% ## @example
% ## fr=1; fs=50;
% ## x=[0:1/fs:1/fr](1:end-1);
% ## y=sin(2*pi*fr*x+1)+0.5*sin(2*pi*8*fr*x+2)+0.3*sin(2*pi*15.5*fr*x+3);
% ## [f,amp,ph]=ampphspectrum(y,fs,1, 'log deg');
% ## @end example
% ## 
% ## See demo for more detailed example.
% ## 
% ## @end deftypefn



        % ---- check input values ---- %<<<1
        % check number of inputs:
        if (nargin > 7 || nargin < 2)
                print_usage();
        end

        % assign optional values:
        % full call of the function in Octave: ampphspectrum(y, fs, verbose=0, plottype='stemabsrad', win='', winparam=[], padding=0)
        % this is because of Matlab:
        if ~exist('verbose', 'var'), verbose = 0; end
        if ~exist('plottype', 'var'), plottype = 'stemabsrad'; end
        if ~exist('win', 'var'), win = ''; end
        if ~exist('winparam', 'var'), winparam = []; end
        if ~exist('padding', 'var'), padding = 0; end

        % check values of inputs:
        if ~( isnumeric(y) && isvector(y))
                error('ampphspectrum: y has to be a vector!');
        end
        if ~( isnumeric(fs) && isscalar(fs) && fs > 0)
                error('amppphspectrum: fs has to be a positive nonzero scalar');
        end
        if ~ischar(plottype)
                plottype='';
        end
        if ~ischar(win)
                error('win has to be a string!');
        end
        if ~( isnumeric(padding) && isscalar(padding) && padding >= 0)
                error('amppphspectrum: padding has to be a non-negative scalar');
        end

        % ---- windowing ---- %<<<1
        % number of samples:
        N = length(y);

        if isempty(win)
                % rectangular window:
                w = ones(size(y));
        else
                % get window coefficients
                if isempty(winparam)
                        w = window_coeff(win, N, 'periodic');
                else
                        w = window_coeff(win, N, winparam, 'periodic');
                end
                % apply window function:
                w = reshape(w, size(y));
                y = w.*y;
        end
        normalisation_factor = sum(w);       % Normalization sum
        normalisation_factor_sq = sum(w.^2); % Normalization sum for power spectrum

        % ---- zero padding ---- %<<<1
        if padding
                % update number of samples:
                N = padding;
        end

        % ---- DFT ---- %<<<1
        % DFT calculation:
        Y = fft(y, N);
        % throw away negative frequencies of the spectrum:
        Y = Y(1 : ceil(N./2+0.5));
        % correct phases:
        Y = Y.*exp(j.*pi./2);
        % normalize power values (factor 2 because of taking only half of the spectrum):
        amp = 2 * abs(Y) ./ normalisation_factor;
        % and fix DC offset error:
        % (The result was rotated by pi/2, therefore whole dc value is in imaginary part
        % of Y(1). Function abs() would cause loss of sign (for AC components it is not important
        % but for DC it is). Thus imag() can be used to obtain value and sign at once.
        % Offset is only once in result of DFT, therefore factor 2 is not valid here.)
        amp(1) = imag(Y(1)) ./ normalisation_factor; 
        % calculate phases:
        ph = angle(Y);
        ph(1) = 0; % no phase angle of the DC!
        % build frequency vector (spacing is df=fs/N):
        f = fs./N.*[0:length(Y)-1];
        % force same orientation of fr. vector as of input y vector:
        % (iscollumn do not work in older Matlabs, thus use of size function)
        if size(y,1) >= 0 && size(y,2) == 1
                f = f';
                w = w';
        end

        % ---- Noise bandwidths ---- %<<<1
         % Normalized Equivalent Noise BandWidth:
        NENBW = N * normalisation_factor_sq / (normalisation_factor^2);
        % Effective Noise BandWidth:
        ENBW = fs * normalisation_factor_sq / (normalisation_factor^2);

        % ---- Amplitude spectral density ---- %<<<1
        SD = normalisation_factor .* amp ./ sqrt(2 .* fs .* normalisation_factor_sq);

        % ---- Highest peak ---- %<<<1
        % Find amplitude, frequency and phase of highest peak. This code is not
        % perfect, because it neglects window widening of the DC value. One way
        % would be to calculate FFT without DC offset, but this would mean
        % calculate second time. The second method is to get width of the
        % window function and mask first points of the spectra. But the window
        % functions are not ready for this.
        % XXX 2DO finish
        [amp_peak, id] = max(amp(3:end));
        f_peak = f(id);
        ph_peak = ph(id);

        % ---- Noise levels ---- %<<<1
        % average spectral density noise level:
        NLD = median(SD);
        % average spectral noise level:
        NL = NLD.*sqrt(2*ENBW);
        % RMS noise amplitude:
        noise_rms = NLD.*sqrt(max(f));
        % signal to noise ratio:
        SNR = (amp_peak./sqrt(2))./noise_rms;
        % signal to noise ratio in decibells:
        SNRdB = 20*log10(SNR);

        % ---- verbose - plot ---- %<<<1
        % plot figures in the case of verbose:
        if verbose
                plottype = lower(plottype);
                % if not keyword line, do stem plot:
                isstem = isempty(strfind(plottype, 'line'));

                % amplitude spectrum %<<<2
                figure
                if strfind(plottype, 'log') > 0 %<<<3
                        % simple logarithmic scale
                        % eps is added to prevent zero values in log plots
                        % abs is added to prevent warnings caused by negative dc values
                        val2plot = abs(amp+eps);
                        if isstem
                                % make stem plot:
                                h=stem(f, val2plot,'-o', 'filled');
                                % first move baseline to some safe value:
                                % (if baseline would be zero or negative, log scaling would generate warnings)
                                set(h, 'basevalue', 1);
                                % change y axis scale:
                                set(gca(),'yscal','log');
                                % move baseline to lower y axis limit:
                                lims = axis();
                                set(h, 'basevalue', lims(3));
                        else
                                semilogy(f, abs(amp+eps),'-')
                        end
                        ylabel('Absolute value of Amplitude (abs. units)');
                elseif strfind(plottype, 'dbm') > 0 %<<<3
                        % decibels relative to 1e-3
                        % eps is added to prevent zero values in log plots
                        % abs is added to prevent warnings caused by negative dc values
                        val2plot = 20*log10(abs(amp/1e-3+eps));
                        if isstem
                                stem(f, val2plot,'-o', 'filled');
                        else
                                plot(f, val2plot,'-')
                        end
                        ylabel('Absolute value of Amplitude (dBm)');
                elseif strfind(plottype, 'dbu') > 0 %<<<3
                        % decibels relative to 1e-6
                        % eps is added to prevent zero values in log plots
                        % abs is added to prevent warnings caused by negative dc values
                        val2plot = 20*log10(abs(amp/1e-6+eps));
                        if isstem
                                stem(f, val2plot,'-o', 'filled');
                        else
                                plot(f, val2plot,'-')
                        end
                        ylabel('Absolute value of Amplitude (dBu)');
                elseif strfind(plottype, 'db') > 0 %<<<3
                        % decibels relative to 1
                        % eps is added to prevent zero values in log plots
                        % abs is added to prevent warnings caused by negative dc values
                        val2plot = 20*log10(abs(amp+eps));
                        if isstem
                                stem(f, val2plot,'-o', 'filled');
                        else
                                plot(f, val2plot,'-')
                        end
                        ylabel('Absolute value of Amplitude (dB)');
                elseif strfind(plottype, 'np') > 0 %<<<3
                        % nepper units relative to 1
                        % eps is added to prevent zero values in log plots
                        % abs is added to prevent warnings caused by negative dc values
                        val2plot = log(abs(amp+eps));
                        if isstem
                                stem(f, val2plot,'-o', 'filled');
                        else
                                plot(f, val2plot,'-')
                        end
                        ylabel('Absolute value of Amplitude (Np)');
                        % neppers
                else % {'abs'  'absstem'} %<<<3
                        % absolute values
                        % abs is not needed, only figure when dc value
                        % is correctly shown:
                        if isstem
                                stem(f, amp,'-o', 'filled');
                        else
                                plot(f, amp,'-')
                        end
                        ylabel('Amplitude (abs. units)');
                end
                title('Amplitude spectrum');
                xlabel('Frequency (Hz)');

                % phase spectrum %<<<2
                figure
                if strfind(plottype, 'deg') > 0 %<<<3
                        % degrees
                        if isstem
                                stem(f, ph.*180./pi, '-o', 'filled')
                        else
                                plot(f, ph.*180./pi, '-')
                        end
                        ylabel('Phase (deg)');
                else % rad %<<<3
                        % radians
                        if isstem
                                stem(f, ph, '-o', 'filled')
                        else
                                plot(f, ph, '-')
                        end
                        ylabel('Phase (rad)');
                end
                title('Phase spectrum');
                xlabel('Frequency (Hz)');
        end
end

% ---- demo ---- %<<<1
%!demo
%!  % Example showing effect of coherent and non-coherent sampling,
%!  % windowing and zero padding on estimating amplitude and phase
%!  % by means of DFT.
%!  
%!  % Construct signal with two harmonic components at 1
%!  % and 8 Hz and one interharmonic component at 15.5 Hz
%!  % with various amplitudes and phases:
%!  sf = [1;   8; 15.5];
%!  sA = [1; 0.5;  0.3];
%!  sp = [0;   1;    2];
%!  % Sampling frequency:
%!  fs = 50;
%!  % Create time vector - one period of first harmonic is sampled coherently:
%!  t = [0 : 1/fs : 1.*sf(1)](1:end-1);
%!  y = sA.*sin(2.*pi.*sf.*t + sp);
%!  % Calculate amplitude and phase spectrum:
%!  [f,amp,ph]=ampphspectrum(sum(y,1),fs, 0);
%!  % Calculate amplitude and phase spectrum with windowing:
%!  [fw,ampw,phw]=ampphspectrum(sum(y,1),fs, 0, 0, 'blackman');
%!  % Calculate amplitude and phase spectrum with windowing and zero padding:
%!  [fwz,ampwz,phwz]=ampphspectrum(sum(y,1),fs, 0, 0, 'blackman', [], 10.*length(y));
%!  % Plot signal:
%!  figure; hold on;
%!  plot(t, y,'-')
%!  plot(t, sum(y,1),'-k','linewidth',2)
%!  title('Sampled signal and components'); legend('1st harmonic', '8th harmonic', 'interharmonic', 'signal')
%!  xlabel('time (s)'); ylabel('amplitude (V)');
%!  hold off;
%!  figure; hold on;
%!  plot(sf, sA, '+r', 'markersize', 10, 'linewidth', 2);
%!  stem(f, amp, '-ob', 'filled', 'markersize', 3);
%!  plot(fw, ampw, '-g','linewidth',2);
%!  plot(fwz, ampwz, '-k');
%!  legend('nominal values','DFT', 'blackman window', 'blck. w. + zero padding')
%!  title('Amplitude spectrum')
%!  xlabel('frequency (Hz)'); ylabel('amplitude (V)');
%!  hold off
%!  figure; hold on;
%!  plot(sf, sp, '+r', 'markersize', 10, 'linewidth', 2);
%!  stem(f, ph, '-ob', 'filled', 'markersize', 3);
%!  plot(fw, phw, '-g','linewidth',2);
%!  plot(fwz, phwz, '-k');
%!  legend('nominal values','DFT', 'blackman window', 'blck. w. + zero padding', 'location', 'southwest')
%!  title('Phase spectrum');
%!  xlabel('frequency (Hz)'); ylabel('phase (rad)');
%!  hold off

% ---- tests ---- %<<<1
%!shared fs, t, y, f, amp, ph, wins, it, winparam, lim
%! % -------- Test proper results for odd and even samples:
%!  t=[0:1/3:1](1:end-1);
%!  y=sin(2*pi*1*t+1);
%!  [f,amp,ph]=ampphspectrum(y,3);
%!assert(f,   [0 1],  1e-14);
%!assert(amp, [0 1],  1e-14);
%!assert(ph(2),   1,  1e-14);
%!  t=[0:1/4:1](1:end-1);
%!  y=sin(2*pi*1*t+1);
%!  [f,amp,ph]=ampphspectrum(y,4);
%!assert(f,   [0 1 2],  1e-14);
%!assert(amp, [0 1 0],  1e-14);
%!assert(ph(2),     1,  1e-14);
%! % -------- Test proper results for complex signal with offset:
%!  fs = 50;
%!  t = [0 : 1/fs : 1](1:end-1);
%!  y = [1; 0.5; 0.3].*sin(2.*pi.*[1; 8; 15].*t + [0; 1; 2]);
%!  y = sum(y,1) - 2;
%!  [f,amp,ph]=ampphspectrum(y,fs);
%!assert (size(f), size(amp))
%!assert (size(f), size(ph))
%!assert (amp(1),   -2, 1e-14)
%!assert (amp(2),    1, 1e-14)
%!assert (amp(9),  0.5, 1e-14)
%!assert (amp(16), 0.3, 1e-14)
%!assert (amp(16), 0.3, 1e-14)
%! % -------- Test offset with windowing:
%!  [f,amp,ph]=ampphspectrum(y,fs, 0, 0, 'hanning');
%!assert (amp(1),   -2, 1e-14)
%! % -------- Test also column vector:
%!  y = y';
%!  [f,amp,ph]=ampphspectrum(y,fs);
%!assert (size(f), size(amp))
%!assert (size(f), size(ph))
%! % -------- Test windowing and zero padding:
%!  y = sin(2.*pi.*10.*t);
%!  [f,amp,ph]=ampphspectrum(y, fs, 0, 0, 'cheb');
%!assert (amp(11),   1, 1e-4)
%!  [f,amp,ph]=ampphspectrum(y, fs, 0, 0, 'cheb', 200);
%!assert (amp(11),   1, 1e-7)
%! % Test windowing and zero padding:
%!  [f,amp,ph]=ampphspectrum(y, fs, 0, 0, 'cheb', [], 10.*length(y));
%!assert (amp(101),  1, 1e-4)
%!  [f,amp,ph]=ampphspectrum(y, fs, 0, 0, 'cheb', 200, 10.*length(y));
%!assert (amp(101),  1, 1e-7)
%! % -------- Test correct amplitude by all windows (too complex, must be in test block):
%!test
%!  fs = 500;
%!  t = [0 : 1/fs : 1](1:end-1);
%!  y = sin(2.*pi.*50.*t);
%! wins = window_coeff();
%! for it = 1:length(wins);
%!   switch (wins{it})
%!     case {'gaussian'}
%!       winparam=0;
%!       lim=1e-7;
%!     case {'welch'}
%!       winparam=200;
%!       lim=1e-4;
%!     otherwise
%!       winparam=200;
%!       lim=1e-7;
%!   endswitch
%!   [f,amp,ph,w]=ampphspectrum(y, fs, 0, 0, wins{it}, winparam);
%!   assert (amp(51), 1, lim)
%!   assert (size(w), size(y))
%! endfor
%! % -------- Test proper error generation:
%!error ampphspectrum (5)
%!error ampphspectrum (1, 2, 3, 4, 5, 6, 7, 8)
%!error ampphspectrum ('a', 1)
%!error ampphspectrum (1, 'a')
%!error ampphspectrum (1, [1:5])
%!error ampphspectrum (1, 1, 1, 1, '', 5, -5)
%!error ampphspectrum (1, 1, 1, 1, 'somewin', 5, 5)

% vim settings line: vim: foldmarker=%<<<,%>>> fdm=marker fen ft=octave
