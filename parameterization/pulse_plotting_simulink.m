% Plots pulse testing data from data and simulink model

% clc; close all;
clear
%% load exp data
data = readtable("DCR_Cell_43_CA2.txt");
% stackedplot(data)
data(1:find(data.I_mA<-1000, 1)-1, :) =[];
data.time_s = data.time_s - data.time_s(1);
data.x_Q_Qo__mA_h = data.x_Q_Qo__mA_h - data.x_Q_Qo__mA_h(1);
%% load and format sim data
load('Cell_43_2C_RC_25.mat')
% Simulation params
Q = capacity; 
SOC_0 = 1; %initial soc 
t_end = 3600*2; %s
cell_area = 0.009; %m2
h_conv = 10; %W/K.m2
cell_mass = 0.06; %kg
cell_Cp_heat = 1100; %J.kg-1.K-1
T_init = 25+273.15;

% Thermal params (venting at ~80s)
cell_area = 0.06;%0.009; % 0.06 m2
h_conv = 5; %25; % 6.1 W/K.m2
cell_mass = 0.104; %kg
cell_Cp_heat = 1100; %J.kg-1.K-1 (increased due to fixture)

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

simout = sim('C:/Users/Vivian/Box/Research/ESC Experiment/Model/cell_model.slx');

%% plot
figure

names = ["Voltage (V)", "Current (A)", "SOC"];%, "Temperature (\circ C)"];

subplot(length(names),1,1)
plot(data.(1),data.(2), simout.tout, simout.V)
xlim([0, data.(1)(end)])
ylabel(names(1));
legend('Data', 'Simulink')
title('Pulse testing comparison')

subplot(length(names),1,2)
plot(data.(1),-data.(3)/1000, simout.tout, simout.I)
xlim([0, data.(1)(end)])
ylabel(names(2));

subplot(length(names),1,3)
plot(data.(1),1+ data.(4)/Q/1000, simout.tout, simout.soc)
xlim([0, data.(1)(end)])
ylabel(names(3));

set(findall(gcf,'type','line'),'linewidth',2)
set(findall(gcf,'type','axes'),'fontsize',10)