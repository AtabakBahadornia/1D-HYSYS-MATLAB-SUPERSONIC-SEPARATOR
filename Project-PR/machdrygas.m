%%%%%%%%%%%
% machNum - computes mach number & velocity
%
%Input:
% T - temperature
% P - pressure
% A - xsection
% mDot - flow rate
%Output:
% machNum -mach number
% v - velocity
function [machNum,v] = machdrygas(T, P, A, mDot)
MyObject=actxserver('Hysys.Application');
MyObject=COM.Hysys_Application;
solver.CanSolve = 1; 
hysolver.CanSolve = 0;
Mycase=MyObject.SimulationCases.Open([cd,strcat('\','hyAPP','.hsc')]);
MyMaterialStreams=Mycase.FlowSheet.MaterialStreams				
strNatgas= get(MyMaterialStreams,'item','natgas');
dT = 0.1;
[entr1, enrgl,momtl,rol,vl] = funcs(hysolver,strNatgas, T, P, A, mDot);
tolerance = 0.005; %tolerance for error
Max_iteration = 200; % maximum number of iterations
%%%%%%%%%%%
% Speed of sound computation
%
P2_inc=P;
k=0;
pres= tolerance + 1.;
exception = false;
while (exception == false) && (pres >= tolerance) && k <= Max_iteration
err= errorEval_mach(hysolver, strNatgas,T+dT/2, P2_inc, A, mDot,entr1);
P2_inc = P2_inc + err;
if P2_inc< 0
exception = true;
else
pres = abs( err );
k=k+1;
end
end
[entr, enrg,momt,ro_inc,v_inc]=funcs(hysolver,strNatgas, T+dT/2, P2_inc, A,mDot);
P2_dec=P;
k=0;
pres= tolerance + 1.;
exception = false;
while (exception== false) && (pres>= tolerance) && k <= Max_iteration
err= errorEval_mach(hysolver, strNatgas, T -dT/2, P2_dec, A, mDot,entr1 );
P2_dec = P2_dec +err;
if P2_dec< 0
exception = true;
else
pres = abs( err );
k=k+1;
end
end
[entr, enrg,momt,ro_dec, v_dec]=funcs(hysolver,strNatgas, T-dT/2, P2_dec, A,mDot);
c= sqrt( abs( (P2_inc-P2_dec)*1000/(ro_inc- ro_dec)) ); % (m/s)
[entr, enrg,momt,ro,v] = funcs(hysolver,strNatgas, T, P, A, mDot);
machNum = v / c;