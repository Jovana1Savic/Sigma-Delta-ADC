max24bit = 8388608; % Maximum absolute value that can be displayed with signed 24 bits.
refVoltage = 1.2;
GAIN = 1;
numOfSamples = 512; % Ideally power of two for fft. 
yLimits = [-refVoltage/GAIN * 1.2, refVoltage/GAIN * 1.2];
xLimits = [1, numOfSamples];
scaleFactor = 1 / max24bit * refVoltage / GAIN;
refreshRate = 256;


Fs = 4000;            % Sampling frequency - 4KHz                   
T = 1 / Fs;           % Sampling period        
L = numOfSamples;     % Length of signal 
t = (0: L-1) * T;     % Time vector
f = Fs*(0:(numOfSamples/2))/numOfSamples;

filename = "test_batch_1.txt";
fileID = fopen (filename , 'r' );
formatSpec = '%e' ;
allData = fscanf (fileID, formatSpec);

i = 4;
data = allData(i*numOfSamples+1:(i + 1)*numOfSamples);

Y = fft(data);
P2 = abs(Y/numOfSamples);
P1 = P2(1:numOfSamples/2+1);
P1(2:end-1) = 2*P1(2:end-1);


[~,loc] = max(P1);
FREQ_ESTIMATE = f(loc);

figure,
subplot(2, 1, 1)
plot(t, data);
xlim([t(1), t(numOfSamples)])
title ( {['frequency estimate = ', num2str(FREQ_ESTIMATE),' Hz']});
xlabel('time (s)');
subplot(2, 1, 2)
sfdr(data, Fs)

sineParams = sineFit(t', data);
offset = sineParams(1); A = sineParams(2); freq = sineParams(3); phase = sineParams(4);
offset = 0; A = 1; freq = 870; phase = -3.25;
real_data = offset + A* sin(2*pi*freq * t +phase);
figure, 
plot(1000 * t, real_data, 'b - o')
hold on
plot (1000 * t, data, 'g')

figure, pspectrum(data, Fs)
hold on, pspectrum(real_data, Fs);

figure,
diff = (data-real_data');
diff = diff(20:numOfSamples);
plot(t(20:numOfSamples), diff);
mu = mean(diff)
sigma = var(diff)
delta = max(abs(diff))

enob = log2(2.4/delta)
enob_sinad = (s - 1.76 + 20*log10(1.2)) / 6.02

figure, histogram(diff);
figure, pspectrum(diff, Fs);
figure, thd(diff, Fs);

Y = fft(diff);
P2 = abs(Y/numOfSamples);
P1 = P2(1:numOfSamples/2+1);
P1(2:end-1) = 2*P1(2:end-1);
plot(f, 20 * log10(P1));
