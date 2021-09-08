% Simulate a module of 1S3P cells using a pulse current profile. Parameter
% variation is applied by scaling the RC parameter functions of each cell
% by the same factor for each cell. 

clc 
clear
close all 

%% Load and plot RC parameters 
% Parameter tables are indexed by (SOC,T)
load('parameters.mat')

% Plot parameters 
figure(1)
subplot(4,1,1)
hold on 
scatter(SOC_RC, Rs(:,1)) %plot T = 25C
scatter(SOC_RC, Rs(:,2)) %plot T = 45C
hold off
legend('T=25\circC', 'T=45\circC')
xlabel('SOC')
ylabel('R_0')
% set(gca,'Fontsize',12, 'Fontname', 'Times');
title('Model parameters')

subplot(4,1,2)
hold on 
scatter(SOC_RC, R1(:,1)) %plot T = 25C
scatter(SOC_RC, R1(:,2)) %plot T = 45C
hold off
xlabel('SOC')
ylabel('R_1')
% set(gca,'Fontsize',12, 'Fontname', 'Times');

subplot(4,1,3)
hold on 
scatter(SOC_RC, C1(:,1)) %plot T = 25C
scatter(SOC_RC, C1(:,2)) %plot T = 45C
hold off
xlabel('SOC')
ylabel('C_1')
% set(gca,'Fontsize',12, 'Fontname', 'Times');

subplot(4,1,4)
plot(SOC_OCV,OCV)
xlabel('SOC')
ylabel('OCV')
% set(gca,'Fontsize',12, 'Fontname', 'Times');
% set(findall(gcf,'type','line'),'linewidth',2)

%% Set up individual cell paraemters   

% Assume same OCV curve for all, but vary RC params
R_ext = 0.002; %Ohm
config = [1 3]; %nSmP
num_cells = prod(config);
var = rand(config)*0.05 + 0.95;

cells(num_cells) = struct(); % initialize struct array
SOC_0 = 1; %initial soc 

for i = 1: num_cells 
    cells(i).capacity = capacity/var(i);
    cells(i).OCV = OCV;
    cells(i).SOC_OCV = SOC_OCV;
    cells(i).SOC_0 = SOC_0; %can be set to something different
    cells(i).Rs = Rs*var(i);
    cells(i).R1 = R1*var(i);
    cells(i).C1 = C1/var(i);   
    cells(i).SOC_RC = SOC_RC;
    cells(i).T_RC = T_RC;
end 

Q = capacity*3600*num_cells; % convert from Ah to ampere-seconds

%% Reorganize parameter data

% choose temperature data to base model on (plant uses T=25C so choosing
% T=45 will simulate modeling error)

T = 1; % 1=25C, 2=45C

R1C1 = R1(:,T).*C1(:,T);
R1C1inv = 1./R1C1; % vector of 1/R1C1

OCV = flip(OCV);
SOC_OCV = flip(SOC_OCV);

%% Compute simple numerical derivatives

dR1dSOC = diff(R1(:,T))./diff(SOC_RC);
dRsdSOC = diff(Rs(:,T))./diff(SOC_RC);
dR1C1invdSOC = diff(R1C1inv)./diff(SOC_RC);
dOCVdSOC = diff(OCV)./diff(SOC_OCV);

%% assumed noise variances for EKF calculation

Rw = 10; % input current noise variance 
Reta = 1; % measurement noise variance
Sigma0 = 1e2*eye(2); % initialize covariance matrix

%% true noise variances for simulation

current_noise_variance = 0.1;
voltage_noise_variance = 0.01;

%% Simulation params

pulse_amplitude = 2*capacity;
pulse_period = 100; %s
pulse_width = 50; % in %

t_end = 3500; %s
dt = 1/500;
observerICs = [0;0];
%% Set observer state initial conditions


out = sim('module.slx');

% Plot results
figure(2)
subplot(2,1,1)
plot(out.I)
ylabel('Current (A)')
title('Module current')
subplot(2,1,2)
plot(out.V)
ylabel('Voltage (V)')
title('Module voltage')

figure(3)
subplot(2,1,1)
plot(out.I_string)
ylabel('Current (A)')
title('Cell currents')
subplot(2,1,2)
plot(out.soc)
ylabel('SOC')
title('Cell SOC')

figure(4)
subplot(2,1,1)
plot(out.V1)
ylabel('Voltage (V)')
title('Voltage across the cell RC pair')
subplot(2,1,2)
plot(out.soc)
ylabel('SOC')
title('Cell SOC')
