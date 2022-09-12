function [] = Nozzle_plot(Inlet_D, Throat_D,Exit_D, L_c, L_d)
Inlet_R=Inlet_D/2;
Throat_R=Throat_D/2;
Exit_R=Exit_D/2;
L=L_c+L_d;
x=[0,0,L_c,L,L,L_c,0]
y=[-Inlet_R , +Inlet_R , +Throat_R , +Exit_D/2 ,...
    -Exit_D/2 , -Throat_R , -Inlet_R]
plot(x,y,'MarkerSize',12);
hold on;
% fill(x,y,'r')
axis([-0.05 0.17 -0.03 0.03])
title('schematic of nozzle','Fontsize',16)
end