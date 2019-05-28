function [P1] = PlotFreq(data)
Fs = 1000; % Sampling frequency
T = 1/Fs; % Sampling period
L = length(data); % Length of signal
t = (0:L-1)*T; % Time Vector


fft_x = fft(data - mean(data));
P2 = abs(fft_x/L);
P1 = P2(1:L/2+1);
P1(2:end-1) = 2*P1(2:end-1);

f = Fs*(0:(L/2))/L;


figure();
subplot(1,2,1);
plot(1000*t,data);
title('Original Data');
xlabel('t (milliseconds)');
ylabel('X(t)');

subplot(1,2,2);
plot(f(1:500),P1(1:500));
title('Frequency of Data');
xlabel('f (Hz)');
ylabel('|P1(f)|');

end

