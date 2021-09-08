clear 
close all

figure (1)
sim = load('Cell_43_RC_25_C.mat');
data = load('Cell_43_RC_25.mat');

subplot(3,1,1)
hold on
yyaxis left
scatter(data.SOC_RC, data.Rs(:,1),'k')
scatter(sim.SOC_RC, sim.Rs(:,2),'r')
ax = gca;
ax.YColor = [0,0,0]; 
ylabel('Rs')
yyaxis right
scatter(data.SOC_RC, (interp1(sim.SOC_RC, sim.Rs(:,2), data.SOC_RC) - data.Rs(:,1))./data.Rs(:,1),'b')
ylabel('Rel error [-]', 'Color','b')
ax.YColor = [0, 0, 1]; 
legend('Data', 'Sim')
title('RC parameter comparison with 2C data')

subplot(3,1,2)
hold on 
yyaxis left
scatter(data.SOC_RC, data.R1(:,1),'k')
scatter(sim.SOC_RC, sim.R1(:,2),'r')
ax = gca;
ax.YColor = [0,0,0]; 
ylabel('R1')
yyaxis right
scatter(data.SOC_RC, (interp1(sim.SOC_RC, sim.R1(:,2), data.SOC_RC) - data.R1(:,1))./data.R1(:,1),'b')
ylabel('Rel error [-]', 'Color','b')
ax.YColor = [0, 0, 1]; 

subplot(3,1,3)
hold on
yyaxis left
scatter(data.SOC_RC, data.C1(:,1),'k')
scatter(sim.SOC_RC, sim.C1(:,2),'r')
ax = gca;
ax.YColor = [0,0,0]; 
ylabel('C1')
yyaxis right
scatter(data.SOC_RC, (interp1(sim.SOC_RC, sim.C1(:,2), data.SOC_RC) - data.C1(:,1))./data.C1(:,1),'b')
ylabel('Rel error [-]', 'Color','b')
ax.YColor = [0, 0, 1]; 
xlabel('SOC')

set(findall(gcf,'type','marker'),'linewidth',2)
set(findall(gcf,'type','axes'),'fontsize',10)