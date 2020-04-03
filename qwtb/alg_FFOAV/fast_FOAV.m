% Program by Saurav Kumaraswami Shastri, Shrikanth Yadav, Ghanashyam B. Chakravarthi, Viraj Kumar, Divya Rao A, Vinod Agrawal.
% This program computes Fully Overlapped Allan Variance (FOAV) employing the fast algorithm proposed in [1].
% [1] S. M. Yadav, S. K. Shastri, G. B. Chakravarthi, V. Kumar, D. R. A and V. Agrawal, "A Fast, Parallel Algorithm for Fully Overlapped Allan Variance and Total Variance for Analysis and Modelling of Noise in Inertial Sensors," in IEEE Sensors Letters. doi: 10.1109/LSENS.2018.2829799 URL: http://ieeexplore.ieee.org/stamp/stamp.jsp?tp=&arnumber=8345576&isnumber=7862766

% MODIFIED by Martin Sira, PURPOSE: change script to function. ALL modified lined marked by % MOD
% clc; clear all; close all;            % MOD

%% Extracting Data

% file_name = 'gyro2_x.txt';            % MOD
% raw = fopen(file_name,'r');           % MOD
% A = textscan(raw,'%f ');              % MOD
% fclose(raw);                          % MOD
% x = cell2mat(A(1));                   % MOD
% x = x(1:30000);                       % MOD

function foav = fast_FOAV(x)            % MOD
%% Computing FOAV

Corr_size = 1:1:fix(numel(x)./2);
count = 4;
N = numel(x);
xpc = x(1:N);

% tic;                                  % MOD

tall1 = xpc(1:end-1);
tall2 = xpc(2:end);

foav = zeros(size(Corr_size')); % stores the FOAV values

for n = Corr_size
    
    temp = (tall2 - tall1).^2;
    
    foav(n) = sum(temp) / (2*(N - 2*n + 1)*n*n);
    
    tall1 = (tall1(1:end-2) + xpc(n+1:end-n-1));
    tall2 = (tall2(2:end-1) + xpc(count:end));
    
    count = count + 2;
    
end

% toc;                                  % MOD
