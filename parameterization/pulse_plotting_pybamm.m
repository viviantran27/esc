% Plots pulse testing data from data and pybamm

clc; close all;

%% load exp data
data = readtable("DCR_Cell_43_CA2.txt");
stackedplot(data)
data(1:498, :) =[];
data.time_s = data.time_s - data.time_s(1);
data.x_Q_Qo__mA_h = data.x_Q_Qo__mA_h - data.x_Q_Qo__mA_h(1);

%% load and format sim data
sim = readtable("SPMe_pulse_2C.csv");
sim_data = table(sim.Time_h_*3600, sim.TerminalVoltage_V_, -sim.Current_A_*1000, -sim.DischargeCapacity_A_h_*1000, sim.Volume_averagedCellTemperature_K_ - 273.15);
sim = renamevars(sim_data, ["Var1","Var2","Var3","Var4", "Var5"], ["time_s", "Ecell_V", "I_mA", "Q_mAh", "Temperature__C"]); 
%% plot
figure(1)

names = ["Voltage (V)", "Current (mA)", "Discharged Q (mAh)"];%, "Temperature (\circ C)"];
for i=1:length(names)
    subplot(length(names),1,i)
    plot(data.(1),data.(i+1), sim.(1), sim.(i+1))
    xlim([0, data.(1)(end)])
    ylabel(names(i));
    
    if i == 1
        legend('Data', 'PYBAMM')
    end
end
set(findall(gcf,'type','line'),'linewidth',2)
