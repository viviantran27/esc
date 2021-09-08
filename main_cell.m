% Manual "parameter fitting". Modified R1, C1, R_ext, R_tab, h, and Cp
clc 
clear
close all 

%% Set parameters

% electrical params
load('parameterization\Cell_43_2C_RC_25_data.mat') % no T dependence, Parameter tables are indexed by (SOC,T)
% load('parameterization\Cell_43_RC_25_C.mat') % params from SPMe
% T_RC = C_RC; % hack to use existing interp in simscape blocks
C1(C1<0) = 1e-3;
SOC_0 = 1;
Q = 4.6; 

% Aged 100%, 75%, 50%
R_tab = 0.0044; 
R_ext = 0.011-R_tab;
R1 = R1*100;
C1 = C1*0.5;
% SOC_RC = sort(SOC_RC);

% Fresh 100%
% R_tab = 0.01; 
% R_ext = 0.011-0.0044;
% R1 = R1*100;
% C1 = C1*0.5;
% Rs = Rs*0.055;

% Aged 15%
% R_tab = 0.00045; 
% R_ext = 0.014-R_tab;
% R1 = R1*100;
% C1 = C1*0.2;

% Thermal params (venting at ~80s)
cell_area = 0.06;%0.009; % 0.06 m2
h_conv = 5; %25; % 6.1 W/K.m2
cell_mass = 0.104; %kg
cell_Cp_heat = 1100*1.3; %J.kg-1.K-1 (increased due to fixture)

% Decomposition params
A_an = 2.5e13; %s-1 frequency factors
A_ca = 2.55e14; %s-1
A_sei = 2.25e15; %s-1
E_an = 2.24e-19; %J activation energy
E_ca = 2.64e-19; %J
E_sei = 2.24e-19; %J
h_an = 1714*1000; %J.kg-1 enthalpy of decomp
h_ca = 790*1000; %J.kg-1
h_sei = 257*1000; %J.kg-1
m_an = 19.107/1000; %kg electrode mass
m_ca = 36.56/1000; %kg
x_an_0 = 0.75; %initial fraction of Li in anode for fully charge cells
x_sei_0 = 0.15; %initial fraction of Li in SEI
z_0 = 0.033; %initial dimensionless SEI thickness
alpha_0 = 0.04; %initial degree of conversion of cathode decomp
k_b = 1.3806e-23; %J.K-1

% Mechanical params
M_C6 = 72/1000; %kg/mol
V_head_0 = 6.65e-6; %m3
L = 2.4/1000; %m
E = 0.19e6; %Pa
alpha_cell = 1.1e-6; %m/K
P_atm = 101e3; %Pa
P_crit = 158e3; %Pa
DMC = [6.4338; 1413; -44.25]; %Antoine coeffs [A B C] 
EC = [6.4897; 1836.57; -102.23];
y_dmc = 0.7;
y_ec = 1-y_dmc;             
R = 8.3145; %J.mol-1.K-1
A_surf = 0.009; %m2

% sim param
t_end = 60*10; %s
%% Choose ESC data file
path = 'C:/Users/Vivian/Box/Research/ESC/Experiment';
% data = readtable([path '/SOC' num2str(SOC_0*100) 'F/SOC' num2str(SOC_0*100) 'F_full.csv']); %testing data
data = readtable([path '/SOC' num2str(SOC_0*100) '/SOC' num2str(SOC_0*100) '_full.csv']); %testing data

data.CurrentShunt = -data.CurrentShunt;
data.SOC =[SOC_0; SOC_0-cumsum(data.CurrentShunt(1:end-1).*diff(data.Time_s_)/3600/Q)];
data.Pressure = data.Force*9.8/A_surf + P_atm; %Pa

start = find(data.CurrentShunt > 1, 1);
data.Time_s_ = data.Time_s_ - data.Time_s_(start); %start at 0s
data_idx = start:find(data.Time_s_>t_end, 1); %end t_end after

T_amb = data.CellTemperature(data_idx(1)) + 273.15; 
sigma_0 = data.Pressure(data_idx(1))-P_atm; %Pa

%% Simulate
out = sim('ESC_cell_model.slx');

%% Plot results
subfigs = 5;

figure(2)
subplot(subfigs,1,1)
hold on 
yyaxis left
plot(data.Time_s_(data_idx), data.CurrentShunt(data_idx),'k')
plot(out.I,'-r')
ylabel('Current (A)','Color','k')
ax = gca;
ax.YColor = [0,0,0]; 
yyaxis right
plot(data.Time_s_(data_idx),interp1(out.tout, out.I.data, data.Time_s_(data_idx))-data.CurrentShunt(data_idx), '--b')
ylabel('Error', 'Color','k')
ax.YColor = [0, 0, 1]; 
hold off
xlim([0,t_end])
% title(['Fresh ' num2str(SOC_0*100) '% Initial SOC'])
title([num2str(SOC_0*100) '% Initial SOC'])

legend('Data', 'Simulink: modified parameters')

subplot(subfigs,1,2)
hold on 
yyaxis left
plot(data.Time_s_(data_idx), data.Voltage_V_(data_idx),'k')
plot(out.V,'-r')
ylabel('Voltage (V)','Color','k')
ax = gca;
ax.YColor = [0,0,0]; 
yyaxis right
plot(data.Time_s_(data_idx),interp1(out.tout, out.V.data, data.Time_s_(data_idx))-data.Voltage_V_(data_idx), '--b')
ylabel('Error', 'Color','k')
ax.YColor = [0, 0, 1]; 
hold off
xlim([0,t_end])

subplot(subfigs,1,3)
hold on 
yyaxis left
plot(data.Time_s_(data_idx), data.SOC(data_idx),'k')
plot(out.soc,'-r')
ylabel('SOC','Color','k')
ax = gca;
ax.YColor = [0,0,0]; 
yyaxis right
plot(data.Time_s_(data_idx),interp1(out.tout, out.soc.Data, data.Time_s_(data_idx))-data.SOC(data_idx), '--b')
ylabel('Error', 'Color','k')
ax.YColor = [0, 0, 1]; 
hold off
xlim([0,t_end])

subplot(subfigs,1,4)
hold on 
yyaxis left
plot(data.Time_s_(data_idx), data.CellTemperature(data_idx),'k')
plot(out.T_cell-273.15,'-r')
ylabel('Temperature (^\circC)','Color','k')
ax = gca;
ax.YColor = [0,0,0]; 
yyaxis right
plot(data.Time_s_(data_idx),interp1(out.tout, out.T_cell.data-273.15, data.Time_s_(data_idx))-data.CellTemperature(data_idx), '--b')
ylabel('Error', 'Color','k')
ax.YColor = [0, 0, 1]; 
hold off
xlim([0,t_end])

subplot(subfigs,1,5)
hold on 
yyaxis left
plot(data.Time_s_(data_idx), data.Pressure(data_idx)/1000,'k')
plot(out.P_total/1000,'-r')
ylabel('Pressure (kPa)','Color','k')
% ylim([0,70])
ax = gca;
ax.YColor = [0,0,0]; 
yyaxis right
plot(data.Time_s_(data_idx),interp1(out.tout, out.P_total.Data/1000, data.Time_s_(data_idx))-data.Pressure(data_idx)/1000, '--b')
ylabel('Error', 'Color','k')
ax.YColor = [0, 0, 1]; 
hold off
xlim([0,t_end])
xlabel('Time (s)')

set(findall(gcf,'type','line'),'linewidth',2)
set(findall(gcf,'type','axes'),'fontsize',10)

% subplot(subfigs,1,5)
% figure
% hold on 
% % yyaxis left
% plot(data.Time_s_(data_idx), data.Force(data_idx)*9.8,'k')
% plot((out.P_total-P_atm)*A_surf,'-r')
% ylabel('Expansion force (N)','Color','k')
% ylim([0,550])
% ax = gca;
% ax.YColor = [0,0,0]; 
% % yyaxis right
% % plot(data.Time_s_(data_idx),interp1(out.tout, out.P_total.Data/1000, data.Time_s_(data_idx))-data.Pressure(data_idx)/1000, '--b')
% % ylabel('Error', 'Color','k')
% % ax.YColor = [0, 0, 1]; 
% hold off
% xlim([0,t_end])
% xlabel('Time (s)')
% 
% set(findall(gcf,'type','line'),'linewidth',2)
% set(findall(gcf,'type','axes'),'fontsize',10)


%% thermal resistance (R_cond = L/(k*A), R_conv = 1/(h*A))
% h_conv2 = 25;
% R_poron = 0.001/0.051/0.009
% R_acrylic = 0.003175/0.2/0.024467
% R_steel = 0.013/36/0.022705
% R_garolite = 0.013/0.288/0.022421
% R_conv1 = 1/0.022705/h_conv2
% R_conv2 = 1/0.0155/h_conv2
% 
% R_total = (1/(R_poron+R_garolite+R_conv1) + 1/(R_poron+(1/R_conv2 + 1/(R_conv1+R_steel+R_acrylic))^-1))^-1
