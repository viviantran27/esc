% Plots thermal pulsing data and fits the thermal mass

clc; close all; 
%% plot raw data
source = 1; 
switch source
    case 1 % thermal relaxation data after pulsing
        data = readtable("Capacity_Cell_43_thermal_pulse_CA2.txt");
        figure (1)
        stackedplot(data) 
        start = 2475; %find index where relaxation begins
        last = 2833;    
        x0 = [1 0 0];
    case 2 % thermal relaxation data post-ESC experiment
        data = readtable("SOC100_full.csv");
        figure (1)
        stackedplot(data) 
        start = 7000; %find index where relaxation begins
        last = 14700;
        data.time_s = data.Time_s_;
        data.Temperature__C = data.CellTemperature;
        x0 = [15 0 0];
end 

t = data.time_s(start:last) - data.time_s(start);
T = data.Temperature__C(start:last);

%save data to simulate pybamm "drive cycle" 
% % profile = [cumsum([repmat(diff([0;data.time_s(1:289)]),2,1); diff([data.time_s(290)-5;data.time_s(290:end)])]),[repmat(data.I_mA(1:289),2,1); data.I_mA(290:end)]/1000]; % edit to discharge to 50%SOC
% % profile = [data.time_s [data.I_mA(1:289)*2; data.I_mA(290:end)]/1000]; % edit to discharge to 50%SOC
% % profile = [data.time_s(310:2519)-data.time_s(310) -data.I_mA(310:2519)/1000];
% % writematrix(profile, "thermal_pulse_test.csv")

%% fit thermal data 

g = fittype('a+b*exp(-c*x)');
f0 = fit(t,T,g, 'StartPoint', x0);

T_amb = f0.a % degC
tau = 1/f0.c % tau = C/hA = mc/hA 
%% plot fit

figure (2)
hold on 
xx = linspace(0,t(end),50);
plot(t,T,xx,f0(xx),'r-');
hold off
set(findall(gcf,'type','line'),'linewidth',2)

% %% read pybamm sim data
% sim_data = readtable('thermal_pulse_test_sim.csv');
% 
% figure(3)
% subplot(3,1,1)
% plot(data.time_s, data.I_mA/1000, sim_data.Time_h_*3600, -sim_data.Current_A_)
% legend ('Data', 'Simulation')
% ylabel('Current (A)')
% subplot(3,1,2)
% plot(data.time_s, data.Ecell_V, sim_data.Time_h_*3600, sim_data.TerminalVoltage_V_)
% ylabel('Voltage (V)')
% subplot(3,1,3)
% plot(data.time_s, data.Temperature__C, sim_data.Time_h_*3600, sim_data.X_averagedCellTemperature_K_- 273)
% ylabel('Temperature (\circ C)')
% set(findall(gcf,'type','line'),'linewidth',2)
