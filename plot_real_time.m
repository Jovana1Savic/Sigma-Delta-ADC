% July, 2020
% plot_real_time.m
%
% This script is used to plot incoming stream of data read from serial
% port. It is intended to be used with MSP430i2041 which reads 24-bit values
% from ADC; sends them via UART to PC at 9600 baud rate. This script
% plots data in real time. UART is sending 8 bit data in order from LSB to
% MSB. In order to convert received bytes into int32 a C++ function
% pack_data is used. UART sends 512 consequtive samples. These are
% displayed along with SINAD parameter. 
% 
% Clicking space will save current 512 samples. 
%
% Start this script before starting MSP to make sure things are
% synchronised.
%
% Jovana Savic, jovana.savic9494@gmail.com
%-------------------------------------------------------------------------%
function R = plot_real_time()
%-------------------------------------------------------------------------%
% Parameters used.
%-------------------------------------------------------------------------%
filename = "test_batch_1.txt";
baudRate = 9600;
max24bit = 8388608; % Maximum absolute value that can be displayed with signed 24 bits.
refVoltage = 1.2;
GAIN = 1;
numOfSamples = 512; % Ideally power of two for fft. 
yLimits = [-refVoltage/GAIN * 1.2, refVoltage/GAIN * 1.2];
xLimits = [1, numOfSamples];
scaleFactor = 1 / max24bit * refVoltage / GAIN;
Fs = 4000; % Sampling rate is 4000 Hz. 
f = Fs*(0:(numOfSamples/2))/numOfSamples;

savedData = zeros(numOfSamples*10, 1);
savedDataCount = 0;
saveData = 0;
sync = 1;

%-------------------------------------------------------------------------%
% Prepare for plot.
%-------------------------------------------------------------------------%

% Open a serial port
s = serial('COM4');
set(s,'BaudRate',baudRate);

try
    fopen(s);
catch
    fclose(instrfind); % Close all ports in case someone (me) didn't close this one. 
    fopen(s);
end

%-------------------------------------------------------------------------%
% Prepare initial plot. 
% Loop until someone closes the figure. After 512 new values, 
% refresh the plot. 
%-------------------------------------------------------------------------%
data = zeros(numOfSamples, 1);

% Create figure.
fig = figure(1);
set(fig,'WindowKeyPressFcn',@keyPressCallback);

while (ishandle(fig))
    %write(s, 1, "uint8" ); % Signal that PC is ready for new batch. 
    for i=1:numOfSamples
        tmp_data = uint8(fread(s, 3, 'uint8')); % From LSB (1) to MSB (3)
        while (isempty(tmp_data))
            tmp_data = uint8(fread(s, 3, 'uint8'));
        end
        data(i) =  double((pack_data(tmp_data(3), tmp_data(2), tmp_data(1)))).*scaleFactor;           
    end

    Y = fft(data);
    P2 = abs(Y/numOfSamples);
    P1 = P2(1:numOfSamples/2+1);
    P1(2:end-1) = 2*P1(2:end-1);
    
    [~,loc] = max(P1);
    FREQ_ESTIMATE = f(loc);
    
    subplot(2, 1, 1);
    plot(data), ylim(yLimits), xim(xLimits);
    title ( {['Frequency estimate = ', num2str(FREQ_ESTIMATE),' Hz']});
    subplot(2,1,2)
    sinad(data, Fs);

    drawnow
    
    if (saveData == 1)
        save_data();
    end
end

%-------------------------------------------------------------------------%
% Clean up serial port
%-------------------------------------------------------------------------%
fclose(s);
delete(s);
clear s;

fileID = fopen(filename,'w');
fprintf(fileID,'%d\n',savedData);
fclose(fileID);

%-------------------------------------------------------------------------%
% Key press callback function.
%-------------------------------------------------------------------------%
 function keyPressCallback(source,eventdata)
      % determine the key that was pressed
      keyPressed = eventdata.Key;
      if strcmpi(keyPressed,'space') % Save current data
          saveData = 1;
      end
 end

function save_data()
    savedData(savedDataCount*numOfSamples+1:(savedDataCount + 1)*numOfSamples) = data(:, 1);
    savedDataCount = savedDataCount + 1;
    savedDataCount = mod(savedDataCount,10);
    saveData = 0;
end

end
