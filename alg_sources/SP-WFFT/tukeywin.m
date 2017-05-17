## Copyright (C) 2007 Laurent Mazet <mazet@crm.mot.com>
##
## This program is free software; you can redistribute it and/or modify it under
## the terms of the GNU General Public License as published by the Free Software
## Foundation; either version 3 of the License, or (at your option) any later
## version.
##
## This program is distributed in the hope that it will be useful, but WITHOUT
## ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
## FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more
## details.
##
## You should have received a copy of the GNU General Public License along with
## this program; if not, see <http://www.gnu.org/licenses/>.

## -*- texinfo -*-
## @deftypefn  {Function File} {} tukeywin (@var{m})
## @deftypefnx {Function File} {} tukeywin (@var{m}, @var{r})
## Return the filter coefficients of a Tukey window (also known as the
## cosine-tapered window) of length @var{m}.  @var{r} defines the ratio
## between the constant section and and the cosine section.  It has to be
## between 0 and 1.  The function returns a Hanning window for @var{r}
## equal to 0 and a full box for @var{r} equals to 1.  The default value of
## @var{r} is 1/2.
##
## For a definition of the Tukey window, see e.g. Fredric J. Harris,
## "On the Use of Windows for Harmonic Analysis with the Discrete Fourier
## Transform, Proceedings of the IEEE", Vol. 66, No. 1, January 1978,
## Page 67, Equation 38.
## @seealso{hanning}
## @end deftypefn

function w = tukeywin (m, r = 1/2)

  if (nargin < 1 || nargin > 2)
    print_usage ();
  elseif (! (isscalar (m) && (m == fix (m)) && (m > 0)))
    error ("tukeywin: M must be a positive integer");
  elseif (nargin == 2)
    ## check that 0 < r < 1
    if r > 1
      r = 1;
    elseif r < 0
      r = 0;
    endif
  endif

  ## generate window
  switch r
    case 0,
      ## full box
      w = ones (m, 1);
    case 1,
      ## Hanning window
      w = hanning (m);
    otherwise
      ## cosine-tapered window
      t = linspace(0,1,m)(1:end/2)';
      w = (1 + cos(pi*(2*t/r-1)))/2;
      w(floor(r*(m-1)/2)+2:end) = 1;
      w = [w; ones(mod(m,2)); flipud(w)];
  endswitch

endfunction

%!demo
%! m = 100;
%! r = 1/3;
%! w = tukeywin (m, r);
%! title(sprintf("%d-point Tukey window, R = %d/%d", m, [p, q] = rat(r), q));
%! plot(w);

%!assert (tukeywin (1), 1)
%!assert (tukeywin (2), zeros (2, 1))
%!assert (tukeywin (3), [0; 1; 0])
%!assert (tukeywin (16, 0), rectwin (16))
%!assert (tukeywin (16, 1), hanning (16))

%% Test input validation
%!error tukeywin ()
%!error tukeywin (0.5)
%!error tukeywin (-1)
%!error tukeywin (ones (1, 4))
%!error tukeywin (1, 2, 3)
