function [f, amp, ph] = ampphspectrum(y,fs)
% Calcualtes discrete fourier transformation of vector of sampled values |y| with sampling
% frequency |fs|, normalize values and returns frequency vector |f|, amplitudes |amp| and
% phases |ph|.
% 
% Example with signal of frequency 1 Hz, sampled by 50 Hz 
% frequency, two harmonic components at 1 and 8 Hz and one
% interharmonic component at 15.5 Hz with various
% amplitudes and phases:
% 
% fr=1; fs=50;
% x=[0:1/fs:1/fr](1:end-1);
% y=sin(2*pi*fr*x+1)+0.5*sin(2*pi*8*fr*x+2)+0.3*sin(2*pi*15.5*fr*x+3);
% [f,amp,ph]=ampphspectrum(y,fs);
% 

        % ---- check input values ----
        if (nargin > 3 || nargin < 2)
                print_usage();
        end

        if ~isvector(y)
                error('y has to be a vector!');
        end

        if ~isscalar(fs)
                error('fs has to be a scalar!');
        end

        % ---- DFT ----
        % number of samples:
        len_Y = length(y);
        % frequency axis vector:
        f = fs/2*linspace(0,1,len_Y/2+1);
        % fft calculation:
        Y = fft(y);
        % get only positive values:         
        Y=Y(1:length(Y)/2+1);
        % power values normalized:
        amp = 2* abs(Y)/length(y);
        % calculate phases:
        % 2DO atan2 should go here:
        %ph=phaseRI(Y);
        ph=angle(Y);

end

% function calculates phases:
function [phase]=phaseRI(c,p)

        % ---- check input values ----
        if (nargin > 2 || nargin <1)
                print_usage ();
        end

        if (~isnumeric(c))
                print_usage ();
        end

        if (~isvector(c))
                print_usage
        end

        if (nargin == 1)
                p=eps;
        end

        %rounding - because after division you never get zero even if it is essentially zero
        arcgtp = abs(real(c))>p;
        re_Y = real(c).*arcgtp;
        % to remove possible negative zeros:
        re_Y = re_Y + 0;

        aicgtp=abs(imag(c))>p;
        im_Y = imag(c).*aicgtp;
        % to remove possible negative zeros:
        im_Y = im_Y + 0;

        % detecting quadrant:
        q1 = im_Y<0 & re_Y<0;
        q2 = im_Y<0 & re_Y>=0;
        q3 = im_Y>=0 & re_Y<0;
        q4 = im_Y>=0 & re_Y>=0;

        % phase in radiants:
        phase = atan( -re_Y./im_Y ).*q1 + atan( -re_Y./im_Y ).*q2 + ( atan( -re_Y./im_Y ) - pi ).*q3 + ( atan( -re_Y./im_Y ) + pi ).*q4;

end

% vim settings line: vim: foldmarker=%{{{,%}}} fdm=marker fen ft=octave
