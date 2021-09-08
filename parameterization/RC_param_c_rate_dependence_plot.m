% plot C-rate dependency of RC params
close all 
clear
%% Plot Rs, R1, and C1 v. SOC
C_RC = [1,2,5,10,15];
color = ['krbgm'];
for i = 1:length(C_RC)
    
    load(['Cell_43_' num2str(C_RC(i)) 'C_RC_25.mat'])
    
    subplot(5,1,1)
    figure (1)
    hold on 
    s(i) = scatter(SOC_RC,Rs(:,1), color(i));
    plot(SOC_RC,Rs(:,1), color(i))
    xlabel('SOC')
    ylabel('Rs')
    title('C-rate dependency of RC Parameters')
    
    subplot(5,1,2)
    hold on 
    scatter(SOC_RC,R1(:,1), color(i))
    plot(SOC_RC,R1(:,1), color(i))
    xlabel('SOC')
    ylabel('R1')

    subplot(5,1,3)
    hold on 
    scatter(SOC_RC,C1(:,1), color(i))
    plot(SOC_RC,C1(:,1), color(i))
    xlabel('SOC')
    ylabel('C1')

    subplot(5,1,4)
    hold on 
    scatter(SOC_RC,R1(:,1).*C1(:,1), color(i))
    plot(SOC_RC,R1(:,1).*C1(:,1), color(i))
    xlabel('SOC')
    ylabel('\tau')
    hold off

    subplot(5,1,5)
    hold on 
    scatter(SOC_OCV(2:end), OCV(2:end), color(i))
    plot(SOC_OCV(2:end), OCV(2:end), color(i))
    xlabel('SOC')
    ylabel('OCV')
    hold off
end
subplot(5,1,1)
hold on
legend(s,[num2str(C_RC'), repmat('C',length(C_RC),1)])

%% 3D plot
figure(2)
camera = [40,35];
for j = 1:length(C_RC)
    load(['Cell_43_' num2str(C_RC(j)) 'C_RC_25.mat'])

    subplot(2,2,1)  
    hold on 
    scatter3(repmat(C_RC(j),length(SOC_RC),1), SOC_RC,Rs(:,1), color(j))
    legend([num2str(C_RC'), repmat('C',length(C_RC),1)])
    view(camera)
    grid on
    title('Rs')
    xlabel('C-rate')
    ylabel('SOC')
    zlabel('Rs')
    
    subplot(2,2,2)
    hold on 
    scatter3(repmat(C_RC(j),length(SOC_RC),1), SOC_RC, R1(:,1), color(j))
    legend([num2str(C_RC'), repmat('C',length(C_RC),1)])
    view(camera)
    grid on
    title('R1')
    xlabel('C-rate')
    ylabel('SOC')
    zlabel('R1')
    
    subplot(2,2,3)
    hold on 
    scatter3(repmat(C_RC(j),length(SOC_RC),1), SOC_RC, C1(:,1), color(j))
    legend([num2str(C_RC'), repmat('C',length(C_RC),1)])
    view(camera)
    grid on
    title('C1')
    xlabel('C-rate')
    ylabel('SOC')
    zlabel('C1')
    
    subplot(2,2,4)
    hold on 
    scatter3(repmat(C_RC(j),length(SOC_RC),1), SOC_RC, R1(:,1).*C1(:,1) , color(j))
    legend([num2str(C_RC'), repmat('C',length(C_RC),1)])
    view(camera)
    grid on
    title('\tau')
    xlabel('C-rate')
    ylabel('SOC')
    zlabel('\tau')
end


%% Save data

SOC_RC= 0.1:0.05:1;
Rs = zeros(length(SOC_RC), length(C_RC));
R1 = Rs;
C1 = Rs;
sim_param = load(['Cell_43_RC_25_C.mat']);

for k = 1:length(C_RC)
    sim_param = load(['Cell_43_' num2str(C_RC(k)) 'C_RC_25.mat']);
    Rs(:,k) = interp1(sim_param.SOC_RC, sim_param.Rs(:,1), SOC_RC, 'spline', 'extrap');
    R1(:,k) = interp1(sim_param.SOC_RC, sim_param.R1(:,1), SOC_RC, 'spline', 'extrap');
    C1(:,k) = interp1(sim_param.SOC_RC, sim_param.C1(:,1), SOC_RC, 'spline', 'extrap');
end
% X = repmat(sim_param.SOC_RC, length(C_RC),1)';
% Y = repmat(C_RC, length(sim_param.SOC_RC),1);
% Xq = repmat(SOC_RC, 
% Rs = interp2(X, , sim_param.Rs, SOC_RC, 'spline', 'extrap');
% R1 = interp1(sim_param.SOC_RC, sim_param.R1(:,1), SOC_RC, 'spline', 'extrap');
% C1 = interp1(sim_param.SOC_RC, sim_param.C1(:,1), SOC_RC, 'spline', 'extrap');

name = 'Cell_43';
save([name '_RC_25_C.mat'],'Rs','R1','C1','SOC_OCV', 'SOC_RC', 'C_RC','OCV','capacity','name')

%% Check saved C-rate dependence params
clear 
% close all

C_RC = [1,2,5,10,15];
color = ['krbgm'];
load('Cell_43_RC_25_C')
figure(3)
camera = [40,35];
for k = 1:length(C_RC)

    subplot(2,2,1)  
    hold on 
    scatter3(repmat(C_RC(k),length(SOC_RC),1), SOC_RC, Rs(:,k),color(k))
    legend([num2str(C_RC'), repmat('C',length(C_RC),1)])
    view(camera)
    grid on
    title('Rs')
    xlabel('C-rate')
    ylabel('SOC')
    zlabel('Rs')
    
    subplot(2,2,2)
    hold on 
    scatter3(repmat(C_RC(k),length(SOC_RC),1), SOC_RC, R1(:,k), color(k))
    legend([num2str(C_RC'), repmat('C',length(C_RC),1)])
    view(camera)
    grid on
    title('R1')
    xlabel('C-rate')
    ylabel('SOC')
    zlabel('R1')
    
    subplot(2,2,3)
    hold on 
    scatter3(repmat(C_RC(k),length(SOC_RC),1), SOC_RC, C1(:,k), color(k))
    legend([num2str(C_RC'), repmat('C',length(C_RC),1)])
    view(camera)
    grid on
    title('C1')
    xlabel('C-rate')
    ylabel('SOC')
    zlabel('C1')
    
    subplot(2,2,4)
    hold on 
    scatter3(repmat(C_RC(k),length(SOC_RC),1), SOC_RC, R1(:,k).*C1(:,k) , color(k))
    legend([num2str(C_RC'), repmat('C',length(C_RC),1)])
    view(camera)
    grid on
    title('\tau')
    xlabel('C-rate')
    ylabel('SOC')
    zlabel('\tau')
end
