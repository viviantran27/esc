% Extracts 1RC eq. circuit parameters from rest periods (discharge I>0)
% Then runs "pulse_plotting_simulink.m" to simulate the pulse charge.
% Manually change profile in the model library and model in a diff
% folder...
% (C:\Users\Vivian\Box\Research\ESC Experiment\Model)

clc; close all;

%% load exp data
C = '1';
name = ['Cell_43_' C 'C'];
cell = readtable(['SPMe_pulse_' C 'C.csv']); 

% stackedplot(data)
cell.time_s = cell.Time_h_*3600;
cell.Time = cell.time_s;
cell.x_Q_Qo__mA_h = 4500-cell.DischargeCapacity_A_h_*1000;
cell.I = cell.Current_A_; 
cell.Voltage = cell.TerminalVoltage_V_;
%% Find period markers
current=cell.I;
tcpe=find(diff([current;0])<-1)-1;     %Indices where current pulse ends/starts to fall
tend=find(diff([current;0])>1);        %Indices where rest period ends
if tend(1)<tcpe(1)
    tend(1) = [];
end
if(length(tend)>length(tcpe)) 
    tend(end)=[];
end
if(length(tend)<length(tcpe)) 
    tcpe(end)=[];
end

%% Plotting voltage and current v time to verify t indices
%Plot current data
figure(1)
subplot(2,1,1)
plot(cell.Time,cell.I)
hold on
scatter(cell.Time(tcpe),cell.I(tcpe) ,10,'g','filled')
scatter(cell.Time(tend),cell.I(tend) ,10,'r','filled')
hold off
xlim([cell.Time(tend(1)),cell.Time(tend(end))]);
xlabel('Time (s)')
ylabel('Current')
legend('Current', 'tcpe','tend')

%Plot voltage data
subplot(2,1,2)
plot(cell.Time, cell.Voltage)
hold on
scatter(cell.Time(tcpe), cell.Voltage(tcpe),10,'g','filled')
scatter(cell.Time(tend),cell.Voltage(tend) ,10,'r','filled')
hold off
xlim([cell.Time(tend(1)),cell.Time(tend(end))]);
xlabel('Time (s)')
ylabel('Voltage')
legend('Voltage', 'tcpe','tend')

%% OCV
%Format SOC data
cell.qCct=cell.x_Q_Qo__mA_h/1000; 
capacity = 4.5; %Ah
soc=1-(cell.qCct(1)-cell.qCct)./capacity;
socData=[1; soc(tcpe)]; %soc between pulses; hacked in (SOC,OCV) = (1,4.2)

%Format OCV data
ocvData=[cell.Voltage(1); cell.Voltage(tend)]; %hacked in (SOC,OCV) = (1,4.2)
ocv=interp1(socData,ocvData,soc,'spline');



%% Parameter Estimation
%Initialize parameters
Rs=zeros(length(tcpe),1);
R1=Rs;
C1=Rs;
dt=60; %pulse duration (s)

%Calculate the RC parameters for each pulse
for j=1:length(tcpe) %number of pulses 
    Tperiod=tcpe(j):tend(j); %duration for parameter estimation 
    ocv1=ocv(tcpe(j)); %ocv over duration
    
    %Set up for matrices
    y=ocv(Tperiod(1:end-1))-cell.Voltage(Tperiod(1:end-1));
    Y=ocv(Tperiod(2:end))-cell.Voltage(Tperiod(2:end));
    I=cell.I(Tperiod(1:end-1));
    Idot=cell.I(Tperiod(2:end));
    
    %Solve ydot=MO 
    phi=[-y I Idot]; %I>0 for discharge
    theta=pinv(phi)*-Y; %[a0, b0, b1]'
    
    Rs(j)= -theta(3);
    C1(j)= dt/(theta(2)-theta(3)*theta(1));
    R1(j)= (theta(2)-theta(3)*theta(1))/(1+theta(1)); 
end
%% Plot Rs, R1, and C1 v. SOC
figure 
subplot(5,1,1)
scatter(soc(tcpe),Rs)
xlabel('SOC')
ylabel('Rs')
title('RC Parameters')

subplot(5,1,2)
scatter(soc(tcpe),R1)
xlabel('SOC')
ylabel('R1')

subplot(5,1,3)
scatter(soc(tcpe),C1)
xlabel('SOC')
ylabel('C1')

subplot(5,1,4)
hold on 
scatter(soc(tcpe), R1.*C1)
xlabel('SOC')
ylabel('\tau')
hold off

subplot(5,1,5)
hold on 
scatter(socData, ocvData)
plot(soc, ocv)
xlabel('SOC')
ylabel('OCV')
hold off


%% Save model parameters to a .mat file to run with cell_model.slx (simscape)
SOC_RC = soc(tcpe(1:end));
SOC_OCV = socData;
OCV = ocvData;
T_RC = [25 35];
capacity = 4.5;
Rs = repmat(Rs(1:end), 1,2);
R1 = repmat(R1(1:end), 1,2);
C1 = repmat(C1(1:end), 1,2);

save([name '_RC_25.mat'],'Rs','R1','C1','SOC_OCV', 'SOC_RC', 'T_RC','OCV','capacity','name')

%% Plot with simulation 
% pulse_plotting_simulink
