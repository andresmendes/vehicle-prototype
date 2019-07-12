%% Identification Main
% The main file for identification.

%% Tomlab
%       cd('C:\tomlab')
%       startup

clear ;  close all ; clc

%% Experimental data
% Distance front sensor
dataRaw = load('identificationData.csv');

% stepdata.csv
distRaw  = dataRaw(:,1);    % Distance measured with front sensor
inputRaw = dataRaw(:,2);    % Input value of dc motor Arduino
timeRaw  = dataRaw(:,3);    % Time in milli seconds

timeRawInitial = timeRaw(1);
timeRawFinal   = timeRaw(end);
timeRawTotal   = (timeRawFinal - timeRawInitial)/1000; % Total time [s]
timeRawLength  = length(timeRaw);

%% Cropped data
% Only the values of interest 

% Manually chosen
indexStart = 185;
indexEnd   = 250;

timeCrop  = timeRaw(indexStart:indexEnd);
distCrop  = distRaw(indexStart:indexEnd);
inputCrop = inputRaw(indexStart:indexEnd);

% Time starting at zero
timeCrop = timeCrop - timeCrop(1);

% Converting measured distance to traveled distance
numberValues = 5;   % Number of values for average
distInit = mean(distCrop(1:numberValues));
distFinal = mean(distCrop(end - (numberValues-1):end));
distTotal = distInit - distFinal;
distTraveled = distTotal - distCrop + distFinal;

%% Speed calculation

veloStep = diff(distTraveled) ./ diff(timeCrop/1000);

veloStep = gradient(distTraveled) ./ gradient(timeCrop/1000);

%% Sem média móvel
   ye = veloStep;
   ue = inputCrop;
   te = timeCrop;
   
%% Tempo em s     
     te = (te - te(1))/1000;   

%% Definições
      toms t k Tau
      tf = te(end);
      no = 400;
      p = tomPhase('p', t, 0, tf, no);
      setPhase(p);
      tomStates y 
      
%% Interpolação dos dados experimentais  
    ue_ = interp1(te,ue,t,'linear');        % ue(te) --> ue_(t)     
    ye_ = interp1(te,ye,t,'linear');        % ye(te) --> ye_(t)
                 
%% valores iniciais (t=0) dos estados 
    cbnd ={  };  
                                        
%% estimativa inicial da solução
    x0 = {  collocate(    y == ye_   )
            collocate(    k == 0.5   )
            collocate(  Tau == 0.2     )  };
 
%% Equações Diferencias
    ceq = {   collocate( dot(y) ==  (k/Tau)*ue_ - (1/Tau)*y )  };
      
%% Restrições
    cbox = {  0 <= collocate(k)   <= 10        
              0 <= collocate(Tau) <= 10
              0 <= collocate(y)         };
      
%% Função Objetivo
    objective = integrate ( (y-ye_)^2 );
   
%% Solução
    options = struct;
    options.name = 'identificacao1';
   
    [solution,result] = ezsolve(   objective, ...
                                  {cbox,cbnd,ceq}, x0, options   );
 
     t  = subs(collocate(t),solution);   
     y  = subs(collocate(y),solution);   
     k  = subs(collocate(k),solution);
    Tau  = subs(collocate(Tau),solution);
    ye_ = subs(collocate(ye_),solution);
    
    disp(' ')
    disp(['k = ',num2str(k(end))] )
    disp(['Tau = ',num2str(Tau(end))] )
    
    % k = 0.44198
    % Tau = 0.072455

%% Gráficos da Solução
    plot(te,ye,'k-',t,y,'r','linewidth',0.5); grid
    hold on
    plot(t,y,'r','linewidth',2); grid 
    legend('ye','y')         
    
%% Results
figure
set(gcf,'Units','centimeters','Position',[0 0 12 9])
subplot(3,1,1)
hold on ; grid on ; box on
plot(timeCrop/1000,distTraveled,'k','linewidth',1)
ylabel('Distance [cm]')
subplot(3,1,2)
grid on ; box on ; hold on
plot(te,ye,'k--',t,y,'r','linewidth',1); grid
plot(t,y,'r','linewidth',1); grid 
legend('Speed data','Fitted model','Location','SouthEast','Orientation','Horizontal')
ylabel('Speed [cm/s]')
subplot(3,1,3)
grid on ; box on ; hold on
set(gca,'ylim',[0 90])
plot(te,inputCrop,'k','linewidth',1)
xlabel('Time [s]')
ylabel('DC motor input')

print(gcf,'-dpng','illustrationsCode/identificationResults.png')
