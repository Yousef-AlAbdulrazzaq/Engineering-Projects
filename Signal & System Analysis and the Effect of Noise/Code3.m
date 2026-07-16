clc; clear;close all

% Choose the required audio
%[s,Fs] = audioread('AudioA.mp3');
[s,Fs] = audioread('AudioB.mp3');
%[s,Fs] = audioread('AudioC.mp3');
%[s,Fs] = audioread('AudioD.mp3');
N = length(s);
ts = 1/Fs;
t = (0:N-1)/Fs;
tone = 0.024*(sin(2*pi*5000*t) + 2*sin(2*pi*10000*t))';
s = s + tone;
sound(s,Fs) % play audio
pause(5)
figure
plot(t,s,'b','linewidth',0.5)
title('Time domain signal')
xlabel(' Time , sec ')
ylabel(' Amplitude ')
grid on

% Convert to frequency domain
f = linspace(-Fs/2,Fs/2 - Fs/N,N);
XF = fftshift( fft(s) );
figure
plot(f,2*abs(XF)/N)
title('Frequency domain signal')
xlabel(' Freq , Hz')
ylabel(' Amplitude ')

% maximum frequency
fmax = 6000;  % Maximum frequency corresponding to the peak in the spectrum

% filter
[b1,a1]= butter(15,fmax/(Fs/2),'low');
% plot filter in frequency domain
figure
freqz(b1,a1)
title('Filter response in frequency domain')
% plot filter response in time domain
figure
impz(b1,a1,[],Fs)
title('Filter response in time domain')

% apply filters
Filteredx1 = filter(b1,a1,s);


% Compute the FFT for Filteredx1 and adjust for one-sided spectrum
N = length(Filteredx1);  % Length of the filtered signal
f = linspace(0, Fs/2, floor(N/2)+1);  % Frequency vector for one-sided spectrum
XF1 = fft(Filteredx1);
XF1 = XF1(1:floor(N/2)+1);  % Keep only the positive frequencies

% Plot the frequency domain of Filteredx1
figure
plot(f, 2*abs(XF1)/N)
title('Frequency domain of the filtered signal')
xlabel('Freq, Hz')
ylabel('Amplitude')

% Plot the time domain of Filteredx1
XT1 = ifft(XF1);
t = (0:length(XT1)-1)*ts;
figure
plot(t, real(XT1))
title('Time domain of the filtered signal')
xlabel(' Time , sec ')
ylabel(' Amplitude ')
grid on

%Play filtered signals
sound(Filteredx1,Fs);

