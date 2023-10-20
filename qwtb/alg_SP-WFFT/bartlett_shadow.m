function c = bartlett_shadow(m)
% -- Function File: bartlett (M)
%     Return the filter coefficients of a Bartlett (triangular) window of
%     length M.
%
%     For a definition of the Bartlett window, see e.g., A. V. Oppenheim
%     & R. W. Schafer, 'Discrete-Time Signal Processing'.

% Copyright (C) 1995-2013 Andreas Weingessel
%
% This file is part of Octave.
%
% Octave is free software; you can redistribute it and/or modify it
% under the terms of the GNU General Public License as published by
% the Free Software Foundation; either version 3 of the License, or (at
% your option) any later version.
%
% Octave is distributed in the hope that it will be useful, but
% WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
% General Public License for more details.
%
% You should have received a copy of the GNU General Public License
% along with Octave; see the file COPYING.  If not, see
% <http://www.gnu.org/licenses/>.

% Author: AW <Andreas.Weingessel@ci.tuwien.ac.at>
% Description: Coefficients of the Bartlett (triangular) window

  if (nargin ~= 1)
    print_usage ();
  end

  if not( (isscalar (m) && (m == fix (m)) && (m > 0)))
    error ('bartlett: M has to be an integer > 0');
  end

  if (m == 1)
    c = 1;
  else
    m = m - 1;
    n = fix (m / 2);
    c = [2*(0:n)/m, 2-2*(n+1:m)/m]';
  end

end

%!assert (bartlett (1), 1)
%!assert (bartlett (2), zeros (2,1))
%!assert (bartlett (16), fliplr (bartlett (16)))
%!assert (bartlett (15), fliplr (bartlett (15)))
%!test
%! N = 9;
%! A = bartlett (N);
%! assert (A(ceil (N/2)), 1);

%!error bartlett ()
%!error bartlett (0.5)
%!error bartlett (-1)
%!error bartlett (ones (1,4))

