function SFDR = spec_to_SFDR(a) %<<<1
% Calculates Spurious Free Dynamic Ratio from signal spectrum algorithm does
% not require knowledge of the window used for calculating the spectrum,
% because the width of the peak is find out iteratively.
%
% Algorithm expects one main signal component and calculates ratio of the main
% signal component to the next highest component.
%
% Input 'a' is amplitude spectrum of the signal.

% identify amplitude of main signal:
[Am, idm] = max(a);

% find width of the main signal peak
% crawl to the right (higher frequency) and detect falling down below Am/2:
hfid = numel(a);
for j = idm:numel(a)
    if a(j) < Am/2;
        % halfwidth found
        hfid = j;
        break
    end % if
end % for j
% crawl to the left (lower frequency) and detect falling down below Am/2:
lfid = 1;
for j = idm:-1:1
    if a(j) < Am/2;
        % halfwidth found
        lfid = j;
        break
    end % if
end % for j
if lfid == 1 && hfid == numel(A)
    % main signal peak is through whole spectrum?
    error('spec_to_SFDR: Cannot identify width of the main peak, maybe main signal peak is lost in noise or insufficient frequency bins between signal components?')
end
% add safety margin:
peak_width = hfid - lfid;
lfid = lfid - peak_width/2;
hfid = hfid + peak_width/2;
% check limits are not outside spectrum:
if lfid < 1
    lfid = 1;
end
if hfid > numel(a)
    hfid = numel(a);
end

% mask out all but main peak:
a(lfid:hfid) = nan;
% find out highest spurious amplitude:
spurious = max(a);
% calculate SFDR:
SFDR = Am./spurious;

end % function spec_to_SFDR
