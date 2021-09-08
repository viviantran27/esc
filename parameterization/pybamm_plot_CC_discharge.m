close all 
low = readtable('SPMe_05C_CC.csv');
med = readtable('SPMe_10C_CC.csv');
high = readtable('SPMe_18C_CC.csv');

figure 
subplot(2,2,[1,3])
hold on 
plot(low.(1), low.(6),'b')
plot(med.(1), med.(6), 'r')
plot(high.(1), high.(6),'g')
legend('0.5C', '10C', '18C')
ylabel( 'Resistance (\Omega)')
xlabel('Time (h)')
title( 'Constant current discharge')

subplot(2,2,2)
plot(low.(1), low.(6), 'b')

subplot(2,2,4)
hold on 
plot(med.(1), med.(6),'r')
plot(high.(1), high.(6),'g')

set(findall(gcf,'type','line'),'linewidth',2)
set(findall(gcf,'type','axes'),'fontsize',10)