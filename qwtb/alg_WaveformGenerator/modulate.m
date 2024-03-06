% Inputs:
%   type: type of the modulation. Possible values: step, ramp, sinus, square, triangle.
%   x: 
%   dx: the variation of the parameter.
%   f: the frequency of the modulation,
%   time: the time after the 0 when the modulation begins, - NOT PROPER DESCRIPTION?!
%   nc: the number of cycles of the modulation (must be an integer).

function x = modulate(type,x,dx,f,time,nc)

switch type
    case 'step'
        x = x+dx;
    case 'ramp'
        dur = dx/f;                           % Ramp duration
        if dur <= max(time)                   % Ramp reaching maximum
            n = max(find(time <= dur));
            x(1:n) = x(1:n)+f*time(1:n);
            m = max(size(time));
            x(n+1:m) = x(n+1:m)+dx;   
        else                                  % Ramp not reaching maximum  
            x = x+f*(time);         
        end
    case 'sinus'
        dur = nc/f;                           % Sinus duration      
        n = max(find(time <= dur));
        x(1:n) = x(1:n)+dx*sin(...
                 2*pi*f*time(1:n));
    case 'square'
        dur = nc/f;                           % Square duration
        half = 0.5/f;
        j = 1;
        for i = 1:ceil(dur/half)
            if (i*half) > dur
                k = max(find(time <= dur));
            else
                k = max(find(time < (i*half)));
            end
            x(j:k) = x(j:k)+dx;
            dx = -dx;
            j = k+1;
        end   
    case 'triangle'
        dur = nc/f;                           % Triangle duration
        if dur > time(max(size(time)))
            dur = time(max(size(time)));
        end
        d = max(find(time < dur)); 
        half = 0.5/f;
        h = max(find(time < half));
        quart = half/2;
        q =max(find(time < quart));       
        slope = 2*dx/half;
        i = 1;
        if quart >= dur
            t = dur; j = d;
        else
            t = quart; j = q;
        end
        while t <= dur
            if i == 1
                x(i:j) = x(i:j)+slope*time(i:j);
                slope = -slope;
            else
                x(i:j) = x(i:j)+dx+slope*time(1:n);
                dx = -dx;
                slope = - slope;  
            end
            if t+half <= dur
                t = t+half;
                i = j+1; j = j+h;
                n = h;
            else
                t = dur;
                i = j+1; n = j; j = d;
                n = d-n;
                if i > j
                    break
                end
            end
        end
    otherwise
        % unknown modulation
        error(sprintf('modulate: unknown modulation type `%s`. Only possible values are: step, ramp, sinus, square, triangle.', type))
end
