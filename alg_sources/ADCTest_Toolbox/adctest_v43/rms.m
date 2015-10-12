function y = rms(x)
x = x(:);
y = sqrt(1/length(x)*x.'*x);
end