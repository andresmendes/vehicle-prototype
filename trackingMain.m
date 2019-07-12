%% Tracking results
%
%% Loading raw data
%

clear ; close all ; clc

% Distance front sensor
dataRaw = load('trackingData.csv');

distRaw  = dataRaw(:,1);    % Distance measured with front sensor
refRaw   = dataRaw(:,2);    % Reference value of dc motor Arduino
inputRaw   = dataRaw(:,3);    % Input value of dc motor Arduino
timeRaw  = dataRaw(:,4);    % Time in milli seconds

%% Crop
timeStart = 300;       % This is verified graphically
timeEnd	  = 1500;        % this is in Arduino code

distCrop  = distRaw(timeStart:timeEnd);
refCrop   = refRaw(timeStart:timeEnd);
inputCrop = inputRaw(timeStart:timeEnd);
timeCrop  = timeRaw(timeStart:timeEnd);

% Resetting time to zero.
timeCrop = timeCrop - timeCrop(1);

% Resultado
figure
set(gcf,'Units','centimeters','Position',[0 0 16 8])
subplot(2,1,1)
    grid on ; box on ; hold on
    set(gca,'xlim',[timeCrop(1) timeCrop(end)]/1000)
    plot(timeCrop/1000,distCrop,'r','linewidth',1)
    plot(timeCrop/1000,refCrop,'k--','linewidth',1)
    xlabel('time [s]')
    ylabel('Separation Distance [cm]')
    legend('Data','Reference','location','NorthWest')
subplot(2,1,2)
    grid on ; box on ; hold on
    set(gca,'xlim',[timeCrop(1) timeCrop(end)]/1000)
    plot(timeCrop/1000,inputCrop,'k','linewidth',1)
    xlabel('time [s]')
    ylabel('DC motor input')

print(gcf,'-dpng','illustrationsCode/trackingResults.png')

