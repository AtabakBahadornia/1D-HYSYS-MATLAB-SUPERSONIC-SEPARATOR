%%%%%%%%%%%
% tpDistr - computes stream properties after downstream the shockwave
%Input:
% Tl -current temperature
% P 1 - current pressure
% A1 -current xsection size
% T2i - next temperature initial guess
% P2i - next pressure initial guess
% A2 - next xsection size
% mDot - flow rate
%Output:
% T2 - next temperature
% P2 - next pressure
% v - next velocity
% vFrac - next vapour fraction
% converged -NR convergence flag
% exception - erroneous parameter flag
function [T2,P2, machNum, v, converged, exception] = tpDistr_as(Tt, Pt, At, T2i,P2i,Aas, mDot)
% linking with hysys
MyObject=actxserver('Hysys.Application');
MyObject=COM.Hysys_Application;
solver.CanSolve = 1; %Start solver
hysolver.CanSolve = 0;
Mycase=MyObject.SimulationCases.Open([cd,strcat('\','hyAPP','.hsc')]);
MyMaterialStreams=Mycase.FlowSheet.MaterialStreams				
strInlet= get(MyMaterialStreams,'item','inlet');
strNatgas = get(MyMaterialStreams,'item','natgas');
% Newton-Raphson
[entrt, enrgt,momtt,rot,vt] = funcs(solver, strNatgas, Tt, Pt, At, mDot);
tol = 0.005;% tolerance for error
Max_iterations = 100; % maximum number of iterations
% set initial guess
Tas = T2i;% (C)
Pas =P2i;
k=0;
tres = tol + 1.;
pres = tol + 1.;
exception = false;
while (exception== false) && (tres >=tol || pres>= tol) && k <= Max_iterations
    err= errorEval_as(hysolver, strNatgas,enrgt,momtt ,Tas, Pas, Aas, mDot);
Pas= abs(Pas + err(2, 1));
Tas = Tas + err(1, 1);
if Tas < -273 || Pas < 0
exception = true;
else
tres = abs( err(1, 1) );
pres = abs( err(2, 1) );
k= k+1;
end
end
T2=Tas;
P2=Pas;
converged = false;
machNum=0;
v=0;
vFrac = 0;
if exception == false
if k>Max_iterations
converged = false;
else
converged = true;
[machNum, v] = machdrygas(Tas, Pas, Aas, mDot);
end
end