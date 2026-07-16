%  PD1 - Technical Report: Theoretical Calculations & Simulation Results
%  Signals and Systems - EE/CE 301 - Summer 2026
%  Section: M1   Group: 5

clear; clc; close all;

%  TASK 1: SIGNAL TRANSFORMATION  x1(t) -> x2(t)
% Extended the time vector to 10s so we can see at least 3 periods of the slower x1(t)
t1 = -2:0.001:10;
x1 = cos(0.5*pi*t1);
x2_target = sin(1.5*pi*t1);

% Applying the transformation x2(t) = x1(3t - 1) we derived in the theory part
x2_built = cos(0.5*pi*(3*t1 - 1));

figure('Name','Task 1: Signal Transformation');

subplot(3,1,1);
plot(t1, x1, 'b', 'LineWidth', 1.4); grid on;
title('Received signal x_1(t) = cos(0.5\pi t)');
xlabel('t (s)'); ylabel('Amplitude (V)');
legend('x_1(t)', 'Location', 'best');

subplot(3,1,2);
plot(t1, x2_target, 'r', 'LineWidth', 1.4); grid on;
title('Desired signal x_2(t) = sin(1.5\pi t)');
xlabel('t (s)'); ylabel('Amplitude (V)');
legend('x_2(t)', 'Location', 'best');

subplot(3,1,3);
plot(t1, x2_target, 'r', 'LineWidth', 2); hold on;
plot(t1, x2_built, 'k--', 'LineWidth', 1.2); grid on;
title('Verification: x_2(t) vs. x_1(3t-1)');
xlabel('t (s)'); ylabel('Amplitude (V)');
legend('x_2(t) target', 'x_1(3t-1) built', 'Location', 'best');

% Checking if the built signal matches the target perfectly
max_error_task1 = max(abs(x2_target - x2_built));
fprintf('Task 1: max error between x2(t) and x1(3t-1) = %.4g\n', max_error_task1);

%  TASK 2: SYSTEM PROPERTY - CAUSALITY

t2 = -1:0.001:8;
% Multiplying by a step function so the input clearly starts at t=0
x_in  = sin(1.5*pi*t2) .* (t2 >= 0);
% Output is just the input delayed by 2s, also zero before t=2
y_out = sin(1.5*pi*(t2-2)) .* ((t2-2) >= 0);

figure('Name','Task 2: Causality Test');
plot(t2, x_in, 'b', 'LineWidth', 1.4); hold on;
plot(t2, y_out, 'r--', 'LineWidth', 1.4); grid on;
xlabel('t (s)'); ylabel('Amplitude (V)');
title('Causality test for y(t) = x(t-2)');
legend('Input x(t), starts at t = 0', 'Output y(t), starts at t = 2',
       'Location', 'best');

disp('Task 2: Output remains zero until t = 2 s (input start + delay).');
disp('        The system never uses future input values -> CAUSAL.');


%  TASK 3: EFFECT OF NOISE - FOURIER SERIES, SPECTRA, AND FILTER DESIGN

% Setting up fundamental freq and period for the Fourier series
w0 = 1.5*pi;
f0 = w0/(2*pi);
T0 = 1/f0;

% 3a. Fourier series coefficients and magnitude spectra (k = -6..6)
k = -6:6;
a_k = zeros(size(k));
b_k = zeros(size(k));

% Plugging in the theoretical values for the signal and the DC noise
a_k(k == 1)  = -1i/2;
a_k(k == -1) =  1i/2;
b_k(k == 0)  = 0.05;

% The received signal coefficients are just the sum of the signal and noise
c_k = a_k + b_k;

figure('Name','Task 3a: Magnitude Spectra');

subplot(3,1,1);
stem(k, abs(a_k), 'filled', 'b'); grid on;
xlabel('k'); ylabel('|a_k|');
title('Magnitude spectrum of x_2(t)');

subplot(3,1,2);
stem(k, abs(b_k), 'filled', 'r'); grid on;
xlabel('k'); ylabel('|b_k|');
title('Magnitude spectrum of noise n(t)');

subplot(3,1,3);
stem(k, abs(c_k), 'filled', 'k'); grid on;
xlabel('k'); ylabel('|c_k|');
title('Magnitude spectrum of received signal y(t) = x_2(t) + n(t)');

% 3b. Effect of multiplying the noise by 10

t3 = 0:0.001:2*T0;
x2_t = sin(w0*t3);

n_orig = 0.05*ones(size(t3));
n_x10  = 0.5*ones(size(t3));

y_orig = x2_t + n_orig;
y_x10  = x2_t + n_x10;

figure('Name','Task 3b: Noise x10 effect');
plot(t3, y_orig, 'b', 'LineWidth', 1.4); hold on;
plot(t3, y_x10,  'r', 'LineWidth', 1.4); grid on;
xlabel('t (s)'); ylabel('Amplitude (V)');
title('Effect of multiplying the noise by 10');
legend('y(t) = x_2(t) + 0.05 V', 'y(t) = x_2(t) + 0.5 V', 'Location', 'best');

% 3c. Recovery filter design: first-order RC high-pass filter

% Picking fc a decade below the signal freq so it blocks DC but passes 0.75Hz
fc = f0/10;
wc = 2*pi*fc;

% Using a standard 10uF capacitor and calculating the required resistor value
C = 10e-6;
R = 1/(wc*C);

fprintf('Task 3c: Filter design -> fc = %.4f Hz, C = %.1f uF, R = %.1f kOhm\n',
        fc, C*1e6, R/1e3);

% Calculating the filter response at each harmonic k
H_k = (1i*k*w0*R*C) ./ (1 + 1i*k*w0*R*C);

figure('Name','Task 3c: Filter Frequency Response');
freq_axis = -1:0.001:1;
w_sweep = 2*pi*freq_axis;
H_sweep = (1i*w_sweep*R*C) ./ (1 + 1i*w_sweep*R*C);

plot(freq_axis, abs(H_sweep), 'LineWidth', 1.4); grid on; hold on;
plot(f0, abs(H_k(k==1)), 'ro', 'MarkerFaceColor', 'r');
xlabel('Frequency (Hz)'); ylabel('|H(f)|');
title('RC High-Pass Filter - Magnitude Response');
legend('|H(f)|', 'Signal frequency f_0 = 0.75 Hz', 'Location', 'best');

% 3d. Recovered signal after filtering
t4 = 0:0.001:2*T0;
y_recovered = zeros(size(t4));

% Reconstructing the time-domain signal by multiplying coefficients with filter gain
for idx = 1:length(k)
    y_recovered = y_recovered + (c_k(idx)*H_k(idx)) * exp(1i*k(idx)*w0*t4);
end
% Dropping the imaginary part since it's just numerical noise
y_recovered = real(y_recovered);

figure('Name','Task 3d: Signal Recovery');
plot(t4, x2_t, 'b', 'LineWidth', 1.6); hold on;
plot(t4, y_orig, 'r:', 'LineWidth', 1.2);
plot(t4, y_recovered, 'k--', 'LineWidth', 1.6); grid on;
xlabel('t (s)'); ylabel('Amplitude (V)');
title('Signal recovery using the RC high-pass filter');
legend('Original x_2(t)', 'Noisy received y(t)', 'Filtered / recovered output',
       'Location', 'best');

fprintf('Task 3d: max recovery error vs. original x2(t) = %.4g V\n',
        max(abs(y_recovered - x2_t)));
