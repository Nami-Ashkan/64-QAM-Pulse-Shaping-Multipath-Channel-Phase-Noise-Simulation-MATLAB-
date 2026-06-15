clear all
clc
%% 1.2
R = 10e6;
T = 1/R;
r = 4;

Fs = r/T;
Ts = 1/Fs;

%% 2.1

N_symbols = 10000;
M = 64; % Modulation order

qam_axis =-sqrt(M)+1:2:sqrt(M)-1;
alphabet = bsxfun(@plus,qam_axis',1j*qam_axis);
symbol_ind=randi(length(alphabet),1,N_symbols);

% Generation of the complex constellation:
alphabet = bsxfun(@plus,qam_axis',1j*qam_axis); % see help bsxfun
% This is equivalent to (alternative way to do the same thing)
% alphabet = repmat(qam_axis', 1, sqrt(M)) + repmat(1j*qam_axis, sqrt(M), 1);
alphabet = alphabet(:).'; % Finally represent alphabet symbols as a row vector

% Then draw a random vector of numbers between 1...M
symbol_ind = randi(length(alphabet),1,N_symbols);

% Then "index" the alphabet vector using the above sequence to effectively
% draw random symbols from the constellation
symbols = alphabet(symbol_ind); % Random symbol sequence to be transmitted

% Plot the symbols
figure(1)
plot(symbols,'ro', 'MarkerFaceColor','r')
axis equal
xlabel('Real part')
ylabel('Imaginary part')
title('Transmitted symbols')
grid on

%% 2.2 2.2 Transmitter pulse shaping filtering

N_symbols_per_pulse = 40; % Duration of TX pulse-shape filter in symbols
alpha = 0.20; % Roll-off factor (excess bandwidth)

gt = rcosdesign(alpha,N_symbols_per_pulse,r,'sqrt');

% Plot the pulse shape of the transmit/receive filter
figure(2)
plot(-N_symbols_per_pulse*r/2*Ts:Ts:N_symbols_per_pulse*r/2*Ts,gt,'b')
xlabel('Time [s]')
ylabel('Value')
title('Transmit RRC filter (pulse shape)')
grid on

% Zero vector initilized for up-sampled symbol sequence
symbols_upsampled = zeros(size(1:r*N_symbols));
% Symbol insertion
symbols_upsampled(1:r:r*N_symbols) = symbols;
% Now the up-sampled sequence looks like {a1 0 0... a2 0 0... a3 0 0...}

% Alternatively, the upsampling by a factor of r can be carried out using
% the ready "upsample" function as follows:
% symbols_upsampled = upsample(symbols, r);
xt = filter(gt,1,symbols_upsampled); % Transmit pulse-shape filtering
xt = xt(1+(length(gt)-1)/2:end); % Correct for the filter delay/transient


NFFT = 16384; % FFT size for spectrum analysis, here 2^14
f = -Fs/2:1/(NFFT*Ts):Fs/2-1/(NFFT*Ts); % Frequency vector

% Calculating and plotting the spectrum, in absolute scale and in dB
figure(3)
subplot(2,1,1);
plot(f/1e6, fftshift(abs(fft(xt, NFFT)))); grid on;
xlabel('Frequency [MHz]')
ylabel('Relative amplitude')
title('TX signal amplitude spectrum')
subplot(2,1,2);
plot(f/1e6, fftshift(20*log10(abs(fft(xt, NFFT))))); grid on;
xlabel('Frequency [MHz]')
ylabel('Relative amplitude [dB]')
title('TX signal amplitude spectrum')

%% 3. Noisy Multipath Channel Model
b1 = 1; % means no multipath at all
b2 = [0.9-0.15j 0 -0.2-0.44j 0 0.1+0.36j]; % some multipath components already
b3 = [0.8+0.2j 0 0 0 -0.3+0.68j 0 0 0 0 0.4-0.6j]/1.5; % more harsh multipaths
% These examples are "from the hat" but b2 and b3 anyway reflect scenarios where
% there are two additional paths on top of the most direct path. (But exact
% multipath weights are from the hat)

b = b2;
yt = filter(b,1,xt); % Applying the multipath channel model to the signal

figure(4)
subplot(2,2,1);
plot(f/1e6, fftshift(abs(fft(xt, NFFT)))); grid on;
xlabel('Frequency [MHz]')
ylabel('Relative amplitude')
title('TX signal amplitude spectrum')
subplot(2,2,3);
plot(f/1e6, fftshift(20*log10(abs(fft(xt, NFFT))))); grid on;
xlabel('Frequency [MHz]')
ylabel('Relative amplitude [dB]')
title('TX signal amplitude spectrum ')
subplot(2,2,2);
plot(f/1e6, fftshift(abs(fft(yt, NFFT)))); grid on;

xlabel('Frequency [MHz]')
ylabel('Relative amplitude')
title('RX signal amplitude spectrum, with multipath')
subplot(2,2,4);
plot(f/1e6, fftshift(20*log10(abs(fft(yt, NFFT))))); grid on;
xlabel('Frequency [MHz]')
ylabel('Relative amplitude [dB]')
title('RX signal amplitude spectrum, with multipath')
%%
SNRdB = 35; % Experimented signal-to-noise ratio [dB]


% Complex white Gaussian noise sequence, first of unit power/variance
n = (1/sqrt(2))*(randn(size(yt)) + 1j*randn(size(yt)));
P_y = var(yt); % Signal power
P_n = var(n); % Noise power
% Defining noise scaling factor based on the SNR level:
noise_scaling_factor = sqrt(P_y/P_n./10.^(SNRdB./10)*(r/(1+alpha)));
% perhaps a little cryptic where the exact expression of the scaling factor
% comes from --can you see it ? Keep in mind that noise has wider bandwidth
% than the useful signal, this is where the final r/(1+alpha) factor comes

rt = yt + noise_scaling_factor*n;

figure(5)
subplot(2,2,1);
plot(f/1e6, fftshift(abs(fft(xt, NFFT)))); grid on;
xlabel('Frequency [MHz]')
ylabel('Relative amplitude')
title('TX signal amplitude spectrum')
subplot(2,2,3);
plot(f/1e6, fftshift(20*log10(abs(fft(xt, NFFT))))); grid on;
xlabel('Frequency [MHz]')
ylabel('Relative amplitude [dB]')

title('TX signal amplitude spectrum')
subplot(2,2,2);
plot(f/1e6, fftshift(abs(fft(rt, NFFT)))); grid on;
xlabel('Frequency [MHz]')
ylabel('Relative amplitude')
title('RX signal amplitude spectrum, with multipath+noise')
subplot(2,2,4);
plot(f/1e6, fftshift(20*log10(abs(fft(rt, NFFT))))); grid on;
xlabel('Frequency [MHz]')
ylabel('Relative amplitude [dB]')
title('RX signal amplitude spectrum, with multipath+noise')

%% TASK 2
figure(99)
subplot(211)
plot(f/1e6, fftshift(abs(fft(b, NFFT)))); grid on;
subplot(212)
plot(f/1e6, fftshift(20*log10(abs(fft(b, NFFT))))); grid on;

%% 2.1
% Creating the receive filter f(t) (it is here the same as in the transmitter)
ft = gt;

% Then filtering the received noisy signal with the chosen RX filter

qt = filter(ft,1,rt); % Receiver filtering
qt = qt(1+(length(ft)-1)/2:end); % Discard filter delay/transient
%%
figure(6)
subplot(2,2,1);
plot(f/1e6, fftshift(abs(fft(rt, NFFT)))); grid on;
xlabel('Frequency [MHz]')
ylabel('Relative amplitude')
title('RX signal amplitude spectrum, before filtering')
subplot(2,2,3);
plot(f/1e6, fftshift(20*log10(abs(fft(rt, NFFT))))); grid on;
xlabel('Frequency [MHz]')
ylabel('Relative amplitude [dB]')
title(' RX signal amplitude spectrum, before filtering ')
subplot(2,2,2);
plot(f/1e6, fftshift(abs(fft(qt, NFFT)))); grid on;
xlabel('Frequency [MHz]')
ylabel('Relative amplitude')
title(' RX signal amplitude spectrum, after filtering ')
subplot(2,2,4);
plot(f/1e6, fftshift(20*log10(abs(fft(qt, NFFT))))); grid on;
xlabel('Frequency [MHz]')
ylabel('Relative amplitude [dB]')
title(' RX signal amplitude spectrum, after filtering ')
%%
% Sampling the filtered RX signal at symbol rate. Remember that we used
% oversampling in the TX, by a factor of r, so this is now just picking every
% r-th sample
qk = qt(1:r:end);
figure(7)
plot(qk,'b*'); hold on; grid on;
plot(alphabet,'ro', 'MarkerFaceColor','r'); hold off
legend('Received samples', 'Original symbols')
xlabel('Real Part')
ylabel('Imaginary Part')
title('Received symbol-rate samples (RX constellation)')
axis equal

% With noise and multipath on, this looks messy ...
%% 4.2
Beta = 5000; % Noise bandwidth in Hz
% Generate phase noise model, i.e. complex exponential with random phase jitter
pt = phasenoise(numel(xt), Fs, Beta);

% Omit AWGN noise and multipath and add phase noise:
% The effect on the used waveform is modeled by multiplying the ideal
% waveform samples with generated phase noise
rt = xt.*pt; %

qt = filter(ft, 1, rt); % Receiver filtering
qt = qt(1+(length(ft)-1)/2:end); % Discard filter delay/transient
qk = qt(1:r:end); % Sample at symbol rate

% Plot the constellation for 1024 symbols
figure(8)
plot(qk(1:1024), 'b*'); hold on; grid on;
plot(alphabet,'ro', 'MarkerFaceColor','r'); hold off
legend('Received samples', 'Original symbols')
xlabel('Real part')
ylabel('Imaginary part')
title('Received symbol-rate samples (RX constellation)')

