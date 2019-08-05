%% Control design

clear ; close all ; clc

s = tf('s');

% Parameters (identification)
Kg = 0.44198;
tau = 0.072455;

% Speed first order transfer function
Pvel = Kg/(tau*s+1);

% Position second order transfer function
Ppos = 1/s*Pvel;

%% Rootlocus
% Proportional controller.

[R,K] = rlocus(Ppos);

figure
set(gcf,'Units','centimeters','Position',[0 0 10 5])
hold on ; grid on ; box on
set(gca,'xlim',[-15 1])
plot(R(1,:),'r','linewidth',1.5)
plot(real(R(1,1)),imag(R(1,1)),'r*','markersize',7)
plot(R(2,:),'b','linewidth',1.5)
plot(real(R(2,1)),imag(R(2,1)),'b*','markersize',7)

xlabel('Real axis')
ylabel('Imaginary axis')

print(gcf,'-dpng','illustrationsCode/modelRlocus.png')

